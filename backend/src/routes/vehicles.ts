import { Router } from 'express';
import { z } from 'zod';
import { query, queryOne, execute } from '../config/db';
import { ok, fail } from '../utils/response';
import { auth, adminOnly, AuthRequest } from '../middlewares/auth';
import { slugify } from '../utils/slug';

const router = Router();

// GET /vehicles — pagination + search/filter
router.get('/', async (req, res) => {
  const page = Math.max(1, parseInt(req.query.page as string) || 1);
  const limit = Math.min(100, Math.max(1, parseInt(req.query.limit as string) || 20));
  const offset = (page - 1) * limit;
  const search = (req.query.search as string) || '';
  const category = req.query.category as string;
  const brand = req.query.brand as string;
  const minPrice = req.query.min_price ? Number(req.query.min_price) : undefined;
  const maxPrice = req.query.max_price ? Number(req.query.max_price) : undefined;
  const year = req.query.year ? Number(req.query.year) : undefined;
  const fuel = req.query.fuel_type as string;
  const transmission = req.query.transmission as string;

  const where: string[] = [];
  const params: any[] = [];
  if (search) { where.push('(v.name LIKE ? OR v.brand LIKE ? OR v.model LIKE ?)'); params.push(`%${search}%`,`%${search}%`,`%${search}%`); }
  if (category) {
    // allow slug or id
    const cat = await queryOne('SELECT id FROM vehicle_categories WHERE slug=? OR id=?', [category, category]);
    if (cat) { where.push('v.category_id=?'); params.push((cat as any).id); }
    else { where.push('1=0'); }
  }
  if (brand) { where.push('v.brand=?'); params.push(brand); }
  if (minPrice !== undefined) { where.push('v.price>=?'); params.push(minPrice); }
  if (maxPrice !== undefined) { where.push('v.price<=?'); params.push(maxPrice); }
  if (year) { where.push('v.year=?'); params.push(year); }
  if (fuel) { where.push('v.fuel_type=?'); params.push(fuel); }
  if (transmission) { where.push('v.transmission=?'); params.push(transmission); }

  const whereSql = where.length ? `WHERE ${where.join(' AND ')}` : '';
  const countRow: any = await queryOne(`SELECT COUNT(*) as total FROM vehicles v ${whereSql}`, params);
  const total = Number(countRow?.total || 0);
  const rows: any[] = await query(`SELECT v.*, c.name as category_name, c.slug as category_slug FROM vehicles v LEFT JOIN vehicle_categories c ON c.id=v.category_id ${whereSql} ORDER BY v.created_at DESC LIMIT ? OFFSET ?`, [...params, limit, offset]);

  // attach images + category
  const data = await Promise.all(rows.map(async (v) => {
    const images: any[] = await query('SELECT image_url, is_primary FROM vehicle_images WHERE vehicle_id=? ORDER BY is_primary DESC, id ASC', [v.id]);
    return {
      id: v.id, category_id: v.category_id, name: v.name, slug: v.slug, brand: v.brand, model: v.model,
      year: v.year, price: Number(v.price), stock: v.stock, description: v.description, engine: v.engine,
      transmission: v.transmission, fuel_type: v.fuel_type, color: v.color, is_available: !!v.is_available,
      created_at: v.created_at, updated_at: v.updated_at,
      category: v.category_id ? { id: v.category_id, name: v.category_name, slug: v.category_slug } : null,
      images: images.map(i=> i.image_url),
      image_urls: images.map(i=> i.image_url),
    };
  }));

  return ok(res, 'Vehicles retrieved', data, { page, limit, total, totalPages: Math.ceil(total/limit) });
});

