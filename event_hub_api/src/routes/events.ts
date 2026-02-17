import { Router, Request, Response } from 'express';
import { v4 as uuidv4 } from 'uuid';
import db from '../db';

const router = Router();

// ── Helpers ──────────────────────────────────────────────────────────────────

function buildEventSummary(row: Record<string, unknown>) {
  return {
    id: row.id,
    title: row.title,
    description: row.description,
    type: row.type,
    status: row.status,
    category: row.category,
    createdAt: row.created_at,
    finalizedAt: row.finalized_at ?? null,
    finalDate: row.final_date ?? null,
    finalLocation: row.final_location ?? null,
    finalDetails: row.final_details ?? null,
    upvotes: row.upvotes,
    commentCount: row.comment_count,
    creator: {
      id: row.creator_id,
      name: row.creator_name,
      email: row.creator_email,
      avatarUrl: row.creator_avatar_url ?? null,
    },
  };
}

// ── GET /api/events ───────────────────────────────────────────────────────────

router.get('/events', (req: Request, res: Response) => {
  const { status, category } = req.query as Record<string, string | undefined>;

  const conditions: string[] = [];
  const params: unknown[] = [];

  if (status) {
    conditions.push('e.status = ?');
    params.push(status);
  }
  if (category) {
    conditions.push('e.category = ?');
    params.push(category);
  }

  const where = conditions.length ? `WHERE ${conditions.join(' AND ')}` : '';

  const rows = db.prepare(`
    SELECT
      e.*,
      u.name        AS creator_name,
      u.email       AS creator_email,
      u.avatar_url  AS creator_avatar_url,
      COUNT(DISTINCT ev.id) AS upvotes,
      COUNT(DISTINCT c.id)  AS comment_count
    FROM events e
    LEFT JOIN users u        ON u.id = e.creator_id
    LEFT JOIN event_votes ev ON ev.event_id = e.id
    LEFT JOIN comments c     ON c.event_id = e.id
    ${where}
    GROUP BY e.id
    ORDER BY e.created_at DESC
  `).all(...params) as Record<string, unknown>[];

  res.json(rows.map(buildEventSummary));
});

// ── GET /api/events/:id ───────────────────────────────────────────────────────

router.get('/events/:id', (req: Request, res: Response) => {
  const { id } = req.params;

  const row = db.prepare(`
    SELECT
      e.*,
      u.name        AS creator_name,
      u.email       AS creator_email,
      u.avatar_url  AS creator_avatar_url,
      COUNT(DISTINCT ev.id) AS upvotes,
      COUNT(DISTINCT c.id)  AS comment_count
    FROM events e
    LEFT JOIN users u        ON u.id = e.creator_id
    LEFT JOIN event_votes ev ON ev.event_id = e.id
    LEFT JOIN comments c     ON c.event_id = e.id
    WHERE e.id = ?
    GROUP BY e.id
  `).get(id) as Record<string, unknown> | undefined;

  if (!row) {
    res.status(404).json({ error: 'Event not found' });
    return;
  }

  // Polls with options and per-option vote counts
  const polls = (db.prepare(`
    SELECT p.id, p.question, p.type
    FROM polls p
    WHERE p.event_id = ?
  `).all(id) as Record<string, unknown>[]).map(poll => {
    const options = db.prepare(`
      SELECT
        po.id,
        po.text,
        COUNT(pv.id) AS vote_count
      FROM poll_options po
      LEFT JOIN poll_votes pv ON pv.option_id = po.id
      WHERE po.poll_id = ?
      GROUP BY po.id
    `).all(poll.id as string) as Record<string, unknown>[];

    return { ...poll, options };
  });

  // Participations with user info
  const participations = (db.prepare(`
    SELECT
      p.id,
      p.status,
      p.created_at,
      u.id        AS user_id,
      u.name      AS user_name,
      u.email     AS user_email,
      u.avatar_url AS user_avatar_url
    FROM participations p
    JOIN users u ON u.id = p.user_id
    WHERE p.event_id = ?
    ORDER BY p.created_at ASC
  `).all(id) as Record<string, unknown>[]).map(p => ({
    id: p.id,
    status: p.status,
    createdAt: p.created_at,
    user: {
      id: p.user_id,
      name: p.user_name,
      email: p.user_email,
      avatarUrl: p.user_avatar_url ?? null,
    },
  }));

  // Comments: flat, then build tree
  const flatComments = db.prepare(`
    SELECT
      c.id,
      c.parent_id,
      c.content,
      c.created_at,
      COUNT(DISTINCT cv.id) AS upvotes,
      u.id        AS user_id,
      u.name      AS user_name,
      u.email     AS user_email,
      u.avatar_url AS user_avatar_url
    FROM comments c
    LEFT JOIN comment_votes cv ON cv.comment_id = c.id
    JOIN users u ON u.id = c.user_id
    WHERE c.event_id = ?
    GROUP BY c.id
    ORDER BY c.created_at ASC
  `).all(id) as Record<string, unknown>[];

  const comments = buildCommentTree(flatComments);

  res.json({
    ...buildEventSummary(row),
    polls,
    participations,
    comments,
  });
});

// ── POST /api/events ──────────────────────────────────────────────────────────

