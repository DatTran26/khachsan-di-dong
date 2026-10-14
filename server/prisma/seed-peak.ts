/**
 * Kịch bản "ca đỉnh" cho demo dashboard + tóm tắt AI (ai-ops-summary spec mục 11 — Assumptions):
 * chạy NGAY TRƯỚC buổi demo để ca hiện tại có hoạt động thật. Chạy SAU `npm run db:seed`: npm run db:seed:peak
 *
 * Tạo bằng CHÍNH các hàm nghiệp vụ (nhận/trả, dọn, xác nhận, báo hỏng, quét quá hạn) → phòng, việc, nhật ký nhất quán.
 * Chạy lại được nhiều lần: mỗi lần dùng các phòng đang sẵn sàng / đang có khách tại thời điểm chạy.
 *   - 8 lượt nhận phòng, 4 lượt trả phòng → 4 việc dọn tự giao
 *   - 2 việc dọn: nhận → nộp ảnh → báo xong; quản lý xác nhận 1 việc
 *   - 1 việc dọn bị quá hạn (lùi hạn để demo cờ quá hạn ngay), 1 báo hỏng mới
 */
import { config } from 'dotenv';

config({ quiet: true });

const { prisma } = await import('../src/lib/prisma.js');
const { checkIn, checkOut } = await import('../src/modules/stays/stays.service.js');
const { acceptTask, completeTask, confirmTask } = await import('../src/modules/housekeeping/housekeeping.service.js');
const { reportIssue } = await import('../src/modules/maintenance/maintenance.service.js');
const { flagOverdueTasks } = await import('../src/jobs/overdue.js');
const { uploadRequiredPhotos } = await import('./demo-photos.js');

const GUESTS = ['Khách đoàn A', 'Khách đoàn B', 'Khách lẻ C', 'Khách lẻ D', 'Khách lẻ E', 'Khách lẻ F', 'Khách lẻ G', 'Khách lẻ H'];

async function user(phone: string) {
  const found = await prisma.user.findUnique({ where: { phone } });
  if (!found) throw new Error(`Thiếu tài khoản ${phone} — chạy "npm run db:seed" trước.`);
  return found;
}

async function main() {
  const manager = await user('0900000001');
  const receptionist = await user('0900000002');

  // 1. Trả phòng: 4 phòng đang có khách lâu nhất → hệ thống tạo + tự giao việc dọn
  const occupied = await prisma.room.findMany({
    where: { occupancy: 'OCCUPIED' },
    orderBy: { updatedAt: 'asc' },
    take: 4,
  });
  const tasks = [];
  for (const room of occupied) {
    const { housekeepingTask } = await checkOut(receptionist, room.id, room.version);
    tasks.push(housekeepingTask);
  }

  // 2. Nhận phòng: 8 phòng đang sẵn sàng (tầng cao trước để không đụng phòng demo tầng 1–2)
  const ready = await prisma.room.findMany({
    where: { occupancy: 'VACANT', cleaning: 'CLEAN', service: 'IN_SERVICE' },
    orderBy: [{ floor: 'desc' }, { number: 'asc' }],
    take: GUESTS.length,
  });
  for (const [i, room] of ready.entries()) {
    await checkIn(receptionist, room.id, room.version, { guestName: GUESTS[i], guestCount: 1 + (i % 3) });
  }

  // 3. Dọn: 2 việc đã giao → nhận, nộp ảnh, báo xong; quản lý xác nhận việc đầu
  const assigned = tasks.filter((t) => t.assignee);
  for (const [i, task] of assigned.slice(0, 2).entries()) {
    const staff = await prisma.user.findUniqueOrThrow({ where: { id: task.assignee!.id } });
    const accepted = await acceptTask(staff, task.id, task.version);
    await uploadRequiredPhotos(staff, task.id);
    const done = await completeTask(staff, task.id, accepted.version);
    if (i === 0) await confirmTask(manager, task.id, done.version);
  }

  // 4. Quá hạn: lùi hạn 1 việc dọn còn mở về quá khứ rồi chạy đúng job quét quá hạn
  const late = tasks.at(-1);
  if (late) {
    await prisma.housekeepingTask.update({ where: { id: late.id }, data: { dueAt: new Date(Date.now() - 60_000) } });
    await flagOverdueTasks();
  }

  // 5. Báo hỏng mới ở 1 phòng sẵn sàng
  const broken = await prisma.room.findFirst({
    where: { occupancy: 'VACANT', cleaning: 'CLEAN', service: 'IN_SERVICE' },
    orderBy: { number: 'asc' },
  });
  if (broken) await reportIssue(receptionist, { roomId: broken.id, description: 'Điều hòa không mát', location: 'Phòng ngủ' });

  console.log(
    `Ca đỉnh: ${ready.length} nhận phòng · ${occupied.length} trả phòng · ${Math.min(2, assigned.length)} báo dọn xong (1 đã xác nhận)` +
      ` · ${late ? 1 : 0} việc quá hạn · ${broken ? 1 : 0} báo hỏng.`,
  );
}

try {
  await main();
} catch (error) {
  console.error(error);
  process.exitCode = 1;
} finally {
  await prisma.$disconnect();
}
