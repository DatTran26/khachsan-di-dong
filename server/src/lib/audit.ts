import type { AuditEntityType, Prisma, Role } from '@prisma/client';

/**
 * Một trường đổi trong một dòng nhật ký.
 * Giá trị đưa vào dạng chuỗi hoặc `null` — không ghi mật khẩu, hash, hay token.
 */
export interface AuditChange {
  /** Chỉ điền khi dòng này thuộc đối tượng KHÁC đối tượng chính của bản ghi (vd trả phòng đổi cả lượt lưu trú). */
  entityType?: AuditEntityType;
  entityId?: string;
  entityLabel?: string;
  field: string;
  before?: string | null;
  after?: string | null;
}

/**
 * Nội dung một dòng nhật ký trước khi ghi.
 * `actorId` null và `actorRole` `SYSTEM` nghĩa là hệ thống tự làm (hết phiên, quá hạn, giao việc).
 */
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
 * Ghi một dòng nhật ký và các `changes` con (audit-log).
 *
 * Luôn gọi bằng `tx` của cùng transaction với thao tác nghiệp vụ, để ghi nhật ký
 * thất bại thì thao tác cũng rollback (audit-log spec). Trigger CSDL cấm UPDATE/DELETE
 * bảng nhật ký — hàm này chỉ INSERT. `position` của từng change là thứ tự trong mảng.
 * @param tx Client transaction đang giữ thao tác chính.
 * @param entry Người thực hiện, hành động, đối tượng, và danh sách trường đổi. `changes` bỏ qua thì thành mảng rỗng.
 * @returns Promise của `auditLog.create` (bản ghi vừa insert, chưa gồm quan hệ đọc lại).
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

/**
 * Liệt kê các trường đã đổi giữa hai trạng thái để đưa vào `changes` của nhật ký.
 *
 * So sánh bằng `!==` trên giá trị hiện có (không so sâu object). `null` và `undefined`
 * đều thành `before`/`after` null khi giá trị là nullish; các kiểu khác bị `String(...)`.
 * Trường không đổi bị bỏ qua. Không ghi nhận trường nằm ngoài `fields`.
 * @param before Trạng thái trước ghi.
 * @param after Trạng thái sau ghi (hoặc bản nháp đã trộn patch).
 * @param fields Tên trường được phép đưa vào nhật ký, theo thứ tự này.
 * @returns Mảng `AuditChange` chỉ gồm trường thực sự khác. Có thể rỗng.
 */
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
