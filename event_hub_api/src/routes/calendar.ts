import { Router, Request, Response } from 'express';
import db from '../db';

const router = Router();

function toICSDate(iso: string): string {
  // Convert ISO 8601 string to ICS UTC format: YYYYMMDDTHHmmssZ
  return iso.replace(/[-:]/g, '').replace(/\.\d+/, '');
}

function escapeICS(value: string): string {
  return value
    .replace(/\\/g, '\\\\')
    .replace(/;/g, '\\;')
    .replace(/,/g, '\\,')
    .replace(/\n/g, '\\n');
}

// ── GET /api/events/:id/calendar.ics ─────────────────────────────────────────

router.get('/events/:id/calendar.ics', (req: Request, res: Response) => {
  const { id } = req.params;

  const event = db.prepare('SELECT * FROM events WHERE id = ?').get(id) as
    | Record<string, string | null>
    | undefined;

  if (!event) {
    res.status(404).json({ error: 'Event not found' });
    return;
  }

  if (event.status !== 'finalized') {
    res.status(400).json({ error: 'Only finalized events can be exported to calendar' });
    return;
  }

  const now = toICSDate(new Date().toISOString());
  const dtStart = event.final_date ? toICSDate(event.final_date) : now;

  // Default duration: 2 hours if no explicit end date
  const startMs = event.final_date ? new Date(event.final_date).getTime() : Date.now();
  const dtEnd = toICSDate(new Date(startMs + 2 * 60 * 60 * 1000).toISOString());

  const lines = [
    'BEGIN:VCALENDAR',
    'VERSION:2.0',
    'PRODID:-//Event Hub//EventHub//EN',
    'CALSCALE:GREGORIAN',
    'METHOD:PUBLISH',
    'BEGIN:VEVENT',
    `UID:${event.id}@eventhub`,
    `DTSTAMP:${now}`,
    `DTSTART:${dtStart}`,
    `DTEND:${dtEnd}`,
    `SUMMARY:${escapeICS(event.title ?? '')}`,
  ];

  if (event.description) {
    lines.push(`DESCRIPTION:${escapeICS(event.description)}`);
  }
  if (event.final_location) {
    lines.push(`LOCATION:${escapeICS(event.final_location)}`);
  }
  if (event.final_details) {
    lines.push(`COMMENT:${escapeICS(event.final_details)}`);
  }

  lines.push('END:VEVENT', 'END:VCALENDAR');

  const icsContent = lines.join('\r\n');

  res.setHeader('Content-Type', 'text/calendar; charset=utf-8');
  res.setHeader('Content-Disposition', `attachment; filename="${id}.ics"`);
  res.send(icsContent);
});

export default router;
