import { Router, Request, Response } from 'express';
import { v4 as uuidv4 } from 'uuid';
import db from '../db';

const router = Router();

// ── POST /api/events/:eventId/polls ───────────────────────────────────────────
// Body: { question: string, type: 'single'|'multiple', options: string[] }

router.post('/events/:eventId/polls', (req: Request, res: Response) => {
  const { eventId } = req.params;
  const { question, type, options } = req.body as {
    question: string;
    type: string;
    options: string[];
  };

  if (!question || !type || !Array.isArray(options) || options.length < 2) {
    res.status(400).json({ error: 'question, type, and at least 2 options are required' });
    return;
  }
  if (!['single', 'multiple'].includes(type)) {
    res.status(400).json({ error: 'type must be "single" or "multiple"' });
    return;
  }

  const event = db.prepare('SELECT id FROM events WHERE id = ?').get(eventId);
  if (!event) {
    res.status(404).json({ error: 'Event not found' });
    return;
  }

  const existingPoll = db.prepare('SELECT id FROM polls WHERE event_id = ?').get(eventId);
  if (existingPoll) {
    res.status(409).json({ error: 'This event already has a poll' });
    return;
  }

  const pollId = uuidv4();

  const createPollAndOptions = db.transaction(() => {
    db.prepare(
      'INSERT INTO polls (id, event_id, question, type) VALUES (?, ?, ?, ?)'
    ).run(pollId, eventId, question, type);

    for (const text of options) {
      db.prepare(
        'INSERT INTO poll_options (id, poll_id, text) VALUES (?, ?, ?)'
      ).run(uuidv4(), pollId, String(text));
    }
  });

  createPollAndOptions();

  const poll = db.prepare('SELECT * FROM polls WHERE id = ?').get(pollId) as Record<string, unknown>;
  const pollOptions = db.prepare(
    'SELECT id, text, 0 AS vote_count FROM poll_options WHERE poll_id = ?'
  ).all(pollId);

  res.status(201).json({ ...poll, options: pollOptions });
});

// ── POST /api/polls/:id/vote ──────────────────────────────────────────────────
// Body: { userId: string, optionId: string }

router.post('/polls/:id/vote', (req: Request, res: Response) => {
  const pollId = req.params.id;
  const { userId, optionId } = req.body as { userId: string; optionId: string };

  if (!userId || !optionId) {
    res.status(400).json({ error: 'userId and optionId are required' });
    return;
  }

  const poll = db.prepare('SELECT * FROM polls WHERE id = ?').get(pollId) as
    | { id: string; type: string }
    | undefined;
  if (!poll) {
    res.status(404).json({ error: 'Poll not found' });
    return;
  }

  const option = db.prepare(
    'SELECT id FROM poll_options WHERE id = ? AND poll_id = ?'
  ).get(optionId, pollId);
  if (!option) {
    res.status(404).json({ error: 'Option not found in this poll' });
    return;
  }

  const existingVoteOnOption = db.prepare(
    'SELECT id FROM poll_votes WHERE poll_id = ? AND option_id = ? AND user_id = ?'
  ).get(pollId, optionId, userId);

  if (existingVoteOnOption) {
    // Toggle off — remove this vote
    db.prepare(
      'DELETE FROM poll_votes WHERE poll_id = ? AND option_id = ? AND user_id = ?'
    ).run(pollId, optionId, userId);
  } else {
    // For single-choice polls, remove any existing vote by this user first
    if (poll.type === 'single') {
      db.prepare(
        'DELETE FROM poll_votes WHERE poll_id = ? AND user_id = ?'
      ).run(pollId, userId);
    }

    db.prepare(
      'INSERT INTO poll_votes (id, poll_id, option_id, user_id) VALUES (?, ?, ?, ?)'
    ).run(uuidv4(), pollId, optionId, userId);
  }

  // Return updated options with vote counts
  const updatedOptions = db.prepare(`
    SELECT
      po.id,
      po.text,
      COUNT(pv.id) AS vote_count
    FROM poll_options po
    LEFT JOIN poll_votes pv ON pv.option_id = po.id
    WHERE po.poll_id = ?
    GROUP BY po.id
  `).all(pollId);

  // Return user's current votes
  const userVotes = (db.prepare(
    'SELECT option_id FROM poll_votes WHERE poll_id = ? AND user_id = ?'
  ).all(pollId, userId) as { option_id: string }[]).map(v => v.option_id);

  res.json({ options: updatedOptions, userVotes });
});

export default router;
