import {
  collection, doc, setDoc, addDoc, updateDoc, deleteDoc,
  getDoc, getDocs, query, where, orderBy, limit,
  onSnapshot, serverTimestamp, Timestamp, type Unsubscribe,
} from 'firebase/firestore';
import {
  createUserWithEmailAndPassword, signInWithEmailAndPassword,
  signOut, updateProfile, sendPasswordResetEmail,
  onAuthStateChanged, type User,
} from 'firebase/auth';
import { auth, db } from './firebase';
import {
  type Child, type FamilyEvent, type FamilyTask,
  type Family, type FamilyMember,
} from '../models';
import { COLLECTIONS } from '../utils/constants';
import { generateInviteCode } from '../utils/helpers';

// ─── Firestore converters ─────────────────────────────────────────────────────

function toDate(v: unknown): Date {
  if (v instanceof Timestamp) return v.toDate();
  if (v instanceof Date) return v;
  return new Date();
}

function childFromDoc(d: any): Child {
  const data = d.data();
  return { ...data, id: d.id, createdAt: toDate(data.createdAt) };
}

function eventFromDoc(d: any): FamilyEvent {
  const data = d.data();
  return {
    ...data, id: d.id,
    startDate: toDate(data.startDate),
    endDate:   data.endDate ? toDate(data.endDate) : undefined,
    createdAt: toDate(data.createdAt),
  };
}

function taskFromDoc(d: any): FamilyTask {
  const data = d.data();
  return {
    ...data, id: d.id,
    dueDate:      data.dueDate      ? toDate(data.dueDate)      : undefined,
    reminderDate: data.reminderDate ? toDate(data.reminderDate) : undefined,
    completedAt:  data.completedAt  ? toDate(data.completedAt)  : undefined,
    createdAt: toDate(data.createdAt),
  };
}

function familyFromDoc(d: any): Family {
  const data = d.data();
  return {
    ...data, id: d.id,
    createdAt: toDate(data.createdAt),
    members: (data.members ?? []).map((m: any) => ({
      ...m, joinedAt: toDate(m.joinedAt),
    })),
  };
}

// ─── Auth ─────────────────────────────────────────────────────────────────────

