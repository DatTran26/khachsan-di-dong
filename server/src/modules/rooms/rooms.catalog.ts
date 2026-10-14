import { Prisma, type User } from '@prisma/client';
import { diffFields, writeAudit, type AuditChange } from '../../lib/audit.js';
import { AppError } from '../../lib/errors.js';
import { MSG } from '../../lib/messages.js';
import { updateWithVersion } from '../../lib/optimistic-lock.js';
import { withTransaction } from '../../lib/transaction.js';
import { CHANNELS } from '../../realtime/events.js';
import { lockRoomForWrite, reloadRoomDto, roomLabel, roomUpdatedEvent, toRoomDto } from './rooms.service.js';

/**
 * Ghi danh mục phòng (room-catalog). Quyền (chốt nhóm 25/09/2026):
 * - Thêm / sửa / xóa / tạo theo dải: chỉ quản lý (kiểm ở routes).
 * - Đặt / gỡ ngừng phục vụ: quản lý + lễ tân (FR-007/008).
 * Mọi thao tác: kiểm version → lưu → nhật ký → sau COMMIT mới phát realtime (FR-011/012).
 */
type Actor = User;

/** 409 khi ngừng/mở phục vụ không đúng trạng thái hold hiện tại. */
const invalidState = () => new AppError(409, 'INVALID_STATE', MSG.invalidState);
/** 409 khi số phòng đụng unique. @param number Số vừa bị từ chối. */
const numberTaken = (number: string) => new AppError(409, 'ROOM_NUMBER_TAKEN', MSG.roomNumberTaken(number));

/**
 * Ghi nhật ký một thao tác danh mục phòng. `roomId` trùng đối tượng chính.
 * @param changes Bỏ qua thì mảng rỗng. Không ghi mật khẩu.
 * @returns Promise của `writeAudit`.
 */
function audit(tx: Prisma.TransactionClient, actor: Actor, action: string, room: { id: string; number: string }, changes: AuditChange[] = []) {
  return writeAudit(tx, {
    actorId: actor.id,
    actorRole: actor.role,
    action,
    entityType: 'ROOM',
    entityId: room.id,
    entityLabel: roomLabel(room),
    roomId: room.id,
    changes,
  });
}

/**
 * Loại phòng phải tồn tại và `isActive`. Ngược lại 400 `ROOM_TYPE_INACTIVE`.
 * @param roomTypeId UUID loại. Không phân biệt "không có" với "đã tắt" — cùng một lỗi.
 */
async function assertActiveRoomType(tx: Prisma.TransactionClient, roomTypeId: string) {
  const type = await tx.roomType.findUnique({ where: { id: roomTypeId } });
  if (!type?.isActive) throw new AppError(400, 'ROOM_TYPE_INACTIVE', MSG.roomTypeInactive);
}

/**
 * @param error Lỗi bắt được từ Prisma. Kiểu khác trả `false` để ném tiếp.
 * @returns `true` khi là P2002 (unique).
 */
function isUniqueViolation(error: unknown) {
  return error instanceof Prisma.PrismaClientKnownRequestError && error.code === 'P2002';
}

/**
 * Thêm một phòng: mặc định trống + sạch + đang phục vụ (FR-001/002).
 *
 * Loại phòng phải đang `isActive`. Trùng số → 409 `ROOM_NUMBER_TAKEN`, kể cả khi hai
 * request cùng lúc đụng unique (P2002). Phát `room:created` sau commit.
 * @param actor Quản lý. Hàm không kiểm role — route đã chặn.
 * @param input Số phòng, tầng dương, id loại phòng.
 * @returns DTO phòng vừa tạo.
 */
export async function createRoom(actor: Actor, input: { number: string; floor: number; roomTypeId: string }) {
  try {
    return await withTransaction(async (tx, enqueue) => {
      await assertActiveRoomType(tx, input.roomTypeId);
      if (await tx.room.findUnique({ where: { number: input.number } })) throw numberTaken(input.number);

      const room = await tx.room.create({ data: input, include: { roomType: true } });
      await audit(tx, actor, 'room.created', room, [
        { field: 'number', after: room.number },
        { field: 'floor', after: String(room.floor) },
        { field: 'roomType', after: room.roomType.name },
      ]);
      const dto = toRoomDto(room);
      enqueue({ channel: CHANNELS.hotel, event: 'room:created', payload: { room: dto } });
      return dto;
    });
  } catch (error) {
    if (isUniqueViolation(error)) throw numberTaken(input.number); // hai người thêm trùng số cùng lúc
    throw error;
  }
}

/**
 * Tạo nhanh theo dải số (FR-009): bỏ qua số đã tồn tại và báo rõ số nào bị bỏ.
 *
 * `from` > `to` hoặc rộng hơn 100 số → 400 `INVALID_RANGE` trước khi mở transaction.
 * Số phòng là chuỗi của số nguyên trong dải, không đệm số 0. Mỗi phòng tạo phát một `room:created`.
 * @param actor Quản lý. Không tự kiểm role.
 * @param input Tầng, số đầu, số cuối, loại phòng đang dùng.
 * @returns `created` (DTO), `skipped` (số đã có), và câu `message` tiếng Việt.
 */
