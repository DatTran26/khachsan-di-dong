/**
 * Đối chiếu docs/features/ai-ops-summary/srs/ai-ops-summary-spec.md (FR / NFR / BR / E-xxx / SC).
 * Dịch vụ AI luôn được giả lập — test không gọi mạng thật, không tốn chi phí.
 */
import { randomUUID } from 'node:crypto';
import request from 'supertest';
import { afterAll, afterEach, beforeAll, beforeEach, describe, expect, it, vi } from 'vitest';
import { createApp } from '../src/app.js';
import { env } from '../src/config/env.js';
import { writeAudit } from '../src/lib/audit.js';
import { MSG } from '../src/lib/messages.js';
import { prisma } from '../src/lib/prisma.js';
import {
  AiFormatError,
  AiServiceError,
  AiTimeoutError,
  MAX_CALL_COST_VND,
  MAX_INPUT_TOKENS,
  SUMMARY_SCHEMA_VERSION,
  aiClient,
  costOf,
  inputTokenBound,
  type AiOutput,
} from '../src/modules/ai-summary/ai-summary.ai.js';
import { resolvePeriod } from '../src/modules/ai-summary/ai-summary.period.js';
import { createSummary } from '../src/modules/ai-summary/ai-summary.service.js';
import { extractNumbers, validateAiOutput } from '../src/modules/ai-summary/ai-summary.validate.js';
import { createUserWithToken } from './helpers.js';

type Payload = {
  phong: { tong: number; dang_o: number; ty_le_lap_day: string };
  danh_sach_can_chu_y: string[];
};

const app = createApp();
const tag = randomUUID().slice(0, 6);
const USAGE = { inputTokens: 1_200, outputTokens: 300 };
const original = { key: env.OPENAI_API_KEY, budget: env.AI_BUDGET_VND };
let manager: Awaited<ReturnType<typeof createUserWithToken>>;
let receptionist: Awaited<ReturnType<typeof createUserWithToken>>;
let roomTypeId: string;

/** Bản AI "ngoan": chỉ dùng số có trong dữ liệu được gửi. */
function goodOutput(payload: unknown): AiOutput {
  const p = payload as Payload;
  return {
    overview: `Hiện có ${p.phong.dang_o}/${p.phong.tong} phòng đang ở, lấp đầy ${p.phong.ty_le_lap_day}.`,
    highlights: ['Ca vận hành ổn định.'],
    attention: p.danh_sach_can_chu_y.slice(0, 3),
  };
}

const create = (auth: Record<string, string>, period = 'CURRENT_SHIFT') =>
  request(app).post('/api/ai-summaries').set(auth).send({ period });

/** Ghi 1 hoạt động vận hành vào nhật ký lúc này → kỳ hiện tại "có dữ liệu". */
async function recordActivity() {
  const room = await prisma.room.create({ data: { number: `AI${tag}${randomUUID().slice(0, 4)}`, floor: 7, roomTypeId } });
  await prisma.$transaction((tx) =>
    writeAudit(tx, {
      actorId: receptionist.user.id,
      actorRole: 'RECEPTIONIST',
      action: 'stay.check_in',
      entityType: 'STAY',
      entityId: randomUUID(),
      roomId: room.id,
    }),
  );
  return room;
}

beforeAll(async () => {
  manager = await createUserWithToken('MANAGER');
  receptionist = await createUserWithToken('RECEPTIONIST');
  roomTypeId = (await prisma.roomType.create({ data: { name: `AI-${tag}` } })).id;
  await recordActivity();
});

beforeEach(() => {
  env.OPENAI_API_KEY = 'sk-test';
  env.AI_BUDGET_VND = 300_000;
});

afterEach(() => {
  vi.restoreAllMocks();
});

afterAll(async () => {
  env.OPENAI_API_KEY = original.key;
  env.AI_BUDGET_VND = original.budget;
  await prisma.$disconnect();
});

