import fs from 'fs';
import path from 'path';
import { pool } from '../config/db';
import { env } from '../config/env';

/**
 * Seed 20 dummy vehicles + matching images (idempotent per slug).
 * - Each vehicle gets 2 images (tampak samping + tampak depan) copied from
 *   `backend/seed-assets/vehicles/<slug>-{1,2}.jpg` into `<UPLOAD_PATH>/seed/`
 *   and registered as `/uploads/seed/<slug>-{1,2}.jpg` (first = primary).
 * - Existing slugs are skipped, so re-runs never duplicate and real user
 *   data (e.g. vehicles created via admin form) is never touched.
 * - Called by initDb on startup and by `npm run seed` / `npm run seed:vehicles`.
 */

interface SeedVehicle {
  slug: string;
  categorySlug: string;
  name: string;
  brand: string;
  model: string;
  year: number;
  price: number;
  stock: number;
  description: string;
  engine: string;
  transmission: string;
  fuelType: string;
  color: string;
}

const VEHICLES: SeedVehicle[] = [
  // ── SUV (5) ──
  {
    slug: 'toyota-fortuner-2-8-vrz', categorySlug: 'suv',
    name: 'Toyota Fortuner 2.8 VRZ', brand: 'Toyota', model: 'Fortuner 2.8 VRZ',
    year: 2024, price: 652000000, stock: 6,
    description: 'SUV ladder-frame 7-penumpang dengan mesin diesel 2.8L bertenaga dan kabin lega untuk keluarga maupun petualangan.',
    engine: 'Diesel 2.8L', transmission: 'Otomatis', fuelType: 'Diesel', color: 'Hitam',
  },
  {
    slug: 'honda-cr-v-1-5-turbo', categorySlug: 'suv',
    name: 'Honda CR-V 1.5 Turbo', brand: 'Honda', model: 'CR-V 1.5 Turbo',
    year: 2023, price: 739000000, stock: 4,
    description: 'SUV medium dengan mesin 1.5L turbo responsif, fitur Honda Sensing lengkap, dan kenyamanan khas Honda.',
    engine: 'Bensin 1.5L Turbo', transmission: 'Otomatis', fuelType: 'Bensin', color: 'Putih',
  },
  {
    slug: 'mitsubishi-pajero-sport-dakar', categorySlug: 'suv',
    name: 'Mitsubishi Pajero Sport Dakar', brand: 'Mitsubishi', model: 'Pajero Sport Dakar',
    year: 2024, price: 735500000, stock: 5,
    description: 'SUV tangguh dengan penggerak Super Select 4WD dan mesin diesel 2.4L MIVEC, siap untuk segala medan.',
    engine: 'Diesel 2.4L MIVEC', transmission: 'Otomatis', fuelType: 'Diesel', color: 'Silver',
  },
  {
    slug: 'suzuki-jimny-5-door', categorySlug: 'suv',
    name: 'Suzuki Jimny 5-Door', brand: 'Suzuki', model: 'Jimny 5-Door',
    year: 2024, price: 478000000, stock: 3,
    description: 'Legenda off-road 4x4 kini berpintu lima — praktis untuk harian, tetap garang di jalur tanah.',
    engine: 'Bensin 1.5L', transmission: 'Otomatis', fuelType: 'Bensin', color: 'Hijau Army',
  },
  {
    slug: 'hyundai-creta-prime', categorySlug: 'suv',
    name: 'Hyundai Creta Prime', brand: 'Hyundai', model: 'Creta Prime',
    year: 2023, price: 415000000, stock: 7,
    description: 'Compact SUV kaya fitur dengan Panoramic Sunroof, Bose audio, dan Hyundai Bluelink di tipe tertinggi.',
    engine: 'Bensin 1.5L', transmission: 'Otomatis', fuelType: 'Bensin', color: 'Merah',
  },
  // ── Sports (8) ──
  {
    slug: 'toyota-gr-supra', categorySlug: 'sports',
    name: 'Toyota GR Supra', brand: 'Toyota', model: 'GR Supra',
    year: 2024, price: 2250000000, stock: 2,
    description: 'Ikon sports car dengan mesin 3.0L turbo segaris-6, penggerak roda belakang, dan handling khas Gazoo Racing.',
    engine: 'Bensin 3.0L Turbo', transmission: 'Otomatis', fuelType: 'Bensin', color: 'Kuning',
  },
  {
    slug: 'honda-civic-type-r', categorySlug: 'sports',
    name: 'Honda Civic Type R', brand: 'Honda', model: 'Civic Type R',
    year: 2023, price: 1399000000, stock: 2,
    description: 'Hot hatch legendaris bermesin 2.0L VTEC Turbo dan transmisi manual 6-percepatan — pemegang rekor sirkuit di kelasnya.',
    engine: 'Bensin 2.0L VTEC Turbo', transmission: 'Manual', fuelType: 'Bensin', color: 'Putih',
  },
  {
    slug: 'mazda-mx-5-miata', categorySlug: 'sports',
    name: 'Mazda MX-5 Miata', brand: 'Mazda', model: 'MX-5 Miata',
    year: 2024, price: 859000000, stock: 3,
    description: 'Roadster atap terbuka paling laris di dunia — ringan, seimbang, dan murni soal kesenangan berkendara.',
    engine: 'Bensin 2.0L SKYACTIV-G', transmission: 'Manual', fuelType: 'Bensin', color: 'Merah',
  },
  {
    slug: 'subaru-brz', categorySlug: 'sports',
    name: 'Subaru BRZ', brand: 'Subaru', model: 'BRZ',
    year: 2024, price: 895000000, stock: 3,
    description: 'Coupe ringan bermesin boxer 2.4L dengan pusat gravitasi rendah — presisi di tikungan, seru setiap hari.',
    engine: 'Bensin 2.4L Boxer', transmission: 'Manual', fuelType: 'Bensin', color: 'Biru',
  },
  {
    slug: 'nissan-gt-r-premium', categorySlug: 'sports',
    name: 'Nissan GT-R Premium', brand: 'Nissan', model: 'GT-R Premium',
    year: 2023, price: 3750000000, stock: 1,
    description: 'Godzilla bermesin V6 3.8L twin-turbo rakitan tangan Takumi dengan penggerak AWD ATTESA E-TS.',
    engine: 'Bensin 3.8L V6 Twin-Turbo', transmission: 'Otomatis', fuelType: 'Bensin', color: 'Biru',
  },
  {
    slug: 'ford-mustang-gt', categorySlug: 'sports',
    name: 'Ford Mustang GT 5.0', brand: 'Ford', model: 'Mustang GT 5.0',
    year: 2024, price: 2650000000, stock: 2,
    description: 'Muscle car Amerika bermesin V8 5.0L dengan raungan khas dan mode knalpot aktif yang bisa diatur.',
    engine: 'Bensin 5.0L V8', transmission: 'Otomatis', fuelType: 'Bensin', color: 'Oranye',
  },
  {
    slug: 'bmw-m4-competition', categorySlug: 'sports',
    name: 'BMW M4 Competition', brand: 'BMW', model: 'M4 Competition',
    year: 2024, price: 2899000000, stock: 2,
    description: 'Coupe Jerman bermesin 3.0L twin-turbo 510 PS dengan sasis M adaptif dan interior berorientasi pengemudi.',
    engine: 'Bensin 3.0L Twin-Turbo', transmission: 'Otomatis', fuelType: 'Bensin', color: 'Hijau',
  },
  {
    slug: 'toyota-gr86', categorySlug: 'sports',
    name: 'Toyota GR86', brand: 'Toyota', model: 'GR86',
    year: 2023, price: 945000000, stock: 4,
    description: 'Adik GR Supra yang ringan dan lincah — mesin boxer 2.4L, paling asyik di kelas harga di bawah satu miliar.',
    engine: 'Bensin 2.4L Boxer', transmission: 'Manual', fuelType: 'Bensin', color: 'Merah',
  },
  // ── Electric (7) ──
  {
    slug: 'tesla-model-3', categorySlug: 'electric',
    name: 'Tesla Model 3', brand: 'Tesla', model: 'Model 3',
    year: 2024, price: 1199000000, stock: 5,
    description: 'Sedan listrik paling populer di dunia dengan Autopilot, akselerasi instan, dan efisiensi baterai terbaik.',
    engine: 'Listrik', transmission: 'Otomatis', fuelType: 'Listrik', color: 'Putih',
  },
  {
    slug: 'byd-atto-3', categorySlug: 'electric',
    name: 'BYD Atto 3 Superior', brand: 'BYD', model: 'Atto 3 Superior',
    year: 2024, price: 515000000, stock: 8,
    description: 'SUV listrik dengan Blade Battery 60.5 kWh, jarak tempuh 480 km, dan interior futuristis yang playful.',
    engine: 'Listrik', transmission: 'Otomatis', fuelType: 'Listrik', color: 'Biru',
  },
  {
    slug: 'hyundai-ioniq-5', categorySlug: 'electric',
    name: 'Hyundai Ioniq 5 Prime', brand: 'Hyundai', model: 'Ioniq 5 Prime',
    year: 2024, price: 895000000, stock: 5,
    description: 'Crossover listrik pemenang World Car of the Year dengan pengisian ultra-cepat 800V dan desain retro-futuristis.',
    engine: 'Listrik', transmission: 'Otomatis', fuelType: 'Listrik', color: 'Silver',
  },
  {
    slug: 'wuling-air-ev', categorySlug: 'electric',
    name: 'Wuling Air EV Long Range', brand: 'Wuling', model: 'Air EV Long Range',
    year: 2023, price: 299500000, stock: 12,
    description: 'Mobil listrik mungil favorit perkotaan — lincah di jalan sempit, murah di kantong dan perawatan.',
    engine: 'Listrik', transmission: 'Otomatis', fuelType: 'Listrik', color: 'Putih',
  },
  {
    slug: 'nissan-leaf', categorySlug: 'electric',
    name: 'Nissan Leaf', brand: 'Nissan', model: 'Leaf',
    year: 2023, price: 749000000, stock: 4,
    description: 'Pelopor mobil listrik massal dengan teknologi e-Pedal dan rekam jejak keandalan baterai teruji.',
    engine: 'Listrik', transmission: 'Otomatis', fuelType: 'Listrik', color: 'Hitam',
  },
  {
    slug: 'kia-ev6-gt-line', categorySlug: 'electric',
    name: 'Kia EV6 GT-Line', brand: 'Kia', model: 'EV6 GT-Line',
    year: 2024, price: 1375000000, stock: 3,
    description: 'Crossover listrik dengan jarak tempuh 528 km, pengisian 10–80% dalam 18 menit, dan kabin lapang.',
    engine: 'Listrik', transmission: 'Otomatis', fuelType: 'Listrik', color: 'Merah',
  },
  {
    slug: 'toyota-bz4x', categorySlug: 'electric',
    name: 'Toyota bZ4X', brand: 'Toyota', model: 'bZ4X',
    year: 2024, price: 1190000000, stock: 4,
    description: 'SUV listrik pertama Toyota dengan DNA off-road, baterai bergaransi panjang, dan build quality khas Toyota.',
    engine: 'Listrik', transmission: 'Otomatis', fuelType: 'Listrik', color: 'Abu-abu',
  },
];

