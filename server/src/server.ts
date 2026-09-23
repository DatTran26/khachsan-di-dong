// Nạp & kiểm tra biến môi trường TRƯỚC mọi module khác.
import { env } from './config/env.js';
import { createServer } from 'node:http';
import { createApp } from './app.js';
import { prisma } from './lib/prisma.js';
import { attachRealtime, closeRealtime } from './realtime/socket.js';

// REST API và Socket.IO dùng chung một cổng.
const httpServer = createServer(createApp());
attachRealtime(httpServer);

httpServer.listen(env.PORT, () => {
  console.log(`Backend chạy tại http://localhost:${env.PORT} (REST + Socket.IO)`);
});

async function shutdown() {
  await closeRealtime();
  httpServer.close();
  await prisma.$disconnect();
  process.exit(0);
}
process.on('SIGINT', shutdown);
process.on('SIGTERM', shutdown);
