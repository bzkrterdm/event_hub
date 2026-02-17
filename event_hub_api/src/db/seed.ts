import { v4 as uuidv4 } from 'uuid';
import Database from 'better-sqlite3';
import path from 'path';
import { runSchema } from './schema';

const DB_PATH = path.resolve(__dirname, '../../event_hub.db');
const db = new Database(DB_PATH);
db.pragma('journal_mode = WAL');
db.pragma('foreign_keys = ON');
runSchema(db);

// ── Users ────────────────────────────────────────────────────────────────────
const userDemo = { id: uuidv4(), name: 'Demo User',  email: 'demo@example.com',   avatar_url: null };
const userAhmet = { id: uuidv4(), name: 'Ahmet',     email: 'ahmet@example.com',  avatar_url: null };
const userMehmet = { id: uuidv4(), name: 'Mehmet',   email: 'mehmet@example.com', avatar_url: null };

const insertUser = db.prepare(
  'INSERT OR IGNORE INTO users (id, name, email, avatar_url) VALUES (@id, @name, @email, @avatar_url)'
);

// ── Events ───────────────────────────────────────────────────────────────────
const eventCinema = {
  id: uuidv4(),
  title: 'Movie Night — Which film?',
  description: 'Vote for the movie we should watch this Friday.',
  type: 'poll',
  status: 'open',
  category: 'cinema',
  creator_id: userAhmet.id,
};

const eventBoardGame = {
  id: uuidv4(),
  title: 'Board Game Night',
  description: 'Vote for your favourite board game.',
  type: 'poll',
  status: 'finalized',
  category: 'games',
  creator_id: userMehmet.id,
  finalized_at: new Date().toISOString(),
  final_date: '2026-02-20T19:00:00.000Z',
  final_location: 'Mehmet\'s place',
  final_details: 'Bring snacks! We\'ll be playing Catan.',
};

const eventLunch = {
  id: uuidv4(),
  title: 'Lunch Spot — Open Discussion',
  description: 'Where should we go for lunch next week? Drop your suggestions!',
  type: 'discussion',
  status: 'open',
  category: 'food',
  creator_id: userDemo.id,
};

const insertEvent = db.prepare(`
  INSERT OR IGNORE INTO events
    (id, title, description, type, status, category, creator_id, finalized_at, final_date, final_location, final_details)
  VALUES
    (@id, @title, @description, @type, @status, @category, @creator_id,
     @finalized_at, @final_date, @final_location, @final_details)
`);

// ── Polls ────────────────────────────────────────────────────────────────────
const pollCinema = { id: uuidv4(), event_id: eventCinema.id, question: 'Which movie should we watch?', type: 'single' };
const pollBoardGame = { id: uuidv4(), event_id: eventBoardGame.id, question: 'Which board game should we play?', type: 'multiple' };

const insertPoll = db.prepare(
  'INSERT OR IGNORE INTO polls (id, event_id, question, type) VALUES (@id, @event_id, @question, @type)'
);

// ── Poll Options ─────────────────────────────────────────────────────────────
const cinemOptions = [
  { id: uuidv4(), poll_id: pollCinema.id, text: 'Dune: Part Two' },
  { id: uuidv4(), poll_id: pollCinema.id, text: 'Oppenheimer' },
  { id: uuidv4(), poll_id: pollCinema.id, text: 'Interstellar' },
];

const boardGameOptions = [
  { id: uuidv4(), poll_id: pollBoardGame.id, text: 'Catan' },
  { id: uuidv4(), poll_id: pollBoardGame.id, text: 'Ticket to Ride' },
  { id: uuidv4(), poll_id: pollBoardGame.id, text: 'Codenames' },
];

const insertOption = db.prepare(
  'INSERT OR IGNORE INTO poll_options (id, poll_id, text) VALUES (@id, @poll_id, @text)'
);

// ── Poll Votes ────────────────────────────────────────────────────────────────
const insertPollVote = db.prepare(
  'INSERT OR IGNORE INTO poll_votes (id, poll_id, option_id, user_id) VALUES (@id, @poll_id, @option_id, @user_id)'
);

// ── Event Votes ───────────────────────────────────────────────────────────────
const insertEventVote = db.prepare(
  'INSERT OR IGNORE INTO event_votes (id, event_id, user_id) VALUES (@id, @event_id, @user_id)'
);

// ── Participations ────────────────────────────────────────────────────────────
const insertParticipation = db.prepare(
  'INSERT OR IGNORE INTO participations (id, event_id, user_id, status) VALUES (@id, @event_id, @user_id, @status)'
);

// ── Comments ──────────────────────────────────────────────────────────────────
const insertComment = db.prepare(
  'INSERT OR IGNORE INTO comments (id, event_id, parent_id, user_id, content) VALUES (@id, @event_id, @parent_id, @user_id, @content)'
);

// ── Comment Votes ─────────────────────────────────────────────────────────────
const insertCommentVote = db.prepare(
  'INSERT OR IGNORE INTO comment_votes (id, comment_id, user_id) VALUES (@id, @comment_id, @user_id)'
);