describe('Kỳ tóm tắt theo ca giờ Việt Nam (FR-001)', () => {
  // 00:30 UTC = 07:30 giờ VN
  const at = (iso: string) => new Date(iso);

  it('07:30 → ca hiện tại 06:00–14:00, ca trước 22:00–06:00', () => {
    const now = at('2026-10-07T00:30:00Z');
    const current = resolvePeriod('CURRENT_SHIFT', now);
    expect(current.start.toISOString()).toBe('2026-10-06T23:00:00.000Z');
    expect(current.end).toEqual(now);
    expect(current.label).toBe('Ca 06:00–14:00 ngày 07/10');
    const previous = resolvePeriod('PREVIOUS_SHIFT', now);
    expect([previous.start.toISOString(), previous.end.toISOString()]).toEqual(['2026-10-06T15:00:00.000Z', '2026-10-06T23:00:00.000Z']);
    expect(previous.label).toBe('Ca 22:00–06:00 ngày 06/10');
  });

  it('03:00 sáng → vẫn thuộc ca 22:00 của hôm trước', () => {
    const current = resolvePeriod('CURRENT_SHIFT', at('2026-10-06T20:00:00Z'));
    expect(current.label).toBe('Ca 22:00–06:00 ngày 06/10');
  });

  it('"hôm nay" bắt đầu từ 00:00 giờ VN; mọi kỳ kết thúc ≤ T (không có kỳ tương lai)', () => {
    const now = at('2026-10-07T10:00:00Z'); // 17:00 VN
    const today = resolvePeriod('TODAY', now);
    expect(today.start.toISOString()).toBe('2026-10-06T17:00:00.000Z');
    for (const period of ['CURRENT_SHIFT', 'PREVIOUS_SHIFT', 'TODAY'] as const) {
      expect(resolvePeriod(period, now).end.getTime()).toBeLessThanOrEqual(now.getTime());
    }
  });
});

describe('Kiểm tra đầu ra AI (FR-005, BR-005)', () => {
  const payload = { phong: { tong: 50, dang_o: 30, ty_le_lap_day: '66,7%' }, danh_sach_can_chu_y: ['Phòng 305 đang ngừng phục vụ'] };

  it('nhận số thập phân kiểu Việt ("66,7") và số phòng có trong dữ liệu', () => {
    expect(extractNumbers('lấp đầy 66,7% và 30 phòng')).toEqual([66.7, 30]);
    const ok = validateAiOutput({ overview: '30/50 phòng đang ở (66,7%).', highlights: [], attention: ['Phòng 305 ngừng phục vụ'] }, payload);
    expect(ok.ok).toBe(true);
  });

  it('con số tự tính / bịa → loại', () => {
    const bad = validateAiOutput({ overview: '20 phòng đang trống.', highlights: [], attention: [] }, payload);
    expect(bad).toMatchObject({ ok: false });
  });

  it('nêu phòng không có trong danh sách cần chú ý → loại', () => {
    const bad = validateAiOutput({ overview: 'Ổn định.', highlights: [], attention: ['Phòng 410 hỏng điều hòa'] }, payload);
    expect(bad.ok).toBe(false);
  });

  it('sai cấu trúc / rỗng → loại', () => {
    expect(validateAiOutput({ overview: '', highlights: [], attention: [] }, payload).ok).toBe(false);
    expect(validateAiOutput({ overview: 'x', highlights: 'không phải mảng' }, payload).ok).toBe(false);
    expect(validateAiOutput(null, payload).ok).toBe(false);
  });
});

