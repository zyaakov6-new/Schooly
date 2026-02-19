import React from 'react';
import { View, Text, StyleSheet, ScrollView, Pressable, Switch, Alert, useColorScheme } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { router } from 'expo-router';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { firebaseService } from '../../services/firebaseService';
import { useAppStore, useFamilyStore } from '../../store';
import { Colors, FontSize, Spacing, Radius } from '../../utils/theme';

export default function ProfileScreen() {
  const dark      = useColorScheme() === 'dark';
  const bg        = dark ? Colors.darkBg   : Colors.lightBg;
  const cardBg    = dark ? Colors.darkCard : Colors.lightCard;
  const txt       = dark ? Colors.darkText : Colors.lightText;
  const muted     = dark ? Colors.darkMuted : Colors.lightMuted;

  const user       = useAppStore(s => s.user);
  const themeMode  = useAppStore(s => s.themeMode);
  const locale     = useAppStore(s => s.locale);
  const setTheme   = useAppStore(s => s.setTheme);
  const setLocale  = useAppStore(s => s.setLocale);
  const family     = useFamilyStore(s => s.family);
  const setFamilyId = useAppStore(s => s.setFamilyId);

  const initial = user?.displayName?.[0]?.toUpperCase() ?? user?.email?.[0]?.toUpperCase() ?? '?';

  const signOut = async () => {
    Alert.alert('התנתקות', 'האם אתה בטוח?', [
      { text: 'ביטול', style: 'cancel' },
      {
        text: 'התנתק', style: 'destructive',
        onPress: async () => {
          await AsyncStorage.clear();
          await firebaseService.logout();
          router.replace('/(auth)/login');
        },
      },
    ]);
  };

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: bg }}>
      <ScrollView contentContainerStyle={{ paddingBottom: 40 }}>
        <Text style={[styles.title, { color: txt, paddingHorizontal: Spacing.lg, paddingTop: Spacing.lg }]}>פרופיל</Text>

        {/* Avatar */}
        <View style={styles.avatarSection}>
          <View style={styles.avatar}>
            <Text style={styles.avatarText}>{initial}</Text>
          </View>
          <Text style={[styles.displayName, { color: txt }]}>{user?.displayName ?? 'הורה'}</Text>
          <Text style={[styles.email, { color: muted }]}>{user?.email}</Text>
          {family && (
            <View style={styles.familyBadge}>
              <Text style={styles.familyBadgeTxt}>🏠 {family.name}</Text>
            </View>
          )}
        </View>

        {/* Appearance */}
        <SettingsSection title="מראה" cardBg={cardBg}>
          <SettingsRow icon="🎨" label="ערכת נושא" cardBg={cardBg} txt={txt}>
            <View style={styles.segmented}>
              {(['system','light','dark'] as const).map(m => (
                <Pressable key={m} onPress={() => setTheme(m)}
                  style={[styles.segment, themeMode === m && styles.segmentActive]}>
                  <Text style={[styles.segmentTxt, themeMode === m && { color: '#fff' }]}>
                    {m === 'system' ? '⚙' : m === 'light' ? '☀' : '🌙'}
                  </Text>
                </Pressable>
              ))}
            </View>
          </SettingsRow>
          <SettingsRow icon="🌐" label="שפה" cardBg={cardBg} txt={txt}>
            <View style={styles.segmented}>
              {(['he','en'] as const).map(l => (
                <Pressable key={l} onPress={() => setLocale(l)}
                  style={[styles.segment, locale === l && styles.segmentActive]}>
                  <Text style={[styles.segmentTxt, locale === l && { color: '#fff' }]}>{l === 'he' ? 'עב' : 'EN'}</Text>
                </Pressable>
              ))}
            </View>
          </SettingsRow>
        </SettingsSection>

        {/* Family */}
        <SettingsSection title="משפחה" cardBg={cardBg}>
          {family && (
            <SettingsRow icon="🔑" label={`קוד הזמנה: ${family.inviteCode}`} cardBg={cardBg} txt={txt}>
              <Text style={{ color: Colors.accent }}>›</Text>
            </SettingsRow>
          )}
          <SettingsRow icon="👥" label="הזמן שותף" cardBg={cardBg} txt={txt} onPress={() => {}}>
            <Text style={{ color: muted }}>›</Text>
          </SettingsRow>
        </SettingsSection>

        {/* Notifications */}
        <SettingsSection title="התראות" cardBg={cardBg}>
          <SettingsRow icon="🔔" label="סיכום יומי" cardBg={cardBg} txt={txt}>
            <Switch value={true} onValueChange={() => {}} trackColor={{ true: Colors.accent }} />
          </SettingsRow>
          <SettingsRow icon="⏰" label="תזכורות משימות" cardBg={cardBg} txt={txt}>
            <Switch value={true} onValueChange={() => {}} trackColor={{ true: Colors.accent }} />
          </SettingsRow>
        </SettingsSection>

        {/* Sign out */}
        <Pressable onPress={signOut} style={[styles.signOutBtn, { borderColor: Colors.error + '55' }]}>
          <Text style={{ color: Colors.error, fontWeight: '700', fontSize: FontSize.base }}>התנתק</Text>
        </Pressable>

        <Text style={[styles.version, { color: muted }]}>FamilyOS v1.0.0</Text>
      </ScrollView>
    </SafeAreaView>
  );
}

