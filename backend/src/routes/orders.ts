import { Router } from 'express';
import { z } from 'zod';
import { query, queryOne, execute, pool } from '../config/db';
import { ok, fail } from '../utils/response';
import { auth, adminOnly, AuthRequest } from '../middlewares/auth';

const router = Router();

// GET /orders — user sees own, admin sees all
router.get('/', auth(), async (req: AuthRequest, res) => {
  const isAdmin = req.user!.role === 'admin';
  const page = Math.max(1, parseInt(req.query.page as string) || 1);
  const limit = Math.min(100, parseInt(req.query.limit as string) || 20);
  const offset = (page - 1) * limit;
  const where = isAdmin ? '' : 'WHERE o.user_id=?';
  const params: any[] = isAdmin ? [] : [req.user!.id];
  const countRow: any = await queryOne(`SELECT COUNT(*) as total FROM orders o ${where}`, params);
  const total = Number(countRow?.total || 0);
  const rows: any[] = await query(`SELECT o.*, u.name as user_name, u.email as user_email FROM orders o LEFT JOIN users u ON u.id=o.user_id ${where} ORDER BY o.created_at DESC LIMIT ? OFFSET ?`, [...params, limit, offset]);
  const data = await Promise.all(rows.map(async (o) => {
    const items: any[] = await query(`SELECT oi.*, v.name as vehicle_name, v.brand, v.price as vehicle_price FROM order_items oi LEFT JOIN vehicles v ON v.id=oi.vehicle_id WHERE oi.order_id=?`, [o.id]);
    return { ...o, total_amount: Number(o.total_amount), items };
  }));
  return ok(res, 'Orders retrieved', data, { page, limit, total, totalPages: Math.ceil(total/limit) });
});

router.get('/:id', auth(), async (req: AuthRequest, res) => {
  const o: any = await queryOne('SELECT o.*, u.name as user_name, u.email as user_email FROM orders o LEFT JOIN users u ON u.id=o.user_id WHERE o.id=?', [req.params.id]);
  if (!o) return fail(res, 'Pesanan tidak ditemukan', 404);
  if (req.user!.role !== 'admin' && String(o.user_id) !== String(req.user!.id)) return fail(res, 'Forbidden', 403);
  const items: any[] = await query(`SELECT oi.*, v.name as vehicle_name, v.brand, v.model FROM order_items oi LEFT JOIN vehicles v ON v.id=oi.vehicle_id WHERE oi.order_id=?`, [o.id]);
  const payment: any = await queryOne('SELECT * FROM payments WHERE order_id=?', [o.id]);
  return ok(res, 'Order retrieved', { ...o, total_amount: Number(o.total_amount), items, payment });
});

const createSchema = z.object({
  items: z.array(z.object({ vehicle_id: z.union([z.string(), z.number()]), quantity: z.number().int().min(1).max(100) })).min(1),
  payment_method: z.string().optional(),
});

function genOrderNumber() {
  return `YAW-${Date.now().toString().slice(-8)}-${Math.floor(Math.random()*900+100)}`;
}

