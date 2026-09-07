import { Router } from 'express';
import { query, queryOne } from '../config/db';
import { ok } from '../utils/response';
import { auth, adminOnly } from '../middlewares/auth';

const router = Router();

router.get('/dashboard', auth(), adminOnly, async (_req, res) => {
  const v: any = await queryOne('SELECT COUNT(*) as total FROM vehicles');
  const u: any = await queryOne('SELECT COUNT(*) as total FROM users');
  const o: any = await queryOne('SELECT COUNT(*) as total FROM orders');
  const rev: any = await queryOne('SELECT COALESCE(SUM(total_amount),0) as total FROM orders WHERE status IN ("completed","processing","confirmed")');
  const pending: any = await queryOne('SELECT COUNT(*) as total FROM orders WHERE status="pending"');
  const completed: any = await queryOne('SELECT COUNT(*) as total FROM orders WHERE status="completed"');
  const recent: any[] = await query('SELECT o.*, u.name as user_name FROM orders o LEFT JOIN users u ON u.id=o.user_id ORDER BY o.created_at DESC LIMIT 5');
  return ok(res, 'Dashboard', {
    totalVehicles: Number(v.total), totalUsers: Number(u.total), totalOrders: Number(o.total),
    totalRevenue: Number(rev.total), pendingOrders: Number(pending.total), completedOrders: Number(completed.total),
    recentOrders: recent,
  });
});

router.get('/statistics', auth(), adminOnly, async (_req, res) => {
  const monthly: any[] = await query(`
    SELECT DATE_FORMAT(created_at, '%Y-%m') as month, COUNT(*) as orders, COALESCE(SUM(total_amount),0) as revenue
    FROM orders GROUP BY DATE_FORMAT(created_at, '%Y-%m') ORDER BY month DESC LIMIT 12
  `);
  const byStatus: any[] = await query(`SELECT status, COUNT(*) as count FROM orders GROUP BY status`);
  const popular: any[] = await query(`
    SELECT v.id, v.name, v.brand, COUNT(oi.id) as sold
    FROM order_items oi JOIN vehicles v ON v.id=oi.vehicle_id
    GROUP BY v.id ORDER BY sold DESC LIMIT 5
  `);
  return ok(res, 'Statistics', { monthly: monthly.reverse(), byStatus, popular });
});

export default router;
