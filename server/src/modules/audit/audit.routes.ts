import { AuditEntityType } from '@prisma/client';
import { Router } from 'express';
import { z } from 'zod';
import { ForbiddenError } from '../../lib/errors.js';
import { MSG } from '../../lib/messages.js';
import { authOf, requireAuth } from '../auth/auth.middleware.js';
import { MAX_PAGE_SIZE, listAuditLogs } from './audit.service.js';

/** Nhật ký — CHỈ quản lý xem, kiểm ở máy chủ (FR-009, BR-003). Không có route sửa/xóa (FR-005). */
export const auditRouter = Router();
/**
 * Chặn mọi method: chỉ `MANAGER`. Lễ tân và nhân viên nhận 403 với câu `MSG.auditForbidden`,
 * không phải câu forbidden chung. Không có nhánh sửa/xóa.
 */
auditRouter.use(requireAuth(), (_req, res, next) => {
  if (authOf(res).user.role !== 'MANAGER') throw new ForbiddenError('FORBIDDEN', MSG.auditForbidden);
  next();
});

const querySchema = z.object({
  roomId: z.string().uuid().optional(),
  from: z.coerce.date().optional(),
  to: z.coerce.date().optional(),
  actorId: z.string().uuid().optional(),
  actorRole: z.enum(['MANAGER', 'RECEPTIONIST', 'STAFF', 'SYSTEM']).optional(),
  action: z.string().max(60).optional(),
  entityType: z.nativeEnum(AuditEntityType).optional(),
  field: z.string().max(30).optional(),
  cursor: z.string().max(200).optional(),
  limit: z.coerce.number().int().min(1).max(MAX_PAGE_SIZE).optional(),
});

/**
 * GET `/`. Query đã parse thành filter. Body JSON là đúng object service trả
 * (`data`, `nextCursor`, `message?`), không bọc thêm một lần `data`.
 */
auditRouter.get('/', async (req, res) => {
  res.json(await listAuditLogs(querySchema.parse(req.query)));
});
