import type { Prisma } from '@prisma/client';
import type { PendingEvent } from '../realtime/events.js';
import { publish } from '../realtime/socket.js';
import { prisma } from './prisma.js';

/** Đẩy một sự kiện vào danh sách chờ của transaction hiện tại. Chưa gửi socket. */
type Enqueue = (event: PendingEvent) => void;

/**
 * "Lưu trước rồi mới phát" (realtime-sync).
 *
 * Chạy `work` trong `prisma.$transaction`. `enqueue` chỉ đẩy vào mảng cục bộ.
 * `publish` chạy sau khi promise transaction resolve, tức là sau COMMIT.
 * Ném lỗi (xung đột version, quy tắc nghiệp vụ) → rollback, mảng sự kiện bị bỏ,
 * không thiết bị nào thấy dữ liệu chưa lưu.
 * Không tự retry. Không bọc timeout riêng — dùng timeout mặc định của Prisma.
 * @param work Nhận client transaction và hàm `enqueue`. Phải dùng `tx` cho mọi ghi muốn cùng commit.
 * @returns Giá trị `work` trả về, sau khi sự kiện đã được phát (hoặc không có sự kiện).
 */
export async function withTransaction<T>(work: (tx: Prisma.TransactionClient, enqueue: Enqueue) => Promise<T>) {
  const pending: PendingEvent[] = [];
  const result = await prisma.$transaction((tx) => work(tx, (event) => pending.push(event)));
  publish(pending);
  return result;
}
