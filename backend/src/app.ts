import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import rateLimit from 'express-rate-limit';
import path from 'path';
import fs from 'fs';
import { env } from './config/env';
import { initDb } from './config/initDb';
import { errorHandler, notFound } from './middlewares/errorHandler';
import authRoutes from './routes/auth';
import categoryRoutes from './routes/categories';
import vehicleRoutes from './routes/vehicles';
import favoriteRoutes from './routes/favorites';
import orderRoutes from './routes/orders';
import userRoutes from './routes/users';
import adminRoutes from './routes/admin';
import uploadRoutes from './routes/upload';

const app = express();

// MariaDB returns BIGINT columns (e.g. users.id) as JS BigInt, which JSON.stringify
// cannot serialize and would crash res.json (seen on POST /auth/login). Convert
// BigInt -> string globally so every route's res.json works without per-field hacks.
app.set('json replacer', (_key: string, value: any) =>
  typeof value === 'bigint' ? value.toString() : value,
);

// Security & middleware
app.use(helmet({ crossOriginResourcePolicy: false }));
app.use(cors({ origin: env.corsOrigin === '*' ? true : env.corsOrigin, credentials: true }));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));
app.use(morgan(env.nodeEnv === 'production' ? 'combined' : 'dev'));
app.use(rateLimit({ windowMs: 15 * 60 * 1000, max: 300, standardHeaders: true, legacyHeaders: false }));

// Static uploads
const uploadDir = path.resolve(env.uploadPath);
if (!fs.existsSync(uploadDir)) fs.mkdirSync(uploadDir, { recursive: true });
app.use('/uploads', express.static(uploadDir));

// Health
app.get('/api/health', (_req, res) => res.json({ success: true, message: 'YAW API running', version: '1.0.0' }));
app.get('/health', (_req, res) => res.json({ success: true, message: 'OK' }));

// API v1
app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/categories', categoryRoutes);
app.use('/api/v1/vehicles', vehicleRoutes);
app.use('/api/v1/favorites', favoriteRoutes);
app.use('/api/v1/orders', orderRoutes);
app.use('/api/v1/users', userRoutes);
app.use('/api/v1/admin', adminRoutes);
app.use('/api/v1/upload', uploadRoutes);

app.use(notFound);
app.use(errorHandler);

const port = env.port;

async function start() {
  try {
    console.log(`[YAW] Initializing database ${env.db.name} @ ${env.db.host}:${env.db.port} ...`);
    await initDb();
    console.log('[YAW] Database ready');
  } catch (e: any) {
    console.error('[YAW] initDb failed (API tetap jalan, cek pool):', e?.message || e);
    console.error(
      `[YAW] DB target: ${env.db.host}:${env.db.port}/${env.db.name} as ${env.db.user}. ` +
      'Start MariaDB first (e.g. `sudo systemctl start mariadb`), or run `docker compose up -d`, ' +
      'and confirm the port matches DB_PORT in ./backend/.env (default MariaDB port is 3306).'
    );
  }
  app.listen(port, () => {
    console.log(`[YAW] API listening on http://localhost:${port}`);
    console.log(`[YAW] Health: http://localhost:${port}/api/health`);
    console.log(`[YAW] DB: ${env.db.host}:${env.db.port}/${env.db.name} as ${env.db.user}`);
  });
}

if (require.main === module) {
  start();
}

export default app;
