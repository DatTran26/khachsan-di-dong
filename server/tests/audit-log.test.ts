/**
 * Đối chiếu docs/features/audit-log/srs/audit-log-spec.md (FR-007…011, E-001/002/004)
 * + mẫu dòng nhật ký brainstorm 7.3.
 */
import { randomUUID } from 'node:crypto';
import type { User } from '@prisma/client';
import request from 'supertest';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { createApp } from '../src/app.js';
import { MSG } from '../src/lib/messages.js';
import { prisma } from '../src/lib/prisma.js';
import { createUserWithToken } from './helpers.js';

type Actor = { user: User; auth: Record<string, string> };

const app = createApp();
const tag = randomUUID().slice(0, 6);
let manager: Actor;
let receptionist: Actor;
let staff: Actor;
let roomId: string;
let roomNumber: string;

const logs = (query: string, actor: Actor = manager) => request(app).get(`/api/audit-logs?${query}`).set(actor.auth);

beforeAll(async () => {
  manager = await createUserWithToken('MANAGER');
  receptionist = await createUserWithToken('RECEPTIONIST', { fullName: 'Trần B' });
  staff = await createUserWithToken('STAFF');
  const typeId = (await prisma.roomType.create({ data: { name: `AUD-${tag}` } })).id;
  roomNumber = `A${tag}`;
  roomId = (await prisma.room.create({ data: { number: roomNumber, floor: 3, roomTypeId: typeId } })).id;

  // Tạo lịch sử thật: nhận rồi trả phòng.
  await request(app).post(`/api/rooms/${roomId}/check-in`).set(receptionist.auth).send({ version: 1, guestName: 'Khách', guestCount: 1 });
  await request(app).post(`/api/rooms/${roomId}/check-out`).set(receptionist.auth).send({ version: 2 });
});

afterAll(() => prisma.$disconnect());

describe('Quyền xem (FR-009, E-001)', () => {
  it('lễ tân và nhân viên không xem được nhật ký — máy chủ từ chối', async () => {
    for (const actor of [receptionist, staff]) {
      const res = await logs('', actor);
      expect(res.status).toBe(403);
      expect(res.body.error.message).toBe(MSG.auditForbidden);
    }
  });
});

describe('Nhật ký theo phòng (FR-007)', () => {
  it('mới nhất trước; mỗi dòng đủ ai / khi / hành động / trục / trước → sau', async () => {
    const res = await logs(`roomId=${roomId}`);
    expect(res.status).toBe(200);
    const actions = res.body.data.map((e: { action: string }) => e.action);
    // trả phòng xảy ra sau nhận phòng → đứng trước trong danh sách
    expect(actions.indexOf('stay.check_out')).toBeLessThan(actions.indexOf('stay.check_in'));

    const checkout = res.body.data.find((e: { action: string }) => e.action === 'stay.check_out');
    expect(checkout).toMatchObject({ actionLabel: 'Trả phòng', actorRoleLabel: 'lễ tân', actor: { fullName: 'Trần B' } });
    expect(checkout.changes).toEqual(
      expect.arrayContaining([
        expect.objectContaining({ fieldLabel: 'lưu trú', beforeLabel: 'đang ở', afterLabel: 'trống' }),
        expect.objectContaining({ fieldLabel: 'vệ sinh', beforeLabel: 'sạch', afterLabel: 'cần dọn' }),
      ]),
    );
  });

  it('mẫu dòng 7.3: "{giờ:phút ngày/tháng} · {họ tên} ({vai trò}) · {hành động} · {đối tượng} · {trục}: {trước} → {sau}"', async () => {
    const res = await logs(`roomId=${roomId}&action=stay.check_out`);
    const line: string = res.body.data[0].line;
    expect(line).toMatch(/^\d{2}:\d{2} \d{2}\/\d{2} · Trần B \(lễ tân\) · Trả phòng · Phòng /);
    expect(line).toContain('lưu trú: đang ở → trống');
    expect(line).toContain('vệ sinh: sạch → cần dọn');
  });

  it('dòng do hệ thống sinh → người thực hiện là "hệ thống"', async () => {
    const res = await logs(`roomId=${roomId}&actorRole=SYSTEM`);
    const created = res.body.data.find((e: { action: string }) => e.action === 'housekeeping.task_created');
    expect(created.actor).toBeNull();
    expect(created.line).toMatch(/ · hệ thống · Tạo việc dọn · /);
    expect(created.line).toContain('việc dọn: — → chờ giao');
  });
});

describe('Lọc (FR-008, FR-010) & tải theo phần (NFR-005)', () => {
  it('lọc theo người thực hiện và theo trục trạng thái', async () => {
    const byActor = await logs(`actorId=${receptionist.user.id}`);
    expect(byActor.body.data.length).toBeGreaterThan(0);
    expect(byActor.body.data.every((e: { actor: { id: string } }) => e.actor?.id === receptionist.user.id)).toBe(true);

    const byAxis = await logs(`roomId=${roomId}&field=occupancy`);
    expect(byAxis.body.data.every((e: { changes: { field: string }[] }) => e.changes.some((c) => c.field === 'occupancy'))).toBe(true);
  });

  it('nhật ký chung gồm sự kiện không gắn phòng (vd đăng nhập)', async () => {
    const res = await logs('entityType=USER');
    expect(res.status).toBe(200);
    expect(res.body.data.every((e: { entity: { type: string } }) => e.entity.type === 'USER')).toBe(true);
  });

  it('E-002: mốc "từ" sau mốc "đến" → báo khoảng thời gian chưa hợp lệ', async () => {
    const res = await logs('from=2026-10-05&to=2026-10-01');
    expect(res.status).toBe(400);
    expect(res.body.error.message).toBe(MSG.auditRangeInvalid);
  });

  it('FR-011 / E-004: phạm vi không có bản ghi → danh sách rỗng + câu trung tính, không lỗi', async () => {
    const res = await logs('from=2000-01-01&to=2000-01-02');
    expect(res.status).toBe(200);
    expect(res.body).toMatchObject({ data: [], nextCursor: null, message: MSG.auditEmpty });
  });

  it('tải theo phần: trang sau nối tiếp trang trước, không trùng, không sót', async () => {
    const all = (await logs(`roomId=${roomId}&limit=200`)).body.data.map((e: { id: string }) => e.id);
    const first = await logs(`roomId=${roomId}&limit=2`);
    expect(first.body.data).toHaveLength(2);
    expect(first.body.nextCursor).toBeTruthy();
    const second = await logs(`roomId=${roomId}&limit=2&cursor=${first.body.nextCursor}`);

    const paged = [...first.body.data, ...second.body.data].map((e: { id: string }) => e.id);
    expect(paged).toEqual(all.slice(0, paged.length));
  });
});
