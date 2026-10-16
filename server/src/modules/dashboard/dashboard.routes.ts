import { Router } from 'express';
import { requireAuth, requireRole } from '../auth/auth.middleware.js';
import { getSummary } from './dashboard.service.js';

/** Chỉ số dashboard tại thời điểm xem — quản lý (chính) và lễ tân (tham khảo), theo ma trận auth-roles 6.2. */
export const dashboardRouter = Router();
dashboardRouter.use(requireAuth(), requireRole('MANAGER', 'RECEPTIONIST'));

/**
 * GET `/summary` — chỉ số tại thời điểm gọi.
 *
 * Quyền đã chặn ở router: quản lý và lễ tân. Nhân viên không gọi được (403).
 * Không ghi nhật ký. `@param _req` không đọc query. `@param res` trả `{ data: summary }`.
 */
dashboardRouter.get('/summary', async (_req, res) => {
  res.json({ data: await getSummary() });
});
