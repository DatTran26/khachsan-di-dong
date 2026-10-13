/**
 * Đối chiếu docs/features/housekeeping/srs/housekeeping-spec.md (FR / BR / E-xxx / SC) + housekeeping-states.md.
 */
import { randomUUID } from 'node:crypto';
import { createServer, type Server as HttpServer } from 'node:http';
import type { AddressInfo } from 'node:net';
import type { User } from '@prisma/client';
import { io as connect, type Socket } from 'socket.io-client';
import request from 'supertest';
import { afterAll, beforeAll, beforeEach, describe, expect, it } from 'vitest';
import { createApp } from '../src/app.js';
import { flagOverdueTasks } from '../src/jobs/overdue.js';
import { MSG } from '../src/lib/messages.js';
import { prisma } from '../src/lib/prisma.js';
import { attachRealtime, closeRealtime } from '../src/realtime/socket.js';
import { REQUIRED_PHOTO_CATEGORIES, TEST_JPEG, createUserWithToken } from './helpers.js';

type Actor = { user: User; token: string; auth: Record<string, string> };
type Note = { kind: string; message: string; taskId?: string };

const app = createApp();
const tag = randomUUID().slice(0, 6);
let httpServer: HttpServer;
let baseUrl: string;
let roomTypeId: string;
let manager: Actor;
let receptionist: Actor;
let staffA: Actor;
let staffB: Actor;
const sockets: Socket[] = [];
const inbox = new Map<string, Note[]>(); // userId → thông báo đã nhận
let n = 0;

async function listen(actor: Actor) {
  const socket = connect(baseUrl, { auth: { token: actor.token }, forceNew: true });
  inbox.set(actor.user.id, []);
  socket.on('notification', (note: Note) => inbox.get(actor.user.id)!.push(note));
  await new Promise<void>((resolve) => socket.once('connect', () => resolve()));
  sockets.push(socket);
}

/** Chờ tới khi người dùng nhận được thông báo loại `kind` (tối đa 3 giây). */
async function waitForNote(userId: string, kind: string) {
  for (let i = 0; i < 30; i++) {
    const note = inbox.get(userId)!.find((x) => x.kind === kind);
    if (note) return note;
    await new Promise((resolve) => setTimeout(resolve, 100));
  }
  return undefined;
}

const setOnDuty = (ids: string[], onDuty: boolean) => prisma.user.updateMany({ where: { id: { in: ids } }, data: { onDuty } });

/** Tạo phòng đang có khách rồi trả phòng qua API thật → hệ thống tạo + tự giao việc dọn. */
async function checkedOutRoom() {
  const room = await prisma.room.create({
    data: { number: `H${tag}${++n}`, floor: 2, roomTypeId, occupancy: 'OCCUPIED' },
  });
  await prisma.stay.create({ data: { roomId: room.id, guestName: 'Khách', checkedInById: receptionist.user.id } });
  const res = await request(app).post(`/api/rooms/${room.id}/check-out`).set(receptionist.auth).send({ version: 1 });
  expect(res.status).toBe(200);
  return { room, task: res.body.data.housekeepingTask as { id: string; status: string; version: number; assignee: { id: string } | null } };
}

const act = (actor: Actor, taskId: string, action: string, body: object) =>
  request(app).post(`/api/housekeeping/tasks/${taskId}/${action}`).set(actor.auth).send(body);
/** Tải đủ bộ ảnh bắt buộc của lượt hiện tại rồi báo dọn xong. */
async function completeWithPhotos(actor: Actor, taskId: string, version: number) {
  for (const category of REQUIRED_PHOTO_CATEGORIES) {
    const res = await request(app)
      .post(`/api/housekeeping/tasks/${taskId}/photos?category=${category}`)
      .set(actor.auth)
      .set('Content-Type', 'image/jpeg')
      .send(TEST_JPEG);
    expect(res.status).toBe(201);
  }
  return act(actor, taskId, 'complete', { version });
}
const taskOf = (id: string) => prisma.housekeepingTask.findUniqueOrThrow({ where: { id } });
const roomOf = (id: string) => prisma.room.findUniqueOrThrow({ where: { id } });

