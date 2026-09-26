/**
 * Đối chiếu docs/features/room-catalog/srs/room-catalog-spec.md (FR / E-xxx) + quyết định nhóm 25/09/2026:
 * chỉ quản lý thêm/sửa/xóa phòng; quản lý + lễ tân đặt/gỡ ngừng phục vụ.
 */
import { randomUUID } from 'node:crypto';
import type { Room } from '@prisma/client';
import request from 'supertest';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { createApp } from '../src/app.js';
import { MSG } from '../src/lib/messages.js';
import { prisma } from '../src/lib/prisma.js';
import { createUserWithToken } from './helpers.js';

const app = createApp();
const tag = randomUUID().slice(0, 6);
let roomTypeId: string;
let manager: Record<string, string>;
let receptionist: Record<string, string>;
let staff: Record<string, string>;
let managerId: string;
let n = 0;

const num = () => `C${tag}${++n}`;
const makeRoom = (data: Partial<Room> = {}) => prisma.room.create({ data: { number: num(), floor: 3, roomTypeId, ...data } });

beforeAll(async () => {
  roomTypeId = (await prisma.roomType.create({ data: { name: `CAT-${tag}` } })).id;
  const m = await createUserWithToken('MANAGER');
  manager = m.auth;
  managerId = m.user.id;
  receptionist = (await createUserWithToken('RECEPTIONIST')).auth;
  staff = (await createUserWithToken('STAFF')).auth;
});

afterAll(() => prisma.$disconnect());

describe('CORS (Flutter Web gọi API từ cổng khác)', () => {
  it('cho phép localhost khi dev', async () => {
    const res = await request(app).options('/api/rooms').set('Origin', 'http://localhost:5555').set('Access-Control-Request-Method', 'GET');
    expect(res.headers['access-control-allow-origin']).toBe('http://localhost:5555');
  });

  it('không cho origin lạ', async () => {
    const res = await request(app).options('/api/rooms').set('Origin', 'https://la.example').set('Access-Control-Request-Method', 'GET');
    expect(res.headers['access-control-allow-origin']).toBeUndefined();
  });
});

describe('Thêm phòng', () => {
  it('FR-001/002: quản lý thêm phòng → mặc định trống + sạch + bình thường, có nhật ký', async () => {
    const number = num();
    const res = await request(app).post('/api/rooms').set(manager).send({ number, floor: 2, roomTypeId });

    expect(res.status).toBe(201);
    expect(res.body.data).toMatchObject({ number, occupancy: 'VACANT', cleaning: 'CLEAN', service: 'IN_SERVICE', isReady: true, version: 1 });
    expect(await prisma.auditLog.count({ where: { roomId: res.body.data.id, action: 'room.created' } })).toBe(1);
  });

  it('chốt 25/09: lễ tân và nhân viên KHÔNG thêm được phòng', async () => {
    for (const auth of [receptionist, staff]) {
      const res = await request(app).post('/api/rooms').set(auth).send({ number: num(), floor: 2, roomTypeId });
      expect(res.status).toBe(403);
      expect(res.body.error.message).toBe(MSG.forbidden);
    }
  });

  it('E-001: số phòng trùng → từ chối', async () => {
    const room = await makeRoom();
    const res = await request(app).post('/api/rooms').set(manager).send({ number: room.number, floor: 2, roomTypeId });
    expect(res.status).toBe(409);
    expect(res.body.error.message).toBe(MSG.roomNumberTaken(room.number));
  });

  it('FR-010: không dùng được loại phòng đã tắt', async () => {
    const off = await prisma.roomType.create({ data: { name: `OFF-${tag}`, isActive: false } });
    const res = await request(app).post('/api/rooms').set(manager).send({ number: num(), floor: 2, roomTypeId: off.id });
    expect(res.body.error.message).toBe(MSG.roomTypeInactive);
  });

  it('FR-009: tạo theo dải → bỏ qua số đã có và báo rõ', async () => {
    const base = 900 + (Number.parseInt(tag, 16) % 50) * 10; // dải riêng cho mỗi lần chạy
    await makeRoom({ number: String(base + 2) });
    const res = await request(app)
      .post('/api/rooms/bulk')
      .set(manager)
      .send({ floor: 9, from: base, to: base + 4, roomTypeId });

    expect(res.status).toBe(201);
    expect(res.body.data.created).toHaveLength(4);
    expect(res.body.data.skipped).toEqual([String(base + 2)]);
    expect(res.body.data.message).toBe(MSG.bulkCreated(4, [String(base + 2)]));
  });
});

