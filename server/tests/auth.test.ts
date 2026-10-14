/**
 * Đối chiếu docs/features/auth-roles/srs/auth-roles-spec.md (FR / BR / E-xxx) + wording brainstorm mục 7.2.
 */
import { createServer, type Server as HttpServer } from 'node:http';
import type { AddressInfo } from 'node:net';
import type { User } from '@prisma/client';
import { io as connect } from 'socket.io-client';
import request from 'supertest';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { createApp } from '../src/app.js';
import { MSG } from '../src/lib/messages.js';
import { prisma } from '../src/lib/prisma.js';
import { attachRealtime, closeRealtime } from '../src/realtime/socket.js';
import { createUser, createUserWithToken, randomPhone, TEST_PASSWORD } from './helpers.js';

const app = createApp();
let httpServer: HttpServer;
let baseUrl: string;
let manager: { user: User; auth: Record<string, string> };
let receptionist: { user: User; auth: Record<string, string> };

const login = (phone: string, password: string) => request(app).post('/api/auth/login').send({ phone, password });

/** Mở socket đã xác thực; trả về socket + promise nhận `session:revoked` đầu tiên. */
async function openSocket(token: string) {
  const socket = connect(baseUrl, { auth: { token }, forceNew: true });
  const revoked = new Promise<{ reason: string; message: string; at: number }>((resolve) =>
    socket.once('session:revoked', (payload) => resolve({ ...payload, at: Date.now() })),
  );
  const disconnected = new Promise<number>((resolve) => socket.once('disconnect', () => resolve(Date.now())));
  await new Promise<void>((resolve, reject) => {
    socket.once('connect', () => resolve());
    socket.once('connect_error', reject);
  });
  return { socket, revoked, disconnected };
}

beforeAll(async () => {
  httpServer = createServer(app);
  attachRealtime(httpServer);
  await new Promise<void>((resolve) => httpServer.listen(0, resolve));
  baseUrl = `http://localhost:${(httpServer.address() as AddressInfo).port}`;
  manager = await createUserWithToken('MANAGER', { fullName: 'Quản lý A' });
  receptionist = await createUserWithToken('RECEPTIONIST', { fullName: 'Lễ tân A' });
});

afterAll(async () => {
  await closeRealtime();
  await new Promise((resolve) => httpServer.close(resolve));
  await prisma.$disconnect();
});

describe('Đăng nhập', () => {
  it('FR-001: đúng SĐT + MK → phiên 12 giờ, không trả mật khẩu, có nhật ký', async () => {
    const user = await createUser('STAFF');
    const res = await login(user.phone, TEST_PASSWORD);

    expect(res.status).toBe(200);
    expect(res.body.data.token).toEqual(expect.any(String));
    const hours = (Date.parse(res.body.data.expiresAt) - Date.now()) / 3_600_000;
    expect(hours).toBeGreaterThan(11.9);
    expect(hours).toBeLessThanOrEqual(12);
    expect(JSON.stringify(res.body)).not.toMatch(/password_?hash/i);
    expect(await prisma.auditLog.count({ where: { entityId: user.id, action: 'auth.login' } })).toBe(1);
  });

  it('E-001: sai MK hoặc SĐT không tồn tại → cùng một câu báo lỗi', async () => {
    const user = await createUser('STAFF');
    const wrong = await login(user.phone, 'SaiMatKhau1');
    const unknown = await login(randomPhone(), 'SaiMatKhau1');

    for (const res of [wrong, unknown]) {
      expect(res.status).toBe(401);
      expect(res.body.error.message).toBe(MSG.invalidCredentials);
    }
  });

  it('FR-015: SĐT sai định dạng → từ chối với câu báo lỗi tiếng Việt', async () => {
    const res = await login('12345', 'abc');
    expect(res.status).toBe(400);
    expect(res.body.error.details.fieldErrors.phone).toContain(MSG.invalidPhone);
  });

  it('FR-011: sai MK 5 lần liên tiếp → hệ thống khóa TK, nhật ký ghi "hệ thống"', async () => {
    const user = await createUser('STAFF');
    const results = [];
    for (let i = 0; i < 5; i++) results.push(await login(user.phone, 'SaiMatKhau1'));

    expect(results.slice(0, 4).every((r) => r.body.error.code === 'INVALID_CREDENTIALS')).toBe(true);
    expect(results[4].body.error).toMatchObject({ code: 'ACCOUNT_LOCKED', message: MSG.accountLocked });
    expect((await prisma.user.findUniqueOrThrow({ where: { id: user.id } })).status).toBe('LOCKED');
    const log = await prisma.auditLog.findFirstOrThrow({ where: { entityId: user.id, action: 'auth.auto_locked' } });
    expect(log.actorRole).toBe('SYSTEM');
  });

  it('E-002: TK bị khóa → báo "bị khóa" chỉ khi MK đúng', async () => {
    const user = await createUser('STAFF', { status: 'LOCKED' });
    expect((await login(user.phone, TEST_PASSWORD)).body.error.message).toBe(MSG.accountLocked);
    expect((await login(user.phone, 'SaiMatKhau1')).body.error.message).toBe(MSG.invalidCredentials);
  });

  it('đăng nhập đúng → đếm sai MK về 0', async () => {
    const user = await createUser('STAFF', { failedLoginCount: 3 });
    await login(user.phone, TEST_PASSWORD);
    expect((await prisma.user.findUniqueOrThrow({ where: { id: user.id } })).failedLoginCount).toBe(0);
  });
});

