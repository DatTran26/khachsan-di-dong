// Nạp & kiểm tra biến môi trường TRƯỚC mọi module khác.
import { env } from './config/env.js';
import { createServer } from 'node:http';
import { createApp } from './app.js';
import { startOverdueJob } from './jobs/overdue.js';
import { prisma } from './lib/prisma.js';
import { attachRealtime, closeRealtime } from './realtime/socket.js';

// REST API và Socket.IO dùng chung một cổng.
const httpServer = createServer(createApp());
attachRealtime(httpServer);
const stopOverdueJob = startOverdueJob();

httpServer.listen(env.PORT, () => {
  // Callback của `listen`: chỉ log khi cổng đã bind. Không kiểm tra CSDL ở đây — `/api/health` làm việc đó.
  console.log(`Backend chạy tại http://localhost:${env.PORT} (REST + Socket.IO)`);
});

/**
 * Dừng job quá hạn, đóng Socket.IO, đóng HTTP server, ngắt pool Prisma, rồi thoát 0.
 *
 * Gắn vào SIGINT và SIGTERM. `httpServer.close()` không được await hết kết nối
 * đang xử lý trước khi `$disconnect` — tiến trình thoát ngay sau khi gọi close.
 * Không bắt lỗi: nếu disconnect ném, process có thể thoát khác 0 do unhandled rejection.
 * @returns Promise kết thúc bằng `process.exit(0)`.
 */
async function shutdown() {
  stopOverdueJob();
  await closeRealtime();
  httpServer.close();
  await prisma.$disconnect();
  process.exit(0);
}
process.on('SIGINT', shutdown);
process.on('SIGTERM', shutdown);
