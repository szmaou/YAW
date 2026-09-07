import { Router } from 'express';
import { query, queryOne, execute } from '../config/db';
import { ok, fail } from '../utils/response';
import { auth, AuthRequest } from '../middlewares/auth';

const router = Router();

router.get('/', auth(), async (req: AuthRequest, res) => {
  const rows: any[] = await query(
    `SELECT v.*, c.name as category_name, c.slug as category_slug, f.created_at as fav_created
     FROM favorites f JOIN vehicles v ON v.id=f.vehicle_id
     LEFT JOIN vehicle_categories c ON c.id=v.category_id
     WHERE f.user_id=? ORDER BY f.created_at DESC`, [req.user!.id]);
  const data = await Promise.all(rows.map(async (v) => {
    const images: any[] = await query('SELECT image_url FROM vehicle_images WHERE vehicle_id=? ORDER BY is_primary DESC', [v.id]);
    return {
      id: v.id, name: v.name, slug: v.slug, brand: v.brand, model: v.model, year: v.year,
      price: Number(v.price), stock: v.stock, fuel_type: v.fuel_type, transmission: v.transmission,
      category: v.category_name ? { name: v.category_name, slug: v.category_slug } : null,
      images: images.map(i=> i.image_url),
      favorited_at: v.fav_created,
      vehicle: { id: v.id, name: v.name, slug: v.slug, brand: v.brand, model: v.model, year: v.year, price: Number(v.price), stock: v.stock, images: images.map(i=> i.image_url) }
    };
  }));
  return ok(res, 'Favorites retrieved', data);
});

router.post('/', auth(), async (req: AuthRequest, res) => {
  const vehicleId = req.body.vehicle_id || req.body.vehicleId;
  if (!vehicleId) return fail(res, 'vehicle_id wajib', 422);
  const vehicle = await queryOne('SELECT id FROM vehicles WHERE id=?', [vehicleId]);
  if (!vehicle) return fail(res, 'Kendaraan tidak ditemukan', 404);
  const exists = await queryOne('SELECT id FROM favorites WHERE user_id=? AND vehicle_id=?', [req.user!.id, vehicleId]);
  if (exists) return ok(res, 'Sudah di favorit', exists);
  const r: any = await execute('INSERT INTO favorites (user_id, vehicle_id) VALUES (?,?)', [req.user!.id, vehicleId]);
  return ok(res, 'Ditambahkan ke favorit', { id: r.insertId });
});

router.delete('/:vehicleId', auth(), async (req: AuthRequest, res) => {
  await execute('DELETE FROM favorites WHERE user_id=? AND vehicle_id=?', [req.user!.id, req.params.vehicleId]);
  return ok(res, 'Dihapus dari favorit', null);
});

export default router;
