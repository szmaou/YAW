import jwt from 'jsonwebtoken';
import { env } from '../config/env';

export function sign(payload: object) {
  return jwt.sign(payload, env.jwt.secret as string, { expiresIn: env.jwt.expiresIn as string } as any);
}
export function verify<T = any>(token: string): T {
  return jwt.verify(token, env.jwt.secret) as T;
}
