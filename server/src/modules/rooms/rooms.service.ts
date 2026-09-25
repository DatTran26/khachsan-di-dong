import type { CleaningStatus, OccupancyStatus, Prisma, Role, Room, RoomType, ServiceStatus } from '@prisma/client';
import { diffFields, writeAudit } from '../../lib/audit.js';
import { NotFoundError, VersionConflictError } from '../../lib/errors.js';
import { updateWithVersion } from '../../lib/optimistic-lock.js';
import { prisma } from '../../lib/prisma.js';
import { withTransaction } from '../../lib/transaction.js';
import { CHANNELS, type PendingEvent } from '../../realtime/events.js';

export type RoomWithType = Room & { roomType: RoomType };

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
  /** true = chỉ phòng sẵn sàng (trống + sạch + đang phục vụ) — lễ tân chọn phòng để nhận khách. */
  ready?: boolean;
}

export async function listRooms(filter: RoomFilter) {
  const readyOnly: Prisma.RoomWhereInput = filter.ready
    ? { occupancy: 'VACANT', cleaning: 'CLEAN', service: 'IN_SERVICE' }
    : {};
  const where: Prisma.RoomWhereInput = {
    floor: filter.floor,
    roomTypeId: filter.roomTypeId,
    occupancy: filter.occupancy,
    cleaning: filter.cleaning,
    service: filter.service,
    AND: [readyOnly],
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

/** Nhãn tiếng Việt của trục vệ sinh — dùng trong câu báo lỗi (vd "Phòng chưa dọn xong (Cần dọn)"). */
export const CLEANING_LABELS: Record<CleaningStatus, string> = {
  DIRTY: 'Cần dọn',
  CLEANING: 'Đang dọn',
  PENDING_INSPECTION: 'Chờ kiểm tra',
  CLEAN: 'Sạch',
};

export const roomLabel = (room: Pick<Room, 'number'>) => `Phòng ${room.number}`;

/**
 * Khóa dòng phòng (SELECT … FOR UPDATE) trong transaction rồi kiểm version.
 * Nhờ khóa dòng, các điều kiện nghiệp vụ (trống/sạch/đang phục vụ…) được kiểm trên trạng thái THẬT
 * tại thời điểm ghi, không bị người khác đổi xen giữa (FR-check-in-out-001/008, NFR-room-catalog-004).
 */
export async function lockRoomForWrite(tx: Prisma.TransactionClient, roomId: string, expectedVersion: number) {
  await tx.$queryRaw`SELECT 1 FROM rooms WHERE id = ${roomId}::uuid FOR UPDATE`;
  const room = await tx.room.findUnique({ where: { id: roomId }, include: { roomType: true } });
  if (!room) throw new NotFoundError('Phòng không tồn tại.');
  if (room.version !== expectedVersion) {
    throw new VersionConflictError('Phòng', roomId, expectedVersion, toRoomDto(room));
  }
  return room;
}

/** Đọc lại phòng (kèm loại) sau khi ghi để trả client + phát realtime. */
export async function reloadRoomDto(tx: Prisma.TransactionClient, roomId: string) {
  return toRoomDto(await tx.room.findUniqueOrThrow({ where: { id: roomId }, include: { roomType: true } }));
}

export function roomUpdatedEvent(room: ReturnType<typeof toRoomDto>): PendingEvent {
  return { channel: CHANNELS.hotel, event: 'room:updated', payload: { room } };
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
