# FamilyOS — Expo TypeScript

A family management app for parents. Built with Expo SDK 51, TypeScript, Firebase, and Zustand.

## Features

- **Dashboard** — Greeting, children overview, today's events, pending tasks, quick-add FAB
- **Calendar** — Monthly view with multi-dot event markers, child filter chips
- **Tasks** — Tabbed pending/in-progress/done list with swipe-to-complete and priority sorting
- **Kids** — Child profiles with per-child event and task views
- **Smart Inbox** — Paste any school/WhatsApp message; auto-extracts events, dates, amounts, and checklists
- **Profile** — Theme (light/dark/system), language (Hebrew/English), sign out

## Tech Stack

| Layer | Library |
|---|---|
| Framework | Expo SDK 51, expo-router v3 |
| Language | TypeScript (strict) |
| State | Zustand v4 |
| Backend | Firebase Auth + Firestore (JS SDK v10) |
| UI | React Native + expo-blur + expo-linear-gradient |
| Gestures | react-native-gesture-handler (swipe tasks) |
| Calendar | react-native-calendars |
| Haptics | expo-haptics |
| Dates | date-fns |

## Setup

### 1. Install dependencies

```bash
cd family_os_expo
npm install
```

### 2. Configure Firebase

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable **Email/Password** authentication
3. Create a **Firestore** database (start in test mode or apply the rules below)
4. Copy your Firebase config and paste it into `services/firebase.ts`:

```typescript
const firebaseConfig = {
  apiKey: "YOUR_API_KEY",
  authDomain: "YOUR_PROJECT.firebaseapp.com",
  projectId: "YOUR_PROJECT_ID",
  storageBucket: "YOUR_PROJECT.appspot.com",
  messagingSenderId: "YOUR_SENDER_ID",
  appId: "YOUR_APP_ID",
};
```

### 3. Firestore Security Rules

Deploy these rules in the Firebase console:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isFamilyMember(familyId) {
      return request.auth != null &&
        exists(/databases/$(database)/documents/families/$(familyId)) &&
        request.auth.uid in get(/databases/$(database)/documents/families/$(familyId)).data.members.map(m, m.userId);
    }
    match /users/{uid} {
      allow read, write: if request.auth.uid == uid;
    }
    match /families/{familyId} {
      allow read: if isFamilyMember(familyId);
      allow create: if request.auth != null;
      allow update: if isFamilyMember(familyId);
      match /children/{childId} {
        allow read, write: if isFamilyMember(familyId);
      }
      match /events/{eventId} {
        allow read, write: if isFamilyMember(familyId);
      }
      match /tasks/{taskId} {
        allow read, write: if isFamilyMember(familyId);
      }
    }
  }
}
```

### 4. Run with Expo Go

```bash
npx expo start
```

Scan the QR code with **Expo Go** (iOS App Store / Google Play).

## Project Structure

```
family_os_expo/
├── app/
│   ├── _layout.tsx          # Root layout — auth listener, Firestore subscriptions
│   ├── onboarding.tsx       # 3-page onboarding carousel
│   ├── (auth)/
│   │   ├── login.tsx
│   │   ├── register.tsx
│   │   ├── create-family.tsx
│   │   └── add-child.tsx
│   └── (app)/
│       ├── index.tsx        # Dashboard
│       ├── calendar.tsx
│       ├── tasks.tsx
│       ├── kids/
│       │   ├── index.tsx
│       │   └── [id].tsx     # Child detail
│       ├── profile.tsx
│       ├── add-event.tsx    # Modal — event form
│       ├── add-task.tsx     # Modal — task form
│       └── inbox.tsx        # Smart inbox parser
├── components/
│   ├── GlassCard.tsx
│   ├── Card.tsx
│   ├── TaskTile.tsx         # Swipeable task row
│   ├── ChildCard.tsx
│   ├── EventTile.tsx
│   ├── ShimmerLoader.tsx
│   └── EmptyState.tsx
├── models/index.ts          # TypeScript interfaces
├── services/
│   ├── firebase.ts          # Firebase init
│   ├── firebaseService.ts   # Firestore CRUD + Auth
│   └── parserService.ts     # Smart message parser
├── store/index.ts           # Zustand stores
└── utils/
    ├── theme.ts             # Colors, Spacing, Radius, FontSize
    ├── constants.ts         # Firestore collection names
    └── helpers.ts           # formatDate, haptic, etc.
```

## Smart Inbox Parser

The inbox understands Hebrew and English:

| Input | Detected |
|---|---|
| `מחר יש מבחן ב-09:00` | Test event tomorrow at 09:00 |
| `טיול ביום שישי, חזור ב-17:00, ₪80` | Trip event Friday, returns 17:00, ₪80 |
| `Reminder: - milk\n- bread\n- eggs` | 3 tasks (checklist items) |
| `15/03 swimming class at 16:30` | Activity event on 15 March at 16:30 |
