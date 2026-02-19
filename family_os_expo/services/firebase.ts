// services/firebase.ts
// Replace the config object with your own from Firebase Console →
// Project Settings → Your apps → SDK setup and configuration
import { initializeApp, getApps, getApp } from 'firebase/app';
import { initializeAuth, getAuth, getReactNativePersistence } from 'firebase/auth';
import { getFirestore } from 'firebase/firestore';
import { getStorage } from 'firebase/storage';
import AsyncStorage from '@react-native-async-storage/async-storage';

const firebaseConfig = {
  apiKey:            'YOUR_API_KEY',
  authDomain:        'YOUR_PROJECT.firebaseapp.com',
  projectId:         'YOUR_PROJECT_ID',
  storageBucket:     'YOUR_PROJECT.appspot.com',
  messagingSenderId: 'YOUR_SENDER_ID',
  appId:             'YOUR_APP_ID',
};

// Only initialise once (hot-reload safe).
// initializeAuth must only be called on the very first initialisation;
// subsequent hot-reloads must use getAuth() on the existing app.
const isFirstInit = getApps().length === 0;
const app = isFirstInit ? initializeApp(firebaseConfig) : getApp();

export const auth = isFirstInit
  ? initializeAuth(app, { persistence: getReactNativePersistence(AsyncStorage) })
  : getAuth(app);

export const db      = getFirestore(app);
export const storage = getStorage(app);
// Note: React Native Firestore uses its own persistence layer automatically.
// enableIndexedDbPersistence is web-only and must not be called here.