function SettingsSection({ title, children, cardBg }: { title: string; children: React.ReactNode; cardBg: string }) {
  const muted = useColorScheme() === 'dark' ? Colors.darkMuted : Colors.lightMuted;
  return (
    <View style={{ marginBottom: Spacing.md }}>
      <Text style={[styles.sectionLabel, { color: muted }]}>{title}</Text>
      <View style={[styles.sectionCard, { backgroundColor: cardBg }]}>{children}</View>
    </View>
  );
}

function SettingsRow({ icon, label, children, cardBg, txt, onPress }:
  { icon: string; label: string; children: React.ReactNode; cardBg: string; txt: string; onPress?: () => void }) {
  return (
    <Pressable onPress={onPress} style={styles.settingsRow}>
      <Text style={{ fontSize: 20, width: 30 }}>{icon}</Text>
      <Text style={[styles.settingsLabel, { color: txt }]}>{label}</Text>
      {children}
    </Pressable>
  );
}

const styles = StyleSheet.create({
  title: { fontSize: FontSize['2xl'], fontWeight: '800', marginBottom: Spacing.sm },
  avatarSection: { alignItems: 'center', paddingVertical: Spacing.xl },
  avatar: {
    width: 80, height: 80, borderRadius: 24,
    backgroundColor: Colors.accent, alignItems: 'center', justifyContent: 'center',
    marginBottom: 12,
  },
  avatarText: { fontSize: 32, fontWeight: '800', color: '#fff' },
  displayName: { fontSize: FontSize.xl, fontWeight: '700' },
  email:       { fontSize: FontSize.md, marginTop: 2 },
  familyBadge: {
    marginTop: 10, backgroundColor: Colors.accent + '22',
    paddingHorizontal: 14, paddingVertical: 6, borderRadius: Radius.full,
  },
  familyBadgeTxt: { color: Colors.accent, fontWeight: '600', fontSize: FontSize.sm },
  sectionLabel: { fontSize: FontSize.xs, letterSpacing: 1.2, fontWeight: '600', paddingHorizontal: Spacing.lg, marginBottom: 6 },
  sectionCard: { marginHorizontal: Spacing.lg, borderRadius: Radius.lg },
  settingsRow: { flexDirection: 'row', alignItems: 'center', padding: 14, gap: 12 },
  settingsLabel: { flex: 1, fontSize: FontSize.md, fontWeight: '500' },
  segmented: { flexDirection: 'row', borderRadius: 8, overflow: 'hidden', borderWidth: 1, borderColor: Colors.lightBorder },
  segment: { paddingHorizontal: 12, paddingVertical: 6 },
  segmentActive: { backgroundColor: Colors.accent },
  segmentTxt: { fontWeight: '700', fontSize: 13, color: Colors.lightMuted },
  signOutBtn: {
    marginHorizontal: Spacing.lg, marginTop: Spacing.sm, padding: 16,
    borderRadius: Radius.lg, borderWidth: 1.5, alignItems: 'center',
  },
  version: { textAlign: 'center', marginTop: Spacing.xl, fontSize: FontSize.sm },
});