describe('Tạo tóm tắt (FR-002…004, FR-006, FR-010)', () => {
  it('kỳ có dữ liệu + còn hạn mức → bản AI đã kiểm tra, kèm thời điểm T và nhãn "tham khảo"', async () => {
    const spy = vi.spyOn(aiClient, 'generate').mockImplementation(async (payload) => ({ output: goodOutput(payload), usage: USAGE }));
    const res = await create(manager.auth);

    expect(res.status).toBe(201);
    expect(spy).toHaveBeenCalledTimes(1);
    expect(res.body.notice).toBeNull();
    expect(res.body.data).toMatchObject({ source: 'AI', label: MSG.summaryLabelAi, calledAi: true, failureReason: null });
    expect(res.body.data.dataAsOfText).toMatch(/^Dữ liệu tính đến \d{2}:\d{2} \d{2}\/\d{2}$/);
    const row = await prisma.aiSummary.findUniqueOrThrow({ where: { id: res.body.data.id } });
    expect(row.costVnd).toBe(costOf(USAGE));
  });

  it('FR-010: mọi lượt tạo đều ghi nhật ký — ai, kỳ, loại kết quả, có gọi AI', async () => {
    vi.spyOn(aiClient, 'generate').mockImplementation(async (payload) => ({ output: goodOutput(payload), usage: USAGE }));
    const res = await create(manager.auth, 'TODAY');
    const log = await prisma.auditLog.findFirstOrThrow({
      where: { entityId: res.body.data.id, action: 'ai_summary.generated' },
      include: { changes: true },
    });
    expect(log).toMatchObject({ actorId: manager.user.id, entityType: 'AI_SUMMARY' });
    expect(log.entityLabel).toMatch(/^Tóm tắt Hôm nay/);
    expect(log.changes.map((c) => [c.field, c.after])).toEqual([
      ['source', 'AI'],
      ['calledAi', 'true'],
    ]);
  });

  it('NFR-002 / SC-04: gói gửi AI chỉ có số tổng hợp — không tên khách, không nhật ký thô', async () => {
    const room = await prisma.room.create({ data: { number: `AIG${tag}`, floor: 7, roomTypeId, occupancy: 'OCCUPIED' } });
    await prisma.stay.create({ data: { roomId: room.id, guestName: 'Khách Bí Mật Xyz', guestCount: 2, checkedInById: receptionist.user.id } });
    let sent = '';
    vi.spyOn(aiClient, 'generate').mockImplementation(async (payload) => {
      sent = JSON.stringify(payload);
      return { output: goodOutput(payload), usage: USAGE };
    });
    await create(manager.auth);

    expect(sent).not.toContain('Khách Bí Mật Xyz');
    expect(sent).not.toMatch(/guest|actorId|fullName|phone/i);
    expect(sent).not.toContain(receptionist.user.fullName);
  });

  it('SC-04: AI không sửa dữ liệu nghiệp vụ — trạng thái/phiên bản phòng giữ nguyên', async () => {
    const before = await prisma.room.findMany({ select: { id: true, version: true }, orderBy: { id: 'asc' } });
    vi.spyOn(aiClient, 'generate').mockImplementation(async (payload) => ({ output: goodOutput(payload), usage: USAGE }));
    await create(manager.auth);
    expect(await prisma.room.findMany({ select: { id: true, version: true }, orderBy: { id: 'asc' } })).toEqual(before);
  });

  it('FR-003 / BR-004 / E-001: kỳ không có hoạt động → báo cáo rỗng, KHÔNG gọi AI', async () => {
    const spy = vi.spyOn(aiClient, 'generate');
    // Ca trước của một ngày trong tương lai xa → chắc chắn không có nhật ký.
    const { summary, notice } = await createSummary(manager.user, 'PREVIOUS_SHIFT', new Date('2030-01-01T03:00:00Z'));

    expect(spy).not.toHaveBeenCalled();
    expect(notice).toBe(MSG.summaryEmpty);
    expect(summary).toMatchObject({ source: 'EMPTY', overview: MSG.summaryEmpty, calledAi: false, label: null });
  });

  it('chốt 10/10: kỳ rỗng vẫn liệt kê việc cần chú ý đang tồn tại (phòng ngừng phục vụ, việc quá hạn)', async () => {
    const oos = await prisma.room.create({ data: { number: `AIE${tag}`, floor: 7, roomTypeId, service: 'OUT_OF_SERVICE' } });
    const { summary } = await createSummary(manager.user, 'PREVIOUS_SHIFT', new Date('2030-01-01T03:00:00Z'));
    expect(summary.source).toBe('EMPTY');
    expect(summary.attention.items).toContainEqual(expect.objectContaining({ type: 'OUT_OF_SERVICE', roomId: oos.id }));
  });
});

