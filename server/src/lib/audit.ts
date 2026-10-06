import type { AuditEntityType, Prisma, Role } from '@prisma/client';

export interface AuditChange {
  /** Chỉ điền khi dòng này thuộc đối tượng KHÁC đối tượng chính của bản ghi (vd trả phòng đổi cả lượt lưu trú). */
  entityType?: AuditEntityType;
  entityId?: string;
  entityLabel?: string;
  field: string;
  before?: string | null;
  after?: string | null;
}

export interface AuditEntry {
  actorId: string | null; // null = hệ thống tự làm
  actorRole: Role | 'SYSTEM';
  action: string; // vd: stay.check_out, housekeeping.confirm
  entityType: AuditEntityType;
  entityId: string;
  entityLabel?: string; // vd: "Phòng 203"
  roomId?: string | null;
  changes?: AuditChange[];
}

/**
 * Ghi 1 bản ghi nhật ký (audit-log). Luôn gọi bằng `tx` của cùng transaction với thao tác,
 * để "ghi nhật ký thất bại thì thao tác cũng thất bại" (audit-log spec).
 */
export function writeAudit(tx: Prisma.TransactionClient, entry: AuditEntry) {
  const { changes = [], ...log } = entry;
  return tx.auditLog.create({
    data: {
      ...log,
      changes: {
        create: changes.map((change, position) => ({ ...change, position })),
      },
    },
  });
}

/** Liệt kê các trường đã đổi giữa 2 trạng thái — dùng làm `changes` cho nhật ký. */
export function diffFields<T extends object>(
  before: T,
  after: T,
  fields: readonly (keyof T & string)[],
): AuditChange[] {
  return fields
    .filter((field) => before[field] !== after[field])
    .map((field) => ({
      field,
      before: before[field] == null ? null : String(before[field]),
      after: after[field] == null ? null : String(after[field]),
    }));
}
