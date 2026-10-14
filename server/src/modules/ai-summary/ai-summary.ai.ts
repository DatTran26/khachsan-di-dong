import { env } from '../../config/env.js';

/**
 * Gọi OpenAI Responses API với Structured Outputs (json_schema) — ai-ops-summary FR-004, mục 11.
 * Gọi thẳng REST (không cần SDK). Khóa API chỉ ở máy chủ. Quá AI_TIMEOUT_MS (15s) thì hủy.
 * `aiClient.generate` tách riêng để test thay bằng bản giả (không gọi mạng thật trong test).
 */

/**
 * Phiên bản dạng dữ liệu tóm tắt: gói gửi AI, cấu trúc đầu ra (SCHEMA), `metrics`, `attention` lưu trong DB.
 * Đổi bất kỳ dạng nào ở trên → tăng số này. Bản lưu khác phiên bản không được trả lại làm "bản gần nhất"
 * (app đọc theo dạng hiện tại) — tạo bản mới thay vì đọc sai.
 */
export const SUMMARY_SCHEMA_VERSION = 1;

export const MAX_OUTPUT_TOKENS = 1_000;
/** Ước lượng token đầu vào tối đa của 1 lượt (prompt + số liệu ~ vài nghìn ký tự) — dùng để chặn trước khi gọi. */
const MAX_INPUT_TOKENS = 4_000;

export interface AiOutput {
  overview: string;
  highlights: string[];
  attention: string[];
}

export interface AiUsage {
  inputTokens: number;
  outputTokens: number;
}

/** Hết `AI_TIMEOUT_MS` hoặc AbortError khi gọi OpenAI. Service tính chi phí mức tối đa. */
export class AiTimeoutError extends Error {}

/** Không kết nối được hoặc HTTP không 2xx. Không kèm usage. Service ghi chi phí 0. */
export class AiServiceError extends Error {}

/**
 * AI trả body nhưng không đúng cấu trúc hoặc chưa `completed`.
 * `usage` có thể có nếu response đã kèm token, để tính chi phí thật thay vì mức tối đa.
 */
export class AiFormatError extends Error {
  constructor(
    message: string,
    readonly usage?: AiUsage,
  ) {
    super(message);
  }
}

/**
 * Chi phí VNĐ, làm tròn lên, theo đơn giá cấu hình trên mỗi triệu token.
 * @param usage Token vào/ra của một lượt. Không âm ở chỗ gọi hiện tại; hàm không tự chặn số âm.
 * @returns Số nguyên VNĐ. 0 token thì 0.
 */
export function costOf(usage: AiUsage) {
  return Math.ceil(
    (usage.inputTokens * env.AI_PRICE_INPUT_VND_PER_1M + usage.outputTokens * env.AI_PRICE_OUTPUT_VND_PER_1M) / 1_000_000,
  );
}

/** Chi phí tối đa có thể phát sinh của 1 lượt — kiểm hạn mức TRƯỚC khi gọi; cũng là mức tính khi quá giờ (không có usage). */
export const MAX_CALL_COST_VND = costOf({ inputTokens: MAX_INPUT_TOKENS, outputTokens: MAX_OUTPUT_TOKENS });

const SCHEMA = {
  type: 'object',
  additionalProperties: false,
  required: ['overview', 'highlights', 'attention'],
  properties: {
    overview: { type: 'string', description: 'Tổng quan 2–4 câu về kỳ.' },
    highlights: { type: 'array', items: { type: 'string' }, description: 'Tối đa 5 điểm nổi bật.' },
    attention: { type: 'array', items: { type: 'string' }, description: 'Việc cần chú ý, chỉ lấy từ danh sách được cung cấp.' },
  },
} as const;

const INSTRUCTIONS = [
  'Bạn tóm tắt tình hình vận hành một khách sạn nhỏ cho quản lý, bằng tiếng Việt, ngắn gọn, giọng trung tính.',
  'CHỈ dùng số liệu trong dữ liệu JSON được cung cấp. Mọi con số bạn viết phải xuất hiện y nguyên trong dữ liệu.',
  'Không tự tính thêm số mới (không cộng, trừ, chia, làm tròn khác), không suy đoán nguyên nhân, không nêu sự kiện không có trong dữ liệu.',
  'Mục "attention" chỉ nêu các việc trong danh_sach_can_chu_y (giữ đúng số phòng); danh sách rỗng thì trả mảng rỗng.',
  'Không đưa ra quyết định thay quản lý, chỉ mô tả.',
].join('\n');

export const aiClient = {
  /**
   * Gọi Responses API một lần. `store: false`. Structured output tên schema có kèm `SUMMARY_SCHEMA_VERSION`.
   *
   * Timeout → `AiTimeoutError`. Mạng lỗi hoặc HTTP không ok → `AiServiceError` (không đọc usage).
   * Body không `completed` hoặc không có output_text → `AiFormatError`, có usage nếu API trả.
   * JSON parse lỗi → `AiFormatError`. Không kiểm số liệu — đó là `validateAiOutput`.
   * @param payload Object đã rút gọn, sẽ `JSON.stringify` vào `input`. Không gồm tên khách.
   * @returns Văn bản đã parse thành object và usage. Chưa trim, chưa đối soát số.
   */
  async generate(payload: unknown): Promise<{ output: AiOutput; usage: AiUsage }> {
    let response: Response;
    try {
      response = await fetch('https://api.openai.com/v1/responses', {
        method: 'POST',
        headers: { Authorization: `Bearer ${env.OPENAI_API_KEY}`, 'Content-Type': 'application/json' },
        body: JSON.stringify({
          model: env.OPENAI_MODEL,
          instructions: INSTRUCTIONS,
          input: JSON.stringify(payload),
          max_output_tokens: MAX_OUTPUT_TOKENS,
          store: false,
          text: {
            format: { type: 'json_schema', name: `tom_tat_van_hanh_v${SUMMARY_SCHEMA_VERSION}`, strict: true, schema: SCHEMA },
          },
        }),
        signal: AbortSignal.timeout(env.AI_TIMEOUT_MS),
      });
    } catch (error) {
      if (error instanceof Error && (error.name === 'TimeoutError' || error.name === 'AbortError')) {
        throw new AiTimeoutError('Quá thời gian chờ dịch vụ AI');
      }
      throw new AiServiceError(`Không gọi được dịch vụ AI: ${String(error)}`);
    }
    if (!response.ok) throw new AiServiceError(`Dịch vụ AI trả lỗi HTTP ${response.status}`);

    const body = (await response.json()) as {
      status?: string;
      usage?: { input_tokens?: number; output_tokens?: number };
      output?: { type: string; content?: { type: string; text?: string }[] }[];
    };
    const usage = { inputTokens: body.usage?.input_tokens ?? 0, outputTokens: body.usage?.output_tokens ?? 0 };
    const text = body.output
      ?.filter((item) => item.type === 'message')
      .flatMap((item) => item.content ?? [])
      .find((c) => c.type === 'output_text')?.text;
    if (body.status !== 'completed' || !text) throw new AiFormatError(`Đầu ra AI chưa hoàn tất (${body.status})`, usage);
    try {
      return { output: JSON.parse(text) as AiOutput, usage };
    } catch {
      throw new AiFormatError('Đầu ra AI không phải JSON', usage);
    }
  },
};
