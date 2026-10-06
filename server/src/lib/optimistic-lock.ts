import type { HousekeepingTask, MaintenanceTask, Prisma, Room, Stay, User } from '@prisma/client';
import { NotFoundError, VersionConflictError } from './errors.js';

/**
 * Chống ghi đè bằng khóa lạc quan (optimistic locking) — spec realtime-sync:
 * "hai thiết bị sửa cùng lúc → kiểm tra phiên bản, từ chối ghi đè".
 *
 * Cách hoạt động:
 *   UPDATE ... SET ..., version = version + 1 WHERE id = :id AND version = :expectedVersion
 * - Khớp 1 dòng  → cập nhật thành công, version tăng 1.
 * - Khớp 0 dòng  → người khác đã sửa trước (version đã đổi) → 409 VERSION_CONFLICT, không ghi gì.
 * Hai request cùng version tới cùng lúc: PostgreSQL khóa dòng, request sau chờ rồi
 * kiểm lại điều kiện WHERE trên dữ liệu mới → khớp 0 dòng → bị từ chối. Chỉ đúng 1 người thắng.
 *
 * Trigger `bump_version` trong migration còn ép version = version cũ + 1 cho MỌI lệnh UPDATE,
 * nên kể cả code quên dùng hàm này thì client cầm version cũ vẫn bị từ chối.
 */
type VersionedModels = {
  room: { record: Room; data: Prisma.RoomUncheckedUpdateManyInput };
  stay: { record: Stay; data: Prisma.StayUncheckedUpdateManyInput };
  housekeepingTask: { record: HousekeepingTask; data: Prisma.HousekeepingTaskUncheckedUpdateManyInput };
  maintenanceTask: { record: MaintenanceTask; data: Prisma.MaintenanceTaskUncheckedUpdateManyInput };
  user: { record: User; data: Prisma.UserUncheckedUpdateManyInput };
};

export type VersionedModel = keyof VersionedModels;

const LABELS: Record<VersionedModel, string> = {
  room: 'Phòng',
  stay: 'Lượt lưu trú',
  housekeepingTask: 'Việc dọn phòng',
  maintenanceTask: 'Việc bảo trì',
  user: 'Tài khoản',
};

// Phần tối thiểu của Prisma delegate mà hàm cần — giúp dùng chung cho 4 model.
interface VersionedDelegate {
  updateMany(args: {
    where: { id: string; version: number };
    data: Record<string, unknown>;
  }): Promise<{ count: number }>;
  findUnique(args: { where: { id: string } }): Promise<unknown>;
}

/**
 * Cập nhật một bản ghi CHỈ KHI version còn khớp. Gọi bên trong `prisma.$transaction`
 * để lỗi xung đột rollback luôn các thay đổi khác (nhật ký, việc dọn...) của cùng thao tác.
 *
 * @returns bản ghi sau khi cập nhật (version mới)
 * @throws NotFoundError nếu không có bản ghi
 * @throws VersionConflictError (409) nếu version đã đổi
 */
export async function updateWithVersion<M extends VersionedModel>(
  db: Prisma.TransactionClient,
  model: M,
  id: string,
  expectedVersion: number,
  data: Omit<VersionedModels[M]['data'], 'id' | 'version'>,
): Promise<VersionedModels[M]['record']> {
  const delegate = db[model] as unknown as VersionedDelegate;

  const { count } = await delegate.updateMany({
    where: { id, version: expectedVersion },
    data: { ...data, version: { increment: 1 } },
  });

  const current = (await delegate.findUnique({ where: { id } })) as
    | VersionedModels[M]['record']
    | null;

  if (!current) throw new NotFoundError(`${LABELS[model]} không tồn tại.`);
  if (count === 0) throw new VersionConflictError(LABELS[model], id, expectedVersion, current);
  return current;
}
