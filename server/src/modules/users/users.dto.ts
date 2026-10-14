import type { User } from '@prisma/client';

/**
 * Dữ liệu tài khoản trả cho client. Không có `passwordHash` hay `failedLoginCount`.
 *
 * Kèm `version` để chống ghi đè. `createdAt` là Date Prisma — JSON hóa thành ISO.
 * @param user Bản ghi đầy đủ từ Prisma, kể cả các cột nhạy cảm. Hàm chỉ nhặt cột an toàn.
 * @returns Object thuần, không còn method Prisma.
 */
export function toUserDto(user: User) {
  return {
    id: user.id,
    phone: user.phone,
    fullName: user.fullName,
    role: user.role,
    status: user.status,
    mustChangePassword: user.mustChangePassword,
    onDuty: user.onDuty,
    version: user.version,
    createdAt: user.createdAt,
  };
}