beforeAll(async () => {
  httpServer = createServer(app);
  attachRealtime(httpServer);
  await new Promise<void>((resolve) => httpServer.listen(0, resolve));
  baseUrl = `http://localhost:${(httpServer.address() as AddressInfo).port}`;

  roomTypeId = (await prisma.roomType.create({ data: { name: `HK-${tag}` } })).id;
  manager = await createUserWithToken('MANAGER');
  receptionist = await createUserWithToken('RECEPTIONIST');
  staffA = await createUserWithToken('STAFF', { fullName: 'NV A' });
  staffB = await createUserWithToken('STAFF', { fullName: 'NV B' });
  for (const actor of [manager, staffA, staffB]) await listen(actor);
});

beforeEach(async () => {
  // Chỉ A và B trực, không còn việc mở cũ → kết quả chia việc xác định.
  await prisma.user.updateMany({ where: { role: 'STAFF' }, data: { onDuty: false } });
  await setOnDuty([staffA.user.id, staffB.user.id], true);
  await prisma.housekeepingTask.updateMany({ where: { status: { not: 'DONE' } }, data: { status: 'DONE' } });
  for (const box of inbox.values()) box.length = 0;
});

afterAll(async () => {
  for (const socket of sockets) socket.disconnect();
  await closeRealtime();
  await new Promise((resolve) => httpServer.close(resolve));
  await prisma.$disconnect();
});

describe('Tạo & tự giao việc (FR-001…003, BR-004)', () => {
  it('trả phòng → đúng 1 việc, giao ngay cho người trực, người đó nhận thông báo', async () => {
    const { room, task } = await checkedOutRoom();

    expect(task.status).toBe('ASSIGNED');
    expect([staffA.user.id, staffB.user.id]).toContain(task.assignee!.id);
    expect(await prisma.housekeepingTask.count({ where: { roomId: room.id } })).toBe(1);
    const note = await waitForNote(task.assignee!.id, 'HOUSEKEEPING_ASSIGNED');
    expect(note?.message).toBe(MSG.taskAssignedToYou(`Phòng ${room.number}`));
  });

  it('chia đều: người đang ít việc mở hơn được giao', async () => {
    const first = await checkedOutRoom();
    const second = await checkedOutRoom();
    expect(second.task.assignee!.id).not.toBe(first.task.assignee!.id);
  });

  it('hòa số việc → người lâu nhất chưa được giao', async () => {
    const first = await checkedOutRoom(); // người X nhận
    await prisma.housekeepingTask.update({ where: { id: first.task.id }, data: { status: 'DONE' } }); // X hết việc → hòa 0–0
    const second = await checkedOutRoom();
    expect(second.task.assignee!.id).not.toBe(first.task.assignee!.id);
  });

  it('FR-003 / E-002: không ai trực → "chờ giao" + cảnh báo quản lý; có người vào trực → tự giao', async () => {
    await setOnDuty([staffA.user.id, staffB.user.id], false);
    const { task } = await checkedOutRoom();
    expect(task.status).toBe('UNASSIGNED');
    expect((await waitForNote(manager.user.id, 'HOUSEKEEPING_UNASSIGNED'))?.message).toBe(MSG.noStaffOnDuty);

    const b = await prisma.user.findUniqueOrThrow({ where: { id: staffB.user.id } });
    await request(app).patch(`/api/users/${b.id}`).set(manager.auth).send({ version: b.version, onDuty: true });
    expect(await taskOf(task.id)).toMatchObject({ status: 'ASSIGNED', assigneeId: staffB.user.id });
  });
});

