import { Router, Request, Response, NextFunction } from 'express';
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

const MAX_FILE_SIZE = 5 * 1024 * 1024; // 5MB per file
const MAX_FILES = 10;

const ALLOWED_MIMETYPES = new Set([
  'image/jpeg',
  'image/png',
  'image/webp',
  'image/gif',
]);
const ALLOWED_EXTENSIONS = new Set(['.jpg', '.jpeg', '.png', '.webp', '.gif']);

const upload = multer({
  storage,
  limits: { fileSize: MAX_FILE_SIZE },
  fileFilter: (_req, file, cb) => {
    const ext = path.extname(file.originalname).toLowerCase();
    if (ALLOWED_MIMETYPES.has(file.mimetype) && ALLOWED_EXTENSIONS.has(ext)) {
      return cb(null, true);
    }
    return cb(
      new Error('File harus gambar (jpeg/png/webp/gif) dengan ukuran maksimal 5MB'),
    );
  },
});

// Accept both the legacy single-file field `file` (max 1) and the
// multi-file field `files` (max 10) on the same route.
const uploadBoth = upload.fields([
  { name: 'file', maxCount: 1 },
  { name: 'files', maxCount: MAX_FILES },
]);

function handleUploadError(err: unknown, res: Response): Response | void {
  if (err instanceof multer.MulterError) {
    if (err.code === 'LIMIT_FILE_SIZE') {
      return fail(res, 'File terlalu besar. Maksimal 5MB per file', 400);
    }
    if (err.code === 'LIMIT_UNEXPECTED_FILE') {
      return fail(res, `Maksimal ${MAX_FILES} file per upload`, 400);
    }
    return fail(res, err.message || 'Gagal mengupload file', 400);
  }
  if (err instanceof Error) {
    return fail(res, err.message || 'File harus gambar (jpeg/png/webp/gif)', 400);
  }
  return fail(res, 'Gagal mengupload file', 400);
}

function runUploadBoth(req: Request, res: Response, next: NextFunction) {
  uploadBoth(req, res, (err: unknown) => {
    if (err) {
      handleUploadError(err, res);
      return;
    }
    next();
  });
}

// POST /api/v1/upload — upload image(s) (admin only).
// Single-file contract (unchanged): multipart field `file` (1 file).
//   -> { url: '/uploads/<file>', filename: '<file>' }
// Multi-file: multipart field `files` (up to 10 files).
//   -> { urls: ['/uploads/<f1>', ...], filenames: [...], count: N }
// Images only (jpeg/png/webp/gif), 5MB per file. Static files served at /uploads.
router.post(
  '/',
  auth(),
  adminOnly,
  runUploadBoth,
  (req: Request, res: Response) => {
    const grouped = req.files as
      | Record<string, Express.Multer.File[]>
      | undefined;
    const multi: Express.Multer.File[] = grouped?.['files'] ?? [];
    const single: Express.Multer.File | undefined =
      grouped?.['file']?.[0] ?? req.file;

    if (multi.length > 0) {
      const filenames = multi.map((f) => f.filename);
      const urls = filenames.map((name) => `/uploads/${name}`);
      return ok(res, 'Upload berhasil', { urls, filenames, count: urls.length });
    }

    if (single) {
      const url = `/uploads/${single.filename}`;
      return ok(res, 'Upload berhasil', { url, filename: single.filename });
    }

    if (!single && multi.length === 0) return fail(res, 'File tidak ditemukan', 400);
    return fail(res, 'File tidak ditemukan', 400);
  },
);

export default router;