describe('Phiên đăng nhập', () => {
  it('FR-012: đăng nhập thiết bị mới → phiên cũ bị hủy + socket cũ nhận thông báo và bị ngắt', async () => {
    const user = await createUser('STAFF');
    const first = (await login(user.phone, TEST_PASSWORD)).body.data.token;
    const old = await openSocket(first);

    await login(user.phone, TEST_PASSWORD);

    expect(await old.revoked).toMatchObject({ reason: 'LOGGED_IN_ELSEWHERE', message: MSG.sessionRevoked });
    await old.disconnected;
    const res = await request(app).get('/api/auth/me').set({ Authorization: `Bearer ${first}` });
    expect(res.status).toBe(401);
  });

  it('FR-002: đăng xuất → token không dùng được nữa', async () => {
    const { auth } = await createUserWithToken('STAFF');
    expect((await request(app).post('/api/auth/logout').set(auth)).status).toBe(204);
    expect((await request(app).get('/api/auth/me').set(auth)).status).toBe(401);
  });

  it('đăng xuất khi phiên đã hết / không có token → vẫn 204 (không tạo vòng lặp 401 ở client)', async () => {
    expect((await request(app).post('/api/auth/logout')).status).toBe(204);
    expect((await request(app).post('/api/auth/logout').set({ Authorization: 'Bearer het-han' })).status).toBe(204);
  });

  it('FR-003 / E-003: quá 12 giờ → từ chối, yêu cầu đăng nhập lại, nhật ký "hết phiên"', async () => {
    const { user, auth } = await createUserWithToken('STAFF');
    await prisma.session.update({ where: { userId: user.id }, data: { expiresAt: new Date(Date.now() - 1_000) } });

    const res = await request(app).get('/api/rooms').set(auth);
    expect(res.status).toBe(401);
    expect(res.body.error).toMatchObject({ code: 'SESSION_EXPIRED', message: MSG.sessionExpired });
    expect(await prisma.auditLog.count({ where: { entityId: user.id, action: 'auth.session_expired' } })).toBe(1);
  });

  it('socket không có token / token sai → bị từ chối kết nối', async () => {
    await expect(openSocket('token-sai')).rejects.toMatchObject({ data: { code: 'SESSION_INVALID' } });
  });
});

