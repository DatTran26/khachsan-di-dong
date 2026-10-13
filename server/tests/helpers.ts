import { randomInt } from 'node:crypto';
import type { Role, User } from '@prisma/client';
import { hashPassword } from '../src/modules/auth/credentials.js';
import { openSession } from '../src/modules/auth/sessions.js';
import { prisma } from '../src/lib/prisma.js';

export const TEST_PASSWORD = 'MatKhau123';
let cachedHash: Promise<string> | undefined;

/** SĐT ngẫu nhiên hợp lệ (0 + 9 số) để các test không đụng nhau. */
export function randomPhone() {
  return `09${String(randomInt(0, 100_000_000)).padStart(8, '0')}`;
}

/** Tạo tài khoản đang hoạt động, MK = TEST_PASSWORD. */
export async function createUser(role: Role, overrides: Partial<User> = {}) {
  cachedHash ??= hashPassword(TEST_PASSWORD);
  return prisma.user.create({
    data: {
      phone: randomPhone(),
      fullName: `Test ${role}`,
      role,
      status: 'ACTIVE',
      mustChangePassword: false,
      passwordHash: await cachedHash,
      ...overrides,
    },
  });
}

/** Tạo tài khoản + phiên đăng nhập, trả token để gọi API / kết nối socket. */
export async function createUserWithToken(role: Role, overrides: Partial<User> = {}) {
  const user = await createUser(role, overrides);
  const { token } = await prisma.$transaction((tx) => openSession(tx, user, 'test', () => {}));
  return { user, token, auth: { Authorization: `Bearer ${token}` } };
}

/** Ảnh JPEG tối thiểu (đúng byte đầu tệp) cho test ảnh nghiệm thu. */
export const TEST_JPEG = Buffer.from('ffd8ffe000104a46494600010100000100010000ffd9', 'hex');

/** 3 nhóm ảnh bắt buộc trước khi báo dọn xong (BR-housekeeping-006). */
export const REQUIRED_PHOTO_CATEGORIES = ['OVERVIEW', 'BED', 'BATHROOM'] as const;
