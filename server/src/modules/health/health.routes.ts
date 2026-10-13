import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';

/** Router `/api/health`. Không yêu cầu đăng nhập — dùng cho giám sát và script dev. */
export const healthRouter = Router();

/**
 * GET `/` — kiểm tra tiến trình còn sống và CSDL còn trả lời `SELECT 1`.
 *
 * Thành công: 200 `{ status: 'ok', db: 'up', time }`. Lỗi Prisma: 503
 * `{ status: 'error', db: 'down', time }` chứ không phải 500, để giám sát tách
 * sự cố CSDL khỏi lỗi code. Không ghi nhật ký, không lộ chuỗi kết nối.
 * @param _req Không đọc query.
 * @param res Luôn gửi JSON, không gọi `next`.
 */
healthRouter.get('/', async (_req, res) => {
  const time = new Date().toISOString();
  try {
    await prisma.$queryRaw`SELECT 1`;
    res.json({ status: 'ok', db: 'up', time });
  } catch {
    res.status(503).json({ status: 'error', db: 'down', time });
  }
});
