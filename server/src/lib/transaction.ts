import type { Prisma } from '@prisma/client';
import type { PendingEvent } from '../realtime/events.js';
import { publish } from '../realtime/socket.js';
import { prisma } from './prisma.js';

type Enqueue = (event: PendingEvent) => void;

/**
 * "Lưu trước rồi mới phát" (realtime-sync): chạy `work` trong một transaction,
 * gom sự kiện realtime qua `enqueue`, và CHỈ phát khi transaction COMMIT thành công.
 * Lỗi (vd xung đột version) → rollback, không sự kiện nào được phát → không thiết bị nào thấy dữ liệu chưa lưu.
 */
export async function withTransaction<T>(work: (tx: Prisma.TransactionClient, enqueue: Enqueue) => Promise<T>) {
  const pending: PendingEvent[] = [];
  const result = await prisma.$transaction((tx) => work(tx, (event) => pending.push(event)));
  publish(pending);
  return result;
}
