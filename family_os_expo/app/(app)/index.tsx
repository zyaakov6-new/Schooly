import React from 'react';
import {
  View, Text, ScrollView, Pressable, StyleSheet,
  useColorScheme, FlatList,
} from 'react-native';
import { router } from 'expo-router';
import { SafeAreaView } from 'react-native-safe-area-context';
import { format } from 'date-fns';
import { he, enUS } from 'date-fns/locale';
import { useAppStore, useChildrenStore, useEventsStore, useTasksStore } from '../../store';
import { Colors, FontSize, Spacing, Radius } from '../../utils/theme';
import { getGreeting } from '../../utils/helpers';
import ChildCard from '../../components/ChildCard';
import TaskTile from '../../components/TaskTile';
import EventTile from '../../components/EventTile';
import EmptyState from '../../components/EmptyState';
import { TaskShimmer, ChildCardShimmer, EventShimmer } from '../../components/ShimmerLoader';

export default function DashboardScreen() {
  const dark     = useColorScheme() === 'dark';
  const bg       = dark ? Colors.darkBg   : Colors.lightBg;
  const txt      = dark ? Colors.darkText : Colors.lightText;
  const familyId = useAppStore(s => s.familyId) ?? '';
  const locale   = useAppStore(s => s.locale);

  const children   = useChildrenStore(s => s.children);
  const todayEvts  = useEventsStore(s => s.todayEvents());
  const pendingTasks = useTasksStore(s => s.pending()).slice(0, 5);

  const dateLabel = format(new Date(), 'EEEE, d MMMM', { locale: locale === 'he' ? he : enUS });

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: bg }}>
      <ScrollView contentContainerStyle={{ paddingBottom: 100 }} showsVerticalScrollIndicator={false}>

        {/* ── Header ─────────────────────────────────────────────── */}
        <View style={styles.header}>
          <View>
            <Text style={[styles.greeting, { color: Colors.accent }]}>{getGreeting(locale)}</Text>
            <Text style={[styles.dateText, { color: txt }]}>{dateLabel}</Text>
          </View>
          <Pressable onPress={() => {}} style={styles.notifBtn}>
            <Text style={{ fontSize: 22 }}>🔔</Text>
          </Pressable>
        </View>

        {/* ── Children ───────────────────────────────────────────── */}
        <SectionHeader title="My Kids" icon="👨‍👩‍👧‍👦" onAdd={() => router.push('/(auth)/add-child')} />
        {children.length === 0 ? (
          <EmptyState emoji="👶" title="No children yet" subtitle="Add your first child to get started" actionLabel="Add child" onAction={() => router.push('/(auth)/add-child')} />
        ) : (
          <FlatList
            data={[...children, null]}   // null = "add" button
            keyExtractor={(_, i) => String(i)}
            horizontal showsHorizontalScrollIndicator={false}
            contentContainerStyle={{ paddingHorizontal: Spacing.lg, paddingBottom: 4 }}
            renderItem={({ item }) =>
              item === null ? (
                <Pressable onPress={() => router.push('/(auth)/add-child')} style={[styles.addChild, { backgroundColor: dark ? Colors.darkCard : Colors.lightCard, borderColor: Colors.accent + '44' }]}>
                  <Text style={{ fontSize: 28, color: Colors.accent }}>＋</Text>
                  <Text style={{ color: Colors.accent, fontWeight: '600', fontSize: 12, marginTop: 4 }}>Add child</Text>
                </Pressable>
              ) : (
                <ChildCard child={item} onPress={() => router.push(`/(app)/kids/${item.id}`)} />
              )
            }
          />
        )}

        {/* ── Today's Events ─────────────────────────────────────── */}
        <SectionHeader title="Today's Schedule" icon="📅" onAdd={() => router.push('/(app)/add-event')} />
        {todayEvts.length === 0 ? (
          <View style={[styles.emptyCard, { backgroundColor: dark ? Colors.darkCard : Colors.lightCard }]}>
            <Text style={{ fontSize: 28 }}>🎉</Text>
            <Text style={[styles.emptyCardTitle, { color: txt }]}>Free day!</Text>
            <Text style={[styles.emptyCardSub, { color: Colors.lightMuted }]}>No events scheduled for today</Text>
          </View>
        ) : (
          todayEvts.map(e => <EventTile key={e.id} event={e} />)
        )}

        {/* ── Pending Tasks ──────────────────────────────────────── */}
        <SectionHeader title="Pending Tasks" icon="✅" onAdd={() => router.push('/(app)/add-task')} />
        {pendingTasks.length === 0 ? (
          <View style={[styles.emptyCard, { backgroundColor: dark ? Colors.darkCard : Colors.lightCard }]}>
            <Text style={{ fontSize: 28 }}>✅</Text>
            <Text style={[styles.emptyCardTitle, { color: txt }]}>All caught up!</Text>
            <Text style={[styles.emptyCardSub, { color: Colors.lightMuted }]}>No pending tasks</Text>
          </View>
        ) : (
          pendingTasks.map(t => <TaskTile key={t.id} task={t} />)
        )}

      </ScrollView>

      {/* FAB */}
      <Pressable onPress={() => router.push('/(app)/add-event')} style={styles.fab}>
        <Text style={styles.fabText}>＋ Add</Text>
      </Pressable>
    </SafeAreaView>
  );
}

function SectionHeader({ title, icon, onAdd }: { title: string; icon: string; onAdd?: () => void }) {
  const dark = useColorScheme() === 'dark';
  const txt  = dark ? Colors.darkText : Colors.lightText;
  return (
    <View style={styles.sectionHeader}>
      <Text style={{ fontSize: 16 }}>{icon}</Text>
      <Text style={[styles.sectionTitle, { color: txt }]}>{title}</Text>
      {onAdd && (
        <Pressable onPress={onAdd} style={styles.seeAll}>
          <Text style={{ color: Colors.accent, fontSize: 13, fontWeight: '600' }}>+ Add</Text>
        </Pressable>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  header: {
    flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center',
    paddingHorizontal: Spacing.lg, paddingTop: Spacing.lg, paddingBottom: Spacing.md,
  },
  greeting: { fontSize: FontSize.sm, fontWeight: '600' },
  dateText:  { fontSize: FontSize.xl, fontWeight: '800', marginTop: 2 },
  notifBtn: { padding: 8 },
  sectionHeader: {
    flexDirection: 'row', alignItems: 'center', gap: 8,
    paddingHorizontal: Spacing.lg, paddingTop: Spacing.xl, paddingBottom: Spacing.md,
  },
  sectionTitle: { fontSize: FontSize.base, fontWeight: '700', flex: 1 },
  seeAll: { marginLeft: 'auto' },
  emptyCard: {
    marginHorizontal: Spacing.lg, padding: Spacing.lg, borderRadius: Radius.lg,
    flexDirection: 'row', alignItems: 'center', gap: 12,
  },
  emptyCardTitle: { fontSize: FontSize.md, fontWeight: '700' },
  emptyCardSub:   { fontSize: FontSize.sm },
  addChild: {
    width: 100, height: 148, borderRadius: 20,
    borderWidth: 1.5, borderStyle: 'dashed',
    alignItems: 'center', justifyContent: 'center',
    marginRight: 12,
  },
  fab: {
    position: 'absolute', bottom: 80, right: 20,
    backgroundColor: Colors.accent,
    paddingHorizontal: 20, paddingVertical: 14,
    borderRadius: Radius.full,
    shadowColor: Colors.accent, shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.5, shadowRadius: 12, elevation: 8,
  },
  fabText: { color: '#fff', fontWeight: '700', fontSize: FontSize.base },
});