export async function createRoomRange(
  actor: Actor,
  input: { floor: number; from: number; to: number; roomTypeId: string },
) {
  if (input.from > input.to || input.to - input.from >= 100) {
    throw new AppError(400, 'INVALID_RANGE', MSG.bulkRangeInvalid);
  }
  return withTransaction(async (tx, enqueue) => {
    await assertActiveRoomType(tx, input.roomTypeId);
    const numbers = Array.from({ length: input.to - input.from + 1 }, (_, i) => String(input.from + i));
    const existing = new Set(
      (await tx.room.findMany({ where: { number: { in: numbers } }, select: { number: true } })).map((r) => r.number),
    );

    const created = [];
    for (const number of numbers.filter((n) => !existing.has(n))) {
      const room = await tx.room.create({
        data: { number, floor: input.floor, roomTypeId: input.roomTypeId },
        include: { roomType: true },
      });
      await audit(tx, actor, 'room.created', room, [
        { field: 'number', after: room.number },
        { field: 'floor', after: String(room.floor) },
        { field: 'roomType', after: room.roomType.name },
      ]);
      const dto = toRoomDto(room);
      enqueue({ channel: CHANNELS.hotel, event: 'room:created', payload: { room: dto } });
      created.push(dto);
    }
    const skipped = numbers.filter((n) => existing.has(n));
    return { created, skipped, message: MSG.bulkCreated(created.length, skipped) };
  });
}

/**
 * Sửa số phòng, tầng, hoặc loại (FR-003). Ba trục trạng thái không sửa ở đây.
 *
 * Khóa dòng rồi kiểm version. Đổi loại thì loại mới phải đang dùng. Trùng số → 409.
 * Nhật ký gắn nhãn số phòng cũ để còn truy "101 đổi thành 111". Phát `room:updated`.
 * @param actor Quản lý.
 * @param roomId Phòng sửa.
 * @param version Version đã đọc.
 * @param patch Trường nào có mặt thì ghi. Object rỗng vẫn tăng version vì `updateWithVersion` luôn UPDATE.
 * @returns DTO sau ghi.
 */
export async function updateRoom(
  actor: Actor,
  roomId: string,
  version: number,
  patch: { number?: string; floor?: number; roomTypeId?: string },
) {
  try {
    return await withTransaction(async (tx, enqueue) => {
      const before = await lockRoomForWrite(tx, roomId, version);
      if (patch.roomTypeId && patch.roomTypeId !== before.roomTypeId) await assertActiveRoomType(tx, patch.roomTypeId);
      if (patch.number && patch.number !== before.number && (await tx.room.findUnique({ where: { number: patch.number } }))) {
        throw numberTaken(patch.number);
      }

      const after = await updateWithVersion(tx, 'room', roomId, version, patch);
      const dto = await reloadRoomDto(tx, roomId);
      const changes = diffFields(before, after, ['number', 'floor']);
      if (before.roomTypeId !== after.roomTypeId) {
        changes.push({ field: 'roomType', before: before.roomType.name, after: dto.roomType.name });
      }
      // Nhãn nhật ký = số phòng TRƯỚC khi sửa → truy vết được "phòng 101 đổi thành 111".
      await audit(tx, actor, 'room.updated', before, changes);
      enqueue(roomUpdatedEvent(dto));
      return dto;
    });
  } catch (error) {
    if (isUniqueViolation(error) && patch.number) throw numberTaken(patch.number);
    throw error;
  }
}

/**
 * Xóa phòng (FR-004): chỉ khi trống + không có việc đang mở + chưa có lịch sử hoạt động
 * (lượt lưu trú, việc dọn, việc sửa, lần ngừng phục vụ). Ngoài ra từ chối và gợi ý "ngừng phục vụ".
 *
 * Đang có khách, đang dọn, hoặc còn việc mở → 409 `ROOM_BUSY`. Có lịch sử dù đã xong → 409 `ROOM_HAS_HISTORY`.
 * Xóa được thì ghi `room.deleted` rồi phát `room:deleted`. Không trả DTO.
 * @param actor Quản lý.
 * @param roomId Phòng xóa.
 * @param version Version đã đọc. Xung đột thì không xóa.
 * @returns Promise rỗng sau commit.
 */
