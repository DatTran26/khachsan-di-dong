import { randomUUID } from 'node:crypto';
import type { Room } from '@prisma/client';
import { afterAll, beforeEach, describe, expect, it } from 'vitest';
import { writeAudit } from '../src/lib/audit.js';
import { NotFoundError, VersionConflictError } from '../src/lib/errors.js';
import { updateWithVersion } from '../src/lib/optimistic-lock.js';
import { prisma } from '../src/lib/prisma.js';

// Mỗi lần chạy dùng loại phòng + phòng riêng (tiền tố TEST-) rồi dọn sạch ở cuối.
const suffix = randomUUID().slice(0, 8);
let roomTypeId: string;
let room: Room;
let counter = 0;

async function freshRoom() {
  counter += 1;
  room = await prisma.room.create({
    data: { number: `TEST-${suffix}-${counter}`, floor: 99, roomTypeId },
  });
}

beforeEach(async () => {
  if (!roomTypeId) {
    roomTypeId = (await prisma.roomType.create({ data: { name: `TEST-${suffix}` } })).id;
  }
  await freshRoom();
});

afterAll(async () => {
  await prisma.room.deleteMany({ where: { number: { startsWith: `TEST-${suffix}` } } });
  await prisma.roomType.deleteMany({ where: { name: `TEST-${suffix}` } });
  await prisma.$disconnect();
});

describe('updateWithVersion — chống ghi đè', () => {
  it('cập nhật khi version khớp và tăng version lên 1', async () => {
    const updated = await updateWithVersion(prisma, 'room', room.id, 1, { cleaning: 'DIRTY' });

    expect(updated.cleaning).toBe('DIRTY');
    expect(updated.version).toBe(2);
  });

  it('từ chối khi client gửi version cũ, không ghi gì và trả về bản mới nhất', async () => {
    await updateWithVersion(prisma, 'room', room.id, 1, { cleaning: 'DIRTY' }); // người A sửa trước

    const attempt = updateWithVersion(prisma, 'room', room.id, 1, { occupancy: 'OCCUPIED' }); // người B cầm version cũ
    await expect(attempt).rejects.toBeInstanceOf(VersionConflictError);
    await attempt.catch((error: VersionConflictError) => {
      expect(error.status).toBe(409);
      expect((error.details as { current: Room }).current.version).toBe(2);
    });

    const inDb = await prisma.room.findUniqueOrThrow({ where: { id: room.id } });
    expect(inDb.occupancy).toBe('VACANT'); // thay đổi của B không được ghi
    expect(inDb.version).toBe(2);
  });

  it('10 người sửa cùng lúc với cùng version → đúng 1 người thành công', async () => {
    const attempts = Array.from({ length: 10 }, (_, i) =>
      prisma.$transaction((tx) =>
        updateWithVersion(tx, 'room', room.id, 1, { cleaning: i % 2 ? 'DIRTY' : 'CLEANING' }),
      ),
    );
    const results = await Promise.allSettled(attempts);

    const won = results.filter((r) => r.status === 'fulfilled');
    const lost = results.filter((r) => r.status === 'rejected');
    expect(won).toHaveLength(1);
    expect(lost).toHaveLength(9);
    for (const r of lost) expect((r as PromiseRejectedResult).reason).toBeInstanceOf(VersionConflictError);

    const inDb = await prisma.room.findUniqueOrThrow({ where: { id: room.id } });
    expect(inDb.version).toBe(2);
  });

  it('xung đột trong transaction → rollback cả nhật ký đã ghi trước đó', async () => {
    await updateWithVersion(prisma, 'room', room.id, 1, { cleaning: 'DIRTY' });
    const action = `test.rollback.${suffix}`;

    await expect(
      prisma.$transaction(async (tx) => {
        await writeAudit(tx, {
          actorId: null,
          actorRole: 'SYSTEM',
          action,
          entityType: 'ROOM',
          entityId: room.id,
        });
        await updateWithVersion(tx, 'room', room.id, 1, { cleaning: 'CLEAN' }); // version cũ → lỗi
      }),
    ).rejects.toBeInstanceOf(VersionConflictError);

    expect(await prisma.auditLog.count({ where: { action } })).toBe(0);
  });

  it('báo không tồn tại khi id sai', async () => {
    await expect(updateWithVersion(prisma, 'room', randomUUID(), 1, { cleaning: 'DIRTY' })).rejects.toBeInstanceOf(
      NotFoundError,
    );
  });

  it('trigger CSDL vẫn tăng version khi code cập nhật trực tiếp (quên dùng updateWithVersion)', async () => {
    await prisma.room.update({ where: { id: room.id }, data: { cleaning: 'DIRTY' } });

    const inDb = await prisma.room.findUniqueOrThrow({ where: { id: room.id } });
    expect(inDb.version).toBe(2);
    await expect(updateWithVersion(prisma, 'room', room.id, 1, { cleaning: 'CLEAN' })).rejects.toBeInstanceOf(
      VersionConflictError,
    );
  });
});

describe('nhật ký chỉ được thêm', () => {
  it('không cho sửa bản ghi nhật ký', async () => {
    // Chạy trong transaction: lệnh sửa bị trigger chặn → cả transaction rollback, không để lại rác.
    await expect(
      prisma.$transaction(async (tx) => {
        const log = await writeAudit(tx, {
          actorId: null,
          actorRole: 'SYSTEM',
          action: `test.append_only.${suffix}`,
          entityType: 'ROOM',
          entityId: room.id,
        });
        await tx.auditLog.update({ where: { id: log.id }, data: { action: 'sua-lai' } });
      }),
    ).rejects.toThrow(/chỉ được thêm mới/);
  });
});