router.post('/events', (req: Request, res: Response) => {
  const { title, description, type, category, creatorId } = req.body as Record<string, string>;

  if (!title || !type || !category || !creatorId) {
    res.status(400).json({ error: 'title, type, category, and creatorId are required' });
    return;
  }

  const validTypes = ['poll', 'discussion', 'announcement'];
  const validCategories = ['cinema', 'food', 'games', 'sports', 'other'];

  if (!validTypes.includes(type)) {
    res.status(400).json({ error: `type must be one of: ${validTypes.join(', ')}` });
    return;
  }
  if (!validCategories.includes(category)) {
    res.status(400).json({ error: `category must be one of: ${validCategories.join(', ')}` });
    return;
  }

  const creator = db.prepare('SELECT id FROM users WHERE id = ?').get(creatorId);
  if (!creator) {
    res.status(404).json({ error: 'Creator user not found' });
    return;
  }

  const id = uuidv4();
  db.prepare(`
    INSERT INTO events (id, title, description, type, status, category, creator_id)
    VALUES (?, ?, ?, ?, 'open', ?, ?)
  `).run(id, title, description ?? null, type, category, creatorId);

  const created = db.prepare(`
    SELECT
      e.*,
      u.name AS creator_name, u.email AS creator_email, u.avatar_url AS creator_avatar_url,
      0 AS upvotes, 0 AS comment_count
    FROM events e
    JOIN users u ON u.id = e.creator_id
    WHERE e.id = ?
  `).get(id) as Record<string, unknown>;

  res.status(201).json(buildEventSummary(created));
});

// ── POST /api/events/:id/vote ─────────────────────────────────────────────────

router.post('/events/:id/vote', (req: Request, res: Response) => {
  const { id } = req.params;
  const { userId } = req.body as { userId: string };

  if (!userId) {
    res.status(400).json({ error: 'userId is required' });
    return;
  }

  const event = db.prepare('SELECT id FROM events WHERE id = ?').get(id);
  if (!event) {
    res.status(404).json({ error: 'Event not found' });
    return;
  }

  const existing = db.prepare(
    'SELECT id FROM event_votes WHERE event_id = ? AND user_id = ?'
  ).get(id, userId);

  if (existing) {
    // Already voted — remove (toggle off)
    db.prepare('DELETE FROM event_votes WHERE event_id = ? AND user_id = ?').run(id, userId);
    const { upvotes } = db.prepare(
      'SELECT COUNT(*) AS upvotes FROM event_votes WHERE event_id = ?'
    ).get(id) as { upvotes: number };
    res.json({ voted: false, upvotes });
  } else {
    // Cast vote
    db.prepare(
      'INSERT INTO event_votes (id, event_id, user_id) VALUES (?, ?, ?)'
    ).run(uuidv4(), id, userId);
    const { upvotes } = db.prepare(
      'SELECT COUNT(*) AS upvotes FROM event_votes WHERE event_id = ?'
    ).get(id) as { upvotes: number };
    res.json({ voted: true, upvotes });
  }
});

// ── PUT /api/events/:id/finalize ──────────────────────────────────────────────

router.put('/events/:id/finalize', (req: Request, res: Response) => {
  const { id } = req.params;
  const { finalDate, finalLocation, finalDetails } = req.body as Record<string, string>;

  const event = db.prepare('SELECT id, status FROM events WHERE id = ?').get(id) as
    | { id: string; status: string }
    | undefined;

  if (!event) {
    res.status(404).json({ error: 'Event not found' });
    return;
  }
  if (event.status === 'finalized') {
    res.status(400).json({ error: 'Event is already finalized' });
    return;
  }
  if (event.status === 'cancelled') {
    res.status(400).json({ error: 'Cannot finalize a cancelled event' });
    return;
  }

  db.prepare(`
    UPDATE events
    SET status = 'finalized',
        finalized_at = datetime('now'),
        final_date = ?,
        final_location = ?,
        final_details = ?
    WHERE id = ?
  `).run(finalDate ?? null, finalLocation ?? null, finalDetails ?? null, id);

  const updated = db.prepare(`
    SELECT
      e.*,
      u.name AS creator_name, u.email AS creator_email, u.avatar_url AS creator_avatar_url,
      COUNT(DISTINCT ev.id) AS upvotes,
      COUNT(DISTINCT c.id)  AS comment_count
    FROM events e
    LEFT JOIN users u        ON u.id = e.creator_id
    LEFT JOIN event_votes ev ON ev.event_id = e.id
    LEFT JOIN comments c     ON c.event_id = e.id
    WHERE e.id = ?
    GROUP BY e.id
  `).get(id) as Record<string, unknown>;

  res.json(buildEventSummary(updated));
});

// ── Nested comment builder ────────────────────────────────────────────────────

interface CommentNode {
  id: string;
  parentId: string | null;
  content: string;
  createdAt: unknown;
  upvotes: unknown;
  user: { id: unknown; name: unknown; email: unknown; avatarUrl: unknown };
  replies: CommentNode[];
}

export function buildCommentTree(flat: Record<string, unknown>[]): CommentNode[] {
  const map = new Map<string, CommentNode>();

  for (const row of flat) {
    map.set(row.id as string, {
      id: row.id as string,
      parentId: (row.parent_id as string) ?? null,
      content: row.content as string,
      createdAt: row.created_at,
      upvotes: row.upvotes,
      user: {
        id: row.user_id,
        name: row.user_name,
        email: row.user_email,
        avatarUrl: row.user_avatar_url ?? null,
      },
      replies: [],
    });
  }

  const roots: CommentNode[] = [];
  for (const node of map.values()) {
    if (node.parentId && map.has(node.parentId)) {
      map.get(node.parentId)!.replies.push(node);
    } else {
      roots.push(node);
    }
  }

  return roots;
}

export default router;
