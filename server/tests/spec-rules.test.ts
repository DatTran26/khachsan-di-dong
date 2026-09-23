/**
 * Test đối chiếu trực tiếp các quy tắc trong docs/features/<feature>/srs/<feature>-spec.md
 * mà tầng CSDL + lõi backend phải đảm bảo (chưa phụ thuộc đăng nhập).
 */
import { randomUUID } from 'node:crypto';
import express from 'express';
import request from 'supertest';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { writeAudit } from '../src/lib/audit.js';
import { prisma } from '../src/lib/prisma.js';
import { errorHandler } from '../src/middleware/error-handler.js';

const suffix = randomUUID().slice(0, 8);
let roomId: string;
let roomTypeId: string;
let userId: string;

beforeAll(async () => {
  roomTypeId = (await prisma.roomType.create({ data: { name: `SPEC-${suffix}` } })).id;
  roomId = (await prisma.room.create({ data: { number: `SPEC-${suffix}`, floor: 2, roomTypeId } })).id;
  userId = (
    await prisma.user.create({
      data: { phone: '0911111111', fullName: 'Lễ tân test', role: 'RECEPTIONIST', passwordHash: 'x' },
    })
  ).id;
});

afterAll(() => prisma.$disconnect());

describe('room-catalog', () => {
  it('FR-002: phòng mới mặc định trống + sạch + bình thường, version 1', async () => {
    const room = await prisma.room.findUniqueOrThrow({ where: { id: roomId } });
    expect(room).toMatchObject({ occupancy: 'VACANT', cleaning: 'CLEAN', service: 'IN_SERVICE', version: 1 });
  });

  it('FR-001: số phòng trùng bị từ chối', async () => {
    await expect(prisma.room.create({ data: { number: `SPEC-${suffix}`, floor: 3, roomTypeId } })).rejects.toThrow();
  });

  it('FR-001: tầng phải là số nguyên dương', async () => {
    await expect(prisma.room.create({ data: { number: `SPEC-${suffix}-0`, floor: 0, roomTypeId } })).rejects.toThrow();
  });
});

describe('check-in-out', () => {
  it('FR-008: tối đa 1 lượt lưu trú đang mở trên mỗi phòng', async () => {
    const stay = { roomId, guestName: 'Khách A', checkedInById: userId };
    await prisma.stay.create({ data: stay });
    await expect(prisma.stay.create({ data: { ...stay, guestName: 'Khách B' } })).rejects.toThrow();
  });
});

describe('housekeeping', () => {
  it('FR-001: mỗi lượt trả phòng sinh đúng 1 việc dọn', async () => {
    const stay = await prisma.stay.findFirstOrThrow({ where: { roomId } });
    const task = { roomId, stayId: stay.id, dueAt: new Date(Date.now() + 60 * 60_000) };
    await prisma.housekeepingTask.create({ data: task });
    await expect(prisma.housekeepingTask.create({ data: task })).rejects.toThrow();
  });

  it('BR-005: ghi chú trả lại tối đa 500 ký tự', async () => {
    const task = { roomId, dueAt: new Date() };
    await expect(prisma.housekeepingTask.create({ data: { ...task, returnNote: 'x'.repeat(501) } })).rejects.toThrow();
    await expect(prisma.housekeepingTask.create({ data: { ...task, returnNote: 'x'.repeat(500) } })).resolves.toBeTruthy();
  });
});

describe('maintenance', () => {
  it('FR-001: mô tả ≤500, vị trí ≤100 ký tự', async () => {
    const base = { roomId, reporterId: userId };
    await expect(prisma.maintenanceTask.create({ data: { ...base, description: 'x'.repeat(501) } })).rejects.toThrow();
    await expect(
      prisma.maintenanceTask.create({ data: { ...base, description: 'Hỏng vòi sen', location: 'x'.repeat(101) } }),
    ).rejects.toThrow();
  });

  it('FR-007: mỗi phòng tối đa 1 lần ngừng phục vụ tay đang đặt, lý do ≤200 ký tự', async () => {
    await expect(
      prisma.outOfServiceHold.create({ data: { roomId, placedById: userId, reason: 'x'.repeat(201) } }),
    ).rejects.toThrow();
    await prisma.outOfServiceHold.create({ data: { roomId, placedById: userId, reason: 'Sơn lại tường' } });
    await expect(
      prisma.outOfServiceHold.create({ data: { roomId, placedById: userId, reason: 'Lần hai' } }),
    ).rejects.toThrow();
  });
});

describe('audit-log', () => {
  it('FR-002: một thao tác đổi nhiều đối tượng → liệt kê đủ trong CÙNG một bản ghi', async () => {
    const stay = await prisma.stay.findFirstOrThrow({ where: { roomId } });
    const log = await writeAudit(prisma, {
      actorId: userId,
      actorRole: 'RECEPTIONIST',
      action: 'stay.check_out',
      entityType: 'ROOM',
      entityId: roomId,
      entityLabel: 'Phòng SPEC',
      roomId,
      changes: [
        { field: 'occupancy', before: 'OCCUPIED', after: 'VACANT' },
        { field: 'cleaning', before: 'CLEAN', after: 'DIRTY' },
        { entityType: 'STAY', entityId: stay.id, entityLabel: 'Lượt của Khách A', field: 'status', before: 'OPEN', after: 'CLOSED' },
      ],
    });

    const saved = await prisma.auditLogChange.findMany({ where: { auditLogId: log.id }, orderBy: { position: 'asc' } });
    expect(saved.map((c) => [c.entityType, c.field, c.before, c.after])).toEqual([
      [null, 'occupancy', 'OCCUPIED', 'VACANT'],
      [null, 'cleaning', 'CLEAN', 'DIRTY'],
      ['STAY', 'status', 'OPEN', 'CLOSED'],
    ]);
  });

  it('NFR-002: đổi số phòng sau khi ghi → bản ghi giữ nhãn cũ', async () => {
    await prisma.room.update({ where: { id: roomId }, data: { number: `SPEC-${suffix}-doi-so` } });
    const log = await prisma.auditLog.findFirstOrThrow({ where: { roomId, action: 'stay.check_out' } });
    expect(log.entityLabel).toBe('Phòng SPEC');
  });

  it('FR-005 / BR-004: không xóa được bản ghi nhật ký', async () => {
    const log = await prisma.auditLog.findFirstOrThrow({ where: { roomId } });
    await expect(prisma.auditLog.delete({ where: { id: log.id } })).rejects.toThrow(/chỉ được thêm mới/);
  });

  it('room-catalog FR-004: phòng đã có lịch sử không xóa cứng được', async () => {
    await expect(prisma.room.delete({ where: { id: roomId } })).rejects.toThrow();
  });
});

describe('thông báo lỗi tiếng Việt theo spec', () => {
  it('E-audit-log-005: lỗi bất ngờ → "Thao tác chưa hoàn tất — vui lòng thử lại."', async () => {
    const app = express();
    app.get('/boom', () => {
      throw new Error('mất kết nối CSDL giữa chừng');
    });
    app.use(errorHandler);

    const originalError = console.error;
    console.error = () => {}; // lỗi cố ý — không in ra màn hình test
    const res = await request(app).get('/boom');
    console.error = originalError;

    expect(res.status).toBe(500);
    expect(res.body.error.message).toBe('Thao tác chưa hoàn tất — vui lòng thử lại.');
  });
});
