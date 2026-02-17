import { Router, Request, Response } from 'express';
import { v4 as uuidv4 } from 'uuid';
import db from '../db';

const router = Router();

// ── POST /api/events/:eventId/participate ─────────────────────────────────────
// Body: { userId: string, status: 'going'|'maybe'|'notGoing' }
// Upserts participation — re-posting with same status removes it (toggle).

router.post('/events/:eventId/participate', (req: Request, res: Response) => {
  const { eventId } = req.params;
  const { userId, status } = req.body as { userId: string; status: string };

  if (!userId || !status) {
    res.status(400).json({ error: 'userId and status are required' });
    return;
  }

  const validStatuses = ['going', 'maybe', 'notGoing'];
  if (!validStatuses.includes(status)) {
    res.status(400).json({ error: `status must be one of: ${validStatuses.join(', ')}` });
    return;
  }

  const event = db.prepare('SELECT id FROM events WHERE id = ?').get(eventId);
  if (!event) {
    res.status(404).json({ error: 'Event not found' });
    return;
  }

  const existing = db.prepare(
    'SELECT id, status FROM participations WHERE event_id = ? AND user_id = ?'
  ).get(eventId, userId) as { id: string; status: string } | undefined;

  if (existing) {
    if (existing.status === status) {
      // Same status — toggle off (remove)
      db.prepare('DELETE FROM participations WHERE id = ?').run(existing.id);
      res.json({ participating: false, status: null });
      return;
    }
    // Different status — update
    db.prepare(
      'UPDATE participations SET status = ? WHERE id = ?'
    ).run(status, existing.id);
  } else {
    // New participation
    db.prepare(
      'INSERT INTO participations (id, event_id, user_id, status) VALUES (?, ?, ?, ?)'
    ).run(uuidv4(), eventId, userId, status);
  }

  // Return updated participation counts for the event
  const counts = db.prepare(`
    SELECT status, COUNT(*) AS count
    FROM participations
    WHERE event_id = ?
    GROUP BY status
  `).all(eventId) as { status: string; count: number }[];

  const summary = { going: 0, maybe: 0, notGoing: 0 };
  for (const row of counts) {
    summary[row.status as keyof typeof summary] = row.count;
  }

  res.json({ participating: true, status, counts: summary });
});

export default router;
