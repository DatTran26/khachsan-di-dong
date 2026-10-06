import type { CorsOptions } from 'cors';

// Flutter Web (dev) chạy ở cổng ngẫu nhiên → cho mọi localhost khi chưa khai báo CORS_ORIGINS.
const LOCALHOST = /^https?:\/\/(localhost|127\.0\.0\.1)(:\d+)?$/;

/** Origin được phép gọi REST API + Socket.IO. App Android không gửi Origin nên không bị ảnh hưởng. */
export function corsOptions(allowedOrigins?: string): CorsOptions {
  const allowList = allowedOrigins
    ?.split(',')
    .map((origin) => origin.trim())
    .filter(Boolean);

  return {
    origin(origin, callback) {
      if (!origin) return callback(null, true); // request không từ trình duyệt (app mobile, curl, test)
      const allowed = allowList?.length ? allowList.includes(origin) : LOCALHOST.test(origin);
      callback(null, allowed);
    },
  };
}
