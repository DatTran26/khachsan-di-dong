import type { ErrorRequestHandler, RequestHandler } from 'express';
import { ZodError } from 'zod';
import { AppError } from '../lib/errors.js';
import { MSG } from '../lib/messages.js';

export const notFoundHandler: RequestHandler = (req, res) => {
  res.status(404).json({ error: { code: 'NOT_FOUND', message: `Không có đường dẫn ${req.method} ${req.path}` } });
};

export const errorHandler: ErrorRequestHandler = (err, _req, res, _next) => {
  if (err instanceof AppError) {
    res.status(err.status).json({ error: { code: err.code, message: err.message, details: err.details } });
    return;
  }
  if (err instanceof ZodError) {
    res.status(400).json({
      error: { code: 'VALIDATION_ERROR', message: 'Dữ liệu gửi lên không hợp lệ.', details: err.flatten() },
    });
    return;
  }
  // Lỗi bất ngờ (kể cả ghi nhật ký thất bại) → transaction đã rollback, thao tác KHÔNG được lưu (E-audit-log-005).
  console.error(err);
  res.status(500).json({ error: { code: 'INTERNAL_ERROR', message: MSG.notCompleted } });
};
