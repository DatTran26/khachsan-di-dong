import request from 'supertest';
import { beforeAll, describe, expect, it } from 'vitest';
import { createApp } from '../src/app.js';
import { prisma } from '../src/lib/prisma.js';
import { createUserWithToken } from './helpers.js';

/**
 * Cổng Sprint 3 "dashboard khớp fixture" (WBS 1.4.1.2, 1.4.3.12; FR-room-dashboard-002/006, SC-room-dashboard-03).
 * CSDL test dùng chung giữa các file → xóa sạch rồi dựng đúng 50 phòng để số đếm là số tuyệt đối, đối soát 100%.
 *
 *   Nhóm | Số phòng | Lưu trú  | Vệ sinh            | Bảo trì
 *   A    | 18       | đang ở   | sạch               | phục vụ
 *   B    | 2        | đang ở   | cần dọn            | phục vụ
 *   C    | 12       | trống    | sạch               | phục vụ        → sẵn sàng
 *   D    | 6        | trống    | cần dọn            | phục vụ
 *   E    | 4        | trống    | đang dọn           | phục vụ
 *   F    | 3        | trống    | chờ kiểm tra       | phục vụ
 *   G    | 3        | trống    | sạch               | ngừng phục vụ  → không tính sẵn sàng
 *   H    | 2        | trống    | cần dọn            | ngừng phục vụ
 */
const GROUPS = [
  { key: 'A', count: 18, occupancy: 'OCCUPIED', cleaning: 'CLEAN', service: 'IN_SERVICE' },
  { key: 'B', count: 2, occupancy: 'OCCUPIED', cleaning: 'DIRTY', service: 'IN_SERVICE' },
  { key: 'C', count: 12, occupancy: 'VACANT', cleaning: 'CLEAN', service: 'IN_SERVICE' },
  { key: 'D', count: 6, occupancy: 'VACANT', cleaning: 'DIRTY', service: 'IN_SERVICE' },
  { key: 'E', count: 4, occupancy: 'VACANT', cleaning: 'CLEANING', service: 'IN_SERVICE' },
  { key: 'F', count: 3, occupancy: 'VACANT', cleaning: 'PENDING_INSPECTION', service: 'IN_SERVICE' },
  { key: 'G', count: 3, occupancy: 'VACANT', cleaning: 'CLEAN', service: 'OUT_OF_SERVICE' },
  { key: 'H', count: 2, occupancy: 'VACANT', cleaning: 'DIRTY', service: 'OUT_OF_SERVICE' },
] as const;

const app = createApp();
let manager: Awaited<ReturnType<typeof createUserWithToken>>;
const roomsOf: Record<string, { id: string; number: string }[]> = {};
const expectedOverdue: { type: string; taskId: string; roomId: string; roomNumber: string }[] = [];

const summary = async () => (await request(app).get('/api/dashboard/summary').set(manager.auth)).body.data;

beforeAll(async () => {
  await prisma.$executeRawUnsafe(`
    TRUNCATE audit_log_changes, audit_logs, ai_summaries, out_of_service_holds,
             maintenance_tasks, housekeeping_photos, housekeeping_tasks, stays, sessions, rooms, room_types, users CASCADE`);
  manager = await createUserWithToken('MANAGER');
  const roomType = await prisma.roomType.create({ data: { name: 'Fixture' } });

  let i = 0;
  for (const { key, count, ...axes } of GROUPS) {
    roomsOf[key] = [];
    for (let k = 0; k < count; k++, i++) {
      const floor = Math.floor(i / 10) + 1;
      const room = await prisma.room.create({
        data: { number: `${floor}${String((i % 10) + 1).padStart(2, '0')}`, floor, roomTypeId: roomType.id, ...axes },
      });
      roomsOf[key].push(room);
    }
  }

  // Việc dọn: chỉ việc có cờ VÀ nhân viên chưa báo xong mới tính quá hạn (BR-housekeeping-002).
  const flagged = new Date(Date.now() - 5 * 60_000);
  const due = new Date(Date.now() - 65 * 60_000);
  const hk = (roomId: string, status: 'ASSIGNED' | 'IN_PROGRESS' | 'PENDING_CONFIRM' | 'DONE', overdueFlaggedAt: Date | null) =>
    prisma.housekeepingTask.create({ data: { roomId, status, dueAt: due, overdueFlaggedAt } });
  const [d0, d1] = roomsOf.D;
  for (const [room, task] of [
    [d0, await hk(d0.id, 'ASSIGNED', flagged)],
    [d1, await hk(d1.id, 'IN_PROGRESS', flagged)],
  ] as const) {
    expectedOverdue.push({ type: 'HOUSEKEEPING', taskId: task.id, roomId: room.id, roomNumber: room.number });
  }
  await hk(roomsOf.F[0].id, 'PENDING_CONFIRM', flagged); // đã báo xong → không tính
  await hk(roomsOf.C[0].id, 'DONE', flagged); // hoàn tất → không tính
  await hk(roomsOf.D[2].id, 'ASSIGNED', null); // chưa bị cờ → không tính

  // Việc sửa: chỉ việc còn mở có cờ mới tính.
  const mt = (roomId: string, status: 'OPEN' | 'IN_PROGRESS' | 'CANCELLED', overdueFlaggedAt: Date | null) =>
    prisma.maintenanceTask.create({
      data: { roomId, status, description: 'Hỏng điều hòa', reporterId: manager.user.id, dueAt: due, overdueFlaggedAt },
    });
  const h0 = roomsOf.H[0];
  const open = await mt(h0.id, 'OPEN', flagged);
  expectedOverdue.push({ type: 'MAINTENANCE', taskId: open.id, roomId: h0.id, roomNumber: h0.number });
  await mt(roomsOf.H[1].id, 'IN_PROGRESS', null); // chưa bị cờ → không tính
  await mt(roomsOf.G[0].id, 'CANCELLED', flagged); // đã hủy → không tính
});

describe('Dashboard đối soát fixture 50 phòng (cổng Sprint 3)', () => {
  it('FR-002: từng chỉ số khớp số đếm kỳ vọng', async () => {
    const data = await summary();
    expect(data).toMatchObject({
      totalRooms: 50,
      occupied: 20, // A + B
      ready: 12, // chỉ C: trống + sạch + đang phục vụ (G sạch nhưng ngừng phục vụ)
      outOfService: 5, // G + H
      cleaning: { DIRTY: 10, CLEANING: 4, PENDING_INSPECTION: 3, CLEAN: 33 }, // "cần dọn" chỉ đếm DIRTY
      occupancy: { occupied: 20, serviceable: 45, rate: 44.4 }, // 20 ÷ 45 = 44,44% → làm tròn 1 chữ số
    });
  });

  it('FR-006: chỉ việc mở có cờ được đếm + tô cờ đúng phòng (chờ xác nhận, hoàn tất, đã hủy, chưa cờ thì không)', async () => {
    const { overdue } = await summary();
    expect(overdue).toMatchObject({ housekeeping: 2, maintenance: 1, total: 3 });
    expect(overdue.tasks).toHaveLength(3);
    expect(overdue.tasks).toEqual(expect.arrayContaining(expectedOverdue));
  });

  it('mẫu số 0: mọi phòng ngừng phục vụ → tỷ lệ lấp đầy null ("không áp dụng"), không chia cho 0', async () => {
    await prisma.room.updateMany({ data: { service: 'OUT_OF_SERVICE' } });
    const data = await summary();
    expect(data).toMatchObject({ ready: 0, outOfService: 50, occupancy: { serviceable: 0, rate: null } });
  });
});
