import { Router } from 'express';
import bcrypt from 'bcryptjs';
import { z } from 'zod';
import { queryOne, execute, query } from '../config/db';
import { sign } from '../utils/jwt';
import { ok, fail } from '../utils/response';
import { auth, AuthRequest } from '../middlewares/auth';

const router = Router();

const registerSchema = z.object({
  name: z.string().min(2).max(100),
  email: z.string().email(),
  password: z.string().min(6).max(100),
  phone: z.string().optional(),
});

router.post('/register', async (req, res) => {
  const parsed = registerSchema.safeParse(req.body);
  if (!parsed.success) return fail(res, 'Validasi gagal', 422, parsed.error.flatten());
  const { name, email, password, phone } = parsed.data;
  const exists = await queryOne('SELECT id FROM users WHERE email=?', [email]);
  if (exists) return fail(res, 'Email sudah terdaftar', 409);
  const hash = await bcrypt.hash(password, 10);
  const result: any = await execute(
    'INSERT INTO users (name,email,password,phone,role) VALUES (?,?,?,?,?)',
    [name, email, hash, phone || null, 'user']
  );
  const id = result.insertId;
  const user = await queryOne('SELECT id,name,email,phone,role,avatar,created_at FROM users WHERE id=?', [id]);
  const token = sign({ id: String(id), email, role: 'user', name });
  return ok(res, 'Registrasi berhasil', { user, token });
});

router.post('/login', async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) return fail(res, 'Email dan password wajib', 422);
  const user: any = await queryOne('SELECT * FROM users WHERE email=?', [email]);
  if (!user) return fail(res, 'Email atau password salah', 401);
  const valid = await bcrypt.compare(password, user.password);
  if (!valid) return fail(res, 'Email atau password salah', 401);
  const token = sign({ id: String(user.id), email: user.email, role: user.role, name: user.name });
  const safe = { id: user.id, name: user.name, email: user.email, phone: user.phone, role: user.role, avatar: user.avatar, created_at: user.created_at };
  return ok(res, 'Login berhasil', { user: safe, token });
});

router.post('/logout', auth(false), async (_req, res) => {
  // Stateless JWT — client just discards token
  return ok(res, 'Logout berhasil', null);
});

router.get('/me', auth(), async (req: AuthRequest, res) => {
  const user = await queryOne('SELECT id,name,email,phone,role,avatar,created_at FROM users WHERE id=?', [req.user!.id]);
  if (!user) return fail(res, 'User tidak ditemukan', 404);
  return ok(res, 'Profile', user);
});

export default router;
