import { PrismaClient } from '@prisma/client';

/**
 * Prisma Client dùng chung cho cả tiến trình.
 *
 * Mỗi `PrismaClient` giữ một connection pool riêng, nên không tạo thêm instance
 * trong route hay test helper — test trỏ vào client này qua `server/tests/test-db.ts`.
 * `server.ts` gọi `$disconnect` khi nhận SIGINT/SIGTERM. Không log câu query.
 */
export const prisma = new PrismaClient();
