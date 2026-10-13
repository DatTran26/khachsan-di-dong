import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';

export const healthRouter = Router();

// Kiểm tra server + kết nối CSDL còn sống. CSDL sập → 503 (không phải 500 chung) để giám sát phân biệt với lỗi code.
healthRouter.get('/', async (_req, res) => {
  const time = new Date().toISOString();
  try {
    await prisma.$queryRaw`SELECT 1`;
    res.json({ status: 'ok', db: 'up', time });
  } catch {
    res.status(503).json({ status: 'error', db: 'down', time });
  }
});
