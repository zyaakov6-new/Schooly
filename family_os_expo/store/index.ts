import { create } from 'zustand';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { type User } from 'firebase/auth';
import { firebaseService } from '../services/firebaseService';
import {
  type Child, type Family, type FamilyEvent, type FamilyTask,
  isSameDay,
} from '../models';
import { STORAGE_KEYS } from '../utils/constants';
import { startOfDay } from '../utils/helpers';

// ─── Auth + App Store ─────────────────────────────────────────────────────────

interface AppState {
  user:        User | null;
  familyId:    string | null;
  themeMode:   'system' | 'light' | 'dark';
  locale:      string;
  isBootstrapped: boolean;

  setUser:     (u: User | null) => void;
  setFamilyId: (id: string | null) => void;
  setTheme:    (m: 'system' | 'light' | 'dark') => void;
  setLocale:   (l: string) => void;
  bootstrap:   () => Promise<void>;
}

export const useAppStore = create<AppState>((set, get) => ({
  user:            null,
  familyId:        null,
  themeMode:       'system',
  locale:          'he',
  isBootstrapped:  false,

  setUser:     (user) => set({ user }),
  setFamilyId: async (familyId) => {
    set({ familyId });
    if (familyId) await AsyncStorage.setItem(STORAGE_KEYS.familyId, familyId);
    else          await AsyncStorage.removeItem(STORAGE_KEYS.familyId);
  },
  setTheme: async (themeMode) => {
    set({ themeMode });
    await AsyncStorage.setItem(STORAGE_KEYS.themeMode, themeMode);
  },
  setLocale: async (locale) => {
    set({ locale });
    await AsyncStorage.setItem(STORAGE_KEYS.language, locale);
  },

  bootstrap: async () => {
    const [familyId, theme, lang] = await Promise.all([
      AsyncStorage.getItem(STORAGE_KEYS.familyId),
      AsyncStorage.getItem(STORAGE_KEYS.themeMode),
      AsyncStorage.getItem(STORAGE_KEYS.language),
    ]);
    set({
      familyId:       familyId   ?? null,
      themeMode:      (theme as any) ?? 'system',
      locale:         lang        ?? 'he',
      isBootstrapped: true,
    });
  },
}));

// ─── Family Store ─────────────────────────────────────────────────────────────

interface FamilyState {
  family: Family | null;
  setFamily: (f: Family | null) => void;
}

export const useFamilyStore = create<FamilyState>((set) => ({
  family: null,
  setFamily: (family) => set({ family }),
}));

// ─── Children Store ───────────────────────────────────────────────────────────

interface ChildrenState {
  children:         Child[];
  selectedChildId:  string | null;
  setChildren:      (c: Child[]) => void;
  setSelectedChild: (id: string | null) => void;
}

export const useChildrenStore = create<ChildrenState>((set) => ({
  children:         [],
  selectedChildId:  null,
  setChildren:      (children) => set({ children }),
  setSelectedChild: (selectedChildId) => set({ selectedChildId }),
}));

// ─── Events Store ─────────────────────────────────────────────────────────────

interface EventsState {
  events:     FamilyEvent[];
  setEvents:  (e: FamilyEvent[]) => void;
  todayEvents:    () => FamilyEvent[];
  eventsOnDay:    (d: Date) => FamilyEvent[];
  eventsMap:      () => Record<string, FamilyEvent[]>;
}

export const useEventsStore = create<EventsState>((set, get) => ({
  events: [],
  setEvents: (events) => set({ events }),
  todayEvents: () => {
    const today = new Date();
    return get().events.filter(e => isSameDay(e.startDate, today));
  },
  eventsOnDay: (d) => get().events.filter(e => isSameDay(e.startDate, d)),
  eventsMap: () => {
    const map: Record<string, FamilyEvent[]> = {};
    for (const e of get().events) {
      const key = startOfDay(e.startDate).toISOString();
      (map[key] ??= []).push(e);
    }
    return map;
  },
}));

// ─── Tasks Store ──────────────────────────────────────────────────────────────

interface TasksState {
  tasks:     FamilyTask[];
  setTasks:  (t: FamilyTask[]) => void;
  pending:   () => FamilyTask[];
  overdue:   () => FamilyTask[];
  forChild:  (id: string) => FamilyTask[];
}

export const useTasksStore = create<TasksState>((set, get) => ({
  tasks: [],
  setTasks: (tasks) => set({ tasks }),
  pending: () => get().tasks
    .filter(t => t.status !== 'done')
    .sort((a, b) => {
      const pc = ['urgent','high','medium','low'].indexOf(a.priority) -
                 ['urgent','high','medium','low'].indexOf(b.priority);
      return pc !== 0 ? pc : (a.dueDate?.getTime() ?? Infinity) - (b.dueDate?.getTime() ?? Infinity);
    }),
  overdue: () => {
    const now = new Date();
    return get().tasks.filter(t => t.dueDate && t.dueDate < now && t.status !== 'done');
  },
  forChild: (id) => get().tasks.filter(t => t.childId === id && t.status !== 'done'),
}));
