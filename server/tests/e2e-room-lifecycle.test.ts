/**
 * Luồng vận hành khép kín (tôn chỉ / PRD §7): nhận phòng → trả phòng → hệ thống tạo & giao việc dọn
 * → nhân viên nhận → báo xong → quản lý xác nhận → phòng sẵn sàng → nhận khách lần sau.
 * Kèm đối soát NFR-audit-log-001: chuỗi nhật ký trục vệ sinh dẫn đúng tới trạng thái hiện tại.
 */
import { randomUUID } from 'node:crypto';
import request from 'supertest';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { createApp } from '../src/app.js';
import { prisma } from '../src/lib/prisma.js';
import { REQUIRED_PHOTO_CATEGORIES, TEST_JPEG, createUserWithToken } from './helpers.js';

const app = createApp();
const tag = randomUUID().slice(0, 6);

afterAll(() => prisma.$disconnect());

describe('Vòng đời một phòng', () => {
  let roomId: string;
  let receptionist: Record<string, string>;
  let manager: Record<string, string>;
  let staff: Record<string, string>;
  let staffId: string;

  beforeAll(async () => {
    const typeId = (await prisma.roomType.create({ data: { name: `E2E-${tag}` } })).id;
    roomId = (await prisma.room.create({ data: { number: `E${tag}`, floor: 1, roomTypeId: typeId } })).id;
    receptionist = (await createUserWithToken('RECEPTIONIST')).auth;
    manager = (await createUserWithToken('MANAGER')).auth;
    await prisma.user.updateMany({ where: { role: 'STAFF' }, data: { onDuty: false } });
    const s = await createUserWithToken('STAFF', { onDuty: true, fullName: 'NV E2E' });
    staff = s.auth;
    staffId = s.user.id;
  });

  it('chạy trọn vòng và phòng nhận khách lại được', async () => {
    const room = () => request(app).get(`/api/rooms/${roomId}`).set(receptionist).then((r) => r.body.data);

    // 1. Nhận phòng
    let r = await room();
    expect(r.isReady).toBe(true);
    expect((await request(app).post(`/api/rooms/${roomId}/check-in`).set(receptionist).send({ version: r.version, guestName: 'Khách 1', guestCount: 2 })).status).toBe(200);

    // 2. Trả phòng → việc dọn được tạo và giao ngay cho nhân viên đang trực
    r = await room();
    const out = await request(app).post(`/api/rooms/${roomId}/check-out`).set(receptionist).send({ version: r.version });
    let task = out.body.data.housekeepingTask;
    expect(task).toMatchObject({ status: 'ASSIGNED', assignee: { id: staffId } });
    expect((await room()).cleaning).toBe('DIRTY');

    // 3. Nhân viên thấy việc của mình, nhận, báo xong
    const mine = await request(app).get('/api/housekeeping/tasks?mine=true').set(staff);
    expect(mine.body.data.map((t: { id: string }) => t.id)).toContain(task.id);
    task = (await request(app).post(`/api/housekeeping/tasks/${task.id}/accept`).set(staff).send({ version: task.version })).body.data;
    expect((await room()).cleaning).toBe('CLEANING');
    for (const category of REQUIRED_PHOTO_CATEGORIES) {
      const photo = await request(app).post(`/api/housekeeping/tasks/${task.id}/photos?category=${category}`).set(staff).set('Content-Type', 'image/jpeg').send(TEST_JPEG);
      expect(photo.status).toBe(201);
    }
    task =(await request(app).post(`/api/housekeeping/tasks/${task.id}/complete`).set(staff).send({ version: task.version })).body.data;
    expect((await room()).cleaning).toBe('PENDING_INSPECTION');

    // Chưa xác nhận → vẫn chưa nhận khách được (SC-housekeeping-03)
    r = await room();
    const early = await request(app).post(`/api/rooms/${roomId}/check-in`).set(receptionist).send({ version: r.version, guestName: 'Khách 2', guestCount: 1 });
    expect(early.status).toBe(409);

    // 4. Quản lý xác nhận → phòng sẵn sàng
    task = (await request(app).post(`/api/housekeeping/tasks/${task.id}/confirm`).set(manager).send({ version: task.version })).body.data;
    expect(task.status).toBe('DONE');
    r = await room();
    expect(r).toMatchObject({ occupancy: 'VACANT', cleaning: 'CLEAN', service: 'IN_SERVICE', isReady: true });

    // 5. Nhận khách lần sau
    expect((await request(app).post(`/api/rooms/${roomId}/check-in`).set(receptionist).send({ version: r.version, guestName: 'Khách 2', guestCount: 1 })).status).toBe(200);
  });

  it('NFR-audit-log-001: chuỗi nhật ký trục vệ sinh (trước → sau) dẫn đúng tới trạng thái hiện tại', async () => {
    const changes = await prisma.auditLogChange.findMany({
      where: { field: 'cleaning', OR: [{ auditLog: { entityType: 'ROOM', entityId: roomId }, entityId: null }, { entityId: roomId }] },
      include: { auditLog: true },
      orderBy: [{ auditLog: { occurredAt: 'asc' } }, { position: 'asc' }],
    });
    const chain = changes.map((c) => `${c.before}→${c.after}`);
    expect(chain).toEqual(['CLEAN→DIRTY', 'DIRTY→CLEANING', 'CLEANING→PENDING_INSPECTION', 'PENDING_INSPECTION→CLEAN']);
    const current = await prisma.room.findUniqueOrThrow({ where: { id: roomId } });
    expect(changes.at(-1)!.after).toBe(current.cleaning);
  });
});