router.post('/', auth(), async (req: AuthRequest, res) => {
  const p = createSchema.safeParse(req.body);
  if (!p.success) return fail(res, 'Validasi gagal', 422, p.error.flatten());

  // All inventory + writes run inside a single transaction on one connection.
  let conn: any;
  try {
    conn = await pool.getConnection();
    await conn.beginTransaction();

    let total = 0;
    const itemsData: any[] = [];
    for (const it of p.data.items) {
      // SELECT ... FOR UPDATE locks the row so stock can't race under concurrent orders
      const rows: any[] = await conn.query('SELECT id, price, stock, name FROM vehicles WHERE id=? FOR UPDATE', [it.vehicle_id]);
      const v = Array.isArray(rows) ? rows[0] : null;
      if (!v) {
        await conn.rollback();
        return fail(res, `Kendaraan ${it.vehicle_id} tidak ditemukan`, 404);
      }
      if (Number(v.stock) < it.quantity) {
        await conn.rollback();
        return fail(res, `Stok ${v.name} tidak cukup`, 400);
      }
      const price = Number(v.price);
      total += price * it.quantity;
      itemsData.push({ vehicle_id: v.id, quantity: it.quantity, price, subtotal: price * it.quantity });
    }

    const orderNumber = genOrderNumber();
    let orderId: any;
    try {
      const r: any = await conn.query(
        'INSERT INTO orders (user_id, order_number, total_amount, status) VALUES (?,?,?,?)',
        [req.user!.id, orderNumber, total, 'pending'],
      );
      orderId = r.insertId;
    } catch (e: any) {
      // order_number collision (UNIQUE) — retry once with a fresh number
      if (String(e.message).includes('Duplicate') || e.errno === 1062) {
        const retryNumber = genOrderNumber();
        try {
          const r2: any = await conn.query(
            'INSERT INTO orders (user_id, order_number, total_amount, status) VALUES (?,?,?,?)',
            [req.user!.id, retryNumber, total, 'pending'],
          );
          orderId = r2.insertId;
        } catch (e2: any) {
          await conn.rollback();
          return fail(res, 'Gagal membuat pesanan: nomor pesanan bentrok', 400);
        }
      } else {
        throw e;
      }
    }

    for (const it of itemsData) {
      await conn.query('INSERT INTO order_items (order_id, vehicle_id, quantity, price, subtotal) VALUES (?,?,?,?,?)', [orderId, it.vehicle_id, it.quantity, it.price, it.subtotal]);
      await conn.query('UPDATE vehicles SET stock = stock - ? WHERE id=?', [it.quantity, it.vehicle_id]);
    }

    if (p.data.payment_method) {
      await conn.query('INSERT INTO payments (order_id, payment_method, payment_status) VALUES (?,?,?)', [orderId, p.data.payment_method, 'pending']);
    }

    await conn.commit();

    const orderRows: any = await conn.query('SELECT * FROM orders WHERE id=?', [orderId]);
    const order: any = Array.isArray(orderRows) ? orderRows[0] : {};
    return ok(res, 'Pesanan dibuat', { ...order, total_amount: Number(order.total_amount), items: itemsData });
  } catch (e: any) {
    if (conn) {
      try { await conn.rollback(); } catch {}
    }
    console.error('[orders:post]', e?.message || e);
    throw e; // surfaced by errorHandler as 500
  } finally {
    if (conn) conn.release();
  }
});

const statusSchema = z.object({
  status: z.enum(['pending', 'confirmed', 'processing', 'completed', 'cancelled', 'paid']),
});

router.put('/:id/status', auth(), adminOnly, async (req, res) => {
  const p = statusSchema.safeParse(req.body);
  if (!p.success) return fail(res, 'Validasi gagal', 422, p.error.flatten());
  const status = p.data.status;
  const o = await queryOne('SELECT id FROM orders WHERE id=?', [req.params.id]);
  if (!o) return fail(res, 'Pesanan tidak ditemukan', 404);

  // 'paid' is not a valid orders.status enum value — it only affects payments.
  if (status !== 'paid') {
    await execute('UPDATE orders SET status=? WHERE id=?', [status, req.params.id]);
  }

  // sync payment_status
  if (status === 'paid' || status === 'completed') {
    await execute('UPDATE payments SET payment_status=? WHERE order_id=?', ['paid', req.params.id]);
  } else if (status === 'cancelled') {
    await execute('UPDATE payments SET payment_status=? WHERE order_id=?', ['cancelled', req.params.id]);
  }

  const updated = await queryOne('SELECT * FROM orders WHERE id=?', [req.params.id]);
  return ok(res, 'Status diperbarui', { ...updated, total_amount: Number(updated.total_amount) });
});

export default router;
