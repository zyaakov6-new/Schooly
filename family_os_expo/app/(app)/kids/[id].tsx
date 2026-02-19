import React from 'react';
import { View, Text, StyleSheet, ScrollView, Pressable, useColorScheme } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useLocalSearchParams, router } from 'expo-router';
import { LinearGradient } from 'expo-linear-gradient';
import { useChildrenStore, useEventsStore, useTasksStore, useAppStore } from '../../../store';
import { Colors, FontSize, Spacing, Radius, cardShadow } from '../../../utils/theme';
import { hexToRgba } from '../../../utils/helpers';
import EventTile from '../../../components/EventTile';
import TaskTile from '../../../components/TaskTile';
import EmptyState from '../../../components/EmptyState';

export default function ChildDetailScreen() {
  const dark     = useColorScheme() === 'dark';
  const bg       = dark ? Colors.darkBg   : Colors.lightBg;
  const txt      = dark ? Colors.darkText : Colors.lightText;
  const { id }   = useLocalSearchParams<{ id: string }>();
  const familyId = useAppStore(s => s.familyId) ?? '';

  const child    = useChildrenStore(s => s.children.find(c => c.id === id));
  const events   = useEventsStore(s => s.events.filter(e => e.childId === id).sort((a,b) => a.startDate.getTime() - b.startDate.getTime()));
  const tasks    = useTasksStore(s => s.tasks.filter(t => t.childId === id && t.status !== 'done'));

  if (!child) return <View style={{ flex: 1, backgroundColor: bg }} />;

  const color = child.colorHex;

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: bg }} edges={['bottom']}>
      <ScrollView contentContainerStyle={{ paddingBottom: 100 }}>
        {/* Hero */}
        <LinearGradient colors={[color + 'CC', color]} style={styles.hero}>
          <Pressable onPress={() => router.back()} style={styles.backBtn}>
            <Text style={styles.backTxt}>→</Text>
          </Pressable>
          <View style={[styles.avatar, { backgroundColor: 'rgba(255,255,255,0.2)' }]}>
            <Text style={{ fontSize: 40 }}>{child.emoji}</Text>
          </View>
          <Text style={styles.heroName}>{child.name}</Text>
          <Text style={styles.heroSub}>{child.age} שנים · {child.school} · {child.className}</Text>
        </LinearGradient>

        {/* Stats */}
        <View style={styles.statsRow}>
          {[
            { label: 'אירועים', value: events.length, icon: '📅', color: color },
            { label: 'משימות',  value: tasks.length,  icon: '✅', color: Colors.warning },
            { label: 'גיל',     value: child.age,     icon: '🎂', color: Colors.success },
          ].map(s => (
            <View key={s.label} style={[styles.statCard, { backgroundColor: dark ? Colors.darkCard : Colors.lightCard }, cardShadow(dark)]}>
              <Text style={{ fontSize: 20 }}>{s.icon}</Text>
              <Text style={[styles.statValue, { color: s.color }]}>{s.value}</Text>
              <Text style={[styles.statLabel, { color: dark ? Colors.darkMuted : Colors.lightMuted }]}>{s.label}</Text>
            </View>
          ))}
        </View>

        {/* Quick actions */}
        <View style={styles.actionsRow}>
          <Pressable onPress={() => router.push(`/(app)/add-event?childId=${id}`)} style={[styles.actionBtn, { borderColor: color + '66' }]}>
            <Text style={[styles.actionTxt, { color }]}>+ אירוע</Text>
          </Pressable>
          <Pressable onPress={() => router.push(`/(app)/add-task?childId=${id}`)} style={[styles.actionBtn, { borderColor: Colors.warning + '66' }]}>
            <Text style={[styles.actionTxt, { color: Colors.warning }]}>+ משימה</Text>
          </Pressable>
        </View>

        {/* Upcoming Events */}
        {events.length > 0 && (
          <>
            <SectionTitle title="אירועים קרובים" />
            {events.slice(0, 5).map(e => <EventTile key={e.id} event={e} />)}
          </>
        )}

        {/* Pending Tasks */}
        {tasks.length > 0 && (
          <>
            <SectionTitle title="משימות ממתינות" />
            {tasks.map(t => <TaskTile key={t.id} task={t} />)}
          </>
        )}

        {events.length === 0 && tasks.length === 0 && (
          <EmptyState emoji="🌟" title="הכל מסודר!" subtitle="אין אירועים או משימות לילד זה עדיין." />
        )}

        {/* Allergies */}
        {child.allergies && (
          <View style={[styles.alertBox]}>
            <Text style={styles.alertTitle}>⚠️ אלרגיות ורפואה</Text>
            <Text style={[styles.alertBody, { color: txt }]}>{child.allergies}</Text>
          </View>
        )}
      </ScrollView>
    </SafeAreaView>
  );
}

function SectionTitle({ title }: { title: string }) {
  const dark = useColorScheme() === 'dark';
  return (
    <Text style={[styles.sectionTitle, { color: dark ? Colors.darkText : Colors.lightText }]}>{title}</Text>
  );
}

const styles = StyleSheet.create({
  hero: { padding: Spacing.xl, paddingTop: 60, alignItems: 'center', gap: 8 },
  backBtn: { position: 'absolute', top: 56, right: 16, padding: 8 },
  backTxt: { fontSize: 22, color: '#fff' },
  avatar: { width: 80, height: 80, borderRadius: 24, alignItems: 'center', justifyContent: 'center', borderWidth: 2, borderColor: 'rgba(255,255,255,0.8)' },
  heroName: { fontSize: FontSize['2xl'], fontWeight: '800', color: '#fff' },
  heroSub:  { fontSize: FontSize.sm, color: 'rgba(255,255,255,0.85)' },
  statsRow: { flexDirection: 'row', gap: 12, paddingHorizontal: Spacing.lg, marginTop: Spacing.lg },
  statCard: { flex: 1, alignItems: 'center', padding: 14, borderRadius: Radius.lg, gap: 4 },
  statValue: { fontSize: FontSize['2xl'], fontWeight: '800' },
  statLabel: { fontSize: FontSize.xs },
  actionsRow: { flexDirection: 'row', gap: 12, paddingHorizontal: Spacing.lg, marginTop: Spacing.md },
  actionBtn: { flex: 1, borderWidth: 1.5, borderRadius: Radius.md, padding: 12, alignItems: 'center' },
  actionTxt: { fontWeight: '700', fontSize: FontSize.md },
  sectionTitle: { fontSize: FontSize.lg, fontWeight: '700', paddingHorizontal: Spacing.lg, marginTop: Spacing.xl, marginBottom: Spacing.sm },
  alertBox: { marginHorizontal: Spacing.lg, marginTop: Spacing.lg, padding: 16, borderRadius: Radius.lg, backgroundColor: Colors.error + '18', borderWidth: 1, borderColor: Colors.error + '44' },
  alertTitle: { fontSize: FontSize.md, fontWeight: '700', color: Colors.error, marginBottom: 4 },
  alertBody: { fontSize: FontSize.sm },
});
