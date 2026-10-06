/**
 * Đo tiêu chí nghiệm thu realtime-sync:
 *   "≥95% trong 100 lượt cập nhật hiển thị trên thiết bị khác ≤3 giây (50 phòng, 30 phiên đồng thời)".
 *
 * Cách đo: khởi động server thật (REST + Socket.IO), mở N kết nối websocket giả lập N thiết bị,
 * thực hiện M lượt đổi trạng thái phòng qua đúng đường ghi thật (transaction + version + nhật ký + phát sự kiện).
 * Độ trễ 1 lượt = từ lúc BẮT ĐẦU lưu → thiết bị CHẬM NHẤT nhận được (khắt khe hơn spec: tính cả thời gian ghi CSDL).
 *
 * Chạy trên CSDL test (không đụng dữ liệu dev):  npm run bench:realtime
 * Tuỳ chỉnh: CLIENTS=30 UPDATES=100 INTERVAL_MS=200 npm run bench:realtime
 */
import { execSync } from 'node:child_process';
import { createServer } from 'node:http';
import type { AddressInfo } from 'node:net';
import { performance } from 'node:perf_hooks';
import { config } from 'dotenv';
import { io as connect, type Socket } from 'socket.io-client';
import { testDatabaseUrl } from '../tests/test-db.js';

config({ quiet: true });
process.env.DATABASE_URL = testDatabaseUrl();
execSync('npx prisma migrate deploy', { env: process.env, stdio: 'pipe' });

// Import sau khi đã trỏ DATABASE_URL sang CSDL test.
const { createApp } = await import('../src/app.js');
const { prisma } = await import('../src/lib/prisma.js');
const { changeRoomStatus } = await import('../src/modules/rooms/rooms.service.js');
const { attachRealtime, closeRealtime } = await import('../src/realtime/socket.js');
const { createUserWithToken } = await import('../tests/helpers.js');

const CLIENTS = Number(process.env.CLIENTS ?? 30);
const UPDATES = Number(process.env.UPDATES ?? 100);
const INTERVAL_MS = Number(process.env.INTERVAL_MS ?? 200);
const LIMIT_MS = 3_000;
const TARGET_RATIO = 0.95;

const SYSTEM = { id: null, role: 'SYSTEM' as const };
const sleep = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));

function percentile(sorted: number[], p: number) {
  return sorted[Math.min(sorted.length - 1, Math.ceil((p / 100) * sorted.length) - 1)];
}

async function main() {
  const httpServer = createServer(createApp());
  attachRealtime(httpServer);
  await new Promise<void>((resolve) => httpServer.listen(0, resolve));
  const { port } = httpServer.address() as AddressInfo;

  const stamp = Date.now();
  const roomType = await prisma.roomType.create({ data: { name: `BENCH-${stamp}` } });
  const room = await prisma.room.create({ data: { number: `BENCH-${stamp}`, floor: 1, roomTypeId: roomType.id } });

  // receivedAt[client][version] = thời điểm thiết bị nhận bản có version đó
  const receivedAt: Map<number, number>[] = [];
  const clients: Socket[] = [];
  // Mỗi thiết bị là một tài khoản đã đăng nhập (1 TK chỉ 1 phiên) — socket bắt buộc có token.
  const tokens: string[] = [];
  for (let i = 0; i < CLIENTS; i++) tokens.push((await createUserWithToken('STAFF', { fullName: `Bench ${i}` })).token);

  for (const token of tokens) {
    const client = connect(`http://localhost:${port}`, { transports: ['websocket'], forceNew: true, auth: { token } });
    const seen = new Map<number, number>();
    client.on('room:updated', ({ room: r }: { room: { id: string; version: number } }) => {
      if (r.id === room.id) seen.set(r.version, performance.now());
    });
    receivedAt.push(seen);
    clients.push(client);
  }
  await Promise.all(clients.map((c) => new Promise<void>((resolve) => c.once('connect', () => resolve()))));
  console.log(`Đã kết nối ${CLIENTS} thiết bị. Bắt đầu ${UPDATES} lượt cập nhật, cách nhau ${INTERVAL_MS}ms...`);

  const startedAt = new Map<number, number>(); // version mới → lúc bắt đầu lưu
  let version = room.version;
  for (let i = 0; i < UPDATES; i++) {
    const t0 = performance.now();
    const updated = await changeRoomStatus(SYSTEM, room.id, version, { cleaning: i % 2 === 0 ? 'DIRTY' : 'CLEAN' });
    version = updated.version;
    startedAt.set(version, t0);
    await sleep(INTERVAL_MS);
  }
  await sleep(LIMIT_MS); // chờ các sự kiện cuối tới nơi

  // Tổng hợp
  const perUpdateWorst: number[] = [];
  const allDeliveries: number[] = [];
  let missing = 0;
  for (const [v, t0] of startedAt) {
    let worst = 0;
    for (const seen of receivedAt) {
      const at = seen.get(v);
      if (at === undefined) {
        missing += 1;
        worst = Number.POSITIVE_INFINITY;
        continue;
      }
      allDeliveries.push(at - t0);
      worst = Math.max(worst, at - t0);
    }
    perUpdateWorst.push(worst);
  }

  const passed = perUpdateWorst.filter((ms) => ms <= LIMIT_MS).length;
  const ratio = passed / UPDATES;
  const sorted = [...allDeliveries].sort((a, b) => a - b);
  const fmt = (ms: number) => `${ms.toFixed(1)} ms`;

  console.log('\n=== Kết quả đo realtime ===');
  console.log(`Thiết bị đồng thời      : ${CLIENTS}`);
  console.log(`Lượt cập nhật           : ${UPDATES}`);
  console.log(`Lượt đạt ≤${LIMIT_MS / 1000}s (mọi TB)  : ${passed}/${UPDATES} (${(ratio * 100).toFixed(1)}%) — yêu cầu ≥${TARGET_RATIO * 100}%`);
  console.log(`Sự kiện bị mất          : ${missing}`);
  console.log(`Độ trễ từng lần nhận    : p50 ${fmt(percentile(sorted, 50))} · p95 ${fmt(percentile(sorted, 95))} · p99 ${fmt(percentile(sorted, 99))} · max ${fmt(sorted[sorted.length - 1])}`);
  const ok = ratio >= TARGET_RATIO;
  console.log(ok ? '\nĐẠT tiêu chí nghiệm thu.' : '\nKHÔNG ĐẠT tiêu chí nghiệm thu.');

  for (const c of clients) c.disconnect();
  await closeRealtime();
  httpServer.close();
  await prisma.$disconnect();
  process.exitCode = ok ? 0 : 1;
}

await main();
