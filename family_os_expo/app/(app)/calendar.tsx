import React, { useState } from 'react';
import { View, Text, StyleSheet, ScrollView, Pressable, useColorScheme } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Calendar } from 'react-native-calendars';
import { router } from 'expo-router';
import { useEventsStore, useChildrenStore } from '../../store';
import { Colors, FontSize, Spacing, Radius } from '../../utils/theme';
import { isSameDay, startOfDay, formatTime, hexToRgba } from '../../utils/helpers';
import { EVENT_META } from '../../models';
import EventTile from '../../components/EventTile';
import EmptyState from '../../components/EmptyState';

export default function CalendarScreen() {
  const dark    = useColorScheme() === 'dark';
  const bg      = dark ? Colors.darkBg   : Colors.lightBg;
  const txt     = dark ? Colors.darkText : Colors.lightText;
  const cardBg  = dark ? Colors.darkCard : Colors.lightCard;
  const eventsMap = useEventsStore(s => s.eventsMap());
  const allEvents = useEventsStore(s => s.events);
  const children  = useChildrenStore(s => s.children);
  const [selected, setSelected]   = useState(new Date());
  const [filterChild, setFilter]  = useState<string | null>(null);

  const todayStr = new Date().toISOString().split('T')[0];
  const selStr   = selected.toISOString().split('T')[0];

  // Build markedDates for react-native-calendars
  const marked: Record<string, any> = {};
  for (const [key, evts] of Object.entries(eventsMap)) {
    const dateStr = new Date(key).toISOString().split('T')[0];
    const dots = evts.slice(0, 3).map(e => ({ color: EVENT_META[e.type].color, key: e.id }));
    marked[dateStr] = { dots, marked: true };
  }
  if (selStr) {
    marked[selStr] = { ...(marked[selStr] ?? {}), selected: true, selectedColor: Colors.accent };
  }

  const dayEvents = allEvents
    .filter(e => isSameDay(e.startDate, selected) && (!filterChild || e.childId === filterChild))
    .sort((a, b) => a.startDate.getTime() - b.startDate.getTime());

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: bg }}>
      <View style={styles.header}>
        <Text style={[styles.title, { color: txt }]}>Calendar</Text>
        <Pressable onPress={() => router.push('/(app)/add-event')} style={styles.addBtn}>
          <Text style={styles.addBtnTxt}>+ Event</Text>
        </Pressable>
      </View>

      {/* Child filter chips */}
      {children.length > 0 && (
        <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.chips}>
          <Pressable onPress={() => setFilter(null)}
            style={[styles.chip, { backgroundColor: !filterChild ? Colors.accent : Colors.accent + '22' }]}>
            <Text style={[styles.chipTxt, { color: !filterChild ? '#fff' : Colors.accent }]}>All</Text>
          </Pressable>
          {children.map(c => (
            <Pressable key={c.id} onPress={() => setFilter(filterChild === c.id ? null : c.id)}
              style={[styles.chip, { backgroundColor: filterChild === c.id ? c.colorHex : hexToRgba(c.colorHex, 0.15) }]}>
              <Text style={[styles.chipTxt, { color: filterChild === c.id ? '#fff' : c.colorHex }]}>
                {c.emoji} {c.name}
              </Text>
            </Pressable>
          ))}
        </ScrollView>
      )}

      <Calendar
        current={selStr}
        onDayPress={d => setSelected(new Date(d.dateString))}
        markingType="multi-dot"
        markedDates={marked}
        theme={{
          backgroundColor: bg,
          calendarBackground: bg,
          selectedDayBackgroundColor: Colors.accent,
          todayTextColor: Colors.accent,
          dayTextColor: txt,
          textDisabledColor: dark ? Colors.darkBorder : Colors.lightBorder,
          monthTextColor: txt,
          arrowColor: Colors.accent,
          dotColor: Colors.accent,
        }}
      />

      <View style={[styles.divider, { backgroundColor: dark ? Colors.darkBorder : Colors.lightBorder }]} />

      <ScrollView contentContainerStyle={{ paddingVertical: 8, paddingBottom: 40 }}>
        {dayEvents.length === 0 ? (
          <EmptyState emoji="📅" title="No events" subtitle="Tap + Event to add one" />
        ) : (
          dayEvents.map(e => <EventTile key={e.id} event={e} />)
        )}
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  header: {
    flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between',
    paddingHorizontal: Spacing.lg, paddingTop: Spacing.lg, paddingBottom: Spacing.sm,
  },
  title: { fontSize: FontSize['2xl'], fontWeight: '800' },
  addBtn: { backgroundColor: Colors.accent, paddingHorizontal: 14, paddingVertical: 8, borderRadius: Radius.full },
  addBtnTxt: { color: '#fff', fontWeight: '700', fontSize: FontSize.sm },
  chips: { paddingHorizontal: Spacing.lg, paddingVertical: Spacing.sm, gap: 8 },
  chip:  { paddingHorizontal: 14, paddingVertical: 7, borderRadius: Radius.full },
  chipTxt: { fontWeight: '600', fontSize: 13 },
  divider: { height: 1, marginTop: 4 },
});
