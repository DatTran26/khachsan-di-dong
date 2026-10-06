import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';

export const healthRouter = Router();

// Kiểm tra server + kết nối CSDL còn sống.
healthRouter.get('/', async (_req, res) => {
  await prisma.$queryRaw`SELECT 1`;
  res.json({ status: 'ok', time: new Date().toISOString() });
});
