import type { Room, Stay, User } from '@prisma/client';
import { writeAudit } from '../../lib/audit.js';
import { AppError } from '../../lib/errors.js';
import { MSG } from '../../lib/messages.js';
import { updateWithVersion } from '../../lib/optimistic-lock.js';
import { prisma } from '../../lib/prisma.js';
import { withTransaction } from '../../lib/transaction.js';
import {
  CLEANING_LABELS,
  lockRoomForWrite,
  reloadRoomDto,
  roomLabel,
  roomUpdatedEvent,
} from '../rooms/rooms.service.js';
import { autoAssign, serializeAssignment } from '../housekeeping/housekeeping.assignment.js';

/** Việc dọn quá hạn sau 60 phút kể từ lúc tạo = mốc trả phòng (BR-housekeeping-002). */
export const HOUSEKEEPING_DUE_MINUTES = 60;

/** Lượt lưu trú trả cho client (lễ tân, quản lý). */
export function toStayDto(stay: Stay & { room: Pick<Room, 'id' | 'number' | 'floor'> }) {
  return {
    id: stay.id,
    room: { id: stay.room.id, number: stay.room.number, floor: stay.room.floor },
    guestName: stay.guestName,
    guestCount: stay.guestCount,
    status: stay.status,
    checkedInAt: stay.checkedInAt,
    checkedOutAt: stay.checkedOutAt,
    expectedCheckout: stay.expectedCheckout,
    note: stay.note,
    version: stay.version,
  };
}

/** Danh sách phòng đang ở: phòng + khách + mốc nhận (FR-005). */
export async function listOpenStays() {
  const stays = await prisma.stay.findMany({
    where: { status: 'OPEN' },
    include: { room: { select: { id: true, number: true, floor: true } } },
    orderBy: { checkedInAt: 'desc' },
  });
  return stays.map(toStayDto);
}

export interface CheckInInput {
  guestName: string;
  guestCount: number;
  note?: string;
  expectedCheckout?: Date;
}

/**
 * Nhận phòng (FR-001…003): khóa dòng phòng rồi kiểm LẠI 3 điều kiện trên trạng thái thật lúc ghi —
 * không tin trạng thái client đang hiển thị. Không đạt → chặn kèm lý do theo đúng trục vi phạm.
 */
export async function checkIn(actor: User, roomId: string, version: number, input: CheckInInput) {
  return withTransaction(async (tx, enqueue) => {
    const room = await lockRoomForWrite(tx, roomId, version);
    if (room.occupancy === 'OCCUPIED') throw new AppError(409, 'ROOM_OCCUPIED', MSG.checkInOccupied);
    if (room.cleaning !== 'CLEAN') {
      throw new AppError(409, 'ROOM_NOT_CLEAN', MSG.checkInNotClean(CLEANING_LABELS[room.cleaning]));
    }
    if (room.service === 'OUT_OF_SERVICE') throw new AppError(409, 'ROOM_OUT_OF_SERVICE', MSG.checkInOutOfService);

    // CSDL còn chặn thêm: mỗi phòng tối đa 1 lượt đang mở (partial unique index).
    const stay = await tx.stay.create({
      data: { roomId, ...input, checkedInById: actor.id },
      include: { room: { select: { id: true, number: true, floor: true } } },
    });
    await updateWithVersion(tx, 'room', roomId, version, { occupancy: 'OCCUPIED' });
    await writeAudit(tx, {
      actorId: actor.id,
      actorRole: actor.role,
      action: 'stay.check_in',
      entityType: 'ROOM',
      entityId: roomId,
      entityLabel: roomLabel(room),
      roomId,
      changes: [
        { field: 'occupancy', before: 'VACANT', after: 'OCCUPIED' },
        { entityType: 'STAY', entityId: stay.id, entityLabel: stay.guestName, field: 'status', after: 'OPEN' },
      ],
    });

    const roomDto = await reloadRoomDto(tx, roomId);
    enqueue(roomUpdatedEvent(roomDto));
    return { room: roomDto, stay: toStayDto(stay) };
  });
}

/**
 * Trả phòng (FR-004): chỉ trên phòng "đang ở" có lượt mở → đóng lượt → lưu trú "trống", vệ sinh LUÔN "cần dọn"
 * (bất kể tình trạng thực tế) → hệ thống tự tạo đúng 1 việc dọn (FR-housekeeping-001). Tất cả một transaction.
 * Phòng đang ngừng phục vụ vẫn trả bình thường và vẫn ngừng phục vụ sau đó.
 */
export async function checkOut(actor: User, roomId: string, version: number) {
  return withTransaction(async (tx, enqueue) => {
    const room = await lockRoomForWrite(tx, roomId, version);
    const stay = await tx.stay.findFirst({ where: { roomId, status: 'OPEN' } });
    if (room.occupancy !== 'OCCUPIED' || !stay) throw new AppError(409, 'INVALID_STATE', MSG.invalidState);

    const now = new Date();
    const closed = await updateWithVersion(tx, 'stay', stay.id, stay.version, {
      status: 'CLOSED',
      checkedOutAt: now,
      checkedOutById: actor.id,
    });
    await updateWithVersion(tx, 'room', roomId, version, { occupancy: 'VACANT', cleaning: 'DIRTY' });

    await writeAudit(tx, {
      actorId: actor.id,
      actorRole: actor.role,
      action: 'stay.check_out',
      entityType: 'ROOM',
      entityId: roomId,
      entityLabel: roomLabel(room),
      roomId,
      changes: [
        { field: 'occupancy', before: 'OCCUPIED', after: 'VACANT' },
        ...(room.cleaning === 'DIRTY' ? [] : [{ field: 'cleaning', before: room.cleaning, after: 'DIRTY' }]),
        { entityType: 'STAY', entityId: stay.id, entityLabel: stay.guestName, field: 'status', before: 'OPEN', after: 'CLOSED' },
      ],
    });

    // Việc dọn do HỆ THỐNG tạo và tự giao → nhật ký với người thực hiện "hệ thống" (FR-audit-log-003).
    await serializeAssignment(tx);
    const task = await tx.housekeepingTask.create({
      data: { roomId, stayId: stay.id, dueAt: new Date(now.getTime() + HOUSEKEEPING_DUE_MINUTES * 60_000) },
    });
    await writeAudit(tx, {
      actorId: null,
      actorRole: 'SYSTEM',
      action: 'housekeeping.task_created',
      entityType: 'HOUSEKEEPING_TASK',
      entityId: task.id,
      entityLabel: `Dọn ${roomLabel(room)}`,
      roomId,
      changes: [{ field: 'status', after: task.status }],
    });

    // Giao ngay cho người trực ít việc nhất; không ai trực → "chờ giao" + cảnh báo quản lý (FR-housekeeping-002/003).
    const housekeepingTask = await autoAssign(tx, task, enqueue);

    const roomDto = await reloadRoomDto(tx, roomId);
    enqueue(roomUpdatedEvent(roomDto));
    return { room: roomDto, stay: toStayDto({ ...closed, room }), housekeepingTask };
  });
}