describe('Nhân viên nhận / từ chối / báo xong (FR-004, FR-005, FR-012)', () => {
  it('nhận việc → "đang làm", phòng → "đang dọn"', async () => {
    const { room, task } = await checkedOutRoom();
    const owner = task.assignee!.id === staffA.user.id ? staffA : staffB;
    const res = await act(owner, task.id, 'accept', { version: task.version });

    expect(res.body.data.status).toBe('IN_PROGRESS');
    expect((await roomOf(room.id)).cleaning).toBe('CLEANING');
  });

  it('E-006: nhân viên khác không thao tác được việc không phải của mình', async () => {
    const { task } = await checkedOutRoom();
    const other = task.assignee!.id === staffA.user.id ? staffB : staffA;
    const res = await act(other, task.id, 'accept', { version: task.version });
    expect(res.status).toBe(403);
  });

  it('E-001 / FR-012: nhận 2 lần cùng lúc (2 thiết bị) → đúng 1 lần thành công', async () => {
    const { task } = await checkedOutRoom();
    const owner = task.assignee!.id === staffA.user.id ? staffA : staffB;
    const [a, b] = await Promise.all([
      act(owner, task.id, 'accept', { version: task.version }),
      act(owner, task.id, 'accept', { version: task.version }),
    ]);
    expect([a.status, b.status].sort()).toEqual([200, 409]);
  });

  it('từ chối → giao cho người trực kế tiếp', async () => {
    const { task } = await checkedOutRoom();
    const owner = task.assignee!.id === staffA.user.id ? staffA : staffB;
    const res = await act(owner, task.id, 'reject', { version: task.version });
    expect(res.body.data.status).toBe('ASSIGNED');
    expect(res.body.data.assignee.id).not.toBe(owner.user.id);
  });

  it('từ chối mà không còn ai trực → "chờ giao"', async () => {
    const { task } = await checkedOutRoom();
    const owner = task.assignee!.id === staffA.user.id ? staffA : staffB;
    await setOnDuty([owner === staffA ? staffB.user.id : staffA.user.id], false);
    const res = await act(owner, task.id, 'reject', { version: task.version });
    expect(res.body.data).toMatchObject({ status: 'UNASSIGNED', assignee: null });
  });

  it('báo hoàn tất → "chờ xác nhận", phòng "chờ kiểm tra", quản lý được báo', async () => {
    const { room, task } = await checkedOutRoom();
    const owner = task.assignee!.id === staffA.user.id ? staffA : staffB;
    await act(owner, task.id, 'accept', { version: task.version });
    const res = await completeWithPhotos(owner, task.id, task.version + 1);

    expect(res.body.data.status).toBe('PENDING_CONFIRM');
    expect((await roomOf(room.id)).cleaning).toBe('PENDING_INSPECTION');
    expect(await waitForNote(manager.user.id, 'HOUSEKEEPING_PENDING_CONFIRM')).toBeDefined();
  });

  it('chuyển trạng thái sai thứ tự → từ chối (báo xong khi chưa nhận)', async () => {
    const { task } = await checkedOutRoom();
    const owner = task.assignee!.id === staffA.user.id ? staffA : staffB;
    const res = await act(owner, task.id, 'complete', { version: task.version });
    expect(res.body.error.message).toBe(MSG.invalidState);
  });
});

describe('Quản lý xác nhận / trả lại / phân công lại (FR-006, FR-009, BR-001, BR-005)', () => {
  async function pendingTask() {
    const { room, task } = await checkedOutRoom();
    const owner = task.assignee!.id === staffA.user.id ? staffA : staffB;
    await act(owner, task.id, 'accept', { version: task.version });
    await completeWithPhotos(owner, task.id, task.version + 1);
    return { room, task: await taskOf(task.id), owner };
  }

  it('BR-001: chỉ quản lý xác nhận — nhân viên, lễ tân bị từ chối', async () => {
    const { task, owner } = await pendingTask();
    expect((await act(owner, task.id, 'confirm', { version: task.version })).status).toBe(403);
    expect((await act(receptionist, task.id, 'confirm', { version: task.version })).status).toBe(403);
  });

  it('SC-03: quản lý xác nhận → "hoàn tất", phòng "sạch" và sẵn sàng', async () => {
    const { room, task } = await pendingTask();
    const res = await act(manager, task.id, 'confirm', { version: task.version });

    expect(res.body.data.status).toBe('DONE');
    const after = await roomOf(room.id);
    expect(after).toMatchObject({ occupancy: 'VACANT', cleaning: 'CLEAN', service: 'IN_SERVICE' });
  });

  it('E-005: trả lại thiếu ghi chú → từ chối', async () => {
    const { task } = await pendingTask();
    const res = await act(manager, task.id, 'return', { version: task.version, note: ' ' });
    expect(res.body.error.details.fieldErrors.note).toContain(MSG.returnNoteRequired);
  });

  it('trả lại kèm ghi chú → "đang làm", phòng "đang dọn", nhân viên nhận ghi chú', async () => {
    const { room, task, owner } = await pendingTask();
    const res = await act(manager, task.id, 'return', { version: task.version, note: 'Chưa thay khăn tắm' });

    expect(res.body.data).toMatchObject({ status: 'IN_PROGRESS', returnNote: 'Chưa thay khăn tắm' });
    expect((await roomOf(room.id)).cleaning).toBe('CLEANING');
    const note = await waitForNote(owner.user.id, 'HOUSEKEEPING_RETURNED');
    expect(note?.message).toBe(MSG.taskReturned(`Phòng ${room.number}`, 'Chưa thay khăn tắm'));
  });

  it('FR-009: quản lý phân công lại → đổi người, có nhật ký', async () => {
    const { task } = await checkedOutRoom();
    const other = task.assignee!.id === staffA.user.id ? staffB : staffA;
    const res = await act(manager, task.id, 'reassign', { version: task.version, assigneeId: other.user.id });

    expect(res.body.data.assignee.id).toBe(other.user.id);
    expect(await prisma.auditLog.count({ where: { entityId: task.id, action: 'housekeeping.task_reassigned' } })).toBe(1);
  });
});

