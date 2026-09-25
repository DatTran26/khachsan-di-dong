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

const invalidState = () => new AppError(409, 'INVALID_STATE', MSG.invalidState);
const numberTaken = (number: string) => new AppError(409, 'ROOM_NUMBER_TAKEN', MSG.roomNumberTaken(number));

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

async function assertActiveRoomType(tx: Prisma.TransactionClient, roomTypeId: string) {
  const type = await tx.roomType.findUnique({ where: { id: roomTypeId } });
  if (!type?.isActive) throw new AppError(400, 'ROOM_TYPE_INACTIVE', MSG.roomTypeInactive);
}

function isUniqueViolation(error: unknown) {
  return error instanceof Prisma.PrismaClientKnownRequestError && error.code === 'P2002';
}

/** Thêm phòng: mặc định trống + sạch + bình thường (FR-001/002). */
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

/** Tạo nhanh theo dải số (FR-009): bỏ qua số đã tồn tại và báo rõ số nào bị bỏ. */
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

/** Sửa số phòng / tầng / loại (FR-003). 3 trục trạng thái KHÔNG sửa ở đây. */
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