describe('Sửa phòng', () => {
  it('FR-003: đổi số phòng → nhật ký giữ nhãn cũ, ghi trước→sau', async () => {
    const room = await makeRoom();
    const newNumber = num();
    const res = await request(app).patch(`/api/rooms/${room.id}`).set(manager).send({ version: room.version, number: newNumber });

    expect(res.body.data).toMatchObject({ number: newNumber, version: 2 });
    const log = await prisma.auditLog.findFirstOrThrow({ where: { roomId: room.id, action: 'room.updated' }, include: { changes: true } });
    expect(log.entityLabel).toBe(`Phòng ${room.number}`);
    expect(log.changes).toEqual([expect.objectContaining({ field: 'number', before: room.number, after: newNumber })]);
  });

  it('chống ghi đè: sửa bằng version cũ → 409 kèm bản mới', async () => {
    const room = await makeRoom();
    await request(app).patch(`/api/rooms/${room.id}`).set(manager).send({ version: 1, floor: 4 });
    const res = await request(app).patch(`/api/rooms/${room.id}`).set(manager).send({ version: 1, floor: 5 });
    expect(res.status).toBe(409);
    expect(res.body.error.details.current).toMatchObject({ floor: 4, version: 2 });
  });
});

describe('Xóa phòng (FR-004)', () => {
  it('phòng mới, chưa có hoạt động → xóa được (nhật ký "tạo phòng" không tính là lịch sử hoạt động)', async () => {
    const created = await request(app).post('/api/rooms').set(manager).send({ number: num(), floor: 2, roomTypeId });
    const res = await request(app).delete(`/api/rooms/${created.body.data.id}`).set(manager).send({ version: 1 });

    expect(res.status).toBe(204);
    expect(await prisma.room.findUnique({ where: { id: created.body.data.id } })).toBeNull();
    // Nhật ký vẫn còn nguyên sau khi xóa phòng (NFR-audit-log-002).
    expect(await prisma.auditLog.count({ where: { roomId: created.body.data.id } })).toBe(2);
  });

  it('E-002: phòng đang có khách → không xóa', async () => {
    const room = await makeRoom({ occupancy: 'OCCUPIED' });
    const res = await request(app).delete(`/api/rooms/${room.id}`).set(manager).send({ version: 1 });
    expect(res.body.error.message).toBe(MSG.roomDeleteBusy);
  });

  it('E-003: phòng đã có lịch sử (từng có khách) → không xóa, gợi ý ngừng phục vụ', async () => {
    const room = await makeRoom();
    await prisma.stay.create({ data: { roomId: room.id, guestName: 'Cũ', checkedInById: managerId, status: 'CLOSED' } });
    const res = await request(app).delete(`/api/rooms/${room.id}`).set(manager).send({ version: 1 });
    expect(res.body.error.message).toBe(MSG.roomDeleteHasHistory);
  });
});

