import { Router, Request, Response } from 'express';
import db from '../db';

const router = Router();

// GET /api/users
router.get('/users', (_req: Request, res: Response) => {
  const users = db.prepare('SELECT * FROM users ORDER BY created_at ASC').all();
  res.json(users);
});

// GET /api/users/:id
router.get('/users/:id', (req: Request, res: Response) => {
  const user = db.prepare('SELECT * FROM users WHERE id = ?').get(req.params.id);
  if (!user) {
    res.status(404).json({ error: 'User not found' });
    return;
  }
  res.json(user);
});

export default router;
