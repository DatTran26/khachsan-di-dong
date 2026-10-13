import { randomUUID } from 'node:crypto';
import { mkdir, readFile, rm, writeFile } from 'node:fs/promises';
import path from 'node:path';
import { env } from '../config/env.js';

/**
 * Lưu tệp ảnh nghiệm thu trên đĩa server (UPLOAD_DIR). CSDL chỉ giữ metadata + `storageKey`.
 * Tên tệp do server sinh (uuid) — không bao giờ dùng tên/đường dẫn client gửi lên.
 */
const ROOT = path.resolve(env.UPLOAD_DIR, 'housekeeping');

export const PHOTO_MAX_BYTES = Math.floor(env.PHOTO_MAX_MB * 1024 * 1024);

const EXT: Record<string, string> = { 'image/jpeg': 'jpg', 'image/png': 'png', 'image/webp': 'webp' };

/** Nhận diện định dạng theo byte đầu tệp (không tin Content-Type client gửi). null = không phải ảnh hỗ trợ. */
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

function resolveKey(storageKey: string) {
  // storageKey luôn do server sinh, nhưng vẫn chặn thoát khỏi thư mục gốc.
  const file = path.resolve(ROOT, storageKey);
  if (path.dirname(file) !== ROOT) throw new Error(`storageKey không hợp lệ: ${storageKey}`);
  return file;
}

export async function savePhoto(data: Buffer, mimeType: keyof typeof EXT) {
  await mkdir(ROOT, { recursive: true });
  const storageKey = `${randomUUID()}.${EXT[mimeType]}`;
  await writeFile(resolveKey(storageKey), data, { flag: 'wx' });
  return storageKey;
}

export function readPhoto(storageKey: string) {
  return readFile(resolveKey(storageKey));
}

/** Xóa tệp; tệp đã mất thì bỏ qua (dọn rác sau khi transaction thất bại / ảnh bị thay). */
export async function deletePhotoFile(storageKey: string) {
  await rm(resolveKey(storageKey), { force: true });
}
