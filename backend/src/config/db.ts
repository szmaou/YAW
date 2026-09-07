import mariadb from 'mariadb';
import { env } from './env';

function resolveHost(h: string) {
  // 'localhost' on some Node/mariadb builds tries unix socket — force TCP
  if (h === 'localhost') return '127.0.0.1';
  return h;
}

export const pool = mariadb.createPool({
  host: resolveHost(env.db.host),
  port: env.db.port,
  user: env.db.user,
  password: env.db.password,
  database: env.db.name,
  connectionLimit: 10,
  connectTimeout: 10000,
  // time to wait for a free connection from pool before failing
  // mariadb v3 uses acquireTimeout
  // @ts-ignore - mariadb options
  acquireTimeout: 10000,
  // @ts-ignore
  allowPublicKeyRetrieval: true,
  // keep idle connections alive across dev restarts
  idleTimeout: 60000,
});

// Log pool errors instead of silent timeout
(pool as any).on('error', (err: any) => {
  console.error('[DB pool error]', err?.message || err);
});

export async function query<T = any>(sql: string, params?: any[]): Promise<T[]> {
  let conn;
  try {
    conn = await pool.getConnection();
    const rows = await conn.query(sql, params);
    // mariadb returns extra meta property — strip it
    return Array.isArray(rows) ? rows as T[] : [];
  } finally {
    if (conn) conn.release();
  }
}

export async function queryOne<T = any>(sql: string, params?: any[]): Promise<T | null> {
  const rows = await query<T>(sql, params);
  return rows[0] ?? null;
}

export async function execute(sql: string, params?: any[]) {
  let conn;
  try {
    conn = await pool.getConnection();
    const res = await conn.query(sql, params);
    return res;
  } finally {
    if (conn) conn.release();
  }
}
