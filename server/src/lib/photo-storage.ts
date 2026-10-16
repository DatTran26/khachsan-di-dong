import { randomUUID } from 'node:crypto';
import { mkdir, readFile, rm, writeFile } from 'node:fs/promises';
import path from 'node:path';
import { env } from '../config/env.js';

/**
 * Lưu tệp ảnh nghiệm thu trên đĩa server (UPLOAD_DIR). CSDL chỉ giữ metadata + `storageKey`.
 * Tên tệp do server sinh (uuid) — không bao giờ dùng tên/đường dẫn client gửi lên.
 */
const ROOT = path.resolve(env.UPLOAD_DIR, 'housekeeping');

/**
 * Trần dung lượng một ảnh, tính từ `PHOTO_MAX_MB` (mặc định 5).
 * Route `express.raw` và `uploadPhoto` cùng dùng số này; vượt trần ở route thì 413
 * trước khi vào service.
 */
export const PHOTO_MAX_BYTES = Math.floor(env.PHOTO_MAX_MB * 1024 * 1024);

const EXT: Record<string, string> = { 'image/jpeg': 'jpg', 'image/png': 'png', 'image/webp': 'webp' };

/**
 * Nhận diện định dạng theo byte đầu tệp. Không tin `Content-Type` client gửi.
 *
 * JPEG: `FF D8 FF`. PNG: chữ ký 8 byte chuẩn. WEBP: `RIFF` ở đầu và `WEBP` tại offset 8.
 * @param data Thân ảnh đã đọc hết vào bộ nhớ.
 * @returns MIME được phép lưu, hoặc `null` nếu không phải JPG/PNG/WEBP (kể cả tệp quá ngắn).
 */
export function detectImageType(data: Buffer): keyof typeof EXT | null {
  if (data.length >= 3 && data[0] === 0xff && data[1] === 0xd8 && data[2] === 0xff) return 'image/jpeg';
  if (data.length >= 8 && data.subarray(0, 8).equals(Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]))) {
    return 'image/png';
  }
  if (data.length >= 12 && data.toString('ascii', 0, 4) === 'RIFF' && data.toString('ascii', 8, 12) === 'WEBP') {
    return 'image/webp';
  }
  return null;
}

/**
 * Đổi `storageKey` thành đường dẫn tuyệt đối nằm đúng trong `ROOT`.
 *
 * `path.resolve` rồi so `dirname` với `ROOT`. Key có `..`, thư mục con, hoặc ký tự
 * tách đường dẫn sẽ ném `Error` — không đọc/ghi ra ngoài `uploads/housekeeping`.
 * @param storageKey Tên tệp server đã sinh (`<uuid>.<ext>`), không phải tên client gửi.
 * @returns Đường dẫn tuyệt đối của tệp.
 */
function resolveKey(storageKey: string) {
  // storageKey luôn do server sinh, nhưng vẫn chặn thoát khỏi thư mục gốc.
  const file = path.resolve(ROOT, storageKey);
  if (path.dirname(file) !== ROOT) throw new Error(`storageKey không hợp lệ: ${storageKey}`);
  return file;
}

/**
 * Ghi ảnh mới với tên UUID. Không dùng tên tệp client gửi.
 *
 * Tạo thư mục gốc nếu chưa có. Cờ `wx` khiến ghi đè tệp đã tồn tại bị lỗi
 * (trùng UUID là cực hiếm). Người gọi phải tự xóa tệp nếu transaction CSDL sau đó thất bại.
 * @param data Byte ảnh đã qua kiểm tra loại.
 * @param mimeType Khóa của `EXT` (`image/jpeg` | `image/png` | `image/webp`).
 * @returns `storageKey` dạng `<uuid>.<ext>` để lưu cột CSDL.
 */
export async function savePhoto(data: Buffer, mimeType: keyof typeof EXT) {
  await mkdir(ROOT, { recursive: true });
  const storageKey = `${randomUUID()}.${EXT[mimeType]}`;
  await writeFile(resolveKey(storageKey), data, { flag: 'wx' });
  return storageKey;
}

/**
 * Đọc toàn bộ byte của một ảnh đã lưu.
 *
 * @param storageKey Giá trị cột `storageKey`. Key lạ bị `resolveKey` từ chối.
 * @returns Promise nội dung tệp. Ném lỗi hệ thống nếu tệp đã mất trên đĩa.
 */
export function readPhoto(storageKey: string) {
  return readFile(resolveKey(storageKey));
}

/**
 * Xóa tệp ảnh. Tệp đã mất thì bỏ qua (`rm` với `force`).
 *
 * Dùng để dọn file vừa ghi khi transaction thất bại, hoặc xóa ảnh bị thay sau khi commit.
 * @param storageKey Key cần xóa. Key thoát khỏi thư mục gốc vẫn bị `resolveKey` ném lỗi, không xóa chỗ khác.
 * @returns Promise hoàn tất khi `rm` xong.
 */
export async function deletePhotoFile(storageKey: string) {
  await rm(resolveKey(storageKey), { force: true });
}