describe('Mật khẩu tạm & đổi mật khẩu', () => {
  it('FR-005 → FR-006 → FR-007: tạo TK, đăng nhập MK tạm bị chặn chức năng, đổi MK xong dùng tiếp phiên cũ', async () => {
    const phone = randomPhone();
    const created = await request(app)
      .post('/api/users')
      .set(manager.auth)
      .send({ fullName: 'Nhân viên Mới', phone, role: 'STAFF' });
    expect(created.status).toBe(201);
    const { tempPassword, user, message } = created.body.data;
    expect(user.status).toBe('PENDING_ACTIVATION');
    expect(message).toBe(MSG.accountCreated('Nhân viên Mới', tempPassword));

    const loggedIn = await login(phone, tempPassword);
    expect(loggedIn.body.data.user.mustChangePassword).toBe(true);
    const auth = { Authorization: `Bearer ${loggedIn.body.data.token}` };

    const blocked = await request(app).get('/api/rooms').set(auth);
    expect(blocked.body.error).toMatchObject({ code: 'PASSWORD_CHANGE_REQUIRED', message: MSG.mustChangePassword });

    const weak = await request(app)
      .post('/api/auth/change-password')
      .set(auth)
      .send({ currentPassword: tempPassword, newPassword: 'chiCoChu' });
    expect(weak.body.error.details.fieldErrors.newPassword).toContain(MSG.weakPassword);

    const changed = await request(app)
      .post('/api/auth/change-password')
      .set(auth)
      .send({ currentPassword: tempPassword, newPassword: 'MoiMoi2026' });
    expect(changed.body.data).toMatchObject({ message: MSG.passwordChanged, user: { status: 'ACTIVE' } });

    expect((await request(app).get('/api/rooms').set(auth)).status).toBe(200); // giữ phiên
  });

  it('E-006: SĐT đã có tài khoản → từ chối', async () => {
    const res = await request(app)
      .post('/api/users')
      .set(manager.auth)
      .send({ fullName: 'Trùng', phone: receptionist.user.phone, role: 'STAFF' });
    expect(res.status).toBe(409);
    expect(res.body.error.message).toBe(MSG.phoneTaken);
  });

  it('NFR-001 / FR-audit-log-004: nhật ký không bao giờ chứa mật khẩu', async () => {
    const res = await request(app)
      .post('/api/users')
      .set(manager.auth)
      .send({ fullName: 'Kiểm tra MK', phone: randomPhone(), role: 'STAFF' });
    const { tempPassword } = res.body.data;
    const leaked = await prisma.auditLogChange.count({
      where: { OR: [{ before: { contains: tempPassword } }, { after: { contains: tempPassword } }] },
    });
    expect(leaked).toBe(0);
  });
});

describe('Phân quyền quản lý tài khoản (BR-auth-roles-001, chốt 23/09/2026)', () => {
  it('lễ tân tạo được TK nhân viên', async () => {
    const res = await request(app)
      .post('/api/users')
      .set(receptionist.auth)
      .send({ fullName: 'NV do lễ tân tạo', phone: randomPhone(), role: 'STAFF' });
    expect(res.status).toBe(201);
  });

  it('lễ tân KHÔNG tạo được TK quản lý', async () => {
    const res = await request(app)
      .post('/api/users')
      .set(receptionist.auth)
      .send({ fullName: 'QL giả', phone: randomPhone(), role: 'MANAGER' });
    expect(res.status).toBe(403);
    expect(res.body.error.message).toBe(MSG.forbidden);
  });

  it('lễ tân KHÔNG khóa / sửa được TK quản lý', async () => {
    const lock = await request(app)
      .post(`/api/users/${manager.user.id}/lock`)
      .set(receptionist.auth)
      .send({ version: manager.user.version });
    const edit = await request(app)
      .patch(`/api/users/${manager.user.id}`)
      .set(receptionist.auth)
      .send({ version: manager.user.version, fullName: 'Đổi tên' });
    expect(lock.status).toBe(403);
    expect(edit.status).toBe(403);
  });

  it('lễ tân KHÔNG nâng nhân viên lên quản lý', async () => {
    const staff = await createUser('STAFF');
    const res = await request(app)
      .patch(`/api/users/${staff.id}`)
      .set(receptionist.auth)
      .send({ version: staff.version, role: 'MANAGER' });
    expect(res.status).toBe(403);
  });

  it('nhân viên buồng phòng–bảo trì không vào được quản lý tài khoản', async () => {
    const { auth } = await createUserWithToken('STAFF');
    const res = await request(app).get('/api/users').set(auth);
    expect(res.status).toBe(403);
    expect(res.body.error.message).toBe(MSG.forbidden);
  });

  it('FR-017: không có thao tác xóa tài khoản', async () => {
    const res = await request(app).delete(`/api/users/${receptionist.user.id}`).set(manager.auth);
    expect(res.status).toBe(404);
  });
});

