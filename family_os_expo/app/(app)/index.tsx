import React from 'react';
import {
  View, Text, ScrollView, Pressable, StyleSheet,
  useColorScheme, FlatList,
} from 'react-native';
import { router } from 'expo-router';
import { SafeAreaView } from 'react-native-safe-area-context';
import { LinearGradient } from 'expo-linear-gradient';
import { format } from 'date-fns';
import { he } from 'date-fns/locale';
import { useAppStore, useChildrenStore, useEventsStore, useTasksStore } from '../../store';
import { Colors, FontSize, Spacing, Radius, cardShadow } from '../../utils/theme';
import { getGreeting } from '../../utils/helpers';
import ChildCard from '../../components/ChildCard';
import TaskTile from '../../components/TaskTile';
import EventTile from '../../components/EventTile';
import EmptyState from '../../components/EmptyState';

export default function DashboardScreen() {
  const dark     = useColorScheme() === 'dark';
  const bg       = dark ? Colors.darkBg   : Colors.lightBg;
  const txt      = dark ? Colors.darkText : Colors.lightText;
  const cardBg   = dark ? Colors.darkCard : '#FFFFFF';
  const muted    = dark ? Colors.darkMuted : Colors.lightMuted;
  const border   = dark ? Colors.darkBorder : Colors.lightBorder;

  const user     = useAppStore(s => s.user);
  const locale   = useAppStore(s => s.locale);

  const children     = useChildrenStore(s => s.children);
  const todayEvts    = useEventsStore(s => s.todayEvents());
  const allEvents    = useEventsStore(s => s.events);
  const pendingTasks = useTasksStore(s => s.pending()).slice(0, 5);
  const allTasks     = useTasksStore(s => s.tasks);

  const dateLabel  = format(new Date(), 'EEEE, d MMMM', { locale: he });
  const greeting   = getGreeting(locale);

  // Stats
  const urgentCount = allTasks.filter(t => t.priority === 'urgent' && t.status !== 'done').length;
  const upcomingCount = allEvents.filter(e => e.startDate >= new Date()).length;
  const doneToday   = allTasks.filter(t => t.status === 'done').length;

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: bg }}>
      <ScrollView contentContainerStyle={{ paddingBottom: 120 }} showsVerticalScrollIndicator={false}>

        {/* ── Gradient Header ─────────────────────────────────────── */}
        <LinearGradient
          colors={dark
            ? [Colors.darkSurface, Colors.darkBg]
            : [Colors.accent + '18', Colors.lightBg]}
          style={styles.header}
        >
          <View style={styles.headerTop}>
            <View style={{ flex: 1 }}>
              <Text style={[styles.greeting, { color: Colors.accent }]}>{greeting} 👋</Text>
              <Text style={[styles.dateText, { color: txt }]}>{dateLabel}</Text>
            </View>
            <Pressable
              onPress={() => router.push('/(app)/inbox')}
              style={[styles.notifBtn, { backgroundColor: cardBg, borderColor: border }, cardShadow(dark)]}
            >
              <Text style={{ fontSize: 20 }}>📨</Text>
            </Pressable>
          </View>

          {/* Quick stats row */}
          <View style={styles.statsRow}>
            <StatChip icon="📅" label="אירועים קרובים" value={upcomingCount} color={Colors.accent} bg={cardBg} border={border} shadow={cardShadow(dark)} />
            <StatChip icon="✅" label="משימות" value={pendingTasks.length} color={Colors.success} bg={cardBg} border={border} shadow={cardShadow(dark)} />
            {urgentCount > 0 && (
              <StatChip icon="🔥" label="דחוף" value={urgentCount} color={Colors.error} bg={cardBg} border={border} shadow={cardShadow(dark)} />
            )}
            {doneToday > 0 && (
              <StatChip icon="🎉" label="בוצע" value={doneToday} color={Colors.warning} bg={cardBg} border={border} shadow={cardShadow(dark)} />
            )}
          </View>

          {/* Quick actions */}
          <View style={styles.quickActions}>
            <QuickAction icon="📅" label="אירוע" color={Colors.accent} onPress={() => router.push('/(app)/add-event')} />
            <QuickAction icon="✅" label="משימה" color={Colors.success} onPress={() => router.push('/(app)/add-task')} />
            <QuickAction icon="📨" label="הודעה" color={Colors.warning} onPress={() => router.push('/(app)/inbox')} />
            <QuickAction icon="📆" label="יומן" color='#8B5CF6' onPress={() => router.push('/(app)/calendar')} />
          </View>
        </LinearGradient>

        {/* ── Children ───────────────────────────────────────────── */}
        <SectionHeader
          title="הילדים שלי"
          count={children.length}
          onAdd={() => router.push('/(auth)/add-child')}
        />
        {children.length === 0 ? (
          <EmptyState
            emoji="👶" title="אין ילדים עדיין"
            subtitle="הוסף את ילדך הראשון כדי להתחיל"
            actionLabel="הוסף ילד" onAction={() => router.push('/(auth)/add-child')}
          />
        ) : (
          <FlatList
            data={[...children, null]}
            keyExtractor={(_, i) => String(i)}
            horizontal showsHorizontalScrollIndicator={false}
            contentContainerStyle={{ paddingHorizontal: Spacing.lg, paddingBottom: 4, gap: 12 }}
            renderItem={({ item }) =>
              item === null ? (
                <Pressable
                  onPress={() => router.push('/(auth)/add-child')}
                  style={[styles.addChild, { backgroundColor: cardBg, borderColor: Colors.accent + '44' }, cardShadow(dark)]}
                >
                  <Text style={{ fontSize: 28, color: Colors.accent }}>＋</Text>
                  <Text style={{ color: Colors.accent, fontWeight: '600', fontSize: 12, marginTop: 4 }}>הוסף ילד</Text>
                </Pressable>
              ) : (
                <ChildCard child={item} onPress={() => router.push(`/(app)/kids/${item.id}`)} />
              )
            }
          />
        )}

        {/* ── Today's Events ─────────────────────────────────────── */}
        <SectionHeader
          title="לוח הזמנים להיום"
          count={todayEvts.length}
          onAdd={() => router.push('/(app)/add-event')}
        />
        {todayEvts.length === 0 ? (
          <View style={[styles.emptyCard, { backgroundColor: cardBg, borderColor: border }, cardShadow(dark)]}>
            <Text style={{ fontSize: 32 }}>🎉</Text>
            <View>
              <Text style={[styles.emptyCardTitle, { color: txt }]}>יום חופשי!</Text>
              <Text style={[styles.emptyCardSub, { color: muted }]}>אין אירועים מתוכננים להיום</Text>
            </View>
          </View>
        ) : (
          todayEvts.map(e => <EventTile key={e.id} event={e} />)
        )}

        {/* ── Pending Tasks ──────────────────────────────────────── */}
        <SectionHeader
          title="משימות ממתינות"
          count={pendingTasks.length}
          onAdd={() => router.push('/(app)/add-task')}
          onMore={() => router.push('/(app)/tasks')}
        />
        {pendingTasks.length === 0 ? (
          <View style={[styles.emptyCard, { backgroundColor: cardBg, borderColor: border }, cardShadow(dark)]}>
            <Text style={{ fontSize: 32 }}>✅</Text>
            <View>
              <Text style={[styles.emptyCardTitle, { color: txt }]}>הכל מסודר!</Text>
              <Text style={[styles.emptyCardSub, { color: muted }]}>אין משימות ממתינות</Text>
            </View>
          </View>
        ) : (
          <>
            {pendingTasks.map(t => <TaskTile key={t.id} task={t} />)}
            {allTasks.filter(t => t.status === 'pending').length > 5 && (
              <Pressable onPress={() => router.push('/(app)/tasks')} style={styles.seeMoreBtn}>
                <Text style={[styles.seeMoreTxt, { color: Colors.accent }]}>
                  צפה בכל המשימות ›
                </Text>
              </Pressable>
            )}
          </>
        )}

      </ScrollView>
    </SafeAreaView>
  );
}