function resolveSeedDir(): string {
  const base = path.isAbsolute(env.uploadPath)
    ? env.uploadPath
    : path.resolve(process.cwd(), env.uploadPath);
  return path.join(base, 'seed');
}

function findSeedAssetsDir(): string | null {
  const candidates = [
    path.resolve(process.cwd(), 'seed-assets/vehicles'),
    path.resolve(process.cwd(), '../seed-assets/vehicles'),
    path.resolve(__dirname, '../../seed-assets/vehicles'),
  ];
  return candidates.find((p) => fs.existsSync(p)) ?? null;
}

export async function seedVehicles(): Promise<{ inserted: number; skipped: number }> {
  let inserted = 0;
  let skipped = 0;
  const conn = await pool.getConnection();
  try {
    // category slug -> id
    const catRows: any = await conn.query('SELECT id, slug FROM vehicle_categories');
    const catBySlug = new Map<string, number>();
    for (const r of catRows) catBySlug.set(String(r.slug), Number(r.id));

    const seedDir = resolveSeedDir();
    fs.mkdirSync(seedDir, { recursive: true });
    const assetsDir = findSeedAssetsDir();
    if (!assetsDir) {
      console.warn('[seed:vehicles] seed-assets/vehicles not found — vehicles will be inserted without images');
    }

    for (const v of VEHICLES) {
      const existing: any = await conn.query('SELECT id FROM vehicles WHERE slug = ? LIMIT 1', [v.slug]);
      if (Array.isArray(existing) && existing.length > 0) {
        skipped++;
        continue;
      }
      const categoryId = catBySlug.get(v.categorySlug);
      if (!categoryId) {
        console.warn(`[seed:vehicles] category '${v.categorySlug}' missing — skipping ${v.slug}`);
        skipped++;
        continue;
      }

      const res: any = await conn.query(
        'INSERT INTO vehicles (category_id, name, slug, brand, model, year, price, stock, description, engine, transmission, fuel_type, color, is_available) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
        [categoryId, v.name, v.slug, v.brand, v.model, v.year, v.price, v.stock, v.description, v.engine, v.transmission, v.fuelType, v.color, 1],
      );
      const vehicleId = Number(res.insertId);
      inserted++;

      // 2 matching images per vehicle (side + front)
      for (let i = 1; i <= 2; i++) {
        const file = `${v.slug}-${i}.jpg`;
        const src = assetsDir ? path.join(assetsDir, file) : null;
        if (src && fs.existsSync(src)) {
          fs.copyFileSync(src, path.join(seedDir, file));
          await conn.query(
            'INSERT INTO vehicle_images (vehicle_id, image_url, is_primary) VALUES (?, ?, ?)',
            [vehicleId, `/uploads/seed/${file}`, i === 1 ? 1 : 0],
          );
        } else {
          console.warn(`[seed:vehicles] asset missing for ${v.slug} view ${i} — skipping image`);
        }
      }
    }
    console.log(`[seed:vehicles] done — inserted ${inserted}, skipped ${skipped} (total ${VEHICLES.length})`);
  } finally {
    conn.release();
  }
  return { inserted, skipped };
}