describe('Ảnh nghiệm thu (FR-005, FR-007, FR-015, BR-006, NFR-006, E-007)', () => {
  const upload = (actor: Actor, taskId: string, category: string, body: Buffer = TEST_JPEG) =>
    request(app)
      .post(`/api/housekeeping/tasks/${taskId}/photos?category=${category}`)
      .set(actor.auth)
      .set('Content-Type', 'image/jpeg')
      .send(body);
  const photosOf = (actor: Actor, taskId: string) =>
    request(app).get(`/api/housekeeping/tasks/${taskId}/photos`).set(actor.auth);

  /** Việc "đang làm" của nhân viên phụ trách. */
  async function inProgressTask() {
    const { room, task } = await checkedOutRoom();
    const owner = task.assignee!.id === staffA.user.id ? staffA : staffB;
    const other = owner === staffA ? staffB : staffA;
    await act(owner, task.id, 'accept', { version: task.version });
    return { room, task: await taskOf(task.id), owner, other };
  }

  it('E-007: thiếu nhóm ảnh bắt buộc → không báo xong được, việc vẫn "đang làm"', async () => {
    const { task, owner } = await inProgressTask();
    await upload(owner, task.id, 'OVERVIEW');
    await upload(owner, task.id, 'BED');
    const res = await act(owner, task.id, 'complete', { version: task.version });

    expect(res.status).toBe(400);
    expect(res.body.error).toMatchObject({ code: 'PHOTOS_REQUIRED', message: MSG.photosRequired });
    expect((await taskOf(task.id)).status).toBe('IN_PROGRESS');
  });

  it('BR-006: đánh dấu bất thường → bắt buộc ảnh cận cảnh', async () => {
    const { task, owner } = await inProgressTask();
    for (const category of REQUIRED_PHOTO_CATEGORIES) await upload(owner, task.id, category);

    const missing = await act(owner, task.id, 'complete', { version: task.version, hasIssue: true });
    expect(missing.body.error).toMatchObject({ code: 'CLOSEUP_REQUIRED', message: MSG.closeupRequired });

    expect((await upload(owner, task.id, 'CLOSEUP')).status).toBe(201);
    const ok = await act(owner, task.id, 'complete', { version: task.version, hasIssue: true });
    expect(ok.body.data).toMatchObject({ status: 'PENDING_CONFIRM', hasIssue: true });
  });

  it('FR-015: lần nộp ảnh được ghi nhật ký cùng lúc báo xong', async () => {
    const { task, owner } = await inProgressTask();
    await completeWithPhotos(owner, task.id, task.version);
    const log = await prisma.auditLog.findFirstOrThrow({
      where: { entityId: task.id, action: 'housekeeping.task_completed' },
      include: { changes: true },
    });
    expect(log.changes).toEqual(expect.arrayContaining([expect.objectContaining({ field: 'photos', after: '3 ảnh (lượt 1)' })]));
  });

  it('tải lại cùng nhóm → thay ảnh cũ (mỗi nhóm bắt buộc giữ 1 ảnh), tệp cũ không còn', async () => {
    const { task, owner } = await inProgressTask();
    const first = (await upload(owner, task.id, 'OVERVIEW')).body.data;
    const second = (await upload(owner, task.id, 'OVERVIEW')).body.data;

    const list = (await photosOf(owner, task.id)).body.data;
    expect(list.photos.map((p: { id: string }) => p.id)).toEqual([second.id]);
    expect((await request(app).get(first.url).set(owner.auth)).status).toBe(404);
  });

  it('chỉ nhận JPG/PNG/WEBP theo nội dung tệp; vượt dung lượng → 413', async () => {
    const { task, owner } = await inProgressTask();
    const fake = await upload(owner, task.id, 'OVERVIEW', Buffer.from('không phải ảnh'));
    expect(fake.body.error).toMatchObject({ code: 'PHOTO_INVALID_TYPE', message: MSG.photoInvalidType });

    const big = Buffer.concat([TEST_JPEG, Buffer.alloc(5 * 1024 * 1024)]);
    const tooLarge = await upload(owner, task.id, 'OVERVIEW', big);
    expect(tooLarge.status).toBe(413);
    expect(tooLarge.body.error.code).toBe('PHOTO_TOO_LARGE');
    expect(await prisma.housekeepingPhoto.count({ where: { taskId: task.id } })).toBe(0);
  });

  it('chỉ thêm ảnh khi đã nhận việc (đang làm)', async () => {
    const { task } = await checkedOutRoom();
    const owner = task.assignee!.id === staffA.user.id ? staffA : staffB;
    const res = await upload(owner, task.id, 'OVERVIEW');
    expect(res.status).toBe(409);
    expect(res.body.error.code).toBe('PHOTO_LOCKED');
  });

  it('NFR-006: chỉ nhân viên phụ trách + quản lý xem ảnh; người khác không thêm / xem được', async () => {
    const { task, owner, other } = await inProgressTask();
    const photo = (await upload(owner, task.id, 'BATHROOM')).body.data;

    expect((await upload(other, task.id, 'OVERVIEW')).status).toBe(403);
    expect((await photosOf(other, task.id)).status).toBe(403);
    expect((await request(app).get(photo.url).set(other.auth)).status).toBe(403);
    expect((await photosOf(receptionist, task.id)).status).toBe(403);
    expect((await request(app).get(photo.url).set(receptionist.auth)).status).toBe(403);

    const file = await request(app).get(photo.url).set(manager.auth);
    expect(file.status).toBe(200);
    expect(file.headers['content-type']).toBe('image/jpeg');
    expect(Buffer.from(file.body).equals(TEST_JPEG)).toBe(true);
  });

  it('FR-007: quản lý xem gallery theo thứ tự nhóm ảnh', async () => {
    const { task, owner } = await inProgressTask();
    for (const category of ['CLOSEUP', 'BATHROOM', 'OVERVIEW', 'BED']) await upload(owner, task.id, category);
    const list = (await photosOf(manager, task.id)).body.data;
    expect(list.photos.map((p: { category: string }) => p.category)).toEqual(['OVERVIEW', 'BED', 'BATHROOM', 'CLOSEUP']);
  });

  it('FR-008: trả lại → lượt ảnh mới, ảnh lượt cũ giữ để truy vết và không xóa được; phải nộp lại đủ bộ', async () => {
    const { task, owner } = await inProgressTask();
    await completeWithPhotos(owner, task.id, task.version);
    const pending = await taskOf(task.id);
    const returned = await act(manager, task.id, 'return', { version: pending.version, note: 'Nhà vệ sinh còn bẩn' });
    expect(returned.body.data.photoRound).toBe(2);

    const oldPhotos = (await photosOf(manager, task.id)).body.data.photos;
    expect(oldPhotos).toHaveLength(3);
    expect(oldPhotos.every((p: { round: number }) => p.round === 1)).toBe(true);
    const del = await request(app).delete(`/api/housekeeping/photos/${oldPhotos[0].id}`).set(owner.auth);
    expect(del.status).toBe(409);

    const again = await act(owner, task.id, 'complete', { version: returned.body.data.version });
    expect(again.body.error.code).toBe('PHOTOS_REQUIRED');
    expect((await completeWithPhotos(owner, task.id, returned.body.data.version)).body.data.status).toBe('PENDING_CONFIRM');
    expect((await photosOf(manager, task.id)).body.data.photos).toHaveLength(6);
  });

  it('nhân viên xóa ảnh lượt hiện tại để chụp lại', async () => {
    const { task, owner } = await inProgressTask();
    const photo = (await upload(owner, task.id, 'BED')).body.data;
    expect((await request(app).delete(`/api/housekeeping/photos/${photo.id}`).set(owner.auth)).status).toBe(204);
    expect((await photosOf(owner, task.id)).body.data.photos).toHaveLength(0);
  });
});

