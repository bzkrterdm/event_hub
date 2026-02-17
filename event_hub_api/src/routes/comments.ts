import { Router, Request, Response } from 'express';
import { v4 as uuidv4 } from 'uuid';
import db from '../db';
import { buildCommentTree } from './events';

const router = Router();

// ── GET /api/events/:eventId/comments ─────────────────────────────────────────

router.get('/events/:eventId/comments', (req: Request, res: Response) => {
  const { eventId } = req.params;

  const event = db.prepare('SELECT id FROM events WHERE id = ?').get(eventId);
  if (!event) {
    res.status(404).json({ error: 'Event not found' });
    return;
  }

  const flat = db.prepare(`
    SELECT
      c.id,
      c.parent_id,
      c.content,
      c.created_at,
      COUNT(DISTINCT cv.id) AS upvotes,
      u.id         AS user_id,
      u.name       AS user_name,
      u.email      AS user_email,
      u.avatar_url AS user_avatar_url
    FROM comments c
    LEFT JOIN comment_votes cv ON cv.comment_id = c.id
    JOIN users u ON u.id = c.user_id
    WHERE c.event_id = ?
    GROUP BY c.id
    ORDER BY c.created_at ASC
  `).all(eventId) as Record<string, unknown>[];

  res.json(buildCommentTree(flat));
});

// ── POST /api/events/:eventId/comments ────────────────────────────────────────
// Body: { userId: string, content: string, parentId?: string }

router.post('/events/:eventId/comments', (req: Request, res: Response) => {
  const { eventId } = req.params;
  const { userId, content, parentId } = req.body as {
    userId: string;
    content: string;
    parentId?: string;
  };

  if (!userId || !content?.trim()) {
    res.status(400).json({ error: 'userId and content are required' });
    return;
  }

  const event = db.prepare('SELECT id FROM events WHERE id = ?').get(eventId);
  if (!event) {
    res.status(404).json({ error: 'Event not found' });
    return;
  }

  if (parentId) {
    const parent = db.prepare(
      'SELECT id FROM comments WHERE id = ? AND event_id = ?'
    ).get(parentId, eventId);
    if (!parent) {
      res.status(404).json({ error: 'Parent comment not found in this event' });
      return;
    }
  }

  const id = uuidv4();
  db.prepare(
    'INSERT INTO comments (id, event_id, parent_id, user_id, content) VALUES (?, ?, ?, ?, ?)'
  ).run(id, eventId, parentId ?? null, userId, content.trim());

  const comment = db.prepare(`
    SELECT
      c.id,
      c.parent_id,
      c.content,
      c.created_at,
      0 AS upvotes,
      u.id         AS user_id,
      u.name       AS user_name,
      u.email      AS user_email,
      u.avatar_url AS user_avatar_url
    FROM comments c
    JOIN users u ON u.id = c.user_id
    WHERE c.id = ?
  `).get(id) as Record<string, unknown>;

  res.status(201).json({
    id: comment.id,
    parentId: comment.parent_id ?? null,
    content: comment.content,
    createdAt: comment.created_at,
    upvotes: 0,
    user: {
      id: comment.user_id,
      name: comment.user_name,
      email: comment.user_email,
      avatarUrl: comment.user_avatar_url ?? null,
    },
    replies: [],
  });
});

// ── POST /api/comments/:id/vote ───────────────────────────────────────────────
// Body: { userId: string }

router.post('/comments/:id/vote', (req: Request, res: Response) => {
  const commentId = req.params.id;
  const { userId } = req.body as { userId: string };

  if (!userId) {
    res.status(400).json({ error: 'userId is required' });
    return;
  }

  const comment = db.prepare('SELECT id FROM comments WHERE id = ?').get(commentId);
  if (!comment) {
    res.status(404).json({ error: 'Comment not found' });
    return;
  }

  const existing = db.prepare(
    'SELECT id FROM comment_votes WHERE comment_id = ? AND user_id = ?'
  ).get(commentId, userId);

  if (existing) {
    db.prepare('DELETE FROM comment_votes WHERE comment_id = ? AND user_id = ?').run(commentId, userId);
  } else {
    db.prepare(
      'INSERT INTO comment_votes (id, comment_id, user_id) VALUES (?, ?, ?)'
    ).run(uuidv4(), commentId, userId);
  }

  const { upvotes } = db.prepare(
    'SELECT COUNT(*) AS upvotes FROM comment_votes WHERE comment_id = ?'
  ).get(commentId) as { upvotes: number };

  res.json({ voted: !existing, upvotes });
});

export default router;
