import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    // Các test dùng chung 1 CSDL test → chạy tuần tự từng file.
    fileParallelism: false,
    globalSetup: ['./tests/global-setup.ts'],
    setupFiles: ['./tests/setup.ts'],
    testTimeout: 20_000,
  },
});
