/**
 * Đối chiếu docs/features/maintenance/srs/maintenance-spec.md (FR-001…012).
 * OQ chưa chốt được giữ trung lập: tự nhận (URD) + chỉ định (FR-009); ngưỡng quá hạn là cấu hình.
 */
import { randomUUID } from 'node:crypto';
import type { Room, User } from '@prisma/client';
import request from 'supertest';
import { afterAll, afterEach, beforeAll, describe, expect, it } from 'vitest';
import { createApp } from '../src/app.js';
import { MSG } from '../src/lib/messages.js';
import { prisma } from '../src/lib/prisma.js';
import { createUserWithToken } from './helpers.js';

type Actor = { user: User; auth: Record<string, string> };

const app = createApp();
const tag = randomUUID().slice(0, 6);
let roomTypeId: string;
let manager: Actor;
let receptionist: Actor;
let staffA: Actor;
let staffB: Actor;
let n = 0;

const makeRoom = (data: Partial<Room> = {}) =>
  prisma.room.create({ data: { number: `M${tag}${++n}`, floor: 3, roomTypeId, ...data } });
const report = (actor: Actor, roomId: string, description = 'Vòi sen bị rò nước', location?: string) =>
  request(app).post('/api/maintenance/tasks').set(actor.auth).send({ roomId, description, location });
const act = (actor: Actor, taskId: string, action: string, body: object) =>
  request(app).post(`/api/maintenance/tasks/${taskId}/${action}`).set(actor.auth).send(body);
const roomOf = (id: string) => prisma.room.findUniqueOrThrow({ where: { id } });

beforeAll(async () => {
  roomTypeId = (await prisma.roomType.create({ data: { name: `MT-${tag}` } })).id;
  manager = await createUserWithToken('MANAGER');
  receptionist = await createUserWithToken('RECEPTIONIST');
  staffA = await createUserWithToken('STAFF', { fullName: 'Bảo trì A' });
  staffB = await createUserWithToken('STAFF', { fullName: 'Bảo trì B' });
});

afterEach(() => {
  delete process.env.MAINTENANCE_DUE_MINUTES;
});

afterAll(() => prisma.$disconnect());

describe('Báo hỏng (FR-001, FR-002, FR-008)', () => {
  it('mọi vai trò báo hỏng được → "chờ nhận"; phòng lập tức "ngừng phục vụ"', async () => {
    for (const actor of [staffA, receptionist, manager]) {
      const room = await makeRoom();
      const res = await report(actor, room.id, 'Điều hòa không lạnh', 'Phòng ngủ');
      expect(res.status).toBe(201);
      expect(res.body.data.task).toMatchObject({ status: 'OPEN', location: 'Phòng ngủ', reporter: { id: actor.user.id } });
      expect((await roomOf(room.id)).service).toBe('OUT_OF_SERVICE');
    }
  });

  it('FR-002: phòng có việc bảo trì mở → không nhận khách được', async () => {
    const room = await makeRoom();
    await report(staffA, room.id);
    const res = await request(app).post(`/api/rooms/${room.id}/check-in`).set(receptionist.auth).send({ version: 2, guestName: 'A', guestCount: 1 });
    expect(res.body.error.message).toBe(MSG.checkInOutOfService);
  });

  it('FR-008: phòng đã có việc mở vẫn báo được, kèm cảnh báo nhẹ', async () => {
    const room = await makeRoom();
    await report(staffA, room.id);
    const second = await report(staffB, room.id, 'Bóng đèn cháy');
    expect(second.status).toBe(201);
    expect(second.body.data.warning).toBe(MSG.maintenanceAlreadyOpen);
  });

  it('mô tả tối đa 500 ký tự', async () => {
    const room = await makeRoom();
    expect((await report(staffA, room.id, 'x'.repeat(501))).status).toBe(400);
  });
});

