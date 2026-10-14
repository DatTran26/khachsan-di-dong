import type { ErrorRequestHandler, RequestHandler } from 'express';
import { ZodError } from 'zod';
import { AppError } from '../lib/errors.js';
import { MSG } from '../lib/messages.js';

/**
 * Bắt route không khớp. Gắn sau mọi router trong `createApp`.
 *
 * @param req Dùng `method` và `path` để nhắc đường dẫn client đã gọi. Không log body.
 * @param res Trả 404 JSON cùng dạng `{ error: { code, message } }` với lỗi nghiệp vụ, không có `details`.
 */
export const notFoundHandler: RequestHandler = (req, res) => {
  res.status(404).json({ error: { code: 'NOT_FOUND', message: `Không có đường dẫn ${req.method} ${req.path}` } });
};

/**
 * Error handler cuối cùng (4 tham số). Express chỉ nhảy vào đây khi `next(err)` hoặc async handler ném.
 *
 * `AppError` giữ status/code/message/details. `ZodError` thành 400 `VALIDATION_ERROR`
 * kèm `flatten()` — không lộ stack. Mọi lỗi khác thành 500 `INTERNAL_ERROR` với câu
 * `MSG.notCompleted` và `console.error` cả object lỗi (có thể chứa dữ liệu nội bộ; không trả ra client).
 * Không phân biệt lỗi ghi nhật ký: transaction đã rollback trước khi tới đây (E-audit-log-005).
 * @param err Lỗi ném từ route hoặc middleware.
 * @param _req Không đọc. Không echo request body.
 * @param res Response còn chưa gửi. Hàm luôn kết thúc bằng `res.status().json()`.
 * @param _next Không gọi tiếp — đây là handler cuối.
 */
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