// ── Run all inserts in a single transaction ───────────────────────────────────
const seed = db.transaction(() => {
  // Users
  insertUser.run(userDemo);
  insertUser.run(userAhmet);
  insertUser.run(userMehmet);

  // Events
  insertEvent.run({ finalized_at: null, final_date: null, final_location: null, final_details: null, ...eventCinema });
  insertEvent.run({ ...eventBoardGame });
  insertEvent.run({ finalized_at: null, final_date: null, final_location: null, final_details: null, ...eventLunch });

  // Polls
  insertPoll.run(pollCinema);
  insertPoll.run(pollBoardGame);

  // Poll options
  cinemOptions.forEach(o => insertOption.run(o));
  boardGameOptions.forEach(o => insertOption.run(o));

  // Poll votes — cinema: Demo→Dune, Ahmet→Oppenheimer; board game: Mehmet→Catan+Codenames
  insertPollVote.run({ id: uuidv4(), poll_id: pollCinema.id, option_id: cinemOptions[0].id, user_id: userDemo.id });
  insertPollVote.run({ id: uuidv4(), poll_id: pollCinema.id, option_id: cinemOptions[1].id, user_id: userAhmet.id });
  insertPollVote.run({ id: uuidv4(), poll_id: pollBoardGame.id, option_id: boardGameOptions[0].id, user_id: userMehmet.id });
  insertPollVote.run({ id: uuidv4(), poll_id: pollBoardGame.id, option_id: boardGameOptions[2].id, user_id: userMehmet.id });

  // Event upvotes
  insertEventVote.run({ id: uuidv4(), event_id: eventCinema.id,    user_id: userDemo.id });
  insertEventVote.run({ id: uuidv4(), event_id: eventCinema.id,    user_id: userMehmet.id });
  insertEventVote.run({ id: uuidv4(), event_id: eventBoardGame.id, user_id: userAhmet.id });
  insertEventVote.run({ id: uuidv4(), event_id: eventLunch.id,     user_id: userAhmet.id });

  // Participations
  insertParticipation.run({ id: uuidv4(), event_id: eventCinema.id, user_id: userDemo.id,   status: 'going' });
  insertParticipation.run({ id: uuidv4(), event_id: eventCinema.id, user_id: userAhmet.id,  status: 'maybe' });
  insertParticipation.run({ id: uuidv4(), event_id: eventCinema.id, user_id: userMehmet.id, status: 'going' });
  insertParticipation.run({ id: uuidv4(), event_id: eventBoardGame.id, user_id: userMehmet.id, status: 'going' });
  insertParticipation.run({ id: uuidv4(), event_id: eventBoardGame.id, user_id: userAhmet.id,  status: 'going' });
  insertParticipation.run({ id: uuidv4(), event_id: eventLunch.id, user_id: userDemo.id,    status: 'maybe' });

  // Comments — cinema event
  const c1 = { id: uuidv4(), event_id: eventCinema.id, parent_id: null, user_id: userAhmet.id,  content: 'I really want to see Dune! The first one was amazing.' };
  const c2 = { id: uuidv4(), event_id: eventCinema.id, parent_id: null, user_id: userMehmet.id, content: 'Oppenheimer is a masterpiece, highly recommend.' };
  const c3 = { id: uuidv4(), event_id: eventCinema.id, parent_id: c1.id, user_id: userDemo.id,  content: 'Agreed, the visuals alone are worth it!' };
  const c4 = { id: uuidv4(), event_id: eventCinema.id, parent_id: c2.id, user_id: userAhmet.id, content: 'Three hours is a lot though, are you sure?' };

  insertComment.run(c1);
  insertComment.run(c2);
  insertComment.run(c3);
  insertComment.run(c4);

  // Comments — lunch event
  const c5 = { id: uuidv4(), event_id: eventLunch.id, parent_id: null, user_id: userMehmet.id, content: 'How about the new Thai place downtown?' };
  const c6 = { id: uuidv4(), event_id: eventLunch.id, parent_id: null, user_id: userAhmet.id,  content: 'I vote for pizza, as always.' };
  const c7 = { id: uuidv4(), event_id: eventLunch.id, parent_id: c5.id, user_id: userDemo.id,  content: 'Yes! I heard great things about it.' };

  insertComment.run(c5);
  insertComment.run(c6);
  insertComment.run(c7);

  // Comment votes
  insertCommentVote.run({ id: uuidv4(), comment_id: c1.id, user_id: userDemo.id });
  insertCommentVote.run({ id: uuidv4(), comment_id: c1.id, user_id: userMehmet.id });
  insertCommentVote.run({ id: uuidv4(), comment_id: c2.id, user_id: userAhmet.id });
  insertCommentVote.run({ id: uuidv4(), comment_id: c5.id, user_id: userAhmet.id });
});

seed();
console.log('Database seeded successfully.');
db.close();
