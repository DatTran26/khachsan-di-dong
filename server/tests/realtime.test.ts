import { createServer, type Server as HttpServer } from 'node:http';
import type { AddressInfo } from 'node:net';
import type { Room } from '@prisma/client';
import { io as connect, type Socket } from 'socket.io-client';
import { afterAll, beforeAll, beforeEach, describe, expect, it } from 'vitest';
import { createApp } from '../src/app.js';
import { VersionConflictError } from '../src/lib/errors.js';
import { prisma } from '../src/lib/prisma.js';
import { changeRoomStatus } from '../src/modules/rooms/rooms.service.js';
import { attachRealtime, closeRealtime } from '../src/realtime/socket.js';
import { createUserWithToken } from './helpers.js';

const SYSTEM = { id: null, role: 'SYSTEM' as const };
let httpServer: HttpServer;
let clients: Socket[] = [];
let room: Room;
let roomTypeId: string;
let counter = 0;

type RoomUpdated = { room: { id: string; version: number; cleaning: string; isReady: boolean }; emittedAt: string };

/** Chờ sự kiện `room:updated` đầu tiên trên client; hết giờ → null. */
function nextRoomUpdate(client: Socket, timeoutMs = 3_000) {
  return new Promise<RoomUpdated | null>((resolve) => {
    const timer = setTimeout(() => {
      client.off('room:updated', onEvent);
      resolve(null);
    }, timeoutMs);
    function onEvent(payload: RoomUpdated) {
      clearTimeout(timer);
      resolve(payload);
    }
    client.once('room:updated', onEvent);
  });
}

beforeAll(async () => {
  httpServer = createServer(createApp());
  attachRealtime(httpServer);
  await new Promise<void>((resolve) => httpServer.listen(0, resolve));
  const { port } = httpServer.address() as AddressInfo;

  // 2 "thiết bị" đã đăng nhập: quản lý (web) và nhân viên buồng phòng (android)
  const tokens = [(await createUserWithToken('MANAGER')).token, (await createUserWithToken('STAFF')).token];
  clients = tokens.map((token) => connect(`http://localhost:${port}`, { auth: { token } }));
  await Promise.all(clients.map((c) => new Promise<void>((resolve) => c.once('connect', () => resolve()))));

  roomTypeId = (await prisma.roomType.create({ data: { name: 'RT-realtime' } })).id;
});

beforeEach(async () => {
  counter += 1;
  room = await prisma.room.create({ data: { number: `RT-${counter}`, floor: 1, roomTypeId } });
});

afterAll(async () => {
  for (const c of clients) c.disconnect();
  await closeRealtime();
  await new Promise((resolve) => httpServer.close(resolve));
  await prisma.$disconnect();
});

describe('realtime — room:updated', () => {
  it('đổi trạng thái → mọi thiết bị nhận bản mới kèm version', async () => {
    const received = clients.map((c) => nextRoomUpdate(c));

    await changeRoomStatus(SYSTEM, room.id, 1, { occupancy: 'VACANT', cleaning: 'DIRTY' });

    for (const payload of await Promise.all(received)) {
      expect(payload).not.toBeNull();
      expect(Number.isNaN(Date.parse(payload!.emittedAt))).toBe(false); // mốc phát để đo độ trễ
      expect(payload!.room).toMatchObject({ id: room.id, cleaning: 'DIRTY', isReady: false, version: 2 });
    }
  });

  it('chỉ phát SAU khi đã lưu: lúc thiết bị nhận, CSDL đã có dữ liệu mới', async () => {
    const received = nextRoomUpdate(clients[0]);
    await changeRoomStatus(SYSTEM, room.id, 1, { cleaning: 'DIRTY' });

    const payload = await received;
    const inDb = await prisma.room.findUniqueOrThrow({ where: { id: room.id } });
    expect(inDb.version).toBe(payload!.room.version);
    expect(inDb.cleaning).toBe('DIRTY');
  });

  it('xung đột version → không lưu và KHÔNG phát sự kiện nào', async () => {
    const fromA = nextRoomUpdate(clients[0]);
    await changeRoomStatus(SYSTEM, room.id, 1, { cleaning: 'DIRTY' }); // người A sửa trước
    await fromA; // nhận xong sự kiện của A rồi mới nghe tiếp
    const received = nextRoomUpdate(clients[0], 800);

    await expect(changeRoomStatus(SYSTEM, room.id, 1, { cleaning: 'CLEAN' })).rejects.toBeInstanceOf(
      VersionConflictError,
    );
    expect(await received).toBeNull();
  });

  it('ghi nhật ký trục đã đổi (từ → sang) cùng transaction', async () => {
    await changeRoomStatus(SYSTEM, room.id, 1, { cleaning: 'DIRTY' });

    const log = await prisma.auditLog.findFirstOrThrow({
      where: { roomId: room.id, action: 'room.status_change' },
      include: { changes: true },
    });
    expect(log.actorRole).toBe('SYSTEM');
    expect(log.changes).toEqual([expect.objectContaining({ field: 'cleaning', before: 'CLEAN', after: 'DIRTY' })]);
  });
});