async function main(): Promise<void> {
  let conn;
  try {
    conn = await pool.getConnection();
    const rows: any = await conn.query('SHOW TABLES');
    const tables = Array.isArray(rows) ? rows.map((r: any) => Object.values(r)[0]) : [];
    if (tables.length === 0) {
      console.error('[seed:vehicles] no tables found — run migrations/initDb first, then retry.');
      process.exitCode = 1;
      return;
    }
    conn.release();
    conn = undefined;

    await seedVehicles();

    conn = await pool.getConnection();
    const vc: any = await conn.query('SELECT COUNT(*) as total FROM vehicles');
    const ic: any = await conn.query('SELECT COUNT(*) as total FROM vehicle_images');
    const noImg: any = await conn.query(
      'SELECT COUNT(*) as total FROM vehicles v LEFT JOIN vehicle_images vi ON vi.vehicle_id = v.id WHERE vi.id IS NULL',
    );
    const countOf = (r: any) => Number(Array.isArray(r) ? r[0]?.total : r?.total);
    console.log(`[seed:vehicles] summary — vehicles: ${countOf(vc)}, images: ${countOf(ic)}, vehicles without images: ${countOf(noImg)}`);
  } catch (e: any) {
    console.error('[seed:vehicles] failed:', e?.message || e);
    process.exitCode = 1;
  } finally {
    if (conn) conn.release();
    await pool.end().catch(() => {});
  }
}

if (require.main === module) {
  void main();
}
