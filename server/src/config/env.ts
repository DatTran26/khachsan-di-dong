import { config } from 'dotenv';
import { z } from 'zod';

config({ quiet: true });

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  PORT: z.coerce.number().int().positive().default(3000),
  DATABASE_URL: z.string().min(1, 'Thiếu DATABASE_URL — sao chép .env.example thành .env'),
  // Danh sách origin được gọi API, cách nhau dấu phẩy. Bỏ trống = chỉ cho localhost (dev).
  CORS_ORIGINS: z.string().optional(),
  // Ngưỡng quá hạn việc bảo trì (phút). Bỏ trống = không tính quá hạn — maintenance OQ-1 chưa chốt.
  MAINTENANCE_DUE_MINUTES: z.coerce.number().int().positive().optional(),
});

const parsed = envSchema.safeParse(process.env);
if (!parsed.success) {
  console.error('Cấu hình môi trường không hợp lệ:', parsed.error.flatten().fieldErrors);
  process.exit(1);
}

export const env = parsed.data;