/* ── Sub-components ──────────────────────────────────── */

function StatChip({ icon, label, value, color, bg, border, shadow }: {
  icon: string; label: string; value: number;
  color: string; bg: string; border: string; shadow: object;
}) {
  if (value === 0) return null;
  return (
    <View style={[styles.statChip, { backgroundColor: bg, borderColor: border }, shadow]}>
      <Text style={{ fontSize: 14 }}>{icon}</Text>
      <Text style={[styles.statValue, { color }]}>{value}</Text>
      <Text style={[styles.statLabel, { color: '#6B7280' }]}>{label}</Text>
    </View>
  );
}

function QuickAction({ icon, label, color, onPress }: {
  icon: string; label: string; color: string; onPress: () => void;
}) {
  return (
    <Pressable onPress={onPress} style={[styles.quickAction, { backgroundColor: color + '15' }]}>
      <Text style={styles.quickActionIcon}>{icon}</Text>
      <Text style={[styles.quickActionLabel, { color }]}>+ {label}</Text>
    </Pressable>
  );
}

function SectionHeader({ title, count, onAdd, onMore }: {
  title: string; count?: number; onAdd?: () => void; onMore?: () => void;
}) {
  const dark = useColorScheme() === 'dark';
  const txt  = dark ? Colors.darkText : Colors.lightText;
  return (
    <View style={styles.sectionHeader}>
      <Text style={[styles.sectionTitle, { color: txt }]}>{title}</Text>
      {count !== undefined && count > 0 && (
        <View style={styles.countBadge}>
          <Text style={styles.countBadgeTxt}>{count}</Text>
        </View>
      )}
      <View style={{ flex: 1 }} />
      {onMore && (
        <Pressable onPress={onMore} style={styles.moreBtn}>
          <Text style={{ color: Colors.accent, fontSize: FontSize.sm, fontWeight: '600' }}>הכל</Text>
        </Pressable>
      )}
      {onAdd && (
        <Pressable onPress={onAdd} style={styles.addBtn}>
          <Text style={{ color: '#fff', fontSize: 13, fontWeight: '700' }}>＋</Text>
        </Pressable>
      )}
    </View>
  );
}

