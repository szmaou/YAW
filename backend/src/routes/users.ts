import { Router } from 'express';
import { z } from 'zod';
import { query, queryOne, execute } from '../config/db';
import { ok, fail } from '../utils/response';
import { auth, adminOnly, AuthRequest } from '../middlewares/auth';

const router = Router();

const RoleEnum = z.enum(['user', 'admin']);

router.get('/', auth(), adminOnly, async (req, res) => {
  const page = Math.max(1, parseInt(req.query.page as string) || 1);
  const limit = Math.min(100, parseInt(req.query.limit as string) || 20);
  const offset = (page - 1) * limit;
  const rows = await query('SELECT id,name,email,phone,role,avatar,created_at FROM users ORDER BY created_at DESC LIMIT ? OFFSET ?', [limit, offset]);
  const countRow: any = await queryOne('SELECT COUNT(*) as total FROM users');
  return ok(res, 'Users retrieved', rows, { page, limit, total: Number(countRow.total), totalPages: Math.ceil(Number(countRow.total)/limit) });
});

router.get('/:id', auth(), async (req: AuthRequest, res) => {
  const isSelf = String(req.user!.id) === String(req.params.id);
  const isAdmin = req.user!.role === 'admin';
  if (!isSelf && !isAdmin) return fail(res, 'Forbidden', 403);
  const user = await queryOne('SELECT id,name,email,phone,role,avatar,created_at FROM users WHERE id=?', [req.params.id]);
  if (!user) return fail(res, 'User tidak ditemukan', 404);
  return ok(res, 'User retrieved', user);
});

// avatar may be a full URL, any string starting with 'http', an empty string (clear), or omitted
const avatarSchema = z.union([z.string().url(), z.string().startsWith('http'), z.literal('')]).optional();

const updateSchema = z.object({
  name: z.string().min(2).max(100).optional(),
  phone: z.string().max(30).optional(),
  avatar: avatarSchema,
  role: RoleEnum.optional(),
});

router.put('/:id', auth(), async (req: AuthRequest, res) => {
  const isSelf = String(req.user!.id) === String(req.params.id);
  const isAdmin = req.user!.role === 'admin';
  if (!isSelf && !isAdmin) return fail(res, 'Forbidden', 403);

  const p = updateSchema.safeParse(req.body);
  if (!p.success) return fail(res, 'Validasi gagal', 422, p.error.flatten());
  const d = p.data;

  // Only admins may change a role
  if (d.role !== undefined && !isAdmin) return fail(res, 'Forbidden — role hanya boleh diubah oleh admin', 403);

  const user: any = await queryOne('SELECT id, role FROM users WHERE id=?', [req.params.id]);
  if (!user) return fail(res, 'User tidak ditemukan', 404);
  const currentRole: string = user.role;

  // Ensure at least one admin remains: block demoting the last admin to 'user'
  if (d.role === 'user' && currentRole === 'admin') {
    const countRow: any = await queryOne('SELECT COUNT(*) as total FROM users WHERE role=?', ['admin']);
    if (Number(countRow?.total || 0) <= 1) return fail(res, 'Tidak dapat menurunkan peran admin terakhir', 400);
  }

  const fields: string[] = []; const vals: any[] = [];
  if (d.name !== undefined) { fields.push('name=?'); vals.push(d.name); }
  if (d.phone !== undefined) { fields.push('phone=?'); vals.push(d.phone); }
  if (d.avatar !== undefined) { fields.push('avatar=?'); vals.push(d.avatar); }
  if (d.role !== undefined) { fields.push('role=?'); vals.push(d.role); }
  if (!fields.length) return fail(res, 'Tidak ada field untuk update', 400);
  vals.push(req.params.id);
  await execute(`UPDATE users SET ${fields.join(',')} WHERE id=?`, vals);
  const updated = await queryOne('SELECT id,name,email,phone,role,avatar,created_at FROM users WHERE id=?', [req.params.id]);
  return ok(res, 'User diperbarui', updated);
});

router.delete('/:id', auth(), adminOnly, async (req, res) => {
  const user = await queryOne('SELECT id FROM users WHERE id=?', [req.params.id]);
  if (!user) return fail(res, 'User tidak ditemukan', 404);
  try {
    // orders -> users is ON DELETE CASCADE, so deleting a user cascades to orders/payments
    await execute('DELETE FROM users WHERE id=?', [req.params.id]);
  } catch (e: any) {
    const msg = String(e.message || '');
    const isFk = e.errno === 1217 || e.errno === 1451 || e.sqlState === '23000'
      || msg.includes('ER_ROW_IS_REFERENCED') || msg.includes('foreign key constraint fails');
    if (isFk) return fail(res, 'Tidak dapat menghapus user yang masih memiliki data terkait', 400);
    throw e;
  }
  return ok(res, 'User dihapus', null);
});

export default router;
