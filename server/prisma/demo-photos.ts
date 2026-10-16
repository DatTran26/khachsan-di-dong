/**
 * Ảnh nghiệm thu giả lập cho dữ liệu demo: PNG một màu (mỗi nhóm một màu) — xem được trong gallery,
 * không dùng ảnh thật (tránh ảnh có đồ cá nhân của khách — NFR-housekeeping-006).
 */
import { deflateSync } from 'node:zlib';
import type { HousekeepingPhotoCategory, User } from '@prisma/client';
import { uploadPhoto } from '../src/modules/housekeeping/housekeeping.photos.js';

const CRC_TABLE = Array.from({ length: 256 }, (_, n) => {
  let c = n;
  for (let k = 0; k < 8; k++) c = c & 1 ? 0xedb88320 ^ (c >>> 1) : c >>> 1;
  return c >>> 0;
});

function crc32(data: Buffer) {
  let c = 0xffffffff;
  for (const byte of data) c = CRC_TABLE[(c ^ byte) & 0xff] ^ (c >>> 8);
  return (c ^ 0xffffffff) >>> 0;
}

function chunk(type: string, data: Buffer) {
  const len = Buffer.alloc(4);
  len.writeUInt32BE(data.length);
  const body = Buffer.concat([Buffer.from(type, 'ascii'), data]);
  const crc = Buffer.alloc(4);
  crc.writeUInt32BE(crc32(body));
  return Buffer.concat([len, body, crc]);
}

/** PNG RGB một màu kích thước w×h. */
export function solidPng(rgb: [number, number, number], w = 320, h = 240) {
  const header = Buffer.alloc(13);
  header.writeUInt32BE(w, 0);
  header.writeUInt32BE(h, 4);
  header.set([8, 2, 0, 0, 0], 8); // 8 bit, RGB
  const row = Buffer.concat([Buffer.from([0]), Buffer.alloc(w * 3, Buffer.from(rgb))]);
  const pixels = deflateSync(Buffer.concat(Array.from({ length: h }, () => row)));
  return Buffer.concat([
    Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]),
    chunk('IHDR', header),
    chunk('IDAT', pixels),
    chunk('IEND', Buffer.alloc(0)),
  ]);
}

const COLORS: Record<HousekeepingPhotoCategory, [number, number, number]> = {
  OVERVIEW: [214, 196, 168],
  BED: [236, 232, 222],
  BATHROOM: [176, 206, 214],
  CLOSEUP: [222, 160, 150],
};

/** Tải đủ 3 ảnh bắt buộc cho việc dọn "đang làm" của nhân viên phụ trách. */
export async function uploadRequiredPhotos(staff: User, taskId: string) {
  for (const category of ['OVERVIEW', 'BED', 'BATHROOM'] as const) {
    await uploadPhoto(staff, taskId, category, solidPng(COLORS[category]));
  }
}
