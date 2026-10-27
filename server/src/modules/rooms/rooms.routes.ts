import { CleaningStatus, OccupancyStatus, ServiceStatus } from '@prisma/client';
import { Router } from 'express';
import { z } from 'zod';
import { MSG } from '../../lib/messages.js';
import { authOf, requireAuth, requireRole } from '../auth/auth.middleware.js';
import { checkIn, checkOut } from '../stays/stays.service.js';
import {
  createRoom,
  createRoomRange,
  deleteRoom,
  liftOutOfService,
  placeOutOfService,
  updateRoom,
} from './rooms.catalog.js';
import { getRoom, listRooms } from './rooms.service.js';

/**
 * Phòng: xem (mọi vai trò) · danh mục (quản lý) · ngừng phục vụ (quản lý, lễ tân) · nhận/trả (chỉ lễ tân).
 * Mọi thao tác ghi gửi kèm `version` của phòng đã đọc (FR-realtime-sync-003).
 */
export const roomsRouter = Router();
roomsRouter.use(requireAuth());

const idParams = z.object({ id: z.string().uuid() });
const version = z.number().int().positive();
const roomNumber = z.string().trim().min(1, 'Vui lòng nhập số phòng.').max(10);
const floor = z.number().int().positive('Tầng phải là số nguyên dương.');

const listQuerySchema = z.object({
  floor: z.coerce.number().int().positive().optional(),
  roomTypeId: z.string().uuid().optional(),
  occupancy: z.nativeEnum(OccupancyStatus).optional(),
  cleaning: z.nativeEnum(CleaningStatus).optional(),
  service: z.nativeEnum(ServiceStatus).optional(),
  ready: z.enum(['true', 'false']).transform((v) => v === 'true').optional(),
});

// ---- Xem --------------------------------------------------------------------

/** GET `/` — lọc phòng. Mọi vai trò đã đăng nhập. Query sai enum → 400. */
roomsRouter.get('/', async (req, res) => {
  res.json({ data: await listRooms(listQuerySchema.parse(req.query)) });
});

/** GET `/:id` — một phòng. UUID sai → 400; không có phòng → 404. */
roomsRouter.get('/:id', async (req, res) => {
  const { id } = idParams.parse(req.params);
  res.json({ data: await getRoom(id) });
});

// ---- Danh mục (chỉ quản lý — chốt nhóm 25/09/2026) ----------------------------

/** POST `/` — thêm một phòng. Chỉ quản lý. 201 kèm DTO. */
roomsRouter.post('/', requireRole('MANAGER'), async (req, res) => {
  const input = z.object({ number: roomNumber, floor, roomTypeId: z.string().uuid() }).parse(req.body);
  res.status(201).json({ data: await createRoom(authOf(res).user, input) });
});

/** POST `/bulk` — tạo dải số. Chỉ quản lý. Phải đăng ký trước các route `/:id` nếu cùng method; POST không đụng GET `/:id`. */
roomsRouter.post('/bulk', requireRole('MANAGER'), async (req, res) => {
  const input = z
    .object({ floor, from: z.number().int().positive(), to: z.number().int().positive(), roomTypeId: z.string().uuid() })
    .parse(req.body);
  res.status(201).json({ data: await createRoomRange(authOf(res).user, input) });
});

/** PATCH `/:id` — sửa số, tầng, loại. Chỉ quản lý. Body bắt buộc `version`. */
roomsRouter.patch('/:id', requireRole('MANAGER'), async (req, res) => {
  const { id } = idParams.parse(req.params);
  const { version: v, ...patch } = z
    .object({ version, number: roomNumber.optional(), floor: floor.optional(), roomTypeId: z.string().uuid().optional() })
    .parse(req.body);
  res.json({ data: await updateRoom(authOf(res).user, id, v, patch) });
});

/** DELETE `/:id` — xóa phòng. Chỉ quản lý. `version` nằm trong body; thành công thì 204 không body. */
roomsRouter.delete('/:id', requireRole('MANAGER'), async (req, res) => {
  const { id } = idParams.parse(req.params);
  await deleteRoom(authOf(res).user, id, z.object({ version }).parse(req.body).version);
  res.status(204).end();
});

// ---- Ngừng phục vụ thủ công (quản lý, lễ tân — FR-007/008) ----------------------

/** POST `/:id/out-of-service` — đặt ngừng phục vụ tay. Quản lý hoặc lễ tân. Bắt buộc `reason`. */
roomsRouter.post('/:id/out-of-service', requireRole('MANAGER', 'RECEPTIONIST'), async (req, res) => {
  const { id } = idParams.parse(req.params);
  const { version: v, ...input } = z
    .object({
      version,
      reason: z.string().trim().min(1, MSG.outOfServiceReasonRequired).max(200),
      confirmOccupied: z.boolean().optional(),
    })
    .parse(req.body);
  res.json({ data: await placeOutOfService(authOf(res).user, id, v, input) });
});

/** POST `/:id/back-in-service` — gỡ ngừng phục vụ tay. Quản lý hoặc lễ tân. */
roomsRouter.post('/:id/back-in-service', requireRole('MANAGER', 'RECEPTIONIST'), async (req, res) => {
  const { id } = idParams.parse(req.params);
  res.json({ data: await liftOutOfService(authOf(res).user, id, z.object({ version }).parse(req.body).version) });
});

// ---- Nhận / trả phòng (chỉ lễ tân — BR-auth-roles-002) -------------------------

/** POST `/:id/check-in` — nhận khách. Chỉ lễ tân (quản lý bị 403 dù biết version). */
roomsRouter.post('/:id/check-in', requireRole('RECEPTIONIST'), async (req, res) => {
  const { id } = idParams.parse(req.params);
  const { version: v, ...input } = z
    .object({
      version,
      guestName: z.string({ required_error: MSG.guestNameRequired }).trim().min(1, MSG.guestNameRequired).max(100),
      guestCount: z.number({ required_error: MSG.guestCountInvalid }).int().min(1, MSG.guestCountInvalid).max(20),
      note: z.string().trim().max(500).optional(),
      expectedCheckout: z.coerce.date().optional(),
    })
    .parse(req.body);
  res.json({ data: await checkIn(authOf(res).user, id, v, input) });
});

/** POST `/:id/check-out` — trả phòng. Chỉ lễ tân. Body chỉ cần `version` của phòng. */
roomsRouter.post('/:id/check-out', requireRole('RECEPTIONIST'), async (req, res) => {
  const { id } = idParams.parse(req.params);
  res.json({ data: await checkOut(authOf(res).user, id, z.object({ version }).parse(req.body).version) });
});
