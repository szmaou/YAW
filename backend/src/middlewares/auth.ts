import { Request, Response, NextFunction } from 'express';
import { verify } from '../utils/jwt';
import { fail } from '../utils/response';

export interface AuthUser { id: string; email: string; role: string; name: string; }
export interface AuthRequest extends Request { user?: AuthUser; }

export function auth(required = true) {
  return (req: AuthRequest, res: Response, next: NextFunction) => {
    const header = req.headers.authorization;
    if (!header || !header.startsWith('Bearer ')) {
      if (!required) return next();
      return fail(res, 'Unauthorized', 401);
    }
    try {
      const payload = verify<AuthUser>(header.slice(7));
      req.user = payload;
      next();
    } catch {
      return fail(res, 'Token tidak valid atau kadaluarsa', 401);
    }
  };
}

export function adminOnly(req: AuthRequest, res: Response, next: NextFunction) {
  if (req.user?.role !== 'admin') return fail(res, 'Forbidden — admin only', 403);
  next();
}
