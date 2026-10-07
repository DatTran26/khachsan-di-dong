import { tmpdir } from 'node:os';
import path from 'node:path';
import { config } from 'dotenv';
import { testDatabaseUrl } from './test-db.js';

config({ quiet: true });
// Mọi PrismaClient trong test (kể cả src/lib/prisma.ts) dùng CSDL test.
process.env.DATABASE_URL = testDatabaseUrl();
// Ảnh nghiệm thu trong test ghi vào thư mục tạm, không lẫn với ảnh dev.
process.env.UPLOAD_DIR = path.join(tmpdir(), 'khachsan-test-uploads');