describe('Danh sách & quá hạn (FR-008, FR-010, SC-04, BR-002)', () => {
  it('FR-010: lọc việc của tôi / theo trạng thái; lễ tân không xem danh sách việc', async () => {
    const { task } = await checkedOutRoom();
    const owner = task.assignee!.id === staffA.user.id ? staffA : staffB;
    const mine = await request(app).get('/api/housekeeping/tasks?mine=true&status=ASSIGNED').set(owner.auth);
    expect(mine.body.data.map((t: { id: string }) => t.id)).toContain(task.id);
    expect((await request(app).get('/api/housekeeping/tasks').set(receptionist.auth)).status).toBe(403);
  });

  it('quá 60 phút chưa báo xong → cờ quá hạn MỘT lần, báo quản lý + người phụ trách; hoàn tất thì gỡ cờ', async () => {
    const { task } = await checkedOutRoom();
    const owner = task.assignee!.id === staffA.user.id ? staffA : staffB;
    const later = new Date(Date.now() + 61 * 60_000);

    const first = await flagOverdueTasks(later);
    expect(first.housekeeping).toBeGreaterThanOrEqual(1);
    expect(await waitForNote(manager.user.id, 'HOUSEKEEPING_OVERDUE')).toBeDefined();
    expect(await waitForNote(owner.user.id, 'HOUSEKEEPING_OVERDUE')).toBeDefined();
    expect((await flagOverdueTasks(later)).housekeeping).toBe(0); // không cảnh báo lặp

    let current = await taskOf(task.id);
    await act(owner, task.id, 'accept', { version: current.version });
    current = await taskOf(task.id);
    await completeWithPhotos(owner, task.id, current.version);
    current = await taskOf(task.id);
    const done = await act(manager, task.id, 'confirm', { version: current.version });
    expect(done.body.data.isOverdue).toBe(false);
  });

  it('BR-002: việc đã báo xong (chờ xác nhận) không bị tính quá hạn', async () => {
    const { task } = await checkedOutRoom();
    const owner = task.assignee!.id === staffA.user.id ? staffA : staffB;
    await act(owner, task.id, 'accept', { version: task.version });
    await completeWithPhotos(owner, task.id, task.version + 1);
    await flagOverdueTasks(new Date(Date.now() + 61 * 60_000));
    expect((await taskOf(task.id)).overdueFlaggedAt).toBeNull();
  });

  it('dashboard: số việc quá hạn + chỉ số phòng; nhân viên không xem', async () => {
    const res = await request(app).get('/api/dashboard/summary').set(receptionist.auth);
    expect(res.status).toBe(200);
    expect(res.body.data).toMatchObject({ overdue: { housekeeping: expect.any(Number) }, cleaning: expect.any(Object) });
    expect(res.body.data.occupancy.rate === null || typeof res.body.data.occupancy.rate === 'number').toBe(true);
    expect((await request(app).get('/api/dashboard/summary').set(staffA.auth)).status).toBe(403);
  });

  it('FR-room-dashboard-006: dashboard liệt kê từng việc quá hạn kèm phòng để tô cờ ô phòng; hoàn tất thì mất', async () => {
    const { room, task } = await checkedOutRoom();
    await flagOverdueTasks(new Date(Date.now() + 61 * 60_000));
    const tasksOf = async () => (await request(app).get('/api/dashboard/summary').set(manager.auth)).body.data.overdue;

    const overdue = await tasksOf();
    expect(overdue.tasks).toContainEqual({ type: 'HOUSEKEEPING', taskId: task.id, roomId: room.id, roomNumber: room.number });
    expect(overdue.total).toBe(overdue.tasks.length);

    await prisma.housekeepingTask.update({ where: { id: task.id }, data: { status: 'DONE' } });
    expect((await tasksOf()).tasks.map((t: { taskId: string }) => t.taskId)).not.toContain(task.id);
  });
});