router.get('/:id', async (req, res) => {
  const v: any = await queryOne('SELECT v.*, c.name as category_name, c.slug as category_slug FROM vehicles v LEFT JOIN vehicle_categories c ON c.id=v.category_id WHERE v.id=? OR v.slug=?', [req.params.id, req.params.id]);
  if (!v) return fail(res, 'Kendaraan tidak ditemukan', 404);
  const images: any[] = await query('SELECT image_url, is_primary FROM vehicle_images WHERE vehicle_id=? ORDER BY is_primary DESC, id ASC', [v.id]);
  return ok(res, 'Vehicle retrieved', {
    id: v.id, category_id: v.category_id, name: v.name, slug: v.slug, brand: v.brand, model: v.model,
    year: v.year, price: Number(v.price), stock: v.stock, description: v.description, engine: v.engine,
    transmission: v.transmission, fuel_type: v.fuel_type, color: v.color, is_available: !!v.is_available,
    category: v.category_id ? { id: v.category_id, name: v.category_name, slug: v.category_slug } : null,
    images: images.map(i=> i.image_url),
    image_urls: images.map(i=> i.image_url),
  });
});

const vehicleSchema = z.object({
  category_id: z.union([z.string(), z.number()]),
  name: z.string().min(2), brand: z.string().min(1), model: z.string().min(1),
  year: z.number().int().min(1900).max(2100), price: z.number().min(0), stock: z.number().int().min(0),
  description: z.string().optional(), engine: z.string().optional(), transmission: z.string().optional(),
  fuel_type: z.string().optional(), color: z.string().optional(), is_available: z.boolean().optional(),
  images: z.array(z.string()).optional(),
});

// All fields optional for partial updates (PUT). Coerce numeric strings before parse.
const updateVehicleSchema = vehicleSchema.partial();

router.post('/', auth(), adminOnly, async (req: AuthRequest, res) => {
  // Coerce numeric fields from string (query/form) inputs before Zod validation
  const input = { ...req.body };
  if (input.year !== undefined) input.year = Number(input.year);
  if (input.price !== undefined) input.price = Number(input.price);
  if (input.stock !== undefined) input.stock = Number(input.stock);
  const p = vehicleSchema.safeParse(input);
  if (!p.success) return fail(res, 'Validasi gagal', 422, p.error.flatten());
  const d = p.data;

  // category must exist
  const cat: any = await queryOne('SELECT id FROM vehicle_categories WHERE id=?', [Number(d.category_id)]);
  if (!cat) return fail(res, 'Kategori tidak ditemukan', 404);

  const slug = slugify(d.name);
  const existing: any = await queryOne('SELECT id FROM vehicles WHERE slug=?', [slug]);
  if (existing) return fail(res, 'Slug sudah ada', 409);
  const r: any = await execute(
    `INSERT INTO vehicles (category_id,name,slug,brand,model,year,price,stock,description,engine,transmission,fuel_type,color,is_available)
     VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)`,
    [d.category_id, d.name, slug, d.brand, d.model, d.year, d.price, d.stock, d.description||null, d.engine||null, d.transmission||null, d.fuel_type||null, d.color||null, d.is_available!==false?1:0]
  );
  const id = r.insertId;
  if (d.images?.length) {
    for (let i=0;i<d.images.length;i++) {
      await execute('INSERT INTO vehicle_images (vehicle_id,image_url,is_primary) VALUES (?,?,?)', [id, d.images[i], i===0?1:0]);
    }
  }
  const v = await queryOne('SELECT * FROM vehicles WHERE id=?', [id]);
  return ok(res, 'Kendaraan dibuat', v);
});

