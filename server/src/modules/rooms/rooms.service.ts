import type { CleaningStatus, OccupancyStatus, Prisma, Role, Room, RoomType, ServiceStatus } from '@prisma/client';
import { diffFields, writeAudit } from '../../lib/audit.js';
import { NotFoundError } from '../../lib/errors.js';
import { updateWithVersion } from '../../lib/optimistic-lock.js';
import { prisma } from '../../lib/prisma.js';
import { withTransaction } from '../../lib/transaction.js';
import { CHANNELS } from '../../realtime/events.js';

type RoomWithType = Room & { roomType: RoomType };

/** "Sẵn sàng" = trống + sạch + đang phục vụ — suy ra, không lưu (BR-housekeeping-003). */
export function isRoomReady(room: Pick<Room, 'occupancy' | 'cleaning' | 'service'>): boolean {
  return room.occupancy === 'VACANT' && room.cleaning === 'CLEAN' && room.service === 'IN_SERVICE';
}

/** Dữ liệu phòng trả cho client. Luôn kèm `version` để client gửi lại khi cập nhật (chống ghi đè). */
export function toRoomDto(room: RoomWithType) {
  return {
    id: room.id,
    number: room.number,
    floor: room.floor,
    roomType: { id: room.roomType.id, name: room.roomType.name },
    occupancy: room.occupancy,
    cleaning: room.cleaning,
    service: room.service,
    isReady: isRoomReady(room),
    version: room.version,
    updatedAt: room.updatedAt,
  };
}

export interface RoomFilter {
  floor?: number;
  roomTypeId?: string;
  occupancy?: OccupancyStatus;
  cleaning?: CleaningStatus;
  service?: ServiceStatus;
}

export async function listRooms(filter: RoomFilter) {
  const where: Prisma.RoomWhereInput = {
    floor: filter.floor,
    roomTypeId: filter.roomTypeId,
    occupancy: filter.occupancy,
    cleaning: filter.cleaning,
    service: filter.service,
  };
  const rooms = await prisma.room.findMany({
    where,
    include: { roomType: true },
    orderBy: [{ floor: 'asc' }, { number: 'asc' }],
  });
  return rooms.map(toRoomDto);
}

export async function getRoom(id: string) {
  const room = await prisma.room.findUnique({ where: { id }, include: { roomType: true } });
  if (!room) throw new NotFoundError('Phòng không tồn tại.');
  return toRoomDto(room);
}

export interface Actor {
  id: string | null; // null = hệ thống
  role: Role | 'SYSTEM';
}

export type RoomStatusPatch = Partial<Pick<Room, 'occupancy' | 'cleaning' | 'service'>>;

const STATUS_FIELDS = ['occupancy', 'cleaning', 'service'] as const;

/**
 * Đổi trạng thái 3 trục của phòng — lõi dùng chung cho nhận/trả phòng, dọn phòng, bảo trì.
 * Một transaction: kiểm version (chống ghi đè) → cập nhật → ghi nhật ký → sau COMMIT mới phát `room:updated`.
 *
 * KHÔNG mở thành API "sửa trạng thái tùy ý": theo room-catalog, trục lưu trú chỉ đổi qua check-in-out,
 * trục vệ sinh qua housekeeping, trục bảo trì qua maintenance / đặt-gỡ ngừng phục vụ. Mỗi feature gọi hàm này
 * sau khi tự kiểm quyền + điều kiện nghiệp vụ của mình.
 */
export async function changeRoomStatus(actor: Actor, roomId: string, expectedVersion: number, patch: RoomStatusPatch) {
  return withTransaction(async (tx, enqueue) => {
    const before = await tx.room.findUnique({ where: { id: roomId } });
    if (!before) throw new NotFoundError('Phòng không tồn tại.');

    const after = await updateWithVersion(tx, 'room', roomId, expectedVersion, patch);
    const roomType = await tx.roomType.findUniqueOrThrow({ where: { id: after.roomTypeId } });

    await writeAudit(tx, {
      actorId: actor.id,
      actorRole: actor.role,
      action: 'room.status_change',
      entityType: 'ROOM',
      entityId: roomId,
      entityLabel: `Phòng ${after.number}`,
      roomId,
      changes: diffFields(before, after, STATUS_FIELDS),
    });

    const room = toRoomDto({ ...after, roomType });
    enqueue({
      channel: CHANNELS.hotel,
      event: 'room:updated',
      payload: { room },
    });
    return room;
  });
}
