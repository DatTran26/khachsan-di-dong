import type { AiSummary, SummaryFailure, SummaryPeriod, SummarySource, User } from '@prisma/client';
import { env } from '../../config/env.js';
import { writeAudit } from '../../lib/audit.js';
import { AppError } from '../../lib/errors.js';
import { MSG } from '../../lib/messages.js';
import { prisma } from '../../lib/prisma.js';
import {
  AiFormatError,
  AiTimeoutError,
  MAX_CALL_COST_VND,
  MAX_INPUT_TOKENS,
  SUMMARY_SCHEMA_VERSION,
  aiClient,
  costOf,
  inputTokenBound,
  type AiOutput,
} from './ai-summary.ai.js';
import { ACTIVITY_LABELS, buildPeriodMetrics, type AttentionItem, type PeriodMetrics } from './ai-summary.metrics.js';
import { formatVnTime, periodLabel, resolvePeriod, type PeriodRange } from './ai-summary.period.js';
import { validateAiOutput } from './ai-summary.validate.js';

/**
 * Tóm tắt vận hành (ai-ops-summary). Luồng (spec mục 9):
 *   chốt T → số liệu kỳ → kỳ rỗng: báo cáo rỗng, KHÔNG gọi AI → chưa cấu hình / hết hạn mức: báo cáo mẫu
 *   → gọi AI (≤15s) → kiểm tra số liệu → hợp lệ: bản AI · lỗi/quá giờ/sai: báo cáo mẫu → lưu + ghi nhật ký.
 * AI chỉ tham khảo: kết quả chỉ ghi vào bảng ai_summaries, không đường nào sửa dữ liệu nghiệp vụ (BR-003).
 */

// Mỗi lúc chỉ 1 lượt tạo (FR-008, BR-007). Một tiến trình backend trên VPS → khóa trong bộ nhớ là đủ.
let running = false;

type Attention = { items: AttentionItem[]; notes: string[] };

const NOTICE: Record<SummaryFailure, string> = {
  NOT_CONFIGURED: MSG.summaryNotConfigured,
  QUOTA_EXCEEDED: MSG.summaryQuotaExceeded,
  TIMEOUT: MSG.summaryAiFailed,
  AI_ERROR: MSG.summaryAiFailed,
  INVALID_OUTPUT: MSG.summaryAiFailed,
};

const formatRate = (rate: number | null) => (rate === null ? 'không áp dụng' : `${String(rate).replace('.', ',')}%`);

/** Gói dữ liệu gửi AI — chỉ số đếm/tỷ lệ + số phòng cần chú ý, không định danh khách (NFR-002). */
function toAiPayload(range: PeriodRange, metrics: PeriodMetrics, attention: AttentionItem[], asOf: Date) {
  const { rooms, openTasks } = metrics;
  return {
    ky: range.label,
    du_lieu_tinh_den: formatVnTime(asOf),
    phong: {
      tong: rooms.total,
      dang_o: rooms.occupied,
      trong: rooms.vacant,
      san_sang: rooms.ready,
      can_don: rooms.dirty,
      dang_don: rooms.cleaning,
      cho_kiem_tra: rooms.pendingInspection,
      ngung_phuc_vu: rooms.outOfService,
      ty_le_lap_day: formatRate(rooms.occupancyRate),
    },
    viec_dang_mo: {
      don_phong_cho_giao: openTasks.housekeeping.unassigned,
      don_phong_da_giao: openTasks.housekeeping.assigned,
      don_phong_dang_lam: openTasks.housekeeping.inProgress,
      don_phong_cho_xac_nhan: openTasks.housekeeping.pendingConfirm,
      bao_tri_cho_nhan: openTasks.maintenance.open,
      bao_tri_dang_sua: openTasks.maintenance.inProgress,
      don_phong_qua_han: openTasks.overdueHousekeeping,
      bao_tri_qua_han: openTasks.overdueMaintenance,
    },
    hoat_dong_trong_ky: Object.fromEntries(
      Object.entries(metrics.activity).map(([action, n]) => [ACTIVITY_LABELS[action as keyof typeof ACTIVITY_LABELS], n]),
    ),
    danh_sach_can_chu_y: attention.map((a) => a.text),
  };
}

type AiPayload = ReturnType<typeof toAiPayload> & { so_muc_can_chu_y_khong_liet_ke?: number };

/**
 * Cắt danh sách cần chú ý (bỏ từ cuối — phòng ngừng phục vụ trước, việc quá hạn giữ lâu nhất) cho tới khi gói vừa
 * MAX_INPUT_TOKENS → chi phí thật không vượt mức đã chặn ngân sách (FR-009, NFR-003). Danh sách đầy đủ vẫn lưu
 * theo quy tắc trong `attention.items`; AI chỉ thấy số mục bị bỏ.
 */
