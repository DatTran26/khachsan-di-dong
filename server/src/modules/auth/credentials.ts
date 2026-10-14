import { createHash, randomBytes, randomInt } from 'node:crypto';
import bcrypt from 'bcryptjs';
import { z } from 'zod';
import { MSG } from '../../lib/messages.js';

/** SĐT di động VN: 10 số, bắt đầu bằng 0 (FR-auth-roles-015). Zod trim trước khi khớp. */
export const phoneSchema = z.string().trim().regex(/^0\d{9}$/, MSG.invalidPhone);

/**
 * MK mới: ít nhất 8 ký tự, có ít nhất một chữ (mọi ngôn ngữ, `\p{L}`) và một chữ số
 * (FR-auth-roles-015). Dùng cho đổi mật khẩu, không áp vào mật khẩu tạm do server sinh.
 */
export const newPasswordSchema = z
  .string()
  .min(8, MSG.weakPassword)
  .regex(/\p{L}/u, MSG.weakPassword)
  .regex(/\d/, MSG.weakPassword);

const BCRYPT_ROUNDS = 10;

/**
 * Băm mật khẩu bằng bcrypt (10 vòng).
 *
 * Không bao giờ lưu, log hay trả về mật khẩu thô (NFR-auth-roles-001).
 * @param password Mật khẩu người dùng vừa nhập, chưa băm.
 * @returns Chuỗi hash bcrypt để ghi vào `User.passwordHash`.
 */
export function hashPassword(password: string): Promise<string> {
  return bcrypt.hash(password, BCRYPT_ROUNDS);
}

/**
 * So mật khẩu thô với hash bcrypt đã lưu.
 *
 * @param password Mật khẩu client gửi.
 * @param hash Giá trị `passwordHash` trong CSDL.
 * @returns `true` khi khớp. Không ném lỗi khi sai.
 */
export function verifyPassword(password: string, hash: string): Promise<boolean> {
  return bcrypt.compare(password, hash);
}

// Hash giả để so sánh khi SĐT không tồn tại → thời gian phản hồi như nhau, không lộ SĐT nào có tài khoản.
const DUMMY_HASH = bcrypt.hashSync('khong-ton-tai-0', BCRYPT_ROUNDS);

/**
 * So mật khẩu với hash cố định, dùng khi không có tài khoản với SĐT đó.
 *
 * Mục đích duy nhất là giữ thời gian bcrypt gần bằng nhánh "có tài khoản",
 * tránh kẻ tấn công phân biệt SĐT tồn tại bằng thời gian phản hồi.
 * Kết quả boolean bị bỏ qua ở chỗ gọi — hàm luôn được await rồi ném lỗi đăng nhập.
 * @param password Mật khẩu client gửi, dù SĐT không có trong CSDL.
 * @returns Kết quả `bcrypt.compare` với hash giả. Không dùng để cấp phiên.
 */
export function verifyAgainstDummy(password: string): Promise<boolean> {
  return bcrypt.compare(password, DUMMY_HASH);
}

// Bỏ các ký tự dễ đọc nhầm (0/O, 1/l/I) vì MK tạm được đọc/chuyển tay cho nhân viên.
const TEMP_LETTERS = 'ABCDEFGHJKMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz';
const TEMP_DIGITS = '23456789';

/**
 * Sinh mật khẩu tạm 8 ký tự, luôn có ít nhất một chữ và một số.
 *
 * Xáo Fisher–Yates bằng `randomInt` (CSPRNG). Hiển thị một lần cho người tạo
 * (FR-auth-roles-005); không ghi giá trị này vào nhật ký.
 * @returns Mật khẩu tạm dạng plaintext. Người gọi phải băm trước khi lưu.
 */
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

/**
 * Tạo token phiên: 32 byte ngẫu nhiên, mã hóa base64url.
 *
 * Client giữ bản gốc. CSDL chỉ giữ SHA-256 (xem `hashSessionToken`).
 * @returns Token đưa cho client đúng một lần khi mở phiên.
 */
export function generateSessionToken(): string {
  return randomBytes(32).toString('base64url');
}

/**
 * Băm token phiên bằng SHA-256, hex 64 ký tự, để tra `Session.tokenHash`.
 *
 * Không dùng bcrypt: token đã đủ entropy, cần so khớp đúng và nhanh trên mỗi request.
 * @param token Token gốc client gửi (header Bearer hoặc handshake socket).
 * @returns Chuỗi hex. Cùng token luôn ra cùng hash.
 */
export function hashSessionToken(token: string): string {
  return createHash('sha256').update(token).digest('hex');
}
