/**
 * Đối chiếu docs/features/check-in-out/srs/check-in-out-spec.md (FR / SC / E-xxx)
 * + quyết định nhóm 25/09/2026: thông tin khách tối thiểu = tên + số người.
 */
import { randomUUID } from 'node:crypto';
import { createServer, type Server as HttpServer } from 'node:http';
import type { AddressInfo } from 'node:net';
import type { Room } from '@prisma/client';
import { io as connect } from 'socket.io-client';
import request from 'supertest';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { createApp } from '../src/app.js';
import { MSG } from '../src/lib/messages.js';
import { prisma } from '../src/lib/prisma.js';
import { attachRealtime, closeRealtime } from '../src/realtime/socket.js';
import { createUserWithToken } from './helpers.js';

const app = createApp();
const tag = randomUUID().slice(0, 6);
let httpServer: HttpServer;
let baseUrl: string;
let roomTypeId: string;
let receptionist: Record<string, string>;
let receptionist2: Record<string, string>;
let manager: Record<string, string>;
let staff: Record<string, string>;
let staffToken: string;
let n = 0;

const makeRoom = (data: Partial<Room> = {}) =>
  prisma.room.create({ data: { number: `S${tag}${++n}`, floor: 1, roomTypeId, ...data } });
const guest = { guestName: 'Nguyễn Văn Khách', guestCount: 2 };
const checkIn = (roomId: string, version: number, body: object = guest, auth = receptionist) =>
  request(app).post(`/api/rooms/${roomId}/check-in`).set(auth).send({ version, ...body });
const checkOut = (roomId: string, version: number, auth = receptionist) =>
  request(app).post(`/api/rooms/${roomId}/check-out`).set(auth).send({ version });

beforeAll(async () => {
  httpServer = createServer(app);
  attachRealtime(httpServer);
  await new Promise<void>((resolve) => httpServer.listen(0, resolve));
  baseUrl = `http://localhost:${(httpServer.address() as AddressInfo).port}`;

  roomTypeId = (await prisma.roomType.create({ data: { name: `CIO-${tag}` } })).id;
  receptionist = (await createUserWithToken('RECEPTIONIST')).auth;
  receptionist2 = (await createUserWithToken('RECEPTIONIST')).auth;
  manager = (await createUserWithToken('MANAGER')).auth;
  const s = await createUserWithToken('STAFF');
  staff = s.auth;
  staffToken = s.token;
});

afterAll(async () => {
  await closeRealtime();
  await new Promise((resolve) => httpServer.close(resolve));
  await prisma.$disconnect();
});

describe('Nhận phòng', () => {
  it('FR-003: phòng sẵn sàng → mở lượt lưu trú, phòng "đang ở", có nhật ký', async () => {
    const room = await makeRoom();
    const res = await checkIn(room.id, 1, { ...guest, note: 'Khách VIP' });

    expect(res.status).toBe(200);
    expect(res.body.data.room).toMatchObject({ occupancy: 'OCCUPIED', isReady: false, version: 2 });
    expect(res.body.data.stay).toMatchObject({ guestName: guest.guestName, guestCount: 2, status: 'OPEN', note: 'Khách VIP' });
    expect(await prisma.auditLog.count({ where: { roomId: room.id, action: 'stay.check_in' } })).toBe(1);
  });

  it('E-008 / BR-auth-roles-002: chỉ lễ tân nhận phòng — quản lý và nhân viên bị từ chối', async () => {
    const room = await makeRoom();
    for (const auth of [manager, staff]) {
      const res = await checkIn(room.id, 1, guest, auth);
      expect(res.status).toBe(403);
      expect(res.body.error.message).toBe(MSG.forbidden);
    }
  });

  it('SC-001 / E-001: phòng đang có khách → chặn, nêu đúng lý do', async () => {
    const room = await makeRoom({ occupancy: 'OCCUPIED' });
    expect((await checkIn(room.id, 1)).body.error.message).toBe(MSG.checkInOccupied);
  });

  it('SC-001 / E-002: phòng chưa sạch → chặn, kèm trạng thái vệ sinh', async () => {
    const room = await makeRoom({ cleaning: 'DIRTY' });
    expect((await checkIn(room.id, 1)).body.error.message).toBe('Phòng chưa dọn xong (Cần dọn) — không thể nhận.');
  });

  it('SC-001 / E-003: phòng ngừng phục vụ → chặn', async () => {
    const room = await makeRoom({ service: 'OUT_OF_SERVICE' });
    expect((await checkIn(room.id, 1)).body.error.message).toBe(MSG.checkInOutOfService);
  });

  it('E-004 / chốt 25/09: thiếu tên khách hoặc số người → từ chối, chỉ rõ trường', async () => {
    const room = await makeRoom();
    const noName = await checkIn(room.id, 1, { guestCount: 1 });
    const noCount = await checkIn(room.id, 1, { guestName: 'A' });
    expect(noName.body.error.details.fieldErrors.guestName).toContain(MSG.guestNameRequired);
    expect(noCount.body.error.details.fieldErrors.guestCount).toContain(MSG.guestCountInvalid);
  });

  it('FR-008 / SC-003: 2 lễ tân nhận cùng một phòng cùng lúc → đúng 1 người thành công, 1 lượt mở', async () => {
    const room = await makeRoom();
    const [a, b] = await Promise.all([checkIn(room.id, 1), checkIn(room.id, 1, guest, receptionist2)]);

    expect([a.status, b.status].sort()).toEqual([200, 409]);
    expect(await prisma.stay.count({ where: { roomId: room.id, status: 'OPEN' } })).toBe(1);
  });
});