describe('Báo cáo mẫu khi không dùng được AI (FR-007, FR-009, NFR-004, SC-02)', () => {
  async function expectFallback(res: request.Response, reason: string, notice: string) {
    expect(res.status).toBe(201);
    expect(res.body.notice).toBe(notice);
    expect(res.body.data).toMatchObject({ source: 'FALLBACK', label: MSG.summaryLabelFallback, failureReason: reason });
    // Báo cáo mẫu vẫn đủ số liệu cốt lõi
    const { rooms } = res.body.data.metrics;
    expect(res.body.data.overview).toContain(`${rooms.occupied}/${rooms.total} phòng đang ở`);
    return prisma.aiSummary.findUniqueOrThrow({ where: { id: res.body.data.id } });
  }

  it('E-005: đầu ra AI sai số liệu → loại bản AI, dùng báo cáo mẫu, vẫn tính chi phí đã gọi', async () => {
    vi.spyOn(aiClient, 'generate').mockResolvedValue({
      output: { overview: 'Có 987 phòng đang ở.', highlights: [], attention: [] },
      usage: USAGE,
    });
    const row = await expectFallback(await create(manager.auth), 'INVALID_OUTPUT', MSG.summaryAiFailed);
    expect(row).toMatchObject({ calledAi: true, costVnd: costOf(USAGE) });
  });

  it('E-005: AI trả sai cấu trúc → báo cáo mẫu', async () => {
    vi.spyOn(aiClient, 'generate').mockRejectedValue(new AiFormatError('không phải JSON', USAGE));
    await expectFallback(await create(manager.auth), 'INVALID_OUTPUT', MSG.summaryAiFailed);
  });

  it('E-002 / NFR-001: quá 15 giây → báo cáo mẫu; tính chi phí tối đa cho an toàn ngân sách', async () => {
    vi.spyOn(aiClient, 'generate').mockRejectedValue(new AiTimeoutError('timeout'));
    const row = await expectFallback(await create(manager.auth), 'TIMEOUT', MSG.summaryAiFailed);
    expect(row.costVnd).toBe(MAX_CALL_COST_VND);
  });

  it('E-002: dịch vụ AI lỗi → báo cáo mẫu', async () => {
    vi.spyOn(aiClient, 'generate').mockRejectedValue(new AiServiceError('HTTP 500'));
    const row = await expectFallback(await create(manager.auth), 'AI_ERROR', MSG.summaryAiFailed);
    expect(row.costVnd).toBe(0);
  });

  it('chưa cấu hình khóa API → báo cáo mẫu, không gọi AI', async () => {
    env.OPENAI_API_KEY = undefined;
    const spy = vi.spyOn(aiClient, 'generate');
    const row = await expectFallback(await create(manager.auth), 'NOT_CONFIGURED', MSG.summaryNotConfigured);
    expect(spy).not.toHaveBeenCalled();
    expect(row.calledAi).toBe(false);
  });

  it('E-003 / FR-009: không đủ ngân sách cho 1 lượt → KHÔNG gọi AI, báo cáo mẫu', async () => {
    const { _sum } = await prisma.aiSummary.aggregate({ _sum: { costVnd: true } });
    env.AI_BUDGET_VND = (_sum.costVnd ?? 0) + MAX_CALL_COST_VND - 1;
    const spy = vi.spyOn(aiClient, 'generate');
    await expectFallback(await create(manager.auth), 'QUOTA_EXCEEDED', MSG.summaryQuotaExceeded);
    expect(spy).not.toHaveBeenCalled();

    const budget = await request(app).get('/api/ai-summaries/budget').set(manager.auth);
    expect(budget.body.data).toMatchObject({ aiConfigured: true, exhausted: true });
  });

  it('FR-007 / FR-012: việc cần chú ý theo quy tắc — việc quá hạn + phòng ngừng phục vụ, có liên kết phòng/việc', async () => {
    const room = await prisma.room.create({ data: { number: `AIO${tag}`, floor: 7, roomTypeId } });
    const task = await prisma.housekeepingTask.create({
      data: { roomId: room.id, dueAt: new Date(Date.now() - 3_600_000), overdueFlaggedAt: new Date() },
    });
    const oos = await prisma.room.create({ data: { number: `AIS${tag}`, floor: 7, roomTypeId, service: 'OUT_OF_SERVICE' } });
    vi.spyOn(aiClient, 'generate').mockRejectedValue(new AiServiceError('down'));
    const res = await create(manager.auth);

    expect(res.body.data.attention.items).toEqual(
      expect.arrayContaining([
        expect.objectContaining({ type: 'HOUSEKEEPING_OVERDUE', roomId: room.id, taskId: task.id, text: `Việc dọn phòng ${room.number} quá hạn` }),
        expect.objectContaining({ type: 'OUT_OF_SERVICE', roomId: oos.id, text: `Phòng ${oos.number} đang ngừng phục vụ` }),
      ]),
    );
    await prisma.housekeepingTask.delete({ where: { id: task.id } });
  });

  it('FR-009 / NFR-003: danh sách cần chú ý quá dài → cắt gói cho vừa trần token (giữ việc quá hạn), lưu đủ danh sách', async () => {
    const overdueRoom = await prisma.room.create({ data: { number: `AIQ${tag}`, floor: 7, roomTypeId } });
    const task = await prisma.housekeepingTask.create({
      data: { roomId: overdueRoom.id, dueAt: new Date(Date.now() - 3_600_000), overdueFlaggedAt: new Date() },
    });
    await prisma.room.createMany({
      data: Array.from({ length: 80 }, (_, i) => ({
        number: `AIB${tag}${String(i).padStart(2, '0')}`,
        floor: 7,
        roomTypeId,
        service: 'OUT_OF_SERVICE' as const,
      })),
    });
    let sent: (Payload & { so_muc_can_chu_y_khong_liet_ke?: number }) | undefined;
    vi.spyOn(aiClient, 'generate').mockImplementation(async (payload) => {
      sent = payload as typeof sent;
      return { output: goodOutput(payload), usage: USAGE };
    });
    const res = await create(manager.auth);

    expect(inputTokenBound(sent)).toBeLessThanOrEqual(MAX_INPUT_TOKENS);
    expect(sent!.so_muc_can_chu_y_khong_liet_ke).toBeGreaterThan(0);
    expect(sent!.danh_sach_can_chu_y).toContain(`Việc dọn phòng ${overdueRoom.number} quá hạn`);
    expect(res.body.data.attention.items.length).toBe(sent!.danh_sach_can_chu_y.length + sent!.so_muc_can_chu_y_khong_liet_ke!);

    await prisma.housekeepingTask.delete({ where: { id: task.id } });
    await prisma.room.deleteMany({ where: { number: { startsWith: `AIB${tag}` } } });
  });
});

