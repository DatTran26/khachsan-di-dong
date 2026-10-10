/**
 * Tình huống demo cho giao diện (chạy SAU `npm run db:seed`): npm run db:seed:demo
 *
 * Tạo bằng CHÍNH các hàm nghiệp vụ (nhận/trả phòng, dọn, báo hỏng…) nên trạng thái phòng, việc và nhật ký
 * luôn nhất quán như khi dùng thật. Chỉ chạy khi CSDL chưa có lượt lưu trú nào (tránh tạo trùng).
 *
 *   101, 102, 103  đang có khách
 *   104            vừa trả → cần dọn, việc đã giao
 *   105            đang dọn
 *   106            dọn xong, chờ quản lý xác nhận
 *   201            báo hỏng, chờ nhận → ngừng phục vụ
 *   202            ngừng phục vụ tay (sơn lại tường)
 */
import { config } from 'dotenv';

config({ quiet: true });

const { prisma } = await import('../src/lib/prisma.js');
const { checkIn, checkOut } = await import('../src/modules/stays/stays.service.js');
const { acceptTask, completeTask } = await import('../src/modules/housekeeping/housekeeping.service.js');
const { reportIssue } = await import('../src/modules/maintenance/maintenance.service.js');
const { placeOutOfService } = await import('../src/modules/rooms/rooms.catalog.js');
const { uploadRequiredPhotos } = await import('./demo-photos.js');

async function user(phone: string) {
  const found = await prisma.user.findUnique({ where: { phone } });
  if (!found) throw new Error(`Thiếu tài khoản ${phone} — chạy "npm run db:seed" trước.`);
  return found;
}

async function room(number: string) {
  const found = await prisma.room.findUnique({ where: { number } });
  if (!found) throw new Error(`Thiếu phòng ${number} — chạy "npm run db:seed" trước.`);
  return found;
}

async function main() {
  if ((await prisma.stay.count()) > 0) {
    console.log('CSDL đã có dữ liệu vận hành — bỏ qua để không tạo trùng.');
    return;
  }
  const manager = await user('0900000001');
  const receptionist = await user('0900000002');

  const guests = ['Nguyễn Minh Anh', 'Trần Quốc Bảo', 'Lê Thu Hà', 'Phạm Gia Huy', 'Võ Ngọc Lan', 'Đỗ Hải Nam'];
  const checkedIn: Record<string, string> = {};
  for (const [i, number] of ['101', '102', '103', '104', '105', '106'].entries()) {
    const r = await room(number);
    await checkIn(receptionist, r.id, r.version, { guestName: guests[i], guestCount: 1 + (i % 3) });
    checkedIn[number] = r.id;
  }

  // 104–106 trả phòng → hệ thống tự giao việc dọn cho nhân viên đang trực
  const tasks: Record<string, { id: string; version: number; assigneeId: string }> = {};
  for (const number of ['104', '105', '106']) {
    const r = await prisma.room.findUniqueOrThrow({ where: { id: checkedIn[number] } });
    const { housekeepingTask } = await checkOut(receptionist, r.id, r.version);
    tasks[number] = { id: housekeepingTask.id, version: housekeepingTask.version, assigneeId: housekeepingTask.assignee!.id };
  }

  // 105: đang dọn · 106: dọn xong chờ xác nhận
  for (const number of ['105', '106']) {
    const task = tasks[number];
    const staff = await prisma.user.findUniqueOrThrow({ where: { id: task.assigneeId } });
    const accepted = await acceptTask(staff, task.id, task.version);
    if (number === '106') {
      // Báo xong cần đủ 3 ảnh nghiệm thu (FR-housekeeping-005)
      await uploadRequiredPhotos(staff, task.id);
      await completeTask(staff, task.id, accepted.version);
    }
  }

  const r201 = await room('201');
  await reportIssue(receptionist, { roomId: r201.id, description: 'Vòi sen bị rò nước', location: 'Phòng tắm' });

  const r202 = await room('202');
  await placeOutOfService(manager, r202.id, r202.version, { reason: 'Sơn lại tường' });

  console.log('Đã tạo tình huống demo: 101–103 có khách · 104 cần dọn · 105 đang dọn · 106 chờ xác nhận · 201 đang báo hỏng · 202 ngừng phục vụ.');
}

try {
  await main();
} catch (error) {
  console.error(error);
  process.exitCode = 1;
} finally {
  await prisma.$disconnect();
}
