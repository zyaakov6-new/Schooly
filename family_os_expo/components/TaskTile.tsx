import React, { useRef } from 'react';
import {
  View, Text, StyleSheet, Pressable,
  useColorScheme,
} from 'react-native';
import { Swipeable } from 'react-native-gesture-handler';
import { type FamilyTask, PRIORITY_META, isTaskOverdue } from '../models';
import { Colors, Radius, FontSize, Spacing, cardShadow } from '../utils/theme';
import { formatRelative, formatAmount, haptic } from '../utils/helpers';
import { firebaseService } from '../services/firebaseService';
import { useAppStore } from '../store';

interface Props {
  task: FamilyTask;
  onPress?: () => void;
}

export default function TaskTile({ task, onPress }: Props) {
  const dark     = useColorScheme() === 'dark';
  const familyId = useAppStore(s => s.familyId) ?? '';
  const swipeRef  = useRef<Swipeable>(null);
  const isOverdue = isTaskOverdue(task);
  const isDone    = task.status === 'done';
  const priority  = PRIORITY_META[task.priority];

  const cardColor  = dark ? Colors.darkCard : '#FFFFFF';
  const textColor  = dark ? Colors.darkText : Colors.lightText;
  const mutedColor = dark ? Colors.darkMuted : Colors.lightMuted;

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
    <Pressable onPress={complete} style={[styles.swipeAction, styles.completeAction]}>
      <Text style={styles.swipeIcon}>✓</Text>
      <Text style={styles.swipeLabel}>בוצע</Text>
    </Pressable>
  );

  const renderRight = () => (
    <View style={styles.rightActions}>
      <Pressable onPress={snooze} style={[styles.swipeAction, styles.snoozeAction]}>
        <Text style={styles.swipeIcon}>⏰</Text>
        <Text style={styles.swipeLabel}>דחה</Text>
      </Pressable>
      <Pressable onPress={remove} style={[styles.swipeAction, styles.deleteAction]}>
        <Text style={styles.swipeIcon}>🗑</Text>
        <Text style={styles.swipeLabel}>מחק</Text>
      </Pressable>
    </View>
  );

  return (
    <Swipeable ref={swipeRef} renderLeftActions={renderLeft} renderRightActions={renderRight}>
      <Pressable
        onPress={onPress}
        style={[
          styles.tile,
          { backgroundColor: cardColor },
          cardShadow(dark),
          isDone && styles.doneTile,
        ]}
      >
        {/* Priority strip */}
        <View style={[styles.priorityStrip, { backgroundColor: priority.color }]} />

        {/* Checkbox */}
        <Pressable
          onPress={isDone ? undefined : complete}
          style={[
            styles.checkbox,
            { borderColor: isDone ? Colors.success : priority.color },
            isDone && { backgroundColor: Colors.success },
          ]}
        >
          {isDone && <Text style={styles.checkmark}>✓</Text>}
        </Pressable>

        {/* Content */}
        <View style={styles.content}>
          <Text
            style={[
              styles.title,
              { color: textColor },
              isDone && styles.doneText,
            ]}
            numberOfLines={2}
          >
            {task.title}
          </Text>

          <View style={styles.metaRow}>
            {task.dueDate && (
              <View style={[styles.metaChip, isOverdue && { backgroundColor: Colors.error + '18' }]}>
                <Text style={[styles.metaText, { color: isOverdue ? Colors.error : mutedColor }]}>
                  {isOverdue ? '⚠️' : '📅'} {formatRelative(task.dueDate)}
                </Text>
              </View>
            )}
            {task.amount != null && (
              <View style={[styles.metaChip, { backgroundColor: Colors.warning + '18' }]}>
                <Text style={[styles.metaText, { color: Colors.warning }]}>
                  💰 {formatAmount(task.amount)}
                </Text>
              </View>
            )}
          </View>
        </View>

        {/* Priority badge — only for non-low */}
        {task.priority !== 'low' && (
          <View style={[styles.priorityBadge, { backgroundColor: priority.color + '18' }]}>
            <Text style={[styles.priorityText, { color: priority.color }]}>{priority.label}</Text>
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
    marginHorizontal: Spacing.lg,
    marginVertical: 4,
    borderRadius: Radius.xl,
    overflow: 'hidden',
    paddingRight: 14,
    gap: Spacing.md,
  },
  doneTile: { opacity: 0.55 },

  priorityStrip: { width: 4, alignSelf: 'stretch' },

  checkbox: {
    width: 28, height: 28, borderRadius: 8,
    borderWidth: 2, alignItems: 'center', justifyContent: 'center',
    marginLeft: 4,
  },
  checkmark: { color: '#fff', fontSize: 14, fontWeight: '800' },

  content: { flex: 1, paddingVertical: 14, gap: 6 },
  title: { fontSize: FontSize.md, fontWeight: '700', lineHeight: 20 },
  doneText: { textDecorationLine: 'line-through', opacity: 0.7 },

  metaRow: { flexDirection: 'row', flexWrap: 'wrap', gap: 6 },
  metaChip: {
    flexDirection: 'row', alignItems: 'center',
    paddingHorizontal: 8, paddingVertical: 3, borderRadius: Radius.full,
    backgroundColor: '#88888814',
  },
  metaText: { fontSize: FontSize.xs, fontWeight: '600' },

  priorityBadge: {
    paddingHorizontal: 10, paddingVertical: 5,
    borderRadius: Radius.full,
  },
  priorityText: { fontSize: FontSize.xs, fontWeight: '800' },

  /* Swipe actions */
  swipeAction: {
    justifyContent: 'center', alignItems: 'center',
    width: 68, marginVertical: 4, borderRadius: Radius.xl, gap: 2,
  },
  swipeIcon:  { fontSize: 18 },
  swipeLabel: { fontSize: FontSize.xs, color: '#fff', fontWeight: '700' },
  completeAction: { backgroundColor: Colors.success, marginLeft: 16 },
  snoozeAction:   { backgroundColor: Colors.warning },
  deleteAction:   { backgroundColor: Colors.error },
  rightActions: { flexDirection: 'row', gap: 6, marginRight: 16 },
});
