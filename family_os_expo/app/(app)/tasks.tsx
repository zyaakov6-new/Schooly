import React, { useState } from 'react';
import { View, Text, StyleSheet, FlatList, Pressable, useColorScheme } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { router } from 'expo-router';
import { useTasksStore, useChildrenStore, useAppStore } from '../../store';
import { type TaskStatus } from '../../models';
import { Colors, FontSize, Spacing, Radius } from '../../utils/theme';
import { hexToRgba } from '../../utils/helpers';
import TaskTile from '../../components/TaskTile';
import EmptyState from '../../components/EmptyState';

const TABS: { key: TaskStatus | 'all'; label: string }[] = [
  { key: 'pending',    label: 'Pending' },
  { key: 'inProgress', label: 'In Progress' },
  { key: 'done',       label: 'Done' },
];

export default function TasksScreen() {
  const dark    = useColorScheme() === 'dark';
  const bg      = dark ? Colors.darkBg   : Colors.lightBg;
  const txt     = dark ? Colors.darkText : Colors.lightText;
  const tasks   = useTasksStore(s => s.tasks);
  const children = useChildrenStore(s => s.children);
  const [tab, setTab]             = useState<TaskStatus>('pending');
  const [filterChild, setFilter]  = useState<string | null>(null);

  const filtered = tasks
    .filter(t => t.status === tab && (!filterChild || t.childId === filterChild))
    .sort((a, b) => {
      const order = ['urgent','high','medium','low'];
      return order.indexOf(a.priority) - order.indexOf(b.priority);
    });

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: bg }}>
      <View style={styles.header}>
        <Text style={[styles.title, { color: txt }]}>Tasks</Text>
        <View style={styles.headerRight}>
          <Pressable onPress={() => router.push('/(app)/inbox')} style={styles.inboxBtn}>
            <Text style={{ fontSize: 20 }}>📨</Text>
          </Pressable>
          <Pressable onPress={() => router.push('/(app)/add-task')} style={styles.addBtn}>
            <Text style={styles.addBtnTxt}>+ Task</Text>
          </Pressable>
        </View>
      </View>

      {/* Child filter */}
      {children.length > 0 && (
        <FlatList
          horizontal showsHorizontalScrollIndicator={false}
          data={[null, ...children]}
          keyExtractor={(_, i) => String(i)}
          contentContainerStyle={styles.chips}
          renderItem={({ item }) => item === null ? (
            <Pressable onPress={() => setFilter(null)}
              style={[styles.chip, { backgroundColor: !filterChild ? Colors.accent : Colors.accent + '22' }]}>
              <Text style={[styles.chipTxt, { color: !filterChild ? '#fff' : Colors.accent }]}>All</Text>
            </Pressable>
          ) : (
            <Pressable onPress={() => setFilter(filterChild === item.id ? null : item.id)}
              style={[styles.chip, { backgroundColor: filterChild === item.id ? item.colorHex : hexToRgba(item.colorHex, 0.15) }]}>
              <Text style={[styles.chipTxt, { color: filterChild === item.id ? '#fff' : item.colorHex }]}>
                {item.emoji} {item.name}
              </Text>
            </Pressable>
          )}
        />
      )}

      {/* Tabs */}
      <View style={styles.tabs}>
        {TABS.map(t => (
          <Pressable key={t.key} onPress={() => setTab(t.key as TaskStatus)} style={[styles.tabBtn, tab === t.key && styles.tabActive]}>
            <Text style={[styles.tabTxt, tab === t.key && { color: Colors.accent }]}>{t.label}</Text>
          </Pressable>
        ))}
      </View>

      {filtered.length === 0 ? (
        <EmptyState
          emoji={tab === 'done' ? '🎉' : '✅'}
          title={`No ${TABS.find(t => t.key === tab)?.label.toLowerCase()} tasks`}
          subtitle={tab === 'pending' ? 'Tap + Task to add one' : ''}
        />
      ) : (
        <FlatList
          data={filtered}
          keyExtractor={t => t.id}
          contentContainerStyle={{ paddingVertical: 8, paddingBottom: 40 }}
          renderItem={({ item }) => <TaskTile task={item} />}
        />
      )}
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  header: {
    flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between',
    paddingHorizontal: Spacing.lg, paddingTop: Spacing.lg, paddingBottom: Spacing.sm,
  },
  title: { fontSize: FontSize['2xl'], fontWeight: '800' },
  headerRight: { flexDirection: 'row', gap: 8, alignItems: 'center' },
  inboxBtn: { padding: 8 },
  addBtn: { backgroundColor: Colors.accent, paddingHorizontal: 14, paddingVertical: 8, borderRadius: Radius.full },
  addBtnTxt: { color: '#fff', fontWeight: '700', fontSize: FontSize.sm },
  chips: { paddingHorizontal: Spacing.lg, paddingVertical: Spacing.sm, gap: 8 },
  chip:  { paddingHorizontal: 14, paddingVertical: 7, borderRadius: Radius.full },
  chipTxt: { fontWeight: '600', fontSize: 13 },
  tabs: { flexDirection: 'row', paddingHorizontal: Spacing.lg, gap: 4, marginBottom: 4 },
  tabBtn: { flex: 1, alignItems: 'center', paddingVertical: 10, borderBottomWidth: 2, borderBottomColor: 'transparent' },
  tabActive: { borderBottomColor: Colors.accent },
  tabTxt: { fontSize: FontSize.sm, fontWeight: '600', color: Colors.lightMuted },
});
