import React, { useRef } from 'react';
import {
  View, Text, StyleSheet, Pressable, Animated,
  useColorScheme,
} from 'react-native';
import { Swipeable } from 'react-native-gesture-handler';
import { type FamilyTask, PRIORITY_META, isTaskOverdue } from '../models';
import { Colors, Radius, FontSize, Spacing } from '../utils/theme';
import { formatRelative, formatAmount, haptic } from '../utils/helpers';
import { firebaseService } from '../services/firebaseService';
import { useAppStore } from '../store';

interface Props {
  task: FamilyTask;
  onPress?: () => void;
}

export default function TaskTile({ task, onPress }: Props) {
  const scheme   = useColorScheme();
  const dark     = scheme === 'dark';
  const familyId = useAppStore(s => s.familyId) ?? '';
  const swipeRef  = useRef<Swipeable>(null);
  const isOverdue = isTaskOverdue(task);
  const isDone    = task.status === 'done';
  const priority  = PRIORITY_META[task.priority];

  const complete = async () => {
    swipeRef.current?.close();
    await haptic.success();
    await firebaseService.completeTask(familyId, task.id);
  };

  const snooze = async () => {
    swipeRef.current?.close();
    await haptic.light();
    await firebaseService.snoozeTask(familyId, task.id);
  };

  const remove = async () => {
    await haptic.heavy();
    await firebaseService.deleteTask(familyId, task.id);
  };

  const renderLeft = () => (
    <Pressable onPress={complete} style={[styles.action, { backgroundColor: Colors.success }]}>
      <Text style={styles.actionIcon}>✓</Text>
    </Pressable>
  );

  const renderRight = () => (
    <View style={styles.rightActions}>
      <Pressable onPress={snooze} style={[styles.action, { backgroundColor: Colors.warning }]}>
        <Text style={styles.actionIcon}>⏰</Text>
      </Pressable>
      <Pressable onPress={remove} style={[styles.action, { backgroundColor: Colors.error }]}>
        <Text style={styles.actionIcon}>🗑</Text>
      </Pressable>
    </View>
  );

  return (
    <Swipeable ref={swipeRef} renderLeftActions={renderLeft} renderRightActions={renderRight}>
      <Pressable
        onPress={onPress}
        style={[
          styles.tile,
          { backgroundColor: dark ? Colors.darkCard : Colors.lightCard },
          isDone && styles.doneTile,
        ]}
      >
        {/* Checkbox */}
        <Pressable onPress={isDone ? undefined : complete} style={[styles.checkbox, isDone && styles.checkboxDone]}>
          {isDone && <Text style={styles.checkmark}>✓</Text>}
        </Pressable>

        {/* Content */}
        <View style={styles.content}>
          <Text
            style={[
              styles.title,
              { color: dark ? Colors.darkText : Colors.lightText },
              isDone && styles.doneText,
            ]}
            numberOfLines={2}
          >
            {task.title}
          </Text>
          <View style={styles.meta}>
            {task.dueDate && (
              <Text style={[styles.metaText, isOverdue && { color: Colors.error }]}>
                🕐 {formatRelative(task.dueDate)}
              </Text>
            )}
            {task.amount && (
              <Text style={[styles.metaText, { color: Colors.warning }]}>
                {formatAmount(task.amount)}
              </Text>
            )}
          </View>
        </View>

        {/* Priority badge */}
        {task.priority !== 'low' && (
          <View style={[styles.badge, { backgroundColor: priority.color + '22' }]}>
            <Text style={[styles.badgeText, { color: priority.color }]}>{priority.label}</Text>
          </View>
        )}
      </Pressable>
    </Swipeable>
  );
}

const styles = StyleSheet.create({
  tile: {
    flexDirection: 'row',
    alignItems: 'center',
    marginHorizontal: 16,
    marginVertical: 4,
    padding: 14,
    borderRadius: Radius.lg,
    gap: Spacing.md,
  },
  doneTile: { opacity: 0.6 },
  checkbox: {
    width: 28, height: 28,
    borderRadius: 8,
    borderWidth: 2,
    borderColor: Colors.accent,
    alignItems: 'center',
    justifyContent: 'center',
  },
  checkboxDone: { backgroundColor: Colors.success, borderColor: Colors.success },
  checkmark: { color: '#fff', fontSize: 14, fontWeight: '700' },
  content: { flex: 1, gap: 4 },
  title: { fontSize: FontSize.md, fontWeight: '600' },
  doneText: { textDecorationLine: 'line-through' },
  meta: { flexDirection: 'row', gap: Spacing.sm },
  metaText: { fontSize: FontSize.sm, color: Colors.lightMuted },
  badge: {
    paddingHorizontal: 8, paddingVertical: 4,
    borderRadius: 8,
  },
  badgeText: { fontSize: FontSize.xs, fontWeight: '700' },
  action: {
    justifyContent: 'center', alignItems: 'center',
    width: 72, borderRadius: Radius.lg,
    marginVertical: 4,
  },
  actionIcon: { fontSize: 20 },
  rightActions: { flexDirection: 'row', gap: 4, marginRight: 16 },
});
