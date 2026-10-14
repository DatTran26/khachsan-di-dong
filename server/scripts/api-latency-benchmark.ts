/**
 * Đo độ trễ API dashboard và tóm tắt vận hành (S3-BAO-013) — baseline p50/p95 cho báo cáo QA.
 *
 * Cách đo: khởi động server thật trên CSDL test, tạo 50 phòng (đúng quy mô nghiệm thu), gọi tuần tự qua HTTP:
 * - GET  /api/dashboard/summary  (REQUESTS lượt)
 * - POST /api/ai-summaries       (SUMMARIES lượt) — dịch vụ AI được thay bằng bản giả trả ngay, nên con số là
 *   thời gian xử lý của server (gom số liệu, kiểm đầu ra, lưu, ghi nhật ký). Thời gian chờ AI thật bị chặn ≤ AI_TIMEOUT_MS.
 *
 * Chạy trên CSDL test (không đụng dữ liệu dev, không gọi mạng AI thật):  npm run bench:api
 * Tuỳ chỉnh: REQUESTS=200 SUMMARIES=30 npm run bench:api
 */
import { execSync } from 'node:child_process';
import { randomUUID } from 'node:crypto';
import { createServer } from 'node:http';
import type { AddressInfo } from 'node:net';
import { performance } from 'node:perf_hooks';
import { config } from 'dotenv';
import { testDatabaseUrl } from '../tests/test-db.js';

config({ quiet: true });
process.env.DATABASE_URL = testDatabaseUrl();
execSync('npx prisma migrate deploy', { env: process.env, stdio: 'pipe' });

// Import sau khi đã trỏ DATABASE_URL sang CSDL test.
const { createApp } = await import('../src/app.js');
const { env } = await import('../src/config/env.js');
const { writeAudit } = await import('../src/lib/audit.js');
const { prisma } = await import('../src/lib/prisma.js');
const { aiClient } = await import('../src/modules/ai-summary/ai-summary.ai.js');
const { createUserWithToken } = await import('../tests/helpers.js');

const REQUESTS = Number(process.env.REQUESTS ?? 100);
const SUMMARIES = Number(process.env.SUMMARIES ?? 20);
const ROOMS = 50;

function percentile(sorted: number[], p: number) {
  return sorted[Math.min(sorted.length - 1, Math.ceil((p / 100) * sorted.length) - 1)];
}

function report(name: string, samples: number[]) {
  const sorted = [...samples].sort((a, b) => a - b);
  const fmt = (ms: number) => `${ms.toFixed(1)} ms`;
  console.log(
    `${name.padEnd(28)}: ${samples.length} lượt · p50 ${fmt(percentile(sorted, 50))} · p95 ${fmt(percentile(sorted, 95))} · max ${fmt(sorted[sorted.length - 1])}`,
  );
}

async function measure(times: number, call: () => Promise<Response>) {
  const samples: number[] = [];
  for (let i = 0; i < times; i++) {
    const t0 = performance.now();
    const res = await call();
    await res.arrayBuffer();
    samples.push(performance.now() - t0);
    if (!res.ok) throw new Error(`HTTP ${res.status} ở lượt ${i + 1}`);
  }
  return samples;
}

async function main() {
  const httpServer = createServer(createApp());
  await new Promise<void>((resolve) => httpServer.listen(0, resolve));
  const { port } = httpServer.address() as AddressInfo;
  const base = `http://localhost:${port}/api`;

  const stamp = Date.now();
  const roomType = await prisma.roomType.create({ data: { name: `BENCH-API-${stamp}` } });
  await prisma.room.createMany({
    data: Array.from({ length: ROOMS }, (_, i) => ({ number: `BA${stamp % 100_000}-${i}`, floor: 9, roomTypeId: roomType.id })),
  });
  const manager = await createUserWithToken('MANAGER', { fullName: 'Bench API' });
  // 1 hoạt động trong kỳ → kỳ "có dữ liệu", tóm tắt đi đúng nhánh gọi AI (không dừng ở báo cáo rỗng).
  await prisma.$transaction((tx) =>
    writeAudit(tx, { actorId: manager.user.id, actorRole: 'MANAGER', action: 'stay.check_in', entityType: 'STAY', entityId: randomUUID() }),
  );

  // AI giả: trả ngay một bản hợp lệ (không chứa số) → đo phần việc của server.
  env.OPENAI_API_KEY = 'sk-bench';
  env.AI_BUDGET_VND = Number.MAX_SAFE_INTEGER;
  aiClient.generate = async () => ({
    output: { overview: 'Vận hành ổn định trong kỳ.', highlights: [], attention: [] },
    usage: { inputTokens: 0, outputTokens: 0 },
  });

  const headers = { ...manager.auth, 'Content-Type': 'application/json' };
  console.log(`CSDL test · ${ROOMS} phòng mới (+ dữ liệu test sẵn có). Bắt đầu đo...`);
  const dashboard = await measure(REQUESTS, () => fetch(`${base}/dashboard/summary`, { headers }));
  const summaries = await measure(SUMMARIES, () =>
    fetch(`${base}/ai-summaries`, { method: 'POST', headers, body: JSON.stringify({ period: 'TODAY' }) }),
  );
  const latest = await measure(REQUESTS, () => fetch(`${base}/ai-summaries/latest`, { headers }));

  console.log('\n=== Độ trễ API (đo tại máy chạy server, không tính mạng) ===');
  report('GET /dashboard/summary', dashboard);
  report('POST /ai-summaries (AI giả)', summaries);
  report('GET /ai-summaries/latest', latest);

  httpServer.close();
  await prisma.$disconnect();
}

await main();
