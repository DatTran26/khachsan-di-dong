import { Prisma, type User } from '@prisma/client';
import { diffFields, writeAudit } from '../../lib/audit.js';
import { AppError, NotFoundError } from '../../lib/errors.js';
import { MSG } from '../../lib/messages.js';
import { prisma } from '../../lib/prisma.js';
import { withTransaction } from '../../lib/transaction.js';

/** Loại phòng (room-catalog FR-010, P1): quản lý thêm / đổi tên / tắt. Không xóa — phòng cũ vẫn tham chiếu. */
const nameTaken = (name: string) => new AppError(409, 'ROOM_TYPE_TAKEN', MSG.roomTypeTaken(name));

function isUniqueViolation(error: unknown) {
  return error instanceof Prisma.PrismaClientKnownRequestError && error.code === 'P2002';
}

export function listRoomTypes() {
  return prisma.roomType.findMany({ orderBy: { name: 'asc' } });
}

export async function createRoomType(actor: User, name: string) {
  try {
    return await withTransaction(async (tx) => {
      const type = await tx.roomType.create({ data: { name } });
      await writeAudit(tx, {
        actorId: actor.id,
        actorRole: actor.role,
        action: 'room_type.created',
        entityType: 'ROOM_TYPE',
        entityId: type.id,
        entityLabel: type.name,
        changes: [{ field: 'name', after: type.name }],
      });
      return type;
    });
  } catch (error) {
    if (isUniqueViolation(error)) throw nameTaken(name);
    throw error;
  }
}

export async function updateRoomType(actor: User, id: string, patch: { name?: string; isActive?: boolean }) {
  try {
    return await withTransaction(async (tx) => {
      const before = await tx.roomType.findUnique({ where: { id } });
      if (!before) throw new NotFoundError('Loại phòng không tồn tại.');
      const after = await tx.roomType.update({ where: { id }, data: patch });
      await writeAudit(tx, {
        actorId: actor.id,
        actorRole: actor.role,
        action: 'room_type.updated',
        entityType: 'ROOM_TYPE',
        entityId: id,
        entityLabel: before.name,
        changes: diffFields(before, after, ['name', 'isActive']),
      });
      return after;
    });
  } catch (error) {
    if (isUniqueViolation(error) && patch.name) throw nameTaken(patch.name);
    throw error;
  }
}