describe('Ngừng phục vụ thủ công (FR-007/008)', () => {
  it('lễ tân đặt ngừng phục vụ kèm lý do → phòng hết "sẵn sàng"', async () => {
    const room = await makeRoom();
    const res = await request(app)
      .post(`/api/rooms/${room.id}/out-of-service`)
      .set(receptionist)
      .send({ version: 1, reason: 'Sơn lại tường' });
    expect(res.body.data).toMatchObject({ service: 'OUT_OF_SERVICE', isReady: false });
  });

  it('E-004: thiếu lý do → từ chối', async () => {
    const room = await makeRoom();
    const res = await request(app).post(`/api/rooms/${room.id}/out-of-service`).set(manager).send({ version: 1, reason: ' ' });
    expect(res.body.error.details.fieldErrors.reason).toContain(MSG.outOfServiceReasonRequired);
  });

  it('phòng đang có khách → phải xác nhận lại', async () => {
    const room = await makeRoom({ occupancy: 'OCCUPIED' });
    const first = await request(app).post(`/api/rooms/${room.id}/out-of-service`).set(manager).send({ version: 1, reason: 'Hỏng điều hòa' });
    expect(first.body.error.code).toBe('OCCUPIED_CONFIRM_REQUIRED');

    const confirmed = await request(app)
      .post(`/api/rooms/${room.id}/out-of-service`)
      .set(manager)
      .send({ version: 1, reason: 'Hỏng điều hòa', confirmOccupied: true });
    expect(confirmed.body.data).toMatchObject({ occupancy: 'OCCUPIED', service: 'OUT_OF_SERVICE' });
  });

  it('nhân viên buồng phòng–bảo trì không đặt được', async () => {
    const room = await makeRoom();
    const res = await request(app).post(`/api/rooms/${room.id}/out-of-service`).set(staff).send({ version: 1, reason: 'x' });
    expect(res.status).toBe(403);
  });

  it('gỡ ngừng phục vụ → phòng lại "sẵn sàng"', async () => {
    const room = await makeRoom();
    await request(app).post(`/api/rooms/${room.id}/out-of-service`).set(manager).send({ version: 1, reason: 'Kiểm tra' });
    const res = await request(app).post(`/api/rooms/${room.id}/back-in-service`).set(receptionist).send({ version: 2 });
    expect(res.body.data).toMatchObject({ service: 'IN_SERVICE', isReady: true });
  });

  it('FR-maintenance-007: còn việc bảo trì đang mở → chưa gỡ được', async () => {
    const room = await makeRoom();
    await request(app).post(`/api/rooms/${room.id}/out-of-service`).set(manager).send({ version: 1, reason: 'Kiểm tra' });
    await prisma.maintenanceTask.create({ data: { roomId: room.id, description: 'Rò nước', reporterId: managerId } });
    const res = await request(app).post(`/api/rooms/${room.id}/back-in-service`).set(manager).send({ version: 2 });
    expect(res.body.error.message).toBe(MSG.roomHasOpenMaintenance);
  });

  it('E-006: gỡ khi không có lần ngừng tay nào → trạng thái không hợp lệ', async () => {
    const room = await makeRoom();
    const res = await request(app).post(`/api/rooms/${room.id}/back-in-service`).set(manager).send({ version: 1 });
    expect(res.body.error.message).toBe(MSG.invalidState);
  });
});

describe('Lọc & loại phòng', () => {
  it('?ready=true → chỉ phòng sẵn sàng', async () => {
    const res = await request(app).get('/api/rooms?ready=true').set(staff);
    expect(res.body.data.length).toBeGreaterThan(0);
    expect(res.body.data.every((r: { isReady: boolean }) => r.isReady)).toBe(true);
  });

  it('FR-010: mọi vai trò xem loại phòng; chỉ quản lý thêm; trùng tên bị từ chối', async () => {
    expect((await request(app).get('/api/room-types').set(staff)).status).toBe(200);
    expect((await request(app).post('/api/room-types').set(receptionist).send({ name: `X-${tag}` })).status).toBe(403);
    expect((await request(app).post('/api/room-types').set(manager).send({ name: `Mới-${tag}` })).status).toBe(201);
    const dup = await request(app).post('/api/room-types').set(manager).send({ name: `Mới-${tag}` });
    expect(dup.body.error.message).toBe(MSG.roomTypeTaken(`Mới-${tag}`));
  });
});
