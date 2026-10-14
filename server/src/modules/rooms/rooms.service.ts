import type { CleaningStatus, OccupancyStatus, Prisma, Role, Room, RoomType, ServiceStatus } from '@prisma/client';
import { diffFields, writeAudit } from '../../lib/audit.js';
import { NotFoundError, VersionConflictError } from '../../lib/errors.js';
import { updateWithVersion } from '../../lib/optimistic-lock.js';
import { prisma } from '../../lib/prisma.js';
import { withTransaction } from '../../lib/transaction.js';
import { CHANNELS, type PendingEvent } from '../../realtime/events.js';

export type RoomWithType = Room & { roomType: RoomType };

/**
 * "Sẵn sàng" = trống + sạch + đang phục vụ. Suy ra, không có cột riêng (BR-housekeeping-003).
 * @param room Ba trục trạng thái. Không cần các cột khác của phòng.
 * @returns `true` chỉ khi cả ba điều kiện đúng cùng lúc.
 */
export function isRoomReady(room: Pick<Room, 'occupancy' | 'cleaning' | 'service'>): boolean {
  return room.occupancy === 'VACANT' && room.cleaning === 'CLEAN' && room.service === 'IN_SERVICE';
}

/**
 * Dữ liệu phòng trả cho client. Luôn kèm `version` để client gửi lại khi cập nhật (chống ghi đè).
 * @param room Phòng đã include `roomType`. Thiếu relation thì đọc `roomType.id` sẽ ném.
 * @returns DTO không gồm ghi chú nội bộ. `isReady` tính bằng `isRoomReady`.
 */
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

/**
 * Danh sách phòng theo bộ lọc. Mọi vai trò đã đăng nhập đều gọi được (route không chặn role).
 *
 * `ready: true` thêm điều kiện trống + sạch + đang phục vụ, AND với các lọc khác
 * (vừa `ready` vừa `occupancy: OCCUPIED` thì ra rỗng). Trường `undefined` bị Prisma bỏ qua.
 * @param filter Tầng, loại, ba trục, hoặc chỉ phòng sẵn sàng. Object rỗng = mọi phòng.
 * @returns DTO sắp theo tầng rồi số phòng. Không phân trang.
 */
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

/**
 * Đọc một phòng kèm loại.
 * @param id UUID phòng.
 * @returns DTO. Ném `NotFoundError` nếu không có — không phân biệt với "không có quyền".
 */
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
 *
 * Không tự tăng version. Chỗ gọi sau đó phải `updateWithVersion` với cùng `expectedVersion`.
 * @param tx Transaction đang mở. Khóa dòng giữ đến commit.
 * @param roomId UUID phòng.
 * @param expectedVersion Version client gửi. Lệch → 409 kèm DTO hiện tại, không ghi.
 * @returns Phòng kèm `roomType` đúng version yêu cầu.
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

/**
 * Đổi trục trạng thái phòng như HỆ QUẢ của một thao tác khác (nhận việc dọn, báo hỏng…):
 * client không gửi version phòng mà gửi version của việc; phòng được khóa dòng rồi cập nhật theo version hiện tại.
 * Trả về phòng trước khi đổi + danh sách trục đã đổi (để ghi vào nhật ký của thao tác gọi).
 *
 * Patch không đổi trục nào thì không UPDATE và không phát sự kiện. Có đổi thì tăng version
 * theo version vừa đọc trong khóa, không theo version client gửi cho việc.
 * @param tx Transaction của thao tác việc dọn/bảo trì.
 * @param roomId Phòng chịu hệ quả.
 * @param patch Một phần ba trục. Trường không gửi giữ nguyên.
 * @param enqueue Hàng đợi realtime của transaction cha.
 * @returns `room` là bản trước khi đổi; `changes` rỗng nếu không có trục nào khác.
 */
export async function applyRoomChange(
  tx: Prisma.TransactionClient,
  roomId: string,
  patch: RoomStatusPatch,
  enqueue: (event: PendingEvent) => void,
) {
  await tx.$queryRaw`SELECT 1 FROM rooms WHERE id = ${roomId}::uuid FOR UPDATE`;
  const before = await tx.room.findUniqueOrThrow({ where: { id: roomId }, include: { roomType: true } });
  const changes = diffFields(before, { ...before, ...patch }, STATUS_FIELDS);
  if (changes.length > 0) {
    await updateWithVersion(tx, 'room', roomId, before.version, patch);
    enqueue(roomUpdatedEvent(await reloadRoomDto(tx, roomId)));
  }
  return { room: before, changes };
}

/**
 * Đọc lại phòng (kèm loại) sau khi ghi để trả client và phát realtime.
 * @param tx Cùng transaction vừa ghi, để thấy bản chưa commit.
 * @param roomId Phòng vừa sửa. Không còn dòng thì `findUniqueOrThrow` ném.
 * @returns DTO bản mới nhất trong transaction.
 */
export async function reloadRoomDto(tx: Prisma.TransactionClient, roomId: string) {
  return toRoomDto(await tx.room.findUniqueOrThrow({ where: { id: roomId }, include: { roomType: true } }));
}

/**
 * Sự kiện `room:updated` trên kênh `hotel`.
 * @param room DTO sau ghi. `emittedAt` do `publish` gắn sau.
 * @returns `PendingEvent` chưa phát.
 */
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
 *
 * Hàm không kiểm vai trò và không kiểm tổ hợp trạng thái hợp lệ. Không có route
 * gọi thẳng — các feature hiện đi qua `lockRoomForWrite` hoặc `applyRoomChange`.
 * @param actor Người ghi nhật ký. `id` null khi là hệ thống.
 * @param roomId Phòng cần đổi.
 * @param expectedVersion Version phòng client đang giữ.
 * @param patch Các trục muốn ghi. Trục không có trong patch giữ nguyên.
 * @returns DTO phòng sau commit, đã phát `room:updated`.
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