describe('Khóa / mở khóa / đặt lại MK', () => {
  it('FR-009 / SC-05: lễ tân khóa nhân viên → phiên đang mở bị hủy trong ≤3 giây', async () => {
    const staff = await createUserWithToken('STAFF', { fullName: 'NV bị khóa' });
    const live = await openSocket(staff.token);

    const startedAt = Date.now();
    const res = await request(app)
      .post(`/api/users/${staff.user.id}/lock`)
      .set(receptionist.auth)
      .send({ version: staff.user.version });

    expect(res.body.data.message).toBe(MSG.accountLockedDone('NV bị khóa'));
    const revoked = await live.revoked;
    expect(revoked.reason).toBe('LOCKED');
    expect(revoked.at - startedAt).toBeLessThanOrEqual(3_000);
    expect((await request(app).get('/api/rooms').set(staff.auth)).status).toBe(401);
  });

  it('không tự khóa chính mình', async () => {
    const me = await prisma.user.findUniqueOrThrow({ where: { id: receptionist.user.id } });
    const res = await request(app).post(`/api/users/${me.id}/lock`).set(receptionist.auth).send({ version: me.version });
    expect(res.body.error.message).toBe(MSG.cannotLockSelf);
  });

  it('FR-010: mở khóa → MK tạm mới, "Chờ kích hoạt", đếm sai về 0, đăng nhập được bằng MK tạm', async () => {
    const locked = await createUser('STAFF', { status: 'LOCKED', failedLoginCount: 5 });
    const res = await request(app)
      .post(`/api/users/${locked.id}/unlock`)
      .set(receptionist.auth)
      .send({ version: locked.version });

    const { tempPassword, user } = res.body.data;
    expect(res.body.data.message).toBe(MSG.accountUnlocked(tempPassword));
    expect(user.status).toBe('PENDING_ACTIVATION');
    expect((await prisma.user.findUniqueOrThrow({ where: { id: locked.id } })).failedLoginCount).toBe(0);
    expect((await login(locked.phone, tempPassword)).status).toBe(200);
  });

  it('FR-008: đặt lại MK → phiên đang mở bị hủy, TK về "Chờ kích hoạt"', async () => {
    const staff = await createUserWithToken('STAFF');
    const live = await openSocket(staff.token);
    const res = await request(app)
      .post(`/api/users/${staff.user.id}/reset-password`)
      .set(manager.auth)
      .send({ version: staff.user.version });

    expect(res.body.data.user.status).toBe('PENDING_ACTIVATION');
    expect((await live.revoked).reason).toBe('PASSWORD_RESET');
  });

  it('chống ghi đè: 2 người sửa cùng một TK với cùng version → người sau bị từ chối', async () => {
    const staff = await createUser('STAFF');
    const [a, b] = await Promise.all([
      request(app).patch(`/api/users/${staff.id}`).set(manager.auth).send({ version: staff.version, fullName: 'Tên A' }),
      request(app).patch(`/api/users/${staff.id}`).set(receptionist.auth).send({ version: staff.version, fullName: 'Tên B' }),
    ]);
    expect([a.status, b.status].sort()).toEqual([200, 409]);
    const loser = a.status === 409 ? a : b;
    expect(loser.body.error.message).toBe(MSG.versionConflict);
  });
});

// Để cuối file: test này khóa mọi quản lý khác trong CSDL test.
describe('Quản lý cuối cùng', () => {
  it('FR-016: không đổi vai trò tài khoản quản lý cuối cùng còn hoạt động', async () => {
    const solo = await createUserWithToken('MANAGER', { fullName: 'QL duy nhất' });
    await prisma.user.updateMany({
      where: { role: 'MANAGER', status: 'ACTIVE', id: { not: solo.user.id } },
      data: { status: 'LOCKED' },
    });

    const res = await request(app)
      .patch(`/api/users/${solo.user.id}`)
      .set(solo.auth)
      .send({ version: solo.user.version, role: 'STAFF' });
    expect(res.status).toBe(409);
    expect(res.body.error.message).toBe(MSG.lastManagerRole);
  });
});
