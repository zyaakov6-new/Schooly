import React from 'react';
import { View, Text, StyleSheet, Pressable, useColorScheme } from 'react-native';
import { type FamilyEvent, EVENT_META } from '../models';
import { Colors, Radius, FontSize, Spacing } from '../utils/theme';
import { formatTime, formatAmount, hexToRgba } from '../utils/helpers';

interface Props {
  event: FamilyEvent;
  onPress?: () => void;
}

export default function EventTile({ event, onPress }: Props) {
  const scheme = useColorScheme();
  const dark   = scheme === 'dark';
  const meta   = EVENT_META[event.type];
  const color  = meta.color;

  return (
    <Pressable
      onPress={onPress}
      style={[
        styles.tile,
        { backgroundColor: dark ? Colors.darkCard : Colors.lightCard },
        { borderLeftColor: color },
      ]}
    >
      {/* Time */}
      <View style={styles.timeCol}>
        <Text style={[styles.timeText, { color }]}>{formatTime(event.startDate)}</Text>
        {event.endDate && (
          <Text style={styles.endTime}>{formatTime(event.endDate)}</Text>
        )}
      </View>

      {/* Details */}
      <View style={styles.content}>
        <Text style={[styles.title, { color: dark ? Colors.darkText : Colors.lightText }]} numberOfLines={2}>
          {event.title}
        </Text>
        {event.location && (
          <Text style={styles.sub} numberOfLines={1}>📍 {event.location}</Text>
        )}
        {event.amount && (
          <Text style={[styles.amount]}>{formatAmount(event.amount)}</Text>
        )}
      </View>

      {/* Icon */}
      <View style={[styles.iconBox, { backgroundColor: hexToRgba(color, 0.12) }]}>
        <Text style={styles.iconText}>{meta.emoji}</Text>
      </View>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  tile: {
    flexDirection: 'row',
    alignItems: 'center',
    marginHorizontal: 16,
    marginVertical: 5,
    padding: 14,
    borderRadius: Radius.lg,
    borderLeftWidth: 4,
    gap: Spacing.md,
  },
  timeCol: { width: 52, alignItems: 'flex-end' },
  timeText: { fontSize: FontSize.sm, fontWeight: '700' },
  endTime:  { fontSize: FontSize.xs, color: Colors.lightMuted },
  content: { flex: 1, gap: 4 },
  title: { fontSize: FontSize.md, fontWeight: '600' },
  sub:   { fontSize: FontSize.xs, color: Colors.lightMuted },
  amount: { fontSize: FontSize.xs, color: Colors.warning, fontWeight: '600' },
  iconBox: { width: 40, height: 40, borderRadius: 12, alignItems: 'center', justifyContent: 'center' },
  iconText: { fontSize: 18 },
});
