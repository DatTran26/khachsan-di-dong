import { config } from 'dotenv';
import { z } from 'zod';

config({ quiet: true });

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  PORT: z.coerce.number().int().positive().default(3000),
  DATABASE_URL: z.string().min(1, 'Thiếu DATABASE_URL — sao chép .env.example thành .env'),
  // Danh sách origin được gọi API, cách nhau dấu phẩy. Bỏ trống = chỉ cho localhost (dev).
  CORS_ORIGINS: z.string().optional(),
  // Ngưỡng quá hạn việc bảo trì (phút). Bỏ trống = 240 (4 giờ — maintenance OQ-1 chốt 10/10/2026); 0 = tắt.
  MAINTENANCE_DUE_MINUTES: z.union([z.literal(''), z.coerce.number().int().nonnegative()]).optional(),
  // Thư mục lưu ảnh nghiệm thu dọn phòng (tương đối với thư mục chạy server). Docker: gắn volume vào đây.
  UPLOAD_DIR: z.string().min(1).default('uploads'),
  // Dung lượng tối đa mỗi ảnh (MB) — housekeeping OQ-4 chưa chốt, mặc định 5 MB.
  PHOTO_MAX_MB: z.coerce.number().positive().max(20).default(5),

  // ---- Tóm tắt vận hành bằng AI (ai-ops-summary) — khóa API chỉ nằm ở máy chủ ----
  // Bỏ trống = không gọi AI, luôn trả báo cáo mẫu từ dữ liệu gốc.
  OPENAI_API_KEY: z.string().optional(),
  OPENAI_MODEL: z.string().min(1).default('gpt-4o-mini'),
  // Ngân sách AI cho toàn MVP (tôn chỉ: ≤300.000 VNĐ). Chặn ở máy chủ trước mỗi lượt gọi.
  AI_BUDGET_VND: z.coerce.number().int().nonnegative().default(300_000),
  // Đơn giá theo model đang dùng, VNĐ / 1 triệu token — cập nhật theo bảng giá provider khi đổi model.
  AI_PRICE_INPUT_VND_PER_1M: z.coerce.number().nonnegative().default(4_000),
  AI_PRICE_OUTPUT_VND_PER_1M: z.coerce.number().nonnegative().default(16_000),
  AI_TIMEOUT_MS: z.coerce.number().int().positive().default(15_000), // NFR-ai-ops-summary-001
});

const parsed = envSchema.safeParse(process.env);
if (!parsed.success) {
  console.error('Cấu hình môi trường không hợp lệ:', parsed.error.flatten().fieldErrors);
  process.exit(1);
}

export const env = parsed.data;