describe('Một lượt mỗi lúc, xem lại, quyền (FR-008, FR-011, FR-013)', () => {
  it('E-007: đang có lượt chạy → lượt sau bị từ chối, chỉ 1 lần gọi AI', async () => {
    let release: () => void = () => {};
    const spy = vi.spyOn(aiClient, 'generate').mockImplementation(
      (payload) => new Promise((resolve) => (release = () => resolve({ output: goodOutput(payload), usage: USAGE }))),
    );
    const first = create(manager.auth).then((r) => r);
    await vi.waitFor(() => expect(spy).toHaveBeenCalledTimes(1));
    const second = await create(manager.auth);
    release();

    expect(second.status).toBe(409);
    expect(second.body.error).toMatchObject({ code: 'SUMMARY_IN_PROGRESS', message: MSG.summaryInProgress });
    expect((await first).status).toBe(201);
    expect(spy).toHaveBeenCalledTimes(1);
  });

  it('FR-013: xem lại bản gần nhất mỗi kỳ — không gọi AI', async () => {
    vi.spyOn(aiClient, 'generate').mockImplementation(async (payload) => ({ output: goodOutput(payload), usage: USAGE }));
    const made = await create(manager.auth, 'TODAY');
    const spy = vi.spyOn(aiClient, 'generate');
    spy.mockClear();

    const res = await request(app).get('/api/ai-summaries/latest').set(manager.auth);
    expect(res.body.data.TODAY.id).toBe(made.body.data.id);
    expect(Object.keys(res.body.data).sort()).toEqual(['CURRENT_SHIFT', 'PREVIOUS_SHIFT', 'TODAY']);
    expect(spy).not.toHaveBeenCalled();
  });

  it('S3-BAO-012: bản lưu mang phiên bản dạng dữ liệu; bản khác phiên bản không trả làm bản gần nhất', async () => {
    vi.spyOn(aiClient, 'generate').mockImplementation(async (payload) => ({ output: goodOutput(payload), usage: USAGE }));
    const made = await create(manager.auth, 'PREVIOUS_SHIFT');
    expect(made.body.data.schemaVersion).toBe(SUMMARY_SCHEMA_VERSION);

    // Bản dạng dữ liệu cũ (vd do bản server trước ghi) nhưng mới hơn về thời gian → phải bị bỏ qua.
    const row = await prisma.aiSummary.findUniqueOrThrow({ where: { id: made.body.data.id } });
    const { id: _id, createdAt: _at, ...rest } = row;
    await prisma.aiSummary.create({
      data: {
        ...rest,
        highlights: rest.highlights as never,
        attention: rest.attention as never,
        metrics: rest.metrics as never,
        schemaVersion: SUMMARY_SCHEMA_VERSION - 1,
        createdAt: new Date(Date.now() + 60_000),
      },
    });

    const res = await request(app).get('/api/ai-summaries/latest').set(manager.auth);
    expect(res.body.data.PREVIOUS_SHIFT.id).toBe(made.body.data.id);
  });

  it('E-006 / BR-001: lễ tân, nhân viên không tạo / xem được', async () => {
    const staff = await createUserWithToken('STAFF');
    for (const actor of [receptionist, staff]) {
      expect((await create(actor.auth)).status).toBe(403);
      expect((await request(app).get('/api/ai-summaries/latest').set(actor.auth)).status).toBe(403);
    }
  });

  it('kỳ không hợp lệ → 400', async () => {
    expect((await create(manager.auth, 'TOMORROW')).status).toBe(400);
  });
});

