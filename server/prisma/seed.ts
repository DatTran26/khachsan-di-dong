/**
 * Dữ liệu giả lập: 3 loại phòng, 50 phòng (5 tầng × 10), 8 tài khoản mẫu.
 * Chạy: npm run db:seed — chạy lại nhiều lần không tạo trùng (upsert).
 */
import { config } from 'dotenv';
import { PrismaClient, type Role } from '@prisma/client';
import bcrypt from 'bcryptjs';

config({ quiet: true });

const prisma = new PrismaClient();

const ROOM_TYPES = ['Standard', 'Deluxe', 'Suite'] as const;
const FLOORS = 5;
const ROOMS_PER_FLOOR = 10;

const USERS: { phone: string; fullName: string; role: Role; onDuty?: boolean }[] = [
  { phone: '0900000001', fullName: 'Nguyễn Văn Quản Lý', role: 'MANAGER' },
  { phone: '0900000002', fullName: 'Trần Thị Lễ Tân', role: 'RECEPTIONIST' },
  { phone: '0900000003', fullName: 'Lê Văn Lễ Tân', role: 'RECEPTIONIST' },
  { phone: '0900000004', fullName: 'Phạm Thị Buồng Phòng', role: 'STAFF', onDuty: true },
  { phone: '0900000005', fullName: 'Hoàng Văn Buồng Phòng', role: 'STAFF', onDuty: true },
  { phone: '0900000006', fullName: 'Võ Thị Buồng Phòng', role: 'STAFF', onDuty: true },
  { phone: '0900000007', fullName: 'Đặng Văn Bảo Trì', role: 'STAFF', onDuty: true },
  { phone: '0900000008', fullName: 'Bùi Thị Nghỉ Ca', role: 'STAFF', onDuty: false },
];

/** Tầng 1–3: Standard, tầng 4: Deluxe, tầng 5: Suite. Số phòng = tầng × 100 + thứ tự (101…510). */
function roomTypeForFloor(floor: number): (typeof ROOM_TYPES)[number] {
  if (floor <= 3) return 'Standard';
  if (floor === 4) return 'Deluxe';
  return 'Suite';
}

async function main() {
  const password = process.env.SEED_PASSWORD;
  if (!password) throw new Error('Thiếu SEED_PASSWORD trong .env');

  const types = new Map<string, string>();
  for (const name of ROOM_TYPES) {
    const type = await prisma.roomType.upsert({ where: { name }, update: {}, create: { name } });
    types.set(name, type.id);
  }

  for (let floor = 1; floor <= FLOORS; floor++) {
    for (let i = 1; i <= ROOMS_PER_FLOOR; i++) {
      const number = String(floor * 100 + i);
      await prisma.room.upsert({
        where: { number },
        update: {},
        create: { number, floor, roomTypeId: types.get(roomTypeForFloor(floor))! },
      });
    }
  }

  // Tài khoản demo ở trạng thái ACTIVE để đăng nhập được ngay (tài khoản thật tạo mới sẽ là PENDING_ACTIVATION).
  const passwordHash = await bcrypt.hash(password, 10);
  for (const user of USERS) {
    await prisma.user.upsert({
      where: { phone: user.phone },
      update: {},
      create: {
        ...user,
        onDuty: user.onDuty ?? false,
        passwordHash,
        status: 'ACTIVE',
        mustChangePassword: false,
      },
    });
  }

  const [roomCount, userCount] = await Promise.all([prisma.room.count(), prisma.user.count()]);
  console.log(`Seed xong: ${roomCount} phòng, ${userCount} tài khoản.`);
}

main()
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  })
  .finally(() => prisma.$disconnect());
