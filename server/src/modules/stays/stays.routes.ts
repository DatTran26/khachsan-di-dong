import { Router } from 'express';
import { requireAuth, requireRole } from '../auth/auth.middleware.js';
import { listOpenStays } from './stays.service.js';

/** Danh sách phòng đang ở (FR-check-in-out-005) — lễ tân, quản lý. Nhận/trả nằm ở /api/rooms/:id/check-in|out. */
export const staysRouter = Router();
staysRouter.use(requireAuth(), requireRole('RECEPTIONIST', 'MANAGER'));

staysRouter.get('/', async (_req, res) => {
  res.json({ data: await listOpenStays() });
});
