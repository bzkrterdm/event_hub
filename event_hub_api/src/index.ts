import express, { NextFunction, Request, Response } from 'express';
import cors from 'cors';
import db from './db';
import usersRouter from './routes/users';
import eventsRouter from './routes/events';
import pollsRouter from './routes/polls';
import participationsRouter from './routes/participations';
import commentsRouter from './routes/comments';
import calendarRouter from './routes/calendar';

const app = express();
const PORT = process.env.PORT ?? 8080;

app.use(cors());
app.use(express.json());

app.get('/health', (_req, res) => {
  res.json({ status: 'ok' });
});

app.use('/api', usersRouter);
app.use('/api', eventsRouter);
app.use('/api', pollsRouter);
app.use('/api', participationsRouter);
app.use('/api', commentsRouter);
app.use('/api', calendarRouter);

// 404
app.use((_req, res) => {
  res.status(404).json({ error: 'Not found' });
});

// Global error handler
app.use((err: Error, _req: Request, res: Response, _next: NextFunction) => {
  console.error(err);
  res.status(500).json({ error: err.message ?? 'Internal server error' });
});

app.listen(PORT, () => {
  console.log(`Event Hub API running on http://localhost:${PORT}`);
});

export { db };