export const firebaseService = {
  // Auth
  currentUser: () => auth.currentUser,

  onAuthChange: (cb: (u: User | null) => void): Unsubscribe =>
    onAuthStateChanged(auth, cb),

  register: async (email: string, password: string, name: string) => {
    const cred = await createUserWithEmailAndPassword(auth, email, password);
    await updateProfile(cred.user, { displayName: name });
    return cred.user;
  },

  login: (email: string, password: string) =>
    signInWithEmailAndPassword(auth, email, password),

  logout: () => signOut(auth),

  resetPassword: (email: string) => sendPasswordResetEmail(auth, email),

  // ─── Family ────────────────────────────────────────────────────────────────

  createFamily: async (name: string): Promise<Family> => {
    const user = auth.currentUser!;
    const member: FamilyMember = {
      userId: user.uid,
      name: user.displayName ?? 'Parent',
      email: user.email ?? undefined,
      role: 'admin',
      joinedAt: new Date(),
    };
    const ref = doc(collection(db, COLLECTIONS.families));
    const family: Omit<Family, 'id'> = {
      name,
      members: [member],
      inviteCode: generateInviteCode(),
      primaryLanguage: 'he',
      createdAt: new Date(),
    };
    await setDoc(ref, {
      ...family,
      createdAt: serverTimestamp(),
      members: [{ ...member, joinedAt: serverTimestamp() }],
    });
    // Store familyId on user doc
    await setDoc(doc(db, COLLECTIONS.users, user.uid), { familyId: ref.id }, { merge: true });
    return { ...family, id: ref.id };
  },

  getUserFamilyId: async (uid: string): Promise<string | null> => {
    const snap = await getDoc(doc(db, COLLECTIONS.users, uid));
    return snap.exists() ? (snap.data().familyId as string) : null;
  },

  getFamilyByCode: async (code: string): Promise<Family | null> => {
    const q = query(
      collection(db, COLLECTIONS.families),
      where('inviteCode', '==', code.toUpperCase()),
      limit(1),
    );
    const snap = await getDocs(q);
    if (snap.empty) return null;
    return familyFromDoc(snap.docs[0]);
  },

  joinFamily: async (familyId: string) => {
    const user = auth.currentUser!;
    const member: FamilyMember = {
      userId: user.uid,
      name: user.displayName ?? 'Parent',
      email: user.email ?? undefined,
      role: 'parent',
      joinedAt: new Date(),
    };
    const ref = doc(db, COLLECTIONS.families, familyId);
    const snap = await getDoc(ref);
    const existing: FamilyMember[] = snap.data()?.members ?? [];
    await updateDoc(ref, {
      members: [...existing, { ...member, joinedAt: serverTimestamp() }],
    });
    await setDoc(doc(db, COLLECTIONS.users, user.uid), { familyId }, { merge: true });
  },

  watchFamily: (familyId: string, cb: (f: Family | null) => void): Unsubscribe =>
    onSnapshot(doc(db, COLLECTIONS.families, familyId), (snap) =>
      cb(snap.exists() ? familyFromDoc(snap) : null)),

  // ─── Children ──────────────────────────────────────────────────────────────

  watchChildren: (familyId: string, cb: (c: Child[]) => void): Unsubscribe =>
    onSnapshot(
      query(collection(db, COLLECTIONS.families, familyId, COLLECTIONS.children), orderBy('createdAt')),
      (snap) => cb(snap.docs.map(childFromDoc)),
    ),

  addChild: async (familyId: string, child: Omit<Child, 'id'>): Promise<Child> => {
    const ref = doc(collection(db, COLLECTIONS.families, familyId, COLLECTIONS.children));
    await setDoc(ref, { ...child, createdAt: serverTimestamp() });
    return { ...child, id: ref.id };
  },

  updateChild: (familyId: string, child: Child) =>
    updateDoc(doc(db, COLLECTIONS.families, familyId, COLLECTIONS.children, child.id), {
      ...child, createdAt: Timestamp.fromDate(child.createdAt),
    }),

  deleteChild: (familyId: string, childId: string) =>
    deleteDoc(doc(db, COLLECTIONS.families, familyId, COLLECTIONS.children, childId)),

  // ─── Events ────────────────────────────────────────────────────────────────

  watchEvents: (familyId: string, cb: (e: FamilyEvent[]) => void): Unsubscribe =>
    onSnapshot(
      query(
        collection(db, COLLECTIONS.families, familyId, COLLECTIONS.events),
        orderBy('startDate'),
        limit(200),
      ),
      (snap) => cb(snap.docs.map(eventFromDoc)),
    ),

  addEvent: async (familyId: string, event: Omit<FamilyEvent, 'id'>): Promise<FamilyEvent> => {
    const ref = doc(collection(db, COLLECTIONS.families, familyId, COLLECTIONS.events));
    await setDoc(ref, {
      ...event,
      startDate: Timestamp.fromDate(event.startDate),
      endDate: event.endDate ? Timestamp.fromDate(event.endDate) : null,
      createdAt: serverTimestamp(),
    });
    return { ...event, id: ref.id };
  },

  updateEvent: (familyId: string, event: FamilyEvent) =>
    updateDoc(doc(db, COLLECTIONS.families, familyId, COLLECTIONS.events, event.id), {
      ...event,
      startDate: Timestamp.fromDate(event.startDate),
      endDate: event.endDate ? Timestamp.fromDate(event.endDate) : null,
      createdAt: Timestamp.fromDate(event.createdAt),
    }),

  deleteEvent: (familyId: string, eventId: string) =>
    deleteDoc(doc(db, COLLECTIONS.families, familyId, COLLECTIONS.events, eventId)),

  // ─── Tasks ─────────────────────────────────────────────────────────────────

  watchTasks: (familyId: string, cb: (t: FamilyTask[]) => void): Unsubscribe =>
    onSnapshot(
      query(
        collection(db, COLLECTIONS.families, familyId, COLLECTIONS.tasks),
        orderBy('createdAt', 'desc'),
        limit(100),
      ),
      (snap) => cb(snap.docs.map(taskFromDoc)),
    ),

  addTask: async (familyId: string, task: Omit<FamilyTask, 'id'>): Promise<FamilyTask> => {
    const ref = doc(collection(db, COLLECTIONS.families, familyId, COLLECTIONS.tasks));
    await setDoc(ref, {
      ...task,
      dueDate: task.dueDate ? Timestamp.fromDate(task.dueDate) : null,
      createdAt: serverTimestamp(),
    });
    return { ...task, id: ref.id };
  },

  updateTask: (familyId: string, task: FamilyTask) =>
    updateDoc(doc(db, COLLECTIONS.families, familyId, COLLECTIONS.tasks, task.id), {
      ...task,
      dueDate:     task.dueDate     ? Timestamp.fromDate(task.dueDate)     : null,
      completedAt: task.completedAt ? Timestamp.fromDate(task.completedAt) : null,
      createdAt:   Timestamp.fromDate(task.createdAt),
    }),

  completeTask: (familyId: string, taskId: string) =>
    updateDoc(doc(db, COLLECTIONS.families, familyId, COLLECTIONS.tasks, taskId), {
      status: 'done',
      completedAt: serverTimestamp(),
    }),

  snoozeTask: (familyId: string, taskId: string) =>
    updateDoc(doc(db, COLLECTIONS.families, familyId, COLLECTIONS.tasks, taskId), {
      status: 'snoozed',
    }),

  deleteTask: (familyId: string, taskId: string) =>
    deleteDoc(doc(db, COLLECTIONS.families, familyId, COLLECTIONS.tasks, taskId)),
};