export async function deleteRoom(actor: Actor, roomId: string, version: number) {
  return withTransaction(async (tx, enqueue) => {
    const room = await lockRoomForWrite(tx, roomId, version);

    const [openHousekeeping, openMaintenance] = await Promise.all([
      tx.housekeepingTask.count({ where: { roomId, status: { not: 'DONE' } } }),
      tx.maintenanceTask.count({ where: { roomId, status: { in: ['OPEN', 'IN_PROGRESS'] } } }),
    ]);
    const busy = room.occupancy === 'OCCUPIED' || room.cleaning === 'CLEANING' || openHousekeeping + openMaintenance > 0;
    if (busy) throw new AppError(409, 'ROOM_BUSY', MSG.roomDeleteBusy);

    const history = await Promise.all([
      tx.stay.count({ where: { roomId } }),
      tx.housekeepingTask.count({ where: { roomId } }),
      tx.maintenanceTask.count({ where: { roomId } }),
      tx.outOfServiceHold.count({ where: { roomId } }),
    ]);
    if (history.some((count) => count > 0)) throw new AppError(409, 'ROOM_HAS_HISTORY', MSG.roomDeleteHasHistory);

    await tx.room.delete({ where: { id: roomId } });
    await audit(tx, actor, 'room.deleted', room, [
      { field: 'number', before: room.number },
      { field: 'floor', before: String(room.floor) },
      { field: 'roomType', before: room.roomType.name },
    ]);
    enqueue({ channel: CHANNELS.hotel, event: 'room:deleted', payload: { roomId } });
  });
}

/**
 * Đặt "ngừng phục vụ" thủ công (FR-007): bắt buộc lý do; phòng đang có khách → phải xác nhận lại
 * (`confirmOccupied`), khách vẫn ở hết kỳ nhưng phòng bị chặn nhận khách mới.
 *
 * Đã có hold chưa gỡ → 409 `INVALID_STATE` (kể cả khi trục service đang tắt vì việc sửa
 * mà chưa có hold tay — lần đặt tay đầu vẫn được). Không tự kết thúc việc bảo trì.
 * @param actor Quản lý hoặc lễ tân.
 * @param roomId Phòng đặt ngừng.
 * @param version Version phòng.
 * @param input `reason` bắt buộc ở route; `confirmOccupied` phải true nếu đang có khách.
 * @returns DTO phòng `OUT_OF_SERVICE`.
 */
export async function placeOutOfService(
  actor: Actor,
  roomId: string,
  version: number,
  input: { reason: string; confirmOccupied?: boolean },
) {
  return withTransaction(async (tx, enqueue) => {
    const room = await lockRoomForWrite(tx, roomId, version);
    if (await tx.outOfServiceHold.findFirst({ where: { roomId, liftedAt: null } })) throw invalidState();
    if (room.occupancy === 'OCCUPIED' && !input.confirmOccupied) {
      throw new AppError(409, 'OCCUPIED_CONFIRM_REQUIRED', MSG.occupiedConfirmRequired);
    }

    const hold = await tx.outOfServiceHold.create({ data: { roomId, reason: input.reason, placedById: actor.id } });
    await updateWithVersion(tx, 'room', roomId, version, { service: 'OUT_OF_SERVICE' });
    await audit(tx, actor, 'room.out_of_service', room, [
      ...(room.service === 'OUT_OF_SERVICE' ? [] : [{ field: 'service', before: room.service, after: 'OUT_OF_SERVICE' }]),
      { entityType: 'OUT_OF_SERVICE_HOLD', entityId: hold.id, field: 'reason', after: hold.reason },
    ]);
    const dto = await reloadRoomDto(tx, roomId);
    enqueue(roomUpdatedEvent(dto));
    return dto;
  });
}

/**
 * Gỡ "ngừng phục vụ" thủ công (FR-008): chỉ khi phòng không còn việc bảo trì đang mở (FR-maintenance-007).
 * Trục bảo trì về "bình thường" → phòng lại "sẵn sàng" nếu trống + sạch.
 *
 * Không có hold đang mở → 409. Còn việc sửa `OPEN`/`IN_PROGRESS` → 409 `ROOM_HAS_OPEN_MAINTENANCE`,
 * hold không bị gỡ. Gỡ được thì ghi `liftedAt` và người gỡ, phát `room:updated`.
 * @param actor Quản lý hoặc lễ tân.
 * @param roomId Phòng mở lại.
 * @param version Version phòng.
 * @returns DTO với `service: IN_SERVICE`.
 */
export async function liftOutOfService(actor: Actor, roomId: string, version: number) {
  return withTransaction(async (tx, enqueue) => {
    const room = await lockRoomForWrite(tx, roomId, version);
    const hold = await tx.outOfServiceHold.findFirst({ where: { roomId, liftedAt: null } });
    if (!hold) throw invalidState();
    const openMaintenance = await tx.maintenanceTask.count({ where: { roomId, status: { in: ['OPEN', 'IN_PROGRESS'] } } });
    if (openMaintenance > 0) throw new AppError(409, 'ROOM_HAS_OPEN_MAINTENANCE', MSG.roomHasOpenMaintenance);

    await tx.outOfServiceHold.update({ where: { id: hold.id }, data: { liftedAt: new Date(), liftedById: actor.id } });
    await updateWithVersion(tx, 'room', roomId, version, { service: 'IN_SERVICE' });
    await audit(tx, actor, 'room.back_in_service', room, [
      { field: 'service', before: room.service, after: 'IN_SERVICE' },
      { entityType: 'OUT_OF_SERVICE_HOLD', entityId: hold.id, field: 'reason', before: hold.reason },
    ]);
    const dto = await reloadRoomDto(tx, roomId);
    enqueue(roomUpdatedEvent(dto));
    return dto;
  });
}
