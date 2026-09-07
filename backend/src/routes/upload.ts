import { Router, Request, Response } from 'express';
import multer from 'multer';
import path from 'path';
import fs from 'fs';
import { env } from '../config/env';
import { auth, adminOnly } from '../middlewares/auth';
import { ok, fail } from '../utils/response';

const router = Router();

const storage = multer.diskStorage({
  destination: (_req, _file, cb) => {
    const dir = path.resolve(env.uploadPath);
    fs.mkdirSync(dir, { recursive: true });
    cb(null, dir);
  },
  filename: (_req, file, cb) => {
    const ext = path.extname(file.originalname) || '';
    const name = `${Date.now()}-${Math.round(Math.random() * 1e9)}${ext}`;
    cb(null, name);
  },
});
const upload = multer({ storage });

// POST /api/v1/upload — upload a single file (admin only).
// Returns the static URL served at /uploads (static middleware is registered in app.ts).
router.post('/', auth(), adminOnly, upload.single('file'), (req: Request, res: Response) => {
  if (!req.file) return fail(res, 'File tidak ditemukan', 400);
  const url = `/uploads/${req.file.filename}`;
  return ok(res, 'Upload berhasil', { url, filename: req.file.filename });
});

export default router;
