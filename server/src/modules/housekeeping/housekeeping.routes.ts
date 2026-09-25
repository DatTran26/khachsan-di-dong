import { HousekeepingTaskStatus } from '@prisma/client';
import { Router, type Request, type Response } from 'express';
import { z } from 'zod';
import { MSG } from '../../lib/messages.js';
import { authOf, requireAuth, requireRole } from '../auth/auth.middleware.js';
import {
  acceptTask,
  completeTask,
  confirmTask,
  listTasks,
  reassignTask,
  rejectTask,
  returnTask,
} from './housekeeping.service.js';

/**
 * Việc dọn phòng. Xem: quản lý + nhân viên (FR-010). Nhận / từ chối / báo xong: nhân viên được giao.
 * Xác nhận / trả lại / phân công lại: CHỈ quản lý (BR-housekeeping-001, NFR-004). Ghi luôn kèm `version` của việc.
 * Việc được tạo bởi hệ thống khi trả phòng — không có API tạo tay (spec housekeeping không có FR tạo tay).
 */
export const housekeepingRouter = Router();
housekeepingRouter.use(requireAuth());

const idParams = z.object({ id: z.string().uuid() });
const versionBody = z.object({ version: z.number().int().positive() });

housekeepingRouter.get('/tasks', requireRole('MANAGER', 'STAFF'), async (req, res) => {
  const query = z
    .object({
      status: z.nativeEnum(HousekeepingTaskStatus).optional(),
      assigneeId: z.string().uuid().optional(),
      roomId: z.string().uuid().optional(),
      mine: z.enum(['true', 'false']).transform((v) => v === 'true').optional(),
      overdue: z.enum(['true', 'false']).transform((v) => v === 'true').optional(),
    })
    .parse(req.query);
  const { mine, ...filter } = query;
  res.json({ data: await listTasks(mine ? { ...filter, assigneeId: authOf(res).user.id } : filter) });
});

/** Thao tác chỉ cần `{ version }` trong body. */
const versionOnly = (action: typeof acceptTask) => async (req: Request, res: Response) => {
  const { id } = idParams.parse(req.params);
  res.json({ data: await action(authOf(res).user, id, versionBody.parse(req.body).version) });
};

housekeepingRouter.post('/tasks/:id/accept', requireRole('STAFF'), versionOnly(acceptTask));
housekeepingRouter.post('/tasks/:id/reject', requireRole('STAFF'), versionOnly(rejectTask));
housekeepingRouter.post('/tasks/:id/complete', requireRole('STAFF'), versionOnly(completeTask));
housekeepingRouter.post('/tasks/:id/confirm', requireRole('MANAGER'), versionOnly(confirmTask));

housekeepingRouter.post('/tasks/:id/return', requireRole('MANAGER'), async (req, res) => {
  const { id } = idParams.parse(req.params);
  const { version, note } = versionBody
    .extend({ note: z.string({ required_error: MSG.returnNoteRequired }).trim().min(1, MSG.returnNoteRequired).max(500) })
    .parse(req.body);
  res.json({ data: await returnTask(authOf(res).user, id, version, note) });
});

housekeepingRouter.post('/tasks/:id/reassign', requireRole('MANAGER'), async (req, res) => {
  const { id } = idParams.parse(req.params);
  const { version, assigneeId } = versionBody.extend({ assigneeId: z.string().uuid() }).parse(req.body);
  res.json({ data: await reassignTask(authOf(res).user, id, version, assigneeId) });
});