describe('Trả phòng', () => {
  it('FR-004 / SC-002: đóng lượt → trống + "cần dọn" → hệ thống tạo đúng 1 việc dọn, hạn 60 phút', async () => {
    const room = await makeRoom();
    await checkIn(room.id, 1);
    const res = await checkOut(room.id, 2);

    expect(res.status).toBe(200);
    expect(res.body.data.room).toMatchObject({ occupancy: 'VACANT', cleaning: 'DIRTY', isReady: false });
    expect(res.body.data.stay).toMatchObject({ status: 'CLOSED' });
    expect(res.body.data.stay.checkedOutAt).toBeTruthy();

    const tasks = await prisma.housekeepingTask.findMany({ where: { roomId: room.id } });
    expect(tasks).toHaveLength(1);
    // Giao cho ai / chờ giao phụ thuộc người đang trực — kiểm chi tiết ở housekeeping.test.ts.
    expect(['ASSIGNED', 'UNASSIGNED']).toContain(tasks[0].status);
    const minutes = (tasks[0].dueAt.getTime() - tasks[0].createdAt.getTime()) / 60_000;
    expect(Math.round(minutes)).toBe(60);
  });

  it('FR-audit-log-002/003: một bản ghi liệt kê đủ thay đổi; việc dọn do "hệ thống" tạo', async () => {
    const room = await makeRoom();
    await checkIn(room.id, 1);
    await checkOut(room.id, 2);

    const log = await prisma.auditLog.findFirstOrThrow({ where: { roomId: room.id, action: 'stay.check_out' }, include: { changes: true } });
    expect(log.changes.map((c) => c.field).sort()).toEqual(['cleaning', 'occupancy', 'status']);
    const system = await prisma.auditLog.findFirstOrThrow({ where: { roomId: room.id, action: 'housekeeping.task_created' } });
    expect(system.actorRole).toBe('SYSTEM');
  });

  it('E-005: trả phòng đang trống → trạng thái không hợp lệ', async () => {
    const room = await makeRoom();
    expect((await checkOut(room.id, 1)).body.error.message).toBe(MSG.invalidState);
  });

  it('BR: phòng ngừng phục vụ mà đang có khách → trả bình thường, sau trả vẫn ngừng phục vụ', async () => {
    const room = await makeRoom();
    await checkIn(room.id, 1);
    await prisma.room.update({ where: { id: room.id }, data: { service: 'OUT_OF_SERVICE' } }); // version → 3
    const res = await checkOut(room.id, 3);
    expect(res.body.data.room).toMatchObject({ occupancy: 'VACANT', cleaning: 'DIRTY', service: 'OUT_OF_SERVICE' });
  });

  it('realtime: thiết bị khác nhận ngay trạng thái mới sau trả phòng', async () => {
    const room = await makeRoom();
    await checkIn(room.id, 1);
    const socket = connect(baseUrl, { auth: { token: staffToken }, forceNew: true });
    await new Promise<void>((resolve) => socket.once('connect', () => resolve()));
    const received = new Promise<{ room: { id: string; cleaning: string } }>((resolve) =>
      socket.on('room:updated', (payload) => payload.room.id === room.id && resolve(payload)),
    );

    await checkOut(room.id, 2);
    expect((await received).room.cleaning).toBe('DIRTY');
    socket.disconnect();
  });
});

describe('Danh sách phòng đang ở (FR-005)', () => {
  it('lễ tân + quản lý xem được phòng + khách + mốc nhận; nhân viên thì không', async () => {
    const room = await makeRoom();
    await checkIn(room.id, 1);

    const res = await request(app).get('/api/stays').set(manager);
    const mine = res.body.data.find((s: { room: { id: string } }) => s.room.id === room.id);
    expect(mine).toMatchObject({ guestName: guest.guestName, status: 'OPEN', room: { number: room.number } });
    expect(mine.checkedInAt).toBeTruthy();
    expect((await request(app).get('/api/stays').set(staff)).status).toBe(403);
  });
});
