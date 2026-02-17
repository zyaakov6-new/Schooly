import { useEffect } from 'react';
import { Stack, router } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import { useColorScheme } from 'react-native';
import * as SplashScreen from 'expo-splash-screen';
import { useFonts, Inter_400Regular, Inter_500Medium, Inter_600SemiBold, Inter_700Bold } from '@expo-google-fonts/inter';
import { firebaseService } from '../services/firebaseService';
import { useAppStore, useFamilyStore, useChildrenStore, useEventsStore, useTasksStore } from '../store';

SplashScreen.preventAutoHideAsync();

export default function RootLayout() {
  const scheme = useColorScheme();
  const { setUser, setFamilyId, bootstrap, isBootstrapped, user, familyId } = useAppStore();
  const setFamily   = useFamilyStore(s => s.setFamily);
  const setChildren = useChildrenStore(s => s.setChildren);
  const setEvents   = useEventsStore(s => s.setEvents);
  const setTasks    = useTasksStore(s => s.setTasks);

  const [fontsLoaded] = useFonts({
    Inter_400Regular, Inter_500Medium, Inter_600SemiBold, Inter_700Bold,
  });

  // Bootstrap persisted state
  useEffect(() => { bootstrap(); }, []);

  // Firebase Auth listener
  useEffect(() => {
    const unsub = firebaseService.onAuthChange(async (firebaseUser) => {
      setUser(firebaseUser);
      if (firebaseUser) {
        const id = await firebaseService.getUserFamilyId(firebaseUser.uid);
        setFamilyId(id);
      } else {
        setFamilyId(null);
      }
    });
    return unsub;
  }, []);

  // Subscribe to Firestore data once we have a familyId
  useEffect(() => {
    if (!familyId) return;
    const subs = [
      firebaseService.watchFamily(familyId, setFamily),
      firebaseService.watchChildren(familyId, setChildren),
      firebaseService.watchEvents(familyId, setEvents),
      firebaseService.watchTasks(familyId, setTasks),
    ];
    return () => subs.forEach(u => u());
  }, [familyId]);

  // Navigation redirect
  useEffect(() => {
    if (!isBootstrapped || !fontsLoaded) return;
    SplashScreen.hideAsync();

    if (!user) {
      router.replace('/(auth)/login');
    } else if (!familyId) {
      router.replace('/(auth)/create-family');
    } else {
      router.replace('/(app)');
    }
  }, [isBootstrapped, fontsLoaded, user, familyId]);

  if (!isBootstrapped || !fontsLoaded) return null;

  return (
    <GestureHandlerRootView style={{ flex: 1 }}>
      <StatusBar style={scheme === 'dark' ? 'light' : 'dark'} />
      <Stack screenOptions={{ headerShown: false, animation: 'fade' }}>
        <Stack.Screen name="(auth)" />
        <Stack.Screen name="(app)" />
        <Stack.Screen name="onboarding" />
      </Stack>
    </GestureHandlerRootView>
  );
}