function fitPayload(payload: AiPayload): AiPayload {
  const list = [...payload.danh_sach_can_chu_y];
  let fitted: AiPayload = payload;
  while (inputTokenBound(fitted) > MAX_INPUT_TOKENS && list.length > 0) {
    list.pop();
    fitted = { ...payload, danh_sach_can_chu_y: list, so_muc_can_chu_y_khong_liet_ke: payload.danh_sach_can_chu_y.length - list.length };
  }
  return fitted;
}

/** Báo cáo mẫu từ dữ liệu gốc (FR-007) — cùng nhóm chỉ số chính, không có lời văn AI. */
function fallbackContent(range: PeriodRange, metrics: PeriodMetrics) {
  const { rooms, openTasks } = metrics;
  const overdue = openTasks.overdueHousekeeping + openTasks.overdueMaintenance;
  return {
    overview:
      `${range.label}: ${rooms.occupied}/${rooms.total} phòng đang ở (lấp đầy ${formatRate(rooms.occupancyRate)}), ` +
      `${rooms.ready} phòng sẵn sàng, ${rooms.dirty} phòng cần dọn, ${rooms.outOfService} phòng ngừng phục vụ; ` +
      `${overdue} việc quá hạn.`,
    highlights: Object.entries(metrics.activity)
      .filter(([, n]) => n > 0)
      .map(([action, n]) => `${ACTIVITY_LABELS[action as keyof typeof ACTIVITY_LABELS]}: ${n}`),
  };
}

const LABEL: Record<SummarySource, string | null> = {
  AI: MSG.summaryLabelAi,
  FALLBACK: MSG.summaryLabelFallback,
  EMPTY: null,
};

export function toSummaryDto(s: AiSummary & { createdBy: Pick<User, 'id' | 'fullName'> }) {
  return {
    id: s.id,
    period: s.period,
    schemaVersion: s.schemaVersion,
    periodLabel: periodLabel(s.period, s.periodStart),
    periodStart: s.periodStart,
    periodEnd: s.periodEnd,
    dataAsOf: s.dataAsOf,
    dataAsOfText: MSG.summaryDataAsOf(formatVnTime(s.dataAsOf)), // FR-006
    source: s.source,
    label: LABEL[s.source], // nhãn cố định "tham khảo" / "báo cáo mẫu" (FR-006, FR-007)
    overview: s.overview,
    highlights: s.highlights as string[],
    attention: s.attention as unknown as Attention, // items: theo quy tắc, có roomId/taskId để mở dashboard (FR-012)
    metrics: s.metrics as unknown as PeriodMetrics,
    calledAi: s.calledAi,
    failureReason: s.failureReason,
    createdBy: s.createdBy,
    createdAt: s.createdAt,
  };
}

const createdByInclude = { createdBy: { select: { id: true, fullName: true } } } as const;

async function spentVnd() {
  const { _sum } = await prisma.aiSummary.aggregate({ _sum: { costVnd: true } });
  return _sum.costVnd ?? 0;
}

type Outcome = {
  source: SummarySource;
  overview: string;
  highlights: string[];
  notes: string[];
  calledAi: boolean;
  failureReason: SummaryFailure | null;
  costVnd: number;
};

/** Thử bản AI; mọi đường lỗi trả về lý do để dựng báo cáo mẫu. */
async function tryAi(payload: unknown): Promise<Omit<Outcome, 'source' | 'overview' | 'highlights' | 'notes'> & { output?: AiOutput }> {
  if (!env.OPENAI_API_KEY) return { calledAi: false, failureReason: 'NOT_CONFIGURED', costVnd: 0 };
  // Cắt danh sách rồi vẫn quá cỡ (không xảy ra với dạng gói hiện tại) → không gọi, giữ đúng trần chi phí.
  if (inputTokenBound(payload) > MAX_INPUT_TOKENS) {
    console.warn('Gói gửi AI vượt giới hạn token đầu vào — dùng báo cáo mẫu');
    return { calledAi: false, failureReason: 'AI_ERROR', costVnd: 0 };
  }
  // Chặn TRƯỚC khi gọi theo chi phí tối đa của 1 lượt → không bao giờ vượt ngân sách (FR-009, NFR-003).
  if ((await spentVnd()) + MAX_CALL_COST_VND > env.AI_BUDGET_VND) {
    return { calledAi: false, failureReason: 'QUOTA_EXCEEDED', costVnd: 0 };
  }
  try {
    const { output, usage } = await aiClient.generate(payload);
    const checked = validateAiOutput(output, payload);
    if (!checked.ok) {
      console.warn('Đầu ra AI không hợp lệ:', checked.reason);
      return { calledAi: true, failureReason: 'INVALID_OUTPUT', costVnd: costOf(usage) };
    }
    return { calledAi: true, failureReason: null, costVnd: costOf(usage), output: checked.output };
  } catch (error) {
    console.warn('Gọi AI thất bại:', error instanceof Error ? error.message : error);
    // Quá giờ: không biết đã tốn bao nhiêu → tính mức tối đa cho an toàn ngân sách.
    if (error instanceof AiTimeoutError) return { calledAi: true, failureReason: 'TIMEOUT', costVnd: MAX_CALL_COST_VND };
    if (error instanceof AiFormatError) {
      return { calledAi: true, failureReason: 'INVALID_OUTPUT', costVnd: error.usage ? costOf(error.usage) : MAX_CALL_COST_VND };
    }
    return { calledAi: true, failureReason: 'AI_ERROR', costVnd: 0 };
  }
}