describe('aiClient gọi OpenAI Responses API (fetch giả lập)', () => {
  const output: AiOutput = { overview: 'Ổn định.', highlights: [], attention: [] };

  it('đọc đầu ra có cấu trúc + usage; gửi json_schema, timeout, không lưu phía provider', async () => {
    const fetchSpy = vi.spyOn(globalThis, 'fetch').mockResolvedValue(
      new Response(
        JSON.stringify({
          status: 'completed',
          usage: { input_tokens: 900, output_tokens: 120 },
          output: [{ type: 'message', content: [{ type: 'output_text', text: JSON.stringify(output) }] }],
        }),
      ),
    );
    const result = await aiClient.generate({ ky: 'x' });

    expect(result).toEqual({ output, usage: { inputTokens: 900, outputTokens: 120 } });
    const [, init] = fetchSpy.mock.calls[0];
    const body = JSON.parse(String(init?.body));
    expect(body.text.format).toMatchObject({ type: 'json_schema', strict: true });
    expect(body.store).toBe(false);
    expect(init?.signal).toBeInstanceOf(AbortSignal);
  });

  it('hết thời gian chờ → AiTimeoutError; HTTP lỗi → AiServiceError; chưa hoàn tất → AiFormatError', async () => {
    const fetchSpy = vi.spyOn(globalThis, 'fetch');
    fetchSpy.mockRejectedValueOnce(Object.assign(new Error('timeout'), { name: 'TimeoutError' }));
    await expect(aiClient.generate({})).rejects.toBeInstanceOf(AiTimeoutError);

    fetchSpy.mockResolvedValueOnce(new Response('{}', { status: 500 }));
    await expect(aiClient.generate({})).rejects.toBeInstanceOf(AiServiceError);

    fetchSpy.mockResolvedValueOnce(new Response(JSON.stringify({ status: 'incomplete', output: [] })));
    await expect(aiClient.generate({})).rejects.toBeInstanceOf(AiFormatError);
  });
});
