import { CleaningStatus, OccupancyStatus, ServiceStatus } from '@prisma/client';
import { Router } from 'express';
import { z } from 'zod';
import { requireAuth } from '../auth/auth.middleware.js';
import { getRoom, listRooms } from './rooms.service.js';

// Mọi vai trò đã đăng nhập được xem phòng (room-catalog FR-006).
export const roomsRouter = Router();
roomsRouter.use(requireAuth());

const listQuerySchema = z.object({
  floor: z.coerce.number().int().positive().optional(),
  roomTypeId: z.string().uuid().optional(),
  occupancy: z.nativeEnum(OccupancyStatus).optional(),
  cleaning: z.nativeEnum(CleaningStatus).optional(),
  service: z.nativeEnum(ServiceStatus).optional(),
});

const idParamsSchema = z.object({ id: z.string().uuid() });

roomsRouter.get('/', async (req, res) => {
  const filter = listQuerySchema.parse(req.query);
  res.json({ data: await listRooms(filter) });
});

roomsRouter.get('/:id', async (req, res) => {
  const { id } = idParamsSchema.parse(req.params);
  res.json({ data: await getRoom(id) });
});
