/**
 * Test chạy trên CSDL riêng (mặc định: tên DB dev + "_test"), KHÔNG đụng dữ liệu dev.
 * Có thể chỉ định bằng TEST_DATABASE_URL trong .env.
 */
export function testDatabaseUrl(): string {
  const devUrl = process.env.DATABASE_URL;
  if (!devUrl) throw new Error('Thiếu DATABASE_URL trong .env');

  let url = process.env.TEST_DATABASE_URL;
  if (!url) {
    const parsed = new URL(devUrl);
    parsed.pathname = `${parsed.pathname}_test`;
    url = parsed.toString();
  }
  if (url === devUrl) throw new Error('TEST_DATABASE_URL không được trùng DATABASE_URL');
  return url;
}