describe('Nhận & sửa (FR-003, FR-004, FR-005)', () => {
  it('nhân viên nhận → "đang sửa" + là người xử lý; người khác không nhận lại được', async () => {
    const room = await makeRoom();
    const task = (await report(receptionist, room.id)).body.data.task;
    const claimed = await act(staffA, task.id, 'claim', { version: task.version });
    expect(claimed.body.data).toMatchObject({ status: 'IN_PROGRESS', assignee: { id: staffA.user.id } });

    const again = await act(staffB, task.id, 'claim', { version: claimed.body.data.version });
    expect(again.body.error.message).toBe(MSG.invalidState);
  });

  it('chỉ người đang sửa báo hoàn tất được; xong hết việc → phòng mở lại phục vụ', async () => {
    const room = await makeRoom();
    const task = (await report(receptionist, room.id)).body.data.task;
    const claimed = (await act(staffA, task.id, 'claim', { version: task.version })).body.data;

    expect((await act(staffB, task.id, 'complete', { version: claimed.version })).status).toBe(403);
    const done = await act(staffA, task.id, 'complete', { version: claimed.version });
    expect(done.body.data.status).toBe('DONE');
    expect((await roomOf(room.id)).service).toBe('IN_SERVICE');
  });

  it('FR-003: còn ngừng phục vụ tay → hoàn tất việc sửa vẫn giữ "ngừng phục vụ"', async () => {
    const room = await makeRoom();
    await request(app).post(`/api/rooms/${room.id}/out-of-service`).set(manager.auth).send({ version: 1, reason: 'Sơn lại' });
    const task = (await report(staffA, room.id)).body.data.task;
    const claimed = (await act(staffA, task.id, 'claim', { version: task.version })).body.data;
    await act(staffA, task.id, 'complete', { version: claimed.version });
    expect((await roomOf(room.id)).service).toBe('OUT_OF_SERVICE');
  });

  it('FR-003: 2 việc mở → xong 1 việc phòng vẫn ngừng phục vụ', async () => {
    const room = await makeRoom();
    const first = (await report(staffA, room.id)).body.data.task;
    await report(staffA, room.id, 'Bóng đèn cháy');
    const claimed = (await act(staffA, first.id, 'claim', { version: first.version })).body.data;
    await act(staffA, first.id, 'complete', { version: claimed.version });
    expect((await roomOf(room.id)).service).toBe('OUT_OF_SERVICE');
  });
});

describe('Hủy & chỉ định (FR-006, FR-009)', () => {
  it('người báo hủy được việc "chờ nhận" → phòng mở lại', async () => {
    const room = await makeRoom();
    const task = (await report(receptionist, room.id)).body.data.task;
    const res = await act(receptionist, task.id, 'cancel', { version: task.version, reason: 'Báo nhầm phòng' });
    expect(res.body.data).toMatchObject({ status: 'CANCELLED', cancelReason: 'Báo nhầm phòng' });
    expect((await roomOf(room.id)).service).toBe('IN_SERVICE');
  });

  it('việc "đang sửa": người báo không hủy được, chỉ quản lý', async () => {
    const room = await makeRoom();
    const task = (await report(receptionist, room.id)).body.data.task;
    const claimed = (await act(staffA, task.id, 'claim', { version: task.version })).body.data;
    expect((await act(receptionist, task.id, 'cancel', { version: claimed.version })).status).toBe(403);
    expect((await act(manager, task.id, 'cancel', { version: claimed.version })).body.data.status).toBe('CANCELLED');
  });

  it('lễ tân chỉ định người xử lý → người khác không nhận được', async () => {
    const room = await makeRoom();
    const task = (await report(manager, room.id)).body.data.task;
    const assigned = await act(receptionist, task.id, 'assign', { version: task.version, assigneeId: staffB.user.id });
    expect(assigned.body.data.assignee.id).toBe(staffB.user.id);

    const other = await act(staffA, task.id, 'claim', { version: assigned.body.data.version });
    expect(other.body.error.message).toBe(MSG.maintenanceAssignedToOther);
    expect((await act(staffB, task.id, 'claim', { version: assigned.body.data.version })).status).toBe(200);
  });

  it('FR-012: lọc theo trạng thái / phòng', async () => {
    const room = await makeRoom();
    await report(staffA, room.id);
    const res = await request(app).get(`/api/maintenance/tasks?roomId=${room.id}&status=OPEN`).set(staffB.auth);
    expect(res.body.data).toHaveLength(1);
  });
});

describe('Quá hạn (FR-010, OQ-1 = cấu hình)', () => {
  it('chưa cấu hình ngưỡng → không tính quá hạn', async () => {
    const room = await makeRoom();
    const task = (await report(staffA, room.id)).body.data.task;
    expect(task.dueAt).toBeNull();
  });
});
