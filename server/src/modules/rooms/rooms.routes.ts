import { CleaningStatus, OccupancyStatus, ServiceStatus } from '@prisma/client';
import { Router } from 'express';
import { z } from 'zod';
import { MSG } from '../../lib/messages.js';
import { authOf, requireAuth, requireRole } from '../auth/auth.middleware.js';
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
 * Phòng: xem (mọi vai trò) · danh mục (quản lý) · ngừng phục vụ (quản lý, lễ tân).
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

roomsRouter.get('/', async (req, res) => {
  res.json({ data: await listRooms(listQuerySchema.parse(req.query)) });
});

roomsRouter.get('/:id', async (req, res) => {
  const { id } = idParams.parse(req.params);
  res.json({ data: await getRoom(id) });
});

// ---- Danh mục (chỉ quản lý — chốt nhóm 25/09/2026) ----------------------------

roomsRouter.post('/', requireRole('MANAGER'), async (req, res) => {
  const input = z.object({ number: roomNumber, floor, roomTypeId: z.string().uuid() }).parse(req.body);
  res.status(201).json({ data: await createRoom(authOf(res).user, input) });
});

roomsRouter.post('/bulk', requireRole('MANAGER'), async (req, res) => {
  const input = z
    .object({ floor, from: z.number().int().positive(), to: z.number().int().positive(), roomTypeId: z.string().uuid() })
    .parse(req.body);
  res.status(201).json({ data: await createRoomRange(authOf(res).user, input) });
});

roomsRouter.patch('/:id', requireRole('MANAGER'), async (req, res) => {
  const { id } = idParams.parse(req.params);
  const { version: v, ...patch } = z
    .object({ version, number: roomNumber.optional(), floor: floor.optional(), roomTypeId: z.string().uuid().optional() })
    .parse(req.body);
  res.json({ data: await updateRoom(authOf(res).user, id, v, patch) });
});

roomsRouter.delete('/:id', requireRole('MANAGER'), async (req, res) => {
  const { id } = idParams.parse(req.params);
  await deleteRoom(authOf(res).user, id, z.object({ version }).parse(req.body).version);
  res.status(204).end();
});

// ---- Ngừng phục vụ thủ công (quản lý, lễ tân — FR-007/008) ----------------------

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

roomsRouter.post('/:id/back-in-service', requireRole('MANAGER', 'RECEPTIONIST'), async (req, res) => {
  const { id } = idParams.parse(req.params);
  res.json({ data: await liftOutOfService(authOf(res).user, id, z.object({ version }).parse(req.body).version) });
});
