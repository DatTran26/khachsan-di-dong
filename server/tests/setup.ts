import { config } from 'dotenv';
import { testDatabaseUrl } from './test-db.js';

config({ quiet: true });
// Mọi PrismaClient trong test (kể cả src/lib/prisma.ts) dùng CSDL test.
process.env.DATABASE_URL = testDatabaseUrl();
