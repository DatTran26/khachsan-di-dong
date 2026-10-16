import { Router } from 'express';
import { requireAuth, requireRole } from '../auth/auth.middleware.js';
import { listOpenStays } from './stays.service.js';

/** Danh sách phòng đang ở (FR-check-in-out-005) — lễ tân, quản lý. Nhận/trả nằm ở /api/rooms/:id/check-in|out. */
export const staysRouter = Router();
staysRouter.use(requireAuth(), requireRole('RECEPTIONIST', 'MANAGER'));

/**
 * GET `/` — mọi lượt đang `OPEN`, mới nhất trước.
 *
 * Không phân trang. Nhận/trả phòng không nằm ở router này.
 * `@param _req` không lọc. `@param res` trả `{ data: StayDto[] }`.
 */
staysRouter.get('/', async (_req, res) => {
  res.json({ data: await listOpenStays() });
});
