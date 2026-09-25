import bcrypt from 'bcryptjs';
import { pool } from '../config/db';

/**
 * Shared, idempotent default-seeding routine.
 * - Inserts a default admin + demo user when the `users` table is empty.
 * - Inserts default vehicle_categories when the table is empty.
 * Passwords are bcrypt-hashed at RUNTIME (10 rounds) — never hardcoded.
 *
 * Reused by initDb.ts on startup, and runnable standalone via `npm run seed`.
 */
const ADMIN_EMAIL = 'admin@yaw.id';
const ADMIN_PASSWORD = 'admin123';
const DEMO_EMAIL = 'user@yaw.id';
const DEMO_PASSWORD = 'user123';

const DefaultCategories = [
  { name: 'Sports', slug: 'sports', description: 'High-performance sports vehicles' },
  { name: 'SUV', slug: 'suv', description: 'Sport utility vehicles' },
  { name: 'Electric', slug: 'electric', description: 'Electric vehicles' },
];

export async function seedDefaults(): Promise<void> {
  let conn;
  try {
    conn = await pool.getConnection();

    // --- Users: only seed when table is empty (idempotent) ---
    const userRow: any = await conn.query('SELECT COUNT(*) as total FROM users');
    const usersCount = Number((Array.isArray(userRow) ? userRow[0]?.total : userRow?.total) || 0);
    if (usersCount === 0) {
      const adminHash = await bcrypt.hash(ADMIN_PASSWORD, 10);
      const demoHash = await bcrypt.hash(DEMO_PASSWORD, 10);
      // single multi-row insert for both default accounts
      await conn.query(
        'INSERT INTO users (name, email, password, phone, role) VALUES (?, ?, ?, ?, ?), (?, ?, ?, ?, ?)',
        [
          'YAW Admin', ADMIN_EMAIL, adminHash, null, 'admin',
          'YAW User', DEMO_EMAIL, demoHash, null, 'user',
        ],
      );
      console.log('[seed] created admin (admin@yaw.id / admin123) and demo user (user@yaw.id / user123)');
    } else {
      console.log(`[seed] users already present (${usersCount}), skipping user seeding`);
    }

    // --- Vehicle categories: only seed when table is empty (idempotent) ---
    const catRow: any = await conn.query('SELECT COUNT(*) as total FROM vehicle_categories');
    const catCount = Number((Array.isArray(catRow) ? catRow[0]?.total : catRow?.total) || 0);
    if (catCount === 0) {
      for (const c of DefaultCategories) {
        await conn.query(
          'INSERT INTO vehicle_categories (name, slug, description) VALUES (?, ?, ?)',
          [c.name, c.slug, c.description],
        );
      }
      console.log(`[seed] created ${DefaultCategories.length} vehicle categories`);
    } else {
      console.log(`[seed] categories already present (${catCount}), skipping category seeding`);
    }
  } finally {
    if (conn) conn.release();
  }
}

async function main(): Promise<void> {
  let conn;
  try {
    // Guard: confirm tables exist before seeding.
    conn = await pool.getConnection();
    const rows: any = await conn.query('SHOW TABLES');
    const tables = Array.isArray(rows) ? rows.map((r: any) => Object.values(r)[0]) : [];
    if (tables.length === 0) {
      console.error('[seed] no tables found — run migrations/initDb first, then retry.');
      process.exitCode = 1;
      return;
    }
    conn.release();
    conn = undefined;

    await seedDefaults();

    // Report final counts.
    conn = await pool.getConnection();
    const u: any = await conn.query('SELECT COUNT(*) as total FROM users');
    const c: any = await conn.query('SELECT COUNT(*) as total FROM vehicle_categories');
    console.log(`[seed] summary — users: ${Number(u.total)}, categories: ${Number(c.total)}`);
  } catch (e: any) {
    console.error('[seed] failed:', e?.message || e);
    process.exitCode = 1;
  } finally {
    if (conn) conn.release();
  }
}

if (require.main === module) {
  void main();
}
