import React, { useState } from 'react';
import {
  View, Text, StyleSheet, ScrollView, TextInput, Pressable,
  Alert, useColorScheme, Platform,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { router, useLocalSearchParams } from 'expo-router';
import DateTimePicker from '@react-native-community/datetimepicker';
import { firebaseService } from '../../services/firebaseService';
import { useAppStore, useChildrenStore } from '../../store';
import { EVENT_META, type EventType } from '../../models';
import { Colors, FontSize, Spacing, Radius } from '../../utils/theme';
import { formatDate, formatTime } from '../../utils/helpers';

const EVENT_TYPES = Object.entries(EVENT_META) as [EventType, typeof EVENT_META[EventType]][];

export default function AddEventScreen() {
  const dark    = useColorScheme() === 'dark';
  const bg      = dark ? Colors.darkBg   : Colors.lightBg;
  const cardBg  = dark ? Colors.darkCard : Colors.lightCard;
  const txt     = dark ? Colors.darkText : Colors.lightText;
  const muted   = dark ? Colors.darkMuted : Colors.lightMuted;
  const border  = dark ? Colors.darkBorder : Colors.lightBorder;

  const familyId = useAppStore(s => s.familyId) ?? '';
  const userId   = useAppStore(s => s.user)?.uid ?? '';
  const children = useChildrenStore(s => s.children);

  const params   = useLocalSearchParams<{ date?: string }>();
  const initDate = params.date ? new Date(params.date) : new Date();

  const [title, setTitle]           = useState('');
  const [type, setType]             = useState<EventType>('school');
  const [startDate, setStartDate]   = useState(initDate);
  const [hasTime, setHasTime]       = useState(false);
  const [hasEnd, setHasEnd]         = useState(false);
  const [endDate, setEndDate]       = useState<Date>(initDate);
  const [childId, setChildId]       = useState<string | undefined>(undefined);
  const [location, setLocation]     = useState('');
  const [notes, setNotes]           = useState('');
  const [amount, setAmount]         = useState('');
  const [saving, setSaving]         = useState(false);

  // Date/time picker state
  const [showDatePicker, setShowDatePicker] = useState(false);
  const [showTimePicker, setShowTimePicker] = useState(false);
  const [showEndPicker, setShowEndPicker]   = useState(false);

  const save = async () => {
    if (!title.trim()) { Alert.alert('Missing title', 'Please enter an event title.'); return; }
    if (!familyId) { Alert.alert('Error', 'No family found.'); return; }
    setSaving(true);
    try {
      await firebaseService.addEvent(familyId, {
        familyId,
        title: title.trim(),
        type,
        startDate,
        endDate: hasEnd ? endDate : undefined,
        childId,
        location: location.trim() || undefined,
        notes: notes.trim() || undefined,
        amount: amount ? parseFloat(amount) : undefined,
        createdAt: new Date(),
        createdBy: userId,
      });
      router.back();
    } catch (e: any) {
      Alert.alert('Error', e.message ?? 'Failed to save event.');
    } finally {
      setSaving(false);
    }
  };

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: bg }}>
      <ScrollView contentContainerStyle={{ paddingBottom: 60 }} keyboardShouldPersistTaps="handled">
        {/* Header */}
        <View style={styles.header}>
          <Pressable onPress={() => router.back()} style={styles.backBtn}>
            <Text style={{ color: Colors.accent, fontSize: FontSize.base }}>Cancel</Text>
          </Pressable>
          <Text style={[styles.headerTitle, { color: txt }]}>New Event</Text>
          <Pressable onPress={save} disabled={saving} style={styles.saveBtn}>
            <Text style={{ color: saving ? muted : Colors.accent, fontWeight: '700', fontSize: FontSize.base }}>
              {saving ? 'Saving…' : 'Save'}
            </Text>
          </Pressable>
        </View>

        {/* Title */}
        <View style={[styles.card, { backgroundColor: cardBg }]}>
          <TextInput
            style={[styles.titleInput, { color: txt }]}
            placeholder="Event title"
            placeholderTextColor={muted}
            value={title}
            onChangeText={setTitle}
            autoFocus
            returnKeyType="done"
          />
        </View>

        {/* Type picker */}
        <SectionLabel label="TYPE" muted={muted} />
        <ScrollView horizontal showsHorizontalScrollIndicator={false} style={{ marginHorizontal: Spacing.lg, marginBottom: Spacing.md }}>
          <View style={{ flexDirection: 'row', gap: 8 }}>
            {EVENT_TYPES.map(([key, meta]) => (
              <Pressable
                key={key}
                onPress={() => setType(key)}
                style={[styles.typeChip, type === key && { backgroundColor: meta.color + '33', borderColor: meta.color }]}
              >
                <Text style={{ fontSize: 16 }}>{meta.emoji}</Text>
                <Text style={[styles.typeLabel, { color: type === key ? meta.color : muted }]}>{meta.label}</Text>
              </Pressable>
            ))}
          </View>
        </ScrollView>

        {/* Date & Time */}
        <SectionLabel label="DATE & TIME" muted={muted} />
        <View style={[styles.card, { backgroundColor: cardBg }]}>
          <RowButton
            label="Date"
            value={formatDate(startDate)}
            onPress={() => setShowDatePicker(true)}
            txt={txt} muted={muted} border={border}
          />
          <RowButton
            label="Time"
            value={hasTime ? formatTime(startDate) : 'None'}
            onPress={() => { setHasTime(true); setShowTimePicker(true); }}
            txt={txt} muted={muted} border={border}
          />
          <RowButton
            label="End time"
            value={hasEnd ? formatTime(endDate) : 'None'}
            onPress={() => { setHasEnd(true); setShowEndPicker(true); }}
            txt={txt} muted={muted}
          />
        </View>

        {showDatePicker && (
          <DateTimePicker
            value={startDate}
            mode="date"
            display={Platform.OS === 'ios' ? 'spinner' : 'default'}
            onChange={(_, d) => {
              setShowDatePicker(Platform.OS === 'android' ? false : showDatePicker);
              if (d) setStartDate(prev => new Date(d.getFullYear(), d.getMonth(), d.getDate(), prev.getHours(), prev.getMinutes()));
            }}
          />
        )}
        {showTimePicker && (
          <DateTimePicker
            value={startDate}
            mode="time"
            display={Platform.OS === 'ios' ? 'spinner' : 'default'}
            onChange={(_, d) => {
              setShowTimePicker(Platform.OS === 'android' ? false : showTimePicker);
              if (d) setStartDate(prev => new Date(prev.getFullYear(), prev.getMonth(), prev.getDate(), d.getHours(), d.getMinutes()));
            }}
          />
        )}
        {showEndPicker && (
          <DateTimePicker
            value={endDate}
            mode="time"
            display={Platform.OS === 'ios' ? 'spinner' : 'default'}
            onChange={(_, d) => {
              setShowEndPicker(Platform.OS === 'android' ? false : showEndPicker);
              if (d) setEndDate(new Date(startDate.getFullYear(), startDate.getMonth(), startDate.getDate(), d.getHours(), d.getMinutes()));
            }}
          />
        )}

        {/* Child */}
        {children.length > 0 && (
          <>
            <SectionLabel label="CHILD" muted={muted} />
            <ScrollView horizontal showsHorizontalScrollIndicator={false} style={{ marginHorizontal: Spacing.lg, marginBottom: Spacing.md }}>
              <View style={{ flexDirection: 'row', gap: 8 }}>
                <Pressable
                  onPress={() => setChildId(undefined)}
                  style={[styles.childChip, !childId && styles.childChipActive, { borderColor: border }]}
                >
                  <Text style={[styles.childChipTxt, { color: !childId ? Colors.accent : muted }]}>All</Text>
                </Pressable>
                {children.map(c => (
                  <Pressable
                    key={c.id}
                    onPress={() => setChildId(c.id)}
                    style={[styles.childChip, childId === c.id && { backgroundColor: c.colorHex + '22', borderColor: c.colorHex }]}
                  >
                    <Text style={{ fontSize: 16 }}>{c.emoji}</Text>
                    <Text style={[styles.childChipTxt, { color: childId === c.id ? c.colorHex : muted }]}>{c.name}</Text>
                  </Pressable>
                ))}
              </View>
            </ScrollView>
          </>
        )}

        {/* Details */}
        <SectionLabel label="DETAILS" muted={muted} />
        <View style={[styles.card, { backgroundColor: cardBg }]}>
          <TextInput
            style={[styles.fieldInput, { color: txt, borderBottomColor: border }]}
            placeholder="📍 Location (optional)"
            placeholderTextColor={muted}
            value={location}
            onChangeText={setLocation}
            returnKeyType="next"
          />
          {(type === 'payment' || type === 'trip') && (
            <TextInput
              style={[styles.fieldInput, { color: txt, borderBottomColor: border }]}
              placeholder="💰 Amount in ₪ (optional)"
              placeholderTextColor={muted}
              value={amount}
              onChangeText={setAmount}
              keyboardType="decimal-pad"
              returnKeyType="next"
            />
          )}
          <TextInput
            style={[styles.fieldInput, styles.notesInput, { color: txt }]}
            placeholder="📝 Notes (optional)"
            placeholderTextColor={muted}
            value={notes}
            onChangeText={setNotes}
            multiline
            numberOfLines={3}
            textAlignVertical="top"
          />
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

