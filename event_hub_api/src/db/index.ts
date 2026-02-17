import Database from 'better-sqlite3';
import path from 'path';
import { runSchema } from './schema';

const DB_PATH = path.resolve(__dirname, '../../event_hub.db');

const db = new Database(DB_PATH);

// Enable WAL mode for better concurrent read performance
db.pragma('journal_mode = WAL');
db.pragma('foreign_keys = ON');

// Initialize schema on startup
runSchema(db);

export default db;
