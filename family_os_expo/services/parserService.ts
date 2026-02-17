import { type EventType, type FamilyEvent, type FamilyTask } from '../models';

export interface ParseResult {
  events: Omit<FamilyEvent, 'id'>[];
  tasks:  Omit<FamilyTask, 'id'>[];
  items:  string[];
  amount?: number;
  parsedDate?: Date;
}

export function parseMessage(
  text: string,
  opts: { familyId?: string; childId?: string; userId?: string } = {},
): ParseResult {
  const now    = new Date();
  const date   = extractDate(text, now);
  const time   = extractTime(text);
  const amount = extractAmount(text);
  const items  = extractItems(text);
  const type   = detectEventType(text);

  const events: Omit<FamilyEvent, 'id'>[] = [];
  const tasks:  Omit<FamilyTask, 'id'>[]  = [];

  if (date) {
    const startDate = time
      ? new Date(date.getFullYear(), date.getMonth(), date.getDate(), time.h, time.m)
      : date;

    const endTimeMatch = text.match(/(?:חזור|חוזר|return|back)\s*(?:ב|at)?\s*(\d{1,2}):(\d{2})/i);
    const endDate = endTimeMatch
      ? new Date(date.getFullYear(), date.getMonth(), date.getDate(),
                 parseInt(endTimeMatch[1]), parseInt(endTimeMatch[2]))
      : undefined;

    events.push({
      familyId:  opts.familyId  ?? '',
      title:     extractTitle(text),
      startDate, endDate,
      childId:   opts.childId,
      type,
      notes: text,
      amount,
      createdAt:  now,
      createdBy:  opts.userId ?? '',
    });
  }

  for (const item of items) {
    tasks.push({
      familyId:  opts.familyId ?? '',
      title:     item,
      dueDate:   date ?? undefined,
      childId:   opts.childId,
      priority:  'medium',
      status:    'pending',
      createdAt: now,
      createdBy: opts.userId ?? '',
    });
  }

  return { events, tasks, items, amount, parsedDate: date ?? undefined };
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

function extractDate(text: string, now: Date): Date | null {
  if (/\bהיום\b|\btoday\b/i.test(text)) return now;
  if (/\bמחר\b|\btomorrow\b/i.test(text)) return addDays(now, 1);
  if (/\bשבוע הבא\b/i.test(text))          return addDays(now, 7);

  const hebrewDays: Record<string, number> = {
    ראשון: 0, שני: 1, שלישי: 2, רביעי: 3, חמישי: 4, שישי: 5, שבת: 6,
  };
  for (const [name, dow] of Object.entries(hebrewDays)) {
    if (text.includes(name)) {
      const diff = (dow - now.getDay() + 7) % 7 || 7;
      return addDays(now, diff);
    }
  }

  const m = text.match(/\b(\d{1,2})[./](\d{1,2})(?:[./](\d{2,4}))?\b/);
  if (m) {
    const day = parseInt(m[1]), month = parseInt(m[2]) - 1;
    let year = now.getFullYear();
    if (m[3]) { year = parseInt(m[3]); if (year < 100) year += 2000; }
    return new Date(year, month, day);
  }

  return null;
}

function extractTime(text: string): { h: number; m: number } | null {
  const m = text.match(/\b(\d{1,2}):(\d{2})\b/);
  if (!m) return null;
  const h = parseInt(m[1]), mi = parseInt(m[2]);
  if (h > 23 || mi > 59) return null;
  return { h, m: mi };
}

function extractAmount(text: string): number | undefined {
  const m = text.match(/(?:₪|ש["""]{0,1}ח|\$)\s*(\d+(?:\.\d{1,2})?)|(\d+(?:\.\d{1,2})?)\s*(?:₪|ש["""]{0,1}ח)/);
  if (!m) return undefined;
  const raw = m[1] ?? m[2];
  return raw ? parseFloat(raw) : undefined;
}

function extractItems(text: string): string[] {
  const items: string[] = [];
  for (const m of text.matchAll(/(?:^|\n)\s*(?:[-•*]|\d+[.):])\s*(.+)/gm)) {
    const item = m[1]?.trim();
    if (item) items.push(item);
  }
  return items;
}

function detectEventType(text: string): EventType {
  if (/טיול|excursion|trip|field trip/i.test(text))               return 'trip';
  if (/מבחן|בחינה|test|exam|quiz/i.test(text))                    return 'test';
  if (/לשלם|תשלום|pay|payment|fee|דמי/i.test(text))               return 'payment';
  if (/כדורגל|כדורסל|שחייה|ספורט|soccer|football|swim/i.test(text)) return 'activity';
  return 'school';
}

function extractTitle(text: string): string {
  const first = text.split('\n').find(l => l.trim());
  if (!first) return text.slice(0, 50);
  return first.trim().length > 60 ? first.trim().slice(0, 57) + '…' : first.trim();
}

function addDays(d: Date, n: number): Date {
  const r = new Date(d);
  r.setDate(r.getDate() + n);
  return r;
}
