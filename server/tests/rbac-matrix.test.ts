import { randomUUID } from 'node:crypto';
import type { Role } from '@prisma/client';
import request from 'supertest';
import { beforeAll, describe, expect, it } from 'vitest';
import { createApp } from '../src/app.js';
import { createUserWithToken } from './helpers.js';

/**
 * Ma trận phân quyền (S1-BAO-05, NFR-auth-roles-003): mọi API × 3 vai trò, kiểm ở máy chủ.
 * - Vai trò KHÔNG được phép → 403 FORBIDDEN (bị chặn trước khi đọc body / đụng dữ liệu).
 * - Vai trò được phép → qua được lớp quyền (body rỗng / id ngẫu nhiên nên nhận 200/400/404, không bao giờ 401/403).
 * - Không token → 401.
 * Quyền chi tiết theo từng bản ghi (vd lễ tân chỉ quản lý TK nhân viên, chỉ người báo được hủy) nằm ở test từng feature.
 * Thêm API mới → thêm 1 dòng vào bảng này.
 */
const ALL: Role[] = ['MANAGER', 'RECEPTIONIST', 'STAFF'];
const id = randomUUID();

const MATRIX: { method: 'get' | 'post' | 'patch' | 'delete'; path: string; allowed: Role[] }[] = [
  // auth-roles — quản lý tài khoản
  { method: 'get', path: '/api/users', allowed: ['MANAGER', 'RECEPTIONIST'] },
  { method: 'post', path: '/api/users', allowed: ['MANAGER', 'RECEPTIONIST'] },
  { method: 'patch', path: `/api/users/${id}`, allowed: ['MANAGER', 'RECEPTIONIST'] },
  { method: 'post', path: `/api/users/${id}/lock`, allowed: ['MANAGER', 'RECEPTIONIST'] },
  { method: 'post', path: `/api/users/${id}/unlock`, allowed: ['MANAGER', 'RECEPTIONIST'] },
  { method: 'post', path: `/api/users/${id}/reset-password`, allowed: ['MANAGER', 'RECEPTIONIST'] },
  // room-catalog
  { method: 'get', path: '/api/room-types', allowed: ALL },
  { method: 'post', path: '/api/room-types', allowed: ['MANAGER'] },
  { method: 'patch', path: `/api/room-types/${id}`, allowed: ['MANAGER'] },
  { method: 'get', path: '/api/rooms', allowed: ALL },
  { method: 'get', path: `/api/rooms/${id}`, allowed: ALL },
  { method: 'post', path: '/api/rooms', allowed: ['MANAGER'] },
  { method: 'post', path: '/api/rooms/bulk', allowed: ['MANAGER'] },
  { method: 'patch', path: `/api/rooms/${id}`, allowed: ['MANAGER'] },
  { method: 'delete', path: `/api/rooms/${id}`, allowed: ['MANAGER'] },
  { method: 'post', path: `/api/rooms/${id}/out-of-service`, allowed: ['MANAGER', 'RECEPTIONIST'] },
  { method: 'post', path: `/api/rooms/${id}/back-in-service`, allowed: ['MANAGER', 'RECEPTIONIST'] },
  // check-in-out
  { method: 'post', path: `/api/rooms/${id}/check-in`, allowed: ['RECEPTIONIST'] },
  { method: 'post', path: `/api/rooms/${id}/check-out`, allowed: ['RECEPTIONIST'] },
  { method: 'get', path: '/api/stays', allowed: ['MANAGER', 'RECEPTIONIST'] },
  // housekeeping
  { method: 'get', path: '/api/housekeeping/tasks', allowed: ['MANAGER', 'STAFF'] },
  { method: 'post', path: `/api/housekeeping/tasks/${id}/accept`, allowed: ['STAFF'] },
  { method: 'post', path: `/api/housekeeping/tasks/${id}/reject`, allowed: ['STAFF'] },
  { method: 'post', path: `/api/housekeeping/tasks/${id}/complete`, allowed: ['STAFF'] },
  { method: 'post', path: `/api/housekeeping/tasks/${id}/confirm`, allowed: ['MANAGER'] },
  { method: 'post', path: `/api/housekeeping/tasks/${id}/return`, allowed: ['MANAGER'] },
  { method: 'post', path: `/api/housekeeping/tasks/${id}/reassign`, allowed: ['MANAGER'] },
  // maintenance
  { method: 'get', path: '/api/maintenance/tasks', allowed: ALL },
  { method: 'post', path: '/api/maintenance/tasks', allowed: ALL },
  { method: 'post', path: `/api/maintenance/tasks/${id}/claim`, allowed: ['STAFF'] },
  { method: 'post', path: `/api/maintenance/tasks/${id}/complete`, allowed: ['STAFF'] },
  { method: 'post', path: `/api/maintenance/tasks/${id}/cancel`, allowed: ALL },
  { method: 'post', path: `/api/maintenance/tasks/${id}/assign`, allowed: ['MANAGER', 'RECEPTIONIST'] },
  // room-dashboard, audit-log
  { method: 'get', path: '/api/dashboard/summary', allowed: ['MANAGER', 'RECEPTIONIST'] },
  { method: 'get', path: '/api/audit-logs', allowed: ['MANAGER'] },
];

const app = createApp();
const tokens = {} as Record<Role, Record<string, string>>;

beforeAll(async () => {
  for (const role of ALL) tokens[role] = (await createUserWithToken(role)).auth;
});

const cases = MATRIX.flatMap((route) =>
  ALL.map((role) => ({ ...route, role, allow: route.allowed.includes(role) })),
);

describe('Ma trận phân quyền API', () => {
  it.each(cases)('$method $path — $role → $allow', async ({ method, path, role, allow }) => {
    const res = await request(app)[method](path).set(tokens[role]).send({});
    if (allow) {
      expect(res.status, JSON.stringify(res.body)).not.toBe(401);
      expect(res.status, JSON.stringify(res.body)).not.toBe(403);
    } else {
      expect(res.status).toBe(403);
      expect(res.body.error.code).toMatch(/FORBIDDEN/);
    }
  });

  it.each(MATRIX)('$method $path — không đăng nhập → 401', async ({ method, path }) => {
    const res = await request(app)[method](path).send({});
    expect(res.status).toBe(401);
  });
});
