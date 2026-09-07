import { Router } from 'express';
import { z } from 'zod';
import { query, queryOne, execute } from '../config/db';
import { ok, fail } from '../utils/response';
import { auth, adminOnly, AuthRequest } from '../middlewares/auth';
import { slugify } from '../utils/slug';

const router = Router();

// GET /categories — optional pagination; if no pagination params, return plain array (backward compatible)
router.get('/', async (req, res) => {
  const pageQ = req.query.page as string | undefined;
  const limitQ = req.query.limit as string | undefined;
  if (pageQ || limitQ) {
    const page = Math.max(1, parseInt(pageQ || '1', 10) || 1);
    const limit = Math.min(100, Math.max(1, parseInt(limitQ || '20', 10) || 20));
    const offset = (page - 1) * limit;
    const rows = await query('SELECT * FROM vehicle_categories ORDER BY name ASC LIMIT ? OFFSET ?', [limit, offset]);
    const countRow: any = await queryOne('SELECT COUNT(*) as total FROM vehicle_categories');
    const total = Number(countRow?.total || 0);
    return ok(res, 'Categories retrieved', rows, { page, limit, total, totalPages: Math.ceil(total/limit) });
  }
  const rows = await query('SELECT * FROM vehicle_categories ORDER BY name ASC');
  return ok(res, 'Categories retrieved', rows);
});

router.post('/', auth(), adminOnly, async (req: AuthRequest, res) => {
  const schema = z.object({ name: z.string().min(2), description: z.string().optional() });
  const p = schema.safeParse(req.body);
  if (!p.success) return fail(res, 'Validasi gagal', 422, p.error.flatten());
  const slug = slugify(p.data.name);
  const exists = await queryOne('SELECT id FROM vehicle_categories WHERE slug=?', [slug]);
  if (exists) return fail(res, 'Kategori sudah ada', 409);
  const r: any = await execute('INSERT INTO vehicle_categories (name,slug,description) VALUES (?,?,?)', [p.data.name, slug, p.data.description || null]);
  const cat = await queryOne('SELECT * FROM vehicle_categories WHERE id=?', [r.insertId]);
  return ok(res, 'Kategori dibuat', cat);
});

router.put('/:id', auth(), adminOnly, async (req, res) => {
  const schema = z.object({
    name: z.string().min(2).optional(),
    description: z.string().optional(),
  });
  const p = schema.safeParse(req.body);
  if (!p.success) return fail(res, 'Validasi gagal', 422, p.error.flatten());
  const { name, description } = p.data;
  const cat: any = await queryOne('SELECT * FROM vehicle_categories WHERE id=?', [req.params.id]);
  if (!cat) return fail(res, 'Kategori tidak ditemukan', 404);

  // Slug uniqueness — check collision excluding self if name changes
  if (name !== undefined) {
    const newSlug = slugify(name);
    const collision: any = await queryOne('SELECT id FROM vehicle_categories WHERE slug=? AND id!=?', [newSlug, req.params.id]);
    if (collision) return fail(res, 'Slug sudah ada', 409);
    await execute('UPDATE vehicle_categories SET name=?, slug=?, description=? WHERE id=?', [name, newSlug, description ?? cat.description, req.params.id]);
  } else {
    await execute('UPDATE vehicle_categories SET name=?, description=? WHERE id=?', [cat.name, description ?? cat.description, req.params.id]);
  }
  const updated = await queryOne('SELECT * FROM vehicle_categories WHERE id=?', [req.params.id]);
  return ok(res, 'Kategori diperbarui', updated);
});

router.delete('/:id', auth(), adminOnly, async (req, res) => {
  const cat = await queryOne('SELECT id FROM vehicle_categories WHERE id=?', [req.params.id]);
  if (!cat) return fail(res, 'Kategori tidak ditemukan', 404);
  try {
    await execute('DELETE FROM vehicle_categories WHERE id=?', [req.params.id]);
  } catch (e: any) {
    const msg = String(e.message || '');
    const isFk = e.errno === 1217 || e.errno === 1451 || e.sqlState === '23000'
      || msg.includes('ER_ROW_IS_REFERENCED') || msg.includes('foreign key constraint fails');
    if (isFk) return fail(res, 'Tidak dapat menghapus kategori yang masih dipakai kendaraan', 400);
    throw e;
  }
  return ok(res, 'Kategori dihapus', null);
});

export default router;
