import { execSync } from 'node:child_process';
import { PrismaClient } from '@prisma/client';
import { config } from 'dotenv';
import { testDatabaseUrl } from './test-db.js';

/** Chạy 1 lần trước toàn bộ test: tạo/cập nhật bảng trong CSDL test rồi xóa sạch dữ liệu cũ. */
export default async function globalSetup() {
  config({ quiet: true });
  const url = testDatabaseUrl();

  execSync('npx prisma migrate deploy', { env: { ...process.env, DATABASE_URL: url }, stdio: 'pipe' });

  const prisma = new PrismaClient({ datasourceUrl: url });
  // TRUNCATE không kích hoạt trigger chặn sửa/xóa nhật ký (trigger theo dòng) → dọn được CSDL test.
  await prisma.$executeRawUnsafe(`
    TRUNCATE audit_log_changes, audit_logs, ai_summaries, ai_quotas, out_of_service_holds,
             maintenance_tasks, housekeeping_tasks, stays, sessions, rooms, room_types, users CASCADE`);
  await prisma.$disconnect();
}
