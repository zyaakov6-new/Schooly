import React from 'react';
import { View, Text, StyleSheet, Pressable, useColorScheme } from 'react-native';
import { type Child } from '../models';
import { useTasksStore, useEventsStore } from '../store';
import { Colors, Radius, FontSize, Spacing, cardShadow } from '../utils/theme';
import { hexToRgba } from '../utils/helpers';

interface Props {
  child: Child;
  onPress?: () => void;
}

export default function ChildCard({ child, onPress }: Props) {
  const scheme     = useColorScheme();
  const dark       = scheme === 'dark';
  const taskCount  = useTasksStore(s => s.forChild(child.id).length);
  const todayEvts  = useEventsStore(s => s.todayEvents().filter(e => e.childId === child.id));
  const color      = child.colorHex;

  const statusColor = taskCount === 0 ? Colors.success
                    : taskCount < 3   ? Colors.warning
                    : Colors.error;

  return (
    <Pressable
      onPress={onPress}
      style={({ pressed }) => [
        styles.card,
        { backgroundColor: dark ? Colors.darkCard : Colors.lightCard },
        { borderColor: hexToRgba(color, 0.3) },
        cardShadow(dark),
        pressed && { opacity: 0.9 },
      ]}
    >
      {/* Avatar + status dot */}
      <View style={styles.row}>
        <View style={[styles.avatar, { backgroundColor: hexToRgba(color, 0.15), borderRadius: 16 }]}>
          <Text style={styles.emoji}>{child.emoji}</Text>
        </View>
        <View style={[styles.dot, { backgroundColor: statusColor, shadowColor: statusColor }]} />
      </View>

      <Text style={[styles.name, { color: dark ? Colors.darkText : Colors.lightText }]} numberOfLines={1}>
        {child.name}
      </Text>
      <Text style={styles.sub} numberOfLines={1}>
        {child.school} · {child.className}
      </Text>

      {/* Chip */}
      <View style={[styles.chip, { backgroundColor: hexToRgba(color, 0.12) }]}>
        <Text style={[styles.chipText, { color }]} numberOfLines={1}>
          {todayEvts.length > 0
            ? todayEvts[0].title
            : taskCount > 0
              ? `${taskCount} task${taskCount !== 1 ? 's' : ''}`
              : 'All clear ✓'}
        </Text>
      </View>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  card: {
    width: 150,
    padding: 14,
    borderRadius: Radius.xl,
    borderWidth: 1.5,
    gap: Spacing.xs,
    marginRight: 12,
  },
  row: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'flex-start' },
  avatar: { width: 48, height: 48, alignItems: 'center', justifyContent: 'center' },
  emoji: { fontSize: 24 },
  dot: {
    width: 10, height: 10, borderRadius: 5,
    shadowOffset: { width: 0, height: 0 }, shadowOpacity: 0.7, shadowRadius: 4,
    elevation: 3,
  },
  name: { fontSize: FontSize.md, fontWeight: '700', marginTop: 4 },
  sub:  { fontSize: FontSize.xs, color: Colors.lightMuted },
  chip: {
    paddingHorizontal: 8, paddingVertical: 4,
    borderRadius: 8, marginTop: 4,
  },
  chipText: { fontSize: FontSize.xs, fontWeight: '600' },
});
