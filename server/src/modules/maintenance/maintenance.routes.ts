import { MaintenanceTaskStatus } from '@prisma/client';
import { Router } from 'express';
import { z } from 'zod';
import { authOf, requireAuth, requireRole } from '../auth/auth.middleware.js';
import { assignTask, cancelTask, claimTask, completeTask, listTasks, reportIssue } from './maintenance.service.js';

/**
 * Báo hỏng & bảo trì. Báo hỏng + xem: mọi vai trò (FR-001/004). Nhận / hoàn tất: nhân viên.
 * Hủy: người báo (việc chờ nhận) hoặc quản lý. Chỉ định người xử lý: quản lý, lễ tân (FR-009).
 */
export const maintenanceRouter = Router();
maintenanceRouter.use(requireAuth());

const idParams = z.object({ id: z.string().uuid() });
const versionBody = z.object({ version: z.number().int().positive() });

/** GET `/tasks` — mọi vai trò đã đăng nhập. Query lọc status, phòng, assignee. */
maintenanceRouter.get('/tasks', async (req, res) => {
  const filter = z
    .object({
      status: z.nativeEnum(MaintenanceTaskStatus).optional(),
      roomId: z.string().uuid().optional(),
      assigneeId: z.string().uuid().optional(),
    })
    .parse(req.query);
  res.json({ data: await listTasks(filter) });
});

/** POST `/tasks` — báo hỏng, mọi vai trò. 201. `description` 1–500 ký tự. */
maintenanceRouter.post('/tasks', async (req, res) => {
  const input = z
    .object({
      roomId: z.string().uuid(),
      description: z.string().trim().min(1, 'Vui lòng mô tả hỏng hóc.').max(500),
      location: z.string().trim().max(100).optional(),
    })
    .parse(req.body);
  res.status(201).json({ data: await reportIssue(authOf(res).user, input) });
});

/** POST `.../claim` — chỉ nhân viên. Body `{ version }`. */
maintenanceRouter.post('/tasks/:id/claim', requireRole('STAFF'), async (req, res) => {
  const { id } = idParams.parse(req.params);
  res.json({ data: await claimTask(authOf(res).user, id, versionBody.parse(req.body).version) });
});

/** POST `.../complete` — nhân viên đang là assignee. Body `{ version }`. */
maintenanceRouter.post('/tasks/:id/complete', requireRole('STAFF'), async (req, res) => {
  const { id } = idParams.parse(req.params);
  res.json({ data: await completeTask(authOf(res).user, id, versionBody.parse(req.body).version) });
});

/**
 * POST `.../cancel` — không chặn role ở route. Service cho quản lý, hoặc người báo khi việc còn `OPEN`.
 * `reason` tùy chọn, tối đa 200. Chuỗi rỗng thành `undefined`.
 */
maintenanceRouter.post('/tasks/:id/cancel', async (req, res) => {
  const { id } = idParams.parse(req.params);
  const { version, reason } = versionBody.extend({ reason: z.string().trim().max(200).optional() }).parse(req.body);
  res.json({ data: await cancelTask(authOf(res).user, id, version, reason || undefined) });
});

/** POST `.../assign` — quản lý hoặc lễ tân. Body `version` + `assigneeId`. */
maintenanceRouter.post('/tasks/:id/assign', requireRole('MANAGER', 'RECEPTIONIST'), async (req, res) => {
  const { id } = idParams.parse(req.params);
  const { version, assigneeId } = versionBody.extend({ assigneeId: z.string().uuid() }).parse(req.body);
  res.json({ data: await assignTask(authOf(res).user, id, version, assigneeId) });
});