async function generate(actor: User, period: SummaryPeriod, now: Date) {
  const range = resolvePeriod(period, now);
  const { metrics, attention, hasActivity } = await buildPeriodMetrics(range);

  let outcome: Outcome;
  if (!hasActivity) {
    // Kỳ rỗng → không gọi AI (FR-003, BR-004). Vẫn kèm việc cần chú ý theo quy tắc (việc quá hạn, phòng ngừng
    // phục vụ đang tồn tại) để quản lý không bỏ sót — chốt 10/10/2026.
    outcome = { source: 'EMPTY', overview: MSG.summaryEmpty, highlights: [], notes: [], calledAi: false, failureReason: null, costVnd: 0 };
  } else {
    const payload = fitPayload(toAiPayload(range, metrics, attention, now));
    const ai = await tryAi(payload);
    outcome = ai.output
      ? { source: 'AI', overview: ai.output.overview, highlights: ai.output.highlights, notes: ai.output.attention, ...ai }
      : { source: 'FALLBACK', ...fallbackContent(range, metrics), notes: [], ...ai };
  }

  const saved = await prisma.$transaction(async (tx) => {
    const summary = await tx.aiSummary.create({
      data: {
        period,
        periodStart: range.start,
        periodEnd: range.end,
        dataAsOf: now,
        source: outcome.source,
        overview: outcome.overview,
        highlights: outcome.highlights,
        attention: { items: attention, notes: outcome.notes } satisfies Attention as never,
        metrics: metrics as never,
        calledAi: outcome.calledAi,
        failureReason: outcome.failureReason,
        costVnd: outcome.costVnd,
        model: outcome.calledAi ? env.OPENAI_MODEL : null,
        schemaVersion: SUMMARY_SCHEMA_VERSION,
        createdById: actor.id,
      },
      include: createdByInclude,
    });
    // Mọi lượt tạo đều ghi nhật ký: ai, khi nào, kỳ nào, loại kết quả, có gọi AI không (FR-010, NFR-005).
    await writeAudit(tx, {
      actorId: actor.id,
      actorRole: actor.role,
      action: 'ai_summary.generated',
      entityType: 'AI_SUMMARY',
      entityId: summary.id,
      entityLabel: `Tóm tắt ${range.label}`,
      changes: [
        { field: 'source', after: outcome.source },
        { field: 'calledAi', after: String(outcome.calledAi) },
        ...(outcome.failureReason ? [{ field: 'failureReason', after: outcome.failureReason }] : []),
      ],
    });
    return summary;
  });

  const notice = outcome.source === 'EMPTY' ? MSG.summaryEmpty : outcome.failureReason ? NOTICE[outcome.failureReason] : null;
  return { summary: toSummaryDto(saved), notice };
}

export async function createSummary(actor: User, period: SummaryPeriod, now: Date = new Date()) {
  if (running) throw new AppError(409, 'SUMMARY_IN_PROGRESS', MSG.summaryInProgress);
  running = true;
  try {
    return await generate(actor, period, now);
  } finally {
    running = false;
  }
}

/** Bản gần nhất của mỗi kỳ — xem lại không gọi AI (FR-013). Chỉ lấy bản cùng phiên bản dạng dữ liệu hiện tại. */
export async function latestSummaries() {
  const periods: SummaryPeriod[] = ['CURRENT_SHIFT', 'PREVIOUS_SHIFT', 'TODAY'];
  const rows = await Promise.all(
    periods.map((period) =>
      prisma.aiSummary.findFirst({
        where: { period, schemaVersion: SUMMARY_SCHEMA_VERSION },
        orderBy: { createdAt: 'desc' },
        include: createdByInclude,
      }),
    ),
  );
  return Object.fromEntries(periods.map((p, i) => [p, rows[i] ? toSummaryDto(rows[i]) : null]));
}

/** Tình trạng ngân sách AI cho màn quản lý. */
export async function budgetStatus() {
  const spent = await spentVnd();
  return {
    aiConfigured: Boolean(env.OPENAI_API_KEY),
    model: env.OPENAI_MODEL,
    budgetVnd: env.AI_BUDGET_VND,
    spentVnd: spent,
    remainingVnd: Math.max(0, env.AI_BUDGET_VND - spent),
    exhausted: spent + MAX_CALL_COST_VND > env.AI_BUDGET_VND,
  };
}
