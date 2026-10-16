import type { AuditEntityType, AuditLog, AuditLogChange, Prisma, User } from '@prisma/client';
import { AppError } from '../../lib/errors.js';
import { MSG } from '../../lib/messages.js';
import { prisma } from '../../lib/prisma.js';
import { ACTION_LABELS, ROLE_LABELS, fieldLabel, formatTime, valueLabel } from './audit.labels.js';

/**
 * Xem nhật ký (audit-log FR-007…011, auth-roles FR-014) — CHỈ đọc, không có sửa/xóa (FR-005).
 * Mới nhất trước, tải theo phần bằng con trỏ (NFR-005).
 * audit-log OQ-1 chưa chốt → mặc định 50 dòng/lần (client đổi được, tối đa 200), không giới hạn khung thời gian.
 */
export const DEFAULT_PAGE_SIZE = 50;
export const MAX_PAGE_SIZE = 200;

export interface AuditFilter {
  roomId?: string;
  from?: Date;
  to?: Date;
  actorId?: string;
  actorRole?: string; // MANAGER | RECEPTIONIST | STAFF | SYSTEM
  action?: string;
  entityType?: AuditEntityType;
  field?: string; // trục: occupancy | cleaning | service (hoặc trường khác)
  cursor?: string;
  limit?: number;
}

type LogWithRefs = AuditLog & { changes: AuditLogChange[]; actor: Pick<User, 'id' | 'fullName'> | null };

/**
 * Con trỏ trang: `occurredAt` ISO và id, base64url, để sort ổn định khi nhiều dòng cùng thời điểm.
 * @param log Dòng cuối của trang vừa trả.
 * @returns Chuỗi không chứa dấu `+` `/` (base64url).
 */
function encodeCursor(log: AuditLog) {
  return Buffer.from(`${log.occurredAt.toISOString()}|${log.id}`).toString('base64url');
}

/**
 * Giải con trỏ. Chuỗi không có `|`, thời điểm không parse được, hoặc thiếu id → 400 `INVALID_CURSOR`
 * với câu `MSG.invalidState` (không có câu riêng cho con trỏ hỏng).
 * @param cursor Giá trị query client gửi lại.
 * @returns Mốc exclusive cho trang sau (nhỏ hơn mốc này).
 */
function decodeCursor(cursor: string) {
  const [time, id] = Buffer.from(cursor, 'base64url').toString().split('|');
  const occurredAt = new Date(time);
  if (!id || Number.isNaN(occurredAt.getTime())) throw new AppError(400, 'INVALID_CURSOR', MSG.invalidState);
  return { occurredAt, id };
}

/**
 * Một dòng nhật ký đủ ai, khi, hành động, trường, trước → sau, kèm câu `line` theo mẫu 7.3.
 *
 * Người thực hiện SYSTEM thành tên "hệ thống" và `actor: null`. Không có user
 * (actorId trỏ tài khoản đã mất) thì tên "tài khoản đã xóa". `changes` sắp theo `position`.
 * @param log Bản ghi kèm `changes` và `actor` (chỉ id, họ tên).
 * @returns DTO hiển thị. Không có route sửa dòng này.
 */
export function toAuditEntryDto(log: LogWithRefs) {
  const isSystem = log.actorRole === 'SYSTEM';
  const actorName = isSystem ? 'hệ thống' : (log.actor?.fullName ?? 'tài khoản đã xóa');
  const roleLabel = ROLE_LABELS[log.actorRole] ?? log.actorRole;
  const changes = [...log.changes]
    .sort((a, b) => a.position - b.position)
    .map((change) => {
      const entityType = change.entityType ?? log.entityType;
      return {
        entityType,
        entityId: change.entityId ?? log.entityId,
        entityLabel: change.entityLabel ?? log.entityLabel,
        field: change.field,
        fieldLabel: fieldLabel(entityType, change.field),
        before: change.before,
        after: change.after,
        beforeLabel: valueLabel(entityType, change.field, change.before),
        afterLabel: valueLabel(entityType, change.field, change.after),
      };
    });
  const actionLabel = ACTION_LABELS[log.action] ?? log.action;
  const parts = [
    formatTime(log.occurredAt),
    isSystem ? actorName : `${actorName} (${roleLabel})`,
    actionLabel,
    log.entityLabel ?? '',
  ].filter(Boolean);
  const detail = changes.map((c) => `${c.fieldLabel}: ${c.beforeLabel} → ${c.afterLabel}`).join('; ');

  return {
    id: log.id,
    occurredAt: log.occurredAt,
    actor: isSystem ? null : { id: log.actorId, fullName: actorName },
    actorRole: log.actorRole,
    actorRoleLabel: roleLabel,
    action: log.action,
    actionLabel,
    entity: { type: log.entityType, id: log.entityId, label: log.entityLabel },
    roomId: log.roomId,
    changes,
    line: detail ? `${parts.join(' · ')} · ${detail}` : parts.join(' · '),
  };
}

/**
 * Đọc nhật ký mới nhất trước, theo con trỏ (NFR-005).
 *
 * `from` > `to` → 400 `INVALID_RANGE`. `limit` mặc định 50, trần `MAX_PAGE_SIZE`.
 * Lấy dư một dòng để biết `nextCursor`. Trang đầu rỗng thì kèm `message` trung tính,
 * không phải lỗi. Không ghi thêm nhật ký vì đây là thao tác đọc.
 * @param filter Các trường đều tùy chọn. `actorRole` là chuỗi đã được route giới hạn bốn giá trị.
 * @returns `{ data, nextCursor, message? }`. `nextCursor` null khi hết.
 */
export async function listAuditLogs(filter: AuditFilter) {
  if (filter.from && filter.to && filter.from > filter.to) {
    throw new AppError(400, 'INVALID_RANGE', MSG.auditRangeInvalid);
  }
  const limit = Math.min(filter.limit ?? DEFAULT_PAGE_SIZE, MAX_PAGE_SIZE);
  const after = filter.cursor ? decodeCursor(filter.cursor) : null;

  const where: Prisma.AuditLogWhereInput = {
    roomId: filter.roomId,
    actorId: filter.actorId,
    actorRole: filter.actorRole,
    action: filter.action,
    entityType: filter.entityType,
    occurredAt: filter.from || filter.to ? { gte: filter.from, lte: filter.to } : undefined,
    ...(filter.field ? { changes: { some: { field: filter.field } } } : {}),
    ...(after
      ? { OR: [{ occurredAt: { lt: after.occurredAt } }, { occurredAt: after.occurredAt, id: { lt: after.id } }] }
      : {}),
  };

  const logs = await prisma.auditLog.findMany({
    where,
    include: { changes: true, actor: { select: { id: true, fullName: true } } },
    orderBy: [{ occurredAt: 'desc' }, { id: 'desc' }],
    take: limit + 1, // lấy dư 1 để biết còn trang sau không
  });
  const page = logs.slice(0, limit);
  return {
    data: page.map(toAuditEntryDto),
    nextCursor: logs.length > limit ? encodeCursor(page[page.length - 1]) : null,
    // Phạm vi rỗng → câu trung tính, không phải lỗi (FR-011, E-audit-log-004).
    message: page.length === 0 && !after ? MSG.auditEmpty : undefined,
  };
}
