import { PrismaClient } from '@prisma/client';

// Một PrismaClient dùng chung cho cả ứng dụng (mỗi client giữ một connection pool riêng).
export const prisma = new PrismaClient();
