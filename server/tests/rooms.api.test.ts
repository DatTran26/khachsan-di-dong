import { randomUUID } from 'node:crypto';
import express from 'express';
import request from 'supertest';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { createApp } from '../src/app.js';
import { VersionConflictError } from '../src/lib/errors.js';
import { prisma } from '../src/lib/prisma.js';
import { errorHandler } from '../src/middleware/error-handler.js';
import { createUserWithToken } from './helpers.js';

const app = createApp();
const suffix = randomUUID().slice(0, 8);
const TEST_FLOOR = 98;
let roomId: string;
let auth: Record<string, string>;

beforeAll(async () => {
  auth = (await createUserWithToken('STAFF')).auth;
  const type = await prisma.roomType.create({ data: { name: `TEST-API-${suffix}` } });
  const ready = await prisma.room.create({
    data: { number: `TEST-API-${suffix}-1`, floor: TEST_FLOOR, roomTypeId: type.id },
  });
  await prisma.room.create({
    data: { number: `TEST-API-${suffix}-2`, floor: TEST_FLOOR, roomTypeId: type.id, cleaning: 'DIRTY' },
  });
  roomId = ready.id;
});

afterAll(async () => {
  await prisma.room.deleteMany({ where: { number: { startsWith: `TEST-API-${suffix}` } } });
  await prisma.roomType.deleteMany({ where: { name: `TEST-API-${suffix}` } });
  await prisma.$disconnect();
});

describe('GET /api/health', () => {
  it('trả ok khi kết nối được CSDL', async () => {
    const res = await request(app).get('/api/health');
    expect(res.status).toBe(200);
    expect(res.body.status).toBe('ok');
  });
});

describe('GET /api/rooms', () => {
  it('lọc theo tầng, kèm version và cờ sẵn sàng suy ra', async () => {
    const res = await request(app).get(`/api/rooms?floor=${TEST_FLOOR}`).set(auth);

    expect(res.status).toBe(200);
    expect(res.body.data).toHaveLength(2);
    const [clean, dirty] = res.body.data;
    expect(clean).toMatchObject({ floor: TEST_FLOOR, isReady: true, version: 1 });
    expect(dirty).toMatchObject({ cleaning: 'DIRTY', isReady: false });
  });

  it('lọc theo loại phòng (FR-room-catalog-006)', async () => {
    const room = await prisma.room.findUniqueOrThrow({ where: { id: roomId } });
    const res = await request(app).get(`/api/rooms?roomTypeId=${room.roomTypeId}`).set(auth);
    expect(res.body.data).toHaveLength(2);
  });

  it('lọc không có kết quả → danh sách rỗng, không báo lỗi', async () => {
    const res = await request(app).get(`/api/rooms?roomTypeId=${randomUUID()}`).set(auth);
    expect(res.status).toBe(200);
    expect(res.body.data).toEqual([]);
  });

  it('lọc theo trạng thái vệ sinh', async () => {
    const res = await request(app).get(`/api/rooms?floor=${TEST_FLOOR}&cleaning=DIRTY`).set(auth);
    expect(res.body.data).toHaveLength(1);
  });

  it('từ chối giá trị lọc không hợp lệ', async () => {
    const res = await request(app).get('/api/rooms?cleaning=BAN').set(auth);
    expect(res.status).toBe(400);
    expect(res.body.error.code).toBe('VALIDATION_ERROR');
  });
});

describe('xác thực', () => {
  it('chưa đăng nhập → 401', async () => {
    const res = await request(app).get('/api/rooms');
    expect(res.status).toBe(401);
    expect(res.body.error.code).toBe('UNAUTHENTICATED');
  });
});

describe('GET /api/rooms/:id', () => {
  it('trả phòng theo id', async () => {
    const res = await request(app).get(`/api/rooms/${roomId}`).set(auth);
    expect(res.status).toBe(200);
    expect(res.body.data.id).toBe(roomId);
  });

  it('404 khi không có phòng', async () => {
    const res = await request(app).get(`/api/rooms/${randomUUID()}`).set(auth);
    expect(res.status).toBe(404);
  });
});

describe('error handler', () => {
  it('trả 409 VERSION_CONFLICT kèm bản mới nhất cho client', async () => {
    const probe = express();
    probe.get('/conflict', () => {
      throw new VersionConflictError('Phòng', 'abc', 1, { id: 'abc', version: 2 });
    });
    probe.use(errorHandler);

    const res = await request(probe).get('/conflict');
    expect(res.status).toBe(409);
    expect(res.body.error).toMatchObject({
      code: 'VERSION_CONFLICT',
      message: 'Dữ liệu vừa được người khác cập nhật — đã tải lại bản mới nhất.', // E-realtime-sync-002
      details: { id: 'abc', expectedVersion: 1, current: { version: 2 } },
    });
  });
});
