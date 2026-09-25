import cors from 'cors';
import express from 'express';
import { corsOptions } from './config/cors.js';
import { errorHandler, notFoundHandler } from './middleware/error-handler.js';
import { authRouter } from './modules/auth/auth.routes.js';
import { healthRouter } from './modules/health/health.routes.js';
import { roomTypesRouter } from './modules/room-types/room-types.routes.js';
import { roomsRouter } from './modules/rooms/rooms.routes.js';
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

  app.use(notFoundHandler);
  app.use(errorHandler);
  return app;
}
