import React from 'react';
import { View, Text, StyleSheet, Pressable, useColorScheme } from 'react-native';
import { type FamilyEvent, EVENT_META } from '../models';
import { Colors, Radius, FontSize, Spacing, cardShadow } from '../utils/theme';
import { formatTime, formatAmount } from '../utils/helpers';

interface Props {
  event: FamilyEvent;
  onPress?: () => void;
}

const DAYS_HE = ['א׳', 'ב׳', 'ג׳', 'ד׳', 'ה׳', 'ו׳', 'ש׳'];
const MONTHS_HE = ['ינו', 'פבר', 'מרץ', 'אפר', 'מאי', 'יונ', 'יול', 'אוג', 'ספט', 'אוק', 'נוב', 'דצמ'];

export default function EventTile({ event, onPress }: Props) {
  const dark  = useColorScheme() === 'dark';
  const meta  = EVENT_META[event.type];
  const color = meta.color;
  const date  = event.startDate;

  const cardColor  = dark ? Colors.darkCard : '#FFFFFF';
  const textColor  = dark ? Colors.darkText : Colors.lightText;
  const mutedColor = dark ? Colors.darkMuted : Colors.lightMuted;

  const dayNum  = date.getDate();
  const dayName = DAYS_HE[date.getDay()];
  const month   = MONTHS_HE[date.getMonth()];
  const hasTime = date.getHours() !== 0 || date.getMinutes() !== 0;

  return (
    <Pressable
      onPress={onPress}
      style={[styles.tile, { backgroundColor: cardColor }, cardShadow(dark)]}
    >
      {/* Left color accent strip */}
      <View style={[styles.strip, { backgroundColor: color }]} />

      {/* Date column */}
      <View style={[styles.dateCol, { backgroundColor: color + '15' }]}>
        <Text style={[styles.dayNum, { color }]}>{dayNum}</Text>
        <Text style={[styles.dayName, { color }]}>{dayName}</Text>
        <Text style={[styles.monthTxt, { color: mutedColor }]}>{month}</Text>
      </View>

      {/* Content */}
      <View style={styles.content}>
        <Text style={[styles.title, { color: textColor }]} numberOfLines={2}>
          {event.title}
        </Text>

        <View style={styles.metaRow}>
          {hasTime && (
            <View style={styles.metaPill}>
              <Text style={[styles.metaTxt, { color: mutedColor }]}>
                ⏰ {formatTime(date)}{event.endDate ? ` – ${formatTime(event.endDate)}` : ''}
              </Text>
            </View>
          )}
          {event.location && (
            <View style={styles.metaPill}>
              <Text style={[styles.metaTxt, { color: mutedColor }]} numberOfLines={1}>
                📍 {event.location}
              </Text>
            </View>
          )}
          {event.amount != null && (
            <View style={[styles.metaPill, { backgroundColor: Colors.warning + '18' }]}>
              <Text style={[styles.metaTxt, { color: Colors.warning }]}>
                💰 {formatAmount(event.amount)}
              </Text>
            </View>
          )}
        </View>
      </View>

      {/* Type badge */}
      <View style={[styles.badge, { backgroundColor: color + '18' }]}>
        <Text style={styles.badgeEmoji}>{meta.emoji}</Text>
        <Text style={[styles.badgeLabel, { color }]}>{meta.label}</Text>
      </View>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  tile: {
    flexDirection: 'row',
    alignItems: 'center',
    marginHorizontal: Spacing.lg,
    marginVertical: 5,
    borderRadius: Radius.xl,
    overflow: 'hidden',
    gap: Spacing.md,
    paddingRight: 12,
  },
  strip: { width: 4, alignSelf: 'stretch' },

  dateCol: {
    width: 52, paddingVertical: 14, alignItems: 'center',
    gap: 1, borderRadius: 0,
  },
  dayNum:   { fontSize: FontSize.xl, fontWeight: '800', lineHeight: 26 },
  dayName:  { fontSize: FontSize.xs, fontWeight: '700' },
  monthTxt: { fontSize: FontSize.xs, marginTop: 2 },

  content: { flex: 1, paddingVertical: 14, gap: 6 },
  title:   { fontSize: FontSize.md, fontWeight: '700', lineHeight: 20 },

  metaRow: { flexDirection: 'row', flexWrap: 'wrap', gap: 4 },
  metaPill: { flexDirection: 'row', alignItems: 'center', gap: 2 },
  metaTxt:  { fontSize: FontSize.xs },

  badge: {
    alignItems: 'center', justifyContent: 'center',
    paddingHorizontal: 8, paddingVertical: 6,
    borderRadius: Radius.lg, gap: 2, minWidth: 44,
  },
  badgeEmoji: { fontSize: 16 },
  badgeLabel: { fontSize: 9, fontWeight: '800', letterSpacing: 0.3 },
});
