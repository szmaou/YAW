import { Response } from 'express';

export function ok(res: Response, message: string, data: any = null, pagination?: any) {
  const body: any = { success: true, message, data };
  if (pagination) body.pagination = pagination;
  return res.json(body);
}

export function fail(res: Response, message: string, status = 400, errors: any = undefined) {
  return res.status(status).json({ success: false, message, ...(errors ? { errors } : {}) });
}