function SectionLabel({ label, muted }: { label: string; muted: string }) {
  return (
    <Text style={[styles.sectionLabel, { color: muted }]}>{label}</Text>
  );
}

function RowButton({ label, value, onPress, txt, muted, border }:
  { label: string; value: string; onPress: () => void; txt: string; muted: string; border?: string }) {
  return (
    <Pressable
      onPress={onPress}
      style={[styles.rowBtn, border ? { borderBottomColor: border, borderBottomWidth: 0.5 } : {}]}
    >
      <Text style={[styles.rowLabel, { color: txt }]}>{label}</Text>
      <Text style={[styles.rowValue, { color: Colors.accent }]}>{value}</Text>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  header: {
    flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between',
    paddingHorizontal: Spacing.lg, paddingVertical: 12,
  },
  backBtn:  { minWidth: 60 },
  saveBtn:  { minWidth: 60, alignItems: 'flex-end' },
  headerTitle: { fontSize: FontSize.lg, fontWeight: '700' },

  card: { marginHorizontal: Spacing.lg, borderRadius: Radius.lg, marginBottom: Spacing.md, overflow: 'hidden' },
  titleInput: { fontSize: FontSize.xl, fontWeight: '600', padding: Spacing.md, minHeight: 56 },

  sectionLabel: {
    fontSize: FontSize.xs, letterSpacing: 1.2, fontWeight: '600',
    paddingHorizontal: Spacing.lg, marginBottom: 6, marginTop: 4,
  },
  typeChip: {
    flexDirection: 'row', alignItems: 'center', gap: 6,
    paddingHorizontal: 14, paddingVertical: 8, borderRadius: Radius.full,
    borderWidth: 1.5, borderColor: 'transparent', backgroundColor: '#88888822',
  },
  typeLabel:  { fontSize: FontSize.sm, fontWeight: '600' },

  childChip: {
    flexDirection: 'row', alignItems: 'center', gap: 6,
    paddingHorizontal: 14, paddingVertical: 8, borderRadius: Radius.full,
    borderWidth: 1.5, backgroundColor: '#88888822',
  },
  childChipActive: { borderColor: Colors.accent, backgroundColor: Colors.accent + '22' },
  childChipTxt: { fontSize: FontSize.sm, fontWeight: '600' },

  rowBtn: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', padding: 14 },
  rowLabel: { fontSize: FontSize.md, fontWeight: '500' },
  rowValue: { fontSize: FontSize.md, fontWeight: '600' },

  fieldInput: { padding: 14, fontSize: FontSize.md, borderBottomWidth: 0.5 },
  notesInput: { minHeight: 80 },
});
