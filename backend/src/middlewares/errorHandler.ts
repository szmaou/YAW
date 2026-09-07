import { Request, Response, NextFunction } from 'express';
import { fail } from '../utils/response';

export function errorHandler(err: any, _req: Request, res: Response, _next: NextFunction) {
  console.error('[ERROR]', err);
  if (res.headersSent) return;
  // Map pool / connection failures to 503 with actionable hint
  const msg: string = err?.message || '';
  const code: number | undefined = err?.errno ?? err?.code;
  const isPoolTimeout =
    msg.includes('pool failed to retrieve') ||
    msg.includes('pool connections') ||
    err?.no === 45028 ||
    code === 45028;
  const isConnRefused =
    msg.includes('ECONNREFUSED') || msg.includes('connect ECONNREFUSED') || msg.includes('Connection refused');

  if (isPoolTimeout || isConnRefused) {
    return fail(
      res,
      'Database tidak terhubung. Cek: (1) MariaDB jalan? `docker ps` / `systemctl status mariadb`  (2) Port benar? DB_PORT=3310 → `ss -tlnp | grep 3310` atau `lsof -i :3310` — kalau pakai MariaDB native ganti DB_PORT=3306  (3) `mysql -h 127.0.0.1 -P 3310 -u yaw_user -pyaw123 -e "SELECT 1"`  (4) DB `yaw` & user sudah dibuat? jalankan `database/migrations/001_init.sql`',
      503,
    );
  }
  const status = err.status || 500;
  const message = err.message || 'Internal server error';
  return fail(res, message, status);
}

export function notFound(_req: Request, res: Response) {
  return fail(res, 'Endpoint tidak ditemukan', 404);
}
