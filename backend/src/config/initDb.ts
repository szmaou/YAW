import fs from 'fs';
import path from 'path';
import mariadb, { Connection, PoolConnection } from 'mariadb';
import { env } from './env';
import { pool } from './db';
import { seedDefaults } from '../seeds/seed';

function resolveHost(h: string) {
  return h === 'localhost' ? '127.0.0.1' : h;
}

/**
 * Ensure `yaw` database + user + schema exist.
 * Called once at startup before first request.
 * - Works when MariaDB already has `yaw` (no-op).
 * - When `yaw` missing, creates DB via a no-database connection, then runs migrations.
 * - Falls back to root/root123 for flutter_auth_db image so yaw_user can be created
 *   even if env only has yaw_user creds.
 */
export async function initDb(): Promise<void> {
  const target = `${resolveHost(env.db.host)}:${env.db.port}/${env.db.name} as ${env.db.user}`;
  console.log(`[initDb] ensuring database — target: ${target}`);
  // 1) Ensure database exists — connect WITHOUT database param
  const baseOpts = {
    host: resolveHost(env.db.host),
    port: env.db.port,
    connectTimeout: 5000,
  } as const;

  const tryCreateDb = async (user: string, password: string) => {
    let conn: Connection | undefined;
    try {
      conn = await mariadb.createConnection({ ...baseOpts, user, password });
      await conn.query(`CREATE DATABASE IF NOT EXISTS \`${env.db.name}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci`);
      // ensure yaw_user exists when we are root
      if (user === 'root') {
        await conn.query(`CREATE USER IF NOT EXISTS '${env.db.user}'@'%' IDENTIFIED BY '${env.db.password}'`);
        await conn.query(`GRANT ALL PRIVILEGES ON \`${env.db.name}\`.* TO '${env.db.user}'@'%'`);
        await conn.query('FLUSH PRIVILEGES');
      }
      return true;
    } catch (e: any) {
      // ER_ACCESS_DENIED / can't create as yaw_user is expected if DB already exists — ignore
      if (String(e.message).includes('already exists')) return true;
      return false;
    } finally {
      if (conn) try { await conn.end(); } catch {}
    }
  };

  // Try yaw_user first (works if DB already exists / user already created)
  let created = await tryCreateDb(env.db.user, env.db.password);
  if (!created) {
    // Fallback to well-known root for flutter_auth_db image
    const rootCandidates = [
      { user: 'root', password: 'root123' },
      { user: 'root', password: '' },
      { user: 'root', password: process.env.MARIADB_ROOT_PASSWORD || '' },
    ];
    for (const c of rootCandidates) {
      if (!c.password && c.user === 'root') continue; // skip empty unless explicitly set
      // eslint-disable-next-line no-await-in-loop
      if (await tryCreateDb(c.user, c.password)) { created = true; break; }
    }
  }

  // 2) Fail-fast connectivity check. If the yaw_user pool cannot reach the DB,
  //    skip migrations + seed entirely. Without this, the loop below calls
  //    pool.getConnection() per statement and can hang ~acquireTimeout (10s) on
  //    each before failing, blocking app.listen for minutes at startup.
  try {
    const conn = await Promise.race([
      pool.getConnection(),
      new Promise<never>((_, reject) =>
        setTimeout(() => reject(new Error('connect timeout after 3000ms')), 3000),
      ),
    ]);
    conn.release();
  } catch (e: any) {
    console.error('[initDb] skip migrations - pool unreachable', e?.message || e);
    console.error(
      '[initDb] HINT: is MariaDB running and reachable on the configured port? ' +
      'Start it (e.g. `sudo systemctl start mariadb`) or bring up Docker ' +
      '(`docker compose up -d`) and ensure the port matches DB_PORT in .env.',
    );
    return; // skip migrations + seed; API still starts
  }

  // 3) Run migrations via pool (now DB should exist)
  const migPath = path.resolve(process.cwd(), 'database/migrations/001_init.sql');
  const fallbackMigPath = path.resolve(process.cwd(), '../database/migrations/001_init.sql');
  const finalPath = fs.existsSync(migPath) ? migPath : fs.existsSync(fallbackMigPath) ? fallbackMigPath : null;

  if (!finalPath) {
    console.warn('[initDb] migration file not found, skipping:', migPath);
    return;
  }

  let sql = fs.readFileSync(finalPath, 'utf8');
  // strip CREATE DATABASE / USE yaw — we already handled it
  sql = sql.replace(/CREATE DATABASE[^;]*;/gi, '-- skip CREATE DATABASE');
  sql = sql.replace(/USE\s+yaw\s*;/gi, '-- skip USE');

  // naive split by ; keeping structure — safe for this migration (no ; inside strings)
  const statements = sql
    .split(';')
    .map((s) => s.trim())
    .filter((s) => s && !s.startsWith('-- skip') && s.length > 5);

  for (const stmt of statements) {
    let conn: PoolConnection | undefined;
    try {
      conn = await pool.getConnection();
      await conn.query(stmt);
    } catch (e: any) {
      const msg = String(e.message || '');
      if (msg.includes('already exists') || msg.includes('Duplicate')) {
        // idempotent
      } else {
        console.error('[initDb] migration statement failed:', msg.slice(0, 200), '\nSQL:', stmt.slice(0, 200));
      }
    } finally {
      if (conn) conn.release();
    }
  }

  // 4) Verify
  try {
    const conn = await pool.getConnection();
    try {
      const rows: any = await conn.query('SHOW TABLES');
      const tables = Array.isArray(rows) ? rows.map((r: any) => Object.values(r)[0]) : [];
      console.log(`[initDb] tables in ${env.db.name}:`, tables.join(', ') || '(empty)');
    } finally {
      conn.release();
    }
   } catch (e: any) {
     console.error(
       `[initDb] verify failed — could not retrieve a pooled connection to ` +
       `${resolveHost(env.db.host)}:${env.db.port}/${env.db.name} as ${env.db.user}:`,
       e.message,
     );
     console.error(
       '[initDb] HINT: is MariaDB running and reachable on the configured port? ' +
       'Start it (e.g. `sudo systemctl start mariadb`) or bring up Docker ' +
       '(`docker compose up -d`) and ensure the port matches DB_PORT in .env.',
     );
     throw e;
   }

  // 5) Seed default admin/demo users + categories (idempotent)
  //    Ensures a real admin exists so auth middleware + GET /users works,
  //    instead of relying on a mock token fallback.
  try {
    await seedDefaults();
  } catch (e: any) {
    console.error('[initDb] seeding skipped/failed (API continues):', e?.message || e);
  }
 }
