import type { AiOutput } from './ai-summary.ai.js';

/**
 * Kiểm tra đầu ra AI trước khi hiển thị (FR-ai-ops-summary-005, BR-005):
 * - Đúng cấu trúc, độ dài hợp lý.
 * - MỌI con số trong văn bản AI phải có trong dữ liệu gốc đã gửi (số liệu, số phòng, mốc giờ của kỳ).
 *   Số lạ = AI tự tính / bịa → loại bản AI, dùng báo cáo mẫu.
 * Số phòng chỉ có trong danh sách cần chú ý → AI nêu phòng không có trong danh sách cũng bị bắt ở bước này.
 */

/**
 * Lấy mọi cụm số trong chuỗi. "66,7" và "66.7" cùng thành 66.7.
 * Không nhận số âm (dấu trừ không nằm trong regex). Không nhận phân cách nghìn.
 * @param text Đoạn AI hoặc JSON nguồn.
 * @returns Mảng số theo thứ tự xuất hiện. Chuỗi không có số thì mảng rỗng.
 */
export function extractNumbers(text: string): number[] {
  return (text.match(/\d+(?:[.,]\d+)?/g) ?? []).map((n) => Number(n.replace(',', '.')));
}

const MAX_TEXT = 600;
const MAX_ITEMS = 10;

/**
 * Kiểm tra cấu trúc và mọi con số trong văn bản AI phải xuất hiện trong payload.
 *
 * `overview` 1–600 ký tự sau khi không tính trim ở bước kiểm (độ dài tính trên chuỗi gốc, trim khi trả về).
 * `highlights` và `attention` tối đa 10 phần tử, mỗi phần tử không rỗng và ≤ 600. Mảng rỗng hợp lệ.
 * Số lạ → `ok: false` kèm reason, không ném. Không sửa dữ liệu nghiệp vụ.
 * @param output JSON đã parse từ AI, chưa tin.
 * @param payload Đúng object đã gửi AI. Số được rút từ `JSON.stringify`.
 */
export function validateAiOutput(output: unknown, payload: unknown): { ok: true; output: AiOutput } | { ok: false; reason: string } {
  const o = output as Partial<AiOutput> | null;
  const isText = (v: unknown): v is string => typeof v === 'string' && v.trim().length > 0 && v.length <= MAX_TEXT;
  const isList = (v: unknown): v is string[] => Array.isArray(v) && v.length <= MAX_ITEMS && v.every(isText);
  if (!o || !isText(o.overview) || !isList(o.highlights) || !isList(o.attention)) {
    return { ok: false, reason: 'Sai cấu trúc' };
  }

  const allowed = new Set(extractNumbers(JSON.stringify(payload)));
  const texts = [o.overview, ...o.highlights, ...o.attention];
  const unknown = texts.flatMap(extractNumbers).filter((n) => !allowed.has(n));
  if (unknown.length) return { ok: false, reason: `Số liệu không có trong dữ liệu gốc: ${[...new Set(unknown)].join(', ')}` };

  return { ok: true, output: { overview: o.overview.trim(), highlights: o.highlights, attention: o.attention } };
}
