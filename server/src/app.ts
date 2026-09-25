import cors from 'cors';
import express from 'express';
import { corsOptions } from './config/cors.js';
import { errorHandler, notFoundHandler } from './middleware/error-handler.js';
import { authRouter } from './modules/auth/auth.routes.js';
import { dashboardRouter } from './modules/dashboard/dashboard.routes.js';
import { healthRouter } from './modules/health/health.routes.js';
import { housekeepingRouter } from './modules/housekeeping/housekeeping.routes.js';
import { maintenanceRouter } from './modules/maintenance/maintenance.routes.js';
import { roomTypesRouter } from './modules/room-types/room-types.routes.js';
import { roomsRouter } from './modules/rooms/rooms.routes.js';
import { staysRouter } from './modules/stays/stays.routes.js';
import { usersRouter } from './modules/users/users.routes.js';

export function createApp() {
  const app = express();
  app.use(cors(corsOptions(process.env.CORS_ORIGINS)));
  app.use(express.json());

  app.use('/api/health', healthRouter);
  app.use('/api/auth', authRouter);
  app.use('/api/users', usersRouter);
  app.use('/api/room-types', roomTypesRouter);
  app.use('/api/rooms', roomsRouter);
  app.use('/api/stays', staysRouter);
  app.use('/api/housekeeping', housekeepingRouter);
  app.use('/api/maintenance', maintenanceRouter);
  app.use('/api/dashboard', dashboardRouter);

  app.use(notFoundHandler);
  app.use(errorHandler);
  return app;
}
