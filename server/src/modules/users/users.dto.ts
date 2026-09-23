import type { User } from '@prisma/client';

/** Dữ liệu tài khoản trả cho client — KHÔNG bao giờ có mật khẩu/mã băm. Kèm `version` để chống ghi đè. */
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