/* ── Styles ──────────────────────────────────────────── */

const styles = StyleSheet.create({
  /* Header */
  header: {
    paddingHorizontal: Spacing.lg, paddingTop: Spacing.lg, paddingBottom: Spacing.xl, gap: 16,
  },
  headerTop: { flexDirection: 'row', alignItems: 'center', gap: 12 },
  greeting:  { fontSize: FontSize.sm, fontWeight: '700' },
  dateText:  { fontSize: FontSize.xl, fontWeight: '800', marginTop: 2 },
  notifBtn:  {
    width: 44, height: 44, borderRadius: Radius.xl,
    alignItems: 'center', justifyContent: 'center', borderWidth: 1,
  },

  /* Stats */
  statsRow: { flexDirection: 'row', gap: 8 },
  statChip: {
    flexDirection: 'row', alignItems: 'center', gap: 5,
    paddingHorizontal: 12, paddingVertical: 8,
    borderRadius: Radius.full, borderWidth: 1,
  },
  statValue: { fontSize: FontSize.base, fontWeight: '800' },
  statLabel: { fontSize: FontSize.xs, fontWeight: '500' },

  /* Quick actions */
  quickActions: { flexDirection: 'row', gap: 8 },
  quickAction: {
    flex: 1, alignItems: 'center', paddingVertical: 10, borderRadius: Radius.xl, gap: 3,
  },
  quickActionIcon:  { fontSize: 20 },
  quickActionLabel: { fontSize: 10, fontWeight: '700' },

  /* Section header */
  sectionHeader: {
    flexDirection: 'row', alignItems: 'center', gap: 8,
    paddingHorizontal: Spacing.lg, paddingTop: Spacing.xl, paddingBottom: Spacing.sm,
  },
  sectionTitle: { fontSize: FontSize.base, fontWeight: '800' },
  countBadge: {
    backgroundColor: Colors.accent, borderRadius: Radius.full,
    minWidth: 20, height: 20, alignItems: 'center', justifyContent: 'center',
    paddingHorizontal: 6,
  },
  countBadgeTxt: { color: '#fff', fontSize: FontSize.xs, fontWeight: '800' },
  moreBtn: { paddingHorizontal: 10, paddingVertical: 4 },
  addBtn: {
    width: 28, height: 28, borderRadius: Radius.full,
    backgroundColor: Colors.accent, alignItems: 'center', justifyContent: 'center',
  },

  /* Empty state inline card */
  emptyCard: {
    marginHorizontal: Spacing.lg, padding: Spacing.lg, borderRadius: Radius.xl,
    flexDirection: 'row', alignItems: 'center', gap: 16, borderWidth: 1,
  },
  emptyCardTitle: { fontSize: FontSize.md, fontWeight: '700' },
  emptyCardSub:   { fontSize: FontSize.sm, marginTop: 2 },

  /* Add child tile */
  addChild: {
    width: 96, height: 148, borderRadius: Radius.xl,
    borderWidth: 1.5, borderStyle: 'dashed',
    alignItems: 'center', justifyContent: 'center',
  },

  /* See more */
  seeMoreBtn: { alignItems: 'center', paddingVertical: 14 },
  seeMoreTxt: { fontWeight: '700', fontSize: FontSize.sm },
});