router.put('/:id', auth(), adminOnly, async (req: AuthRequest, res) => {
  const existing: any = await queryOne('SELECT * FROM vehicles WHERE id=?', [req.params.id]);
  if (!existing) return fail(res, 'Kendaraan tidak ditemukan', 404);

  // Coerce numeric fields from string inputs before Zod validation
  const input: any = { ...req.body };
  if (input.year !== undefined) input.year = Number(input.year);
  if (input.price !== undefined) input.price = Number(input.price);
  if (input.stock !== undefined) input.stock = Number(input.stock);
  const p = updateVehicleSchema.safeParse(input);
  if (!p.success) return fail(res, 'Validasi gagal', 422, p.error.flatten());
  const d = p.data;

  // Validate category exists if provided
  if (d.category_id !== undefined) {
    const cat: any = await queryOne('SELECT id FROM vehicle_categories WHERE id=?', [Number(d.category_id)]);
    if (!cat) return fail(res, 'Kategori tidak ditemukan', 404);
  }

  const fields: string[] = []; const vals: any[] = [];
  if (d.category_id !== undefined) { fields.push('category_id=?'); vals.push(Number(d.category_id)); }
  if (d.name !== undefined) { fields.push('name=?'); vals.push(d.name); }
  if (d.brand !== undefined) { fields.push('brand=?'); vals.push(d.brand); }
  if (d.model !== undefined) { fields.push('model=?'); vals.push(d.model); }
  if (d.year !== undefined) { fields.push('year=?'); vals.push(d.year); }
  if (d.price !== undefined) { fields.push('price=?'); vals.push(d.price); }
  if (d.stock !== undefined) { fields.push('stock=?'); vals.push(d.stock); }
  if (d.description !== undefined) { fields.push('description=?'); vals.push(d.description); }
  if (d.engine !== undefined) { fields.push('engine=?'); vals.push(d.engine); }
  if (d.transmission !== undefined) { fields.push('transmission=?'); vals.push(d.transmission); }
  if (d.fuel_type !== undefined) { fields.push('fuel_type=?'); vals.push(d.fuel_type); }
  if (d.color !== undefined) { fields.push('color=?'); vals.push(d.color); }
  if (d.is_available !== undefined) { fields.push('is_available=?'); vals.push(d.is_available ? 1 : 0); }

  // Slug uniqueness — check collision excluding self if name changes
  if (d.name !== undefined) {
    const newSlug = slugify(d.name);
    const collision: any = await queryOne('SELECT id FROM vehicles WHERE slug=? AND id!=?', [newSlug, req.params.id]);
    if (collision) return fail(res, 'Slug sudah ada', 409);
    fields.push('slug=?'); vals.push(newSlug);
  }

  if (!fields.length) return fail(res, 'Tidak ada field untuk update', 400);
  vals.push(req.params.id);
  await execute(`UPDATE vehicles SET ${fields.join(',')} WHERE id=?`, vals);

  if (d.images && Array.isArray(d.images)) {
    await execute('DELETE FROM vehicle_images WHERE vehicle_id=?', [req.params.id]);
    for (let i=0;i<d.images.length;i++) {
      await execute('INSERT INTO vehicle_images (vehicle_id,image_url,is_primary) VALUES (?,?,?)', [req.params.id, d.images[i], i===0?1:0]);
    }
  }
  const updated = await queryOne('SELECT * FROM vehicles WHERE id=?', [req.params.id]);
  return ok(res, 'Kendaraan diperbarui', updated);
});

router.delete('/:id', auth(), adminOnly, async (req, res) => {
  const v = await queryOne('SELECT id FROM vehicles WHERE id=?', [req.params.id]);
  if (!v) return fail(res, 'Kendaraan tidak ditemukan', 404);
  // vehicle_images are deleted first (ON DELETE CASCADE anyway) — required by spec
  await execute('DELETE FROM vehicle_images WHERE vehicle_id=?', [req.params.id]);
  try {
    await execute('DELETE FROM vehicles WHERE id=?', [req.params.id]);
  } catch (e: any) {
    const msg = String(e.message || '');
    const isFk = e.errno === 1217 || e.errno === 1451 || e.sqlState === '23000'
      || msg.includes('ER_ROW_IS_REFERENCED') || msg.includes('foreign key constraint fails');
    if (isFk) return fail(res, 'Tidak dapat menghapus kendaraan yang sudah ada pesanan', 400);
    throw e;
  }
  return ok(res, 'Kendaraan dihapus', null);
});

export default router;
