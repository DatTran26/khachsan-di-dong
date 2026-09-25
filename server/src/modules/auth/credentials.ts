import { createHash, randomBytes, randomInt } from 'node:crypto';
import bcrypt from 'bcryptjs';
import { z } from 'zod';
import { MSG } from '../../lib/messages.js';

/** SĐT di động VN: 10 số, bắt đầu bằng 0 (FR-auth-roles-015). */
export const phoneSchema = z.string().trim().regex(/^0\d{9}$/, MSG.invalidPhone);

/** MK mới: ≥8 ký tự, có cả chữ và số (FR-auth-roles-015). */
export const newPasswordSchema = z
  .string()
  .min(8, MSG.weakPassword)
  .regex(/\p{L}/u, MSG.weakPassword)
  .regex(/\d/, MSG.weakPassword);

const BCRYPT_ROUNDS = 10;

/** Băm MK — không bao giờ lưu, log hay trả về MK thô (NFR-auth-roles-001). */
export function hashPassword(password: string): Promise<string> {
  return bcrypt.hash(password, BCRYPT_ROUNDS);
}

export function verifyPassword(password: string, hash: string): Promise<boolean> {
  return bcrypt.compare(password, hash);
}

// Hash giả để so sánh khi SĐT không tồn tại → thời gian phản hồi như nhau, không lộ SĐT nào có tài khoản.
const DUMMY_HASH = bcrypt.hashSync('khong-ton-tai-0', BCRYPT_ROUNDS);
export function verifyAgainstDummy(password: string): Promise<boolean> {
  return bcrypt.compare(password, DUMMY_HASH);
}

// Bỏ các ký tự dễ đọc nhầm (0/O, 1/l/I) vì MK tạm được đọc/chuyển tay cho nhân viên.
const TEMP_LETTERS = 'ABCDEFGHJKMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz';
const TEMP_DIGITS = '23456789';

/** MK tạm 8 ký tự, luôn có cả chữ và số. Hiển thị MỘT lần cho người tạo (FR-auth-roles-005). */
export function generateTempPassword(): string {
  const all = TEMP_LETTERS + TEMP_DIGITS;
  const chars = [
    TEMP_LETTERS[randomInt(TEMP_LETTERS.length)],
    TEMP_DIGITS[randomInt(TEMP_DIGITS.length)],
    ...Array.from({ length: 6 }, () => all[randomInt(all.length)]),
  ];
  for (let i = chars.length - 1; i > 0; i--) {
    const j = randomInt(i + 1);
    [chars[i], chars[j]] = [chars[j], chars[i]];
  }
  return chars.join('');
}

/** Token phiên: 32 byte ngẫu nhiên. Client giữ bản gốc, CSDL chỉ giữ SHA-256. */
export function generateSessionToken(): string {
  return randomBytes(32).toString('base64url');
}

export function hashSessionToken(token: string): string {
  return createHash('sha256').update(token).digest('hex');
}
