import type { CorsOptions } from 'cors';

// Flutter Web (dev) chạy ở cổng ngẫu nhiên → cho mọi localhost khi chưa khai báo CORS_ORIGINS.
const LOCALHOST = /^https?:\/\/(localhost|127\.0\.0\.1)(:\d+)?$/;

/**
 * Origin được phép gọi REST API và Socket.IO.
 *
 * Request không có header `Origin` (app Android, curl, test) được chấp nhận.
 * Khi `allowedOrigins` có ít nhất một origin sau khi tách bằng dấu phẩy thì chỉ
 * đúng danh sách đó. Chuỗi rỗng hoặc bỏ qua → mọi `http(s)://localhost|127.0.0.1`
 * kèm cổng tùy ý (Flutter web dev đổi cổng). Origin lạ nhận `callback(null, false)`,
 * không ném lỗi. Không phản chiếu origin tùy ý khi đã có allow-list.
 * @param allowedOrigins Giá trị thô `CORS_ORIGINS`. Có thể bỏ qua.
 * @returns Cấu hình truyền cho `cors()` và Socket.IO. Không ghi log.
 */
export function corsOptions(allowedOrigins?: string): CorsOptions {
  const allowList = allowedOrigins
    ?.split(',')
    .map((origin) => origin.trim())
    .filter(Boolean);

  return {
    /**
     * @param origin Origin trình duyệt, hoặc `undefined` nếu client không gửi.
     * @param callback `(null, true)` cho phép, `(null, false)` từ chối. Không truyền `Error`.
     */
    origin(origin, callback) {
      if (!origin) return callback(null, true); // request không từ trình duyệt (app mobile, curl, test)
      const allowed = allowList?.length ? allowList.includes(origin) : LOCALHOST.test(origin);
      callback(null, allowed);
    },
  };
}
