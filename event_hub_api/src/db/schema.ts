import type Database from 'better-sqlite3';

export function runSchema(db: Database.Database): void {
  db.exec(`
    -- Users
    CREATE TABLE IF NOT EXISTS users (
      id         TEXT PRIMARY KEY,
      name       TEXT NOT NULL,
      email      TEXT NOT NULL UNIQUE,
      avatar_url TEXT,
      created_at TEXT NOT NULL DEFAULT (datetime('now'))
    );

    -- Events
    -- upvotes is derived from event_votes; comment_count is derived from comments
    CREATE TABLE IF NOT EXISTS events (
      id               TEXT PRIMARY KEY,
      title            TEXT NOT NULL,
      description      TEXT,
      type             TEXT NOT NULL CHECK(type IN ('poll', 'discussion', 'announcement')),
      status           TEXT NOT NULL DEFAULT 'open' CHECK(status IN ('open', 'finalized', 'cancelled')),
      category         TEXT NOT NULL CHECK(category IN ('cinema', 'food', 'games', 'sports', 'other')),
      creator_id       TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      created_at       TEXT NOT NULL DEFAULT (datetime('now')),
      finalized_at     TEXT,
      final_date       TEXT,
      final_location   TEXT,
      final_details    TEXT
    );

    -- Event upvotes (one vote per user per event)
    CREATE TABLE IF NOT EXISTS event_votes (
      id         TEXT PRIMARY KEY,
      event_id   TEXT NOT NULL REFERENCES events(id) ON DELETE CASCADE,
      user_id    TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      created_at TEXT NOT NULL DEFAULT (datetime('now')),
      UNIQUE(event_id, user_id)
    );

    -- Polls (one poll per event)
    CREATE TABLE IF NOT EXISTS polls (
      id       TEXT PRIMARY KEY,
      event_id TEXT NOT NULL UNIQUE REFERENCES events(id) ON DELETE CASCADE,
      question TEXT NOT NULL,
      type     TEXT NOT NULL CHECK(type IN ('single', 'multiple'))
    );

    -- Poll options
    CREATE TABLE IF NOT EXISTS poll_options (
      id      TEXT PRIMARY KEY,
      poll_id TEXT NOT NULL REFERENCES polls(id) ON DELETE CASCADE,
      text    TEXT NOT NULL
    );

    -- Poll votes (one vote per user per option for single-choice; multiple allowed for multiple-choice)
    CREATE TABLE IF NOT EXISTS poll_votes (
      id        TEXT PRIMARY KEY,
      poll_id   TEXT NOT NULL REFERENCES polls(id) ON DELETE CASCADE,
      option_id TEXT NOT NULL REFERENCES poll_options(id) ON DELETE CASCADE,
      user_id   TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      UNIQUE(poll_id, option_id, user_id)
    );

    -- Participations (one status per user per event)
    CREATE TABLE IF NOT EXISTS participations (
      id         TEXT PRIMARY KEY,
      event_id   TEXT NOT NULL REFERENCES events(id) ON DELETE CASCADE,
      user_id    TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      status     TEXT NOT NULL CHECK(status IN ('going', 'maybe', 'notGoing')),
      created_at TEXT NOT NULL DEFAULT (datetime('now')),
      UNIQUE(event_id, user_id)
    );

    -- Comments (supports nesting via parent_id)
    CREATE TABLE IF NOT EXISTS comments (
      id         TEXT PRIMARY KEY,
      event_id   TEXT NOT NULL REFERENCES events(id) ON DELETE CASCADE,
      parent_id  TEXT REFERENCES comments(id) ON DELETE CASCADE,
      user_id    TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      content    TEXT NOT NULL,
      created_at TEXT NOT NULL DEFAULT (datetime('now'))
    );

    -- Comment upvotes (one vote per user per comment)
    CREATE TABLE IF NOT EXISTS comment_votes (
      id         TEXT PRIMARY KEY,
      comment_id TEXT NOT NULL REFERENCES comments(id) ON DELETE CASCADE,
      user_id    TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      created_at TEXT NOT NULL DEFAULT (datetime('now')),
      UNIQUE(comment_id, user_id)
    );
  `);
}
