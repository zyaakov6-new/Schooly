// ─── Child ────────────────────────────────────────────────────────────────────

export const CHILD_COLORS = ['#1976D2','#E91E63','#4CAF50','#FF9800','#9C27B0','#00BCD4'] as const;
export const CHILD_EMOJIS = ['👦','👧','🧒','👶','🎓','⭐'] as const;

export interface Child {
  id: string;
  familyId: string;
  name: string;
  age: number;
  school: string;
  className: string;
  photoUrl?: string;
  allergies?: string;
  medicalNotes?: string;
  colorHex: string;
  emoji: string;
  createdAt: Date;
}

// ─── Event ────────────────────────────────────────────────────────────────────

export type EventType = 'school' | 'test' | 'activity' | 'family' | 'payment' | 'trip';

export const EVENT_META: Record<EventType, { label: string; emoji: string; color: string }> = {
  school:   { label: 'בית ספר', emoji: '🏫', color: '#1976D2' },
  test:     { label: 'מבחן',    emoji: '📝', color: '#EF4444' },
  activity: { label: 'פעילות',  emoji: '⚽', color: '#10B981' },
  family:   { label: 'משפחה',   emoji: '👨‍👩‍👧‍👦', color: '#F59E0B' },
  payment:  { label: 'תשלום',   emoji: '💰', color: '#8B5CF6' },
  trip:     { label: 'טיול',    emoji: '🚌', color: '#06B6D4' },
};

export interface FamilyEvent {
  id: string;
  familyId: string;
  title: string;
  startDate: Date;
  endDate?: Date;
  childId?: string;
  type: EventType;
  location?: string;
  notes?: string;
  amount?: number;
  isRecurring?: boolean;
  createdAt: Date;
  createdBy: string;
}

// ─── Task ─────────────────────────────────────────────────────────────────────

export type TaskPriority = 'low' | 'medium' | 'high' | 'urgent';
export type TaskStatus   = 'pending' | 'inProgress' | 'done' | 'snoozed';

export const PRIORITY_META: Record<TaskPriority, { label: string; color: string }> = {
  low:    { label: 'נמוכה',  color: '#10B981' },
  medium: { label: 'בינונית', color: '#F59E0B' },
  high:   { label: 'גבוהה',  color: '#EF4444' },
  urgent: { label: 'דחוף',   color: '#DC2626' },
};

export interface FamilyTask {
  id: string;
  familyId: string;
  title: string;
  description?: string;
  dueDate?: Date;
  childId?: string;
  assigneeId?: string;
  priority: TaskPriority;
  status: TaskStatus;
  reminderDate?: Date;
  amount?: number;
  items?: string[];
  createdAt: Date;
  createdBy: string;
  completedAt?: Date;
}

// ─── Family ───────────────────────────────────────────────────────────────────

export type MemberRole = 'admin' | 'parent' | 'viewer';

export interface FamilyMember {
  userId: string;
  name: string;
  email?: string;
  photoUrl?: string;
  role: MemberRole;
  joinedAt: Date;
}

export interface Family {
  id: string;
  name: string;
  members: FamilyMember[];
  inviteCode: string;
  primaryLanguage: string;
  createdAt: Date;
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

export function isTaskDone(t: FamilyTask) { return t.status === 'done'; }
export function isTaskOverdue(t: FamilyTask) {
  return !!t.dueDate && t.dueDate < new Date() && !isTaskDone(t);
}
export function isSameDay(a: Date, b: Date) {
  return a.getFullYear() === b.getFullYear() &&
         a.getMonth()    === b.getMonth()    &&
         a.getDate()     === b.getDate();
}
