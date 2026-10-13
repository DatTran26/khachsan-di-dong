import { SummaryPeriod } from '@prisma/client';
import { Router } from 'express';
import { z } from 'zod';
import { authOf, requireAuth, requireRole } from '../auth/auth.middleware.js';
import { budgetStatus, createSummary, latestSummaries } from './ai-summary.service.js';

/** Tóm tắt vận hành — CHỈ quản lý, kiểm ở máy chủ (FR-ai-ops-summary-011, BR-001). */
export const aiSummaryRouter = Router();
aiSummaryRouter.use(requireAuth(), requireRole('MANAGER'));

/** Tạo bản tóm tắt cho kỳ. Luôn trả về một bản (AI / báo cáo mẫu / rỗng) + `notice` khi không dùng được AI. */
aiSummaryRouter.post('/', async (req, res) => {
  const { period } = z.object({ period: z.nativeEnum(SummaryPeriod) }).parse(req.body);
  const { summary, notice } = await createSummary(authOf(res).user, period);
  res.status(201).json({ data: summary, notice });
});

/** Bản gần nhất của mỗi kỳ (FR-013) — không gọi AI. */
aiSummaryRouter.get('/latest', async (_req, res) => {
  res.json({ data: await latestSummaries() });
});

aiSummaryRouter.get('/budget', async (_req, res) => {
  res.json({ data: await budgetStatus() });
});
