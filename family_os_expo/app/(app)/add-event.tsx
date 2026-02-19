import React, { useState } from 'react';
import {
  View, Text, StyleSheet, ScrollView, TextInput, Pressable,
  Alert, useColorScheme,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { router, useLocalSearchParams } from 'expo-router';
import { firebaseService } from '../../services/firebaseService';
import { useAppStore, useChildrenStore } from '../../store';
import { EVENT_META, type EventType } from '../../models';
import { Colors, FontSize, Spacing, Radius } from '../../utils/theme';
import { DateInput } from '../../components/DateInput';

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

  const [title, setTitle]         = useState('');
  const [type, setType]           = useState<EventType>('school');
  const [startDate, setStartDate] = useState(initDate);
  const [hasEnd, setHasEnd]       = useState(false);
  const [endDate, setEndDate]     = useState<Date>(initDate);
  const [childId, setChildId]     = useState<string | undefined>(undefined);
  const [location, setLocation]   = useState('');
  const [notes, setNotes]         = useState('');
  const [amount, setAmount]       = useState('');
  const [saving, setSaving]       = useState(false);

  const save = async () => {
    if (!title.trim()) { Alert.alert('כותרת חסרה', 'אנא הזן כותרת לאירוע.'); return; }
    if (!familyId)     { Alert.alert('שגיאה', 'לא נמצאה משפחה.'); return; }
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
      Alert.alert('שגיאה', e.message ?? 'שמירת האירוע נכשלה.');
    } finally {
      setSaving(false);
    }
  };

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: bg }}>
      <ScrollView contentContainerStyle={{ paddingBottom: 60 }} keyboardShouldPersistTaps="handled">
        {/* Header */}
        <View style={styles.header}>
          <Pressable onPress={() => router.back()}>
            <Text style={{ color: Colors.accent, fontSize: FontSize.base }}>ביטול</Text>
          </Pressable>
          <Text style={[styles.headerTitle, { color: txt }]}>אירוע חדש</Text>
          <Pressable onPress={save} disabled={saving}>
            <Text style={{ color: saving ? muted : Colors.accent, fontWeight: '700', fontSize: FontSize.base }}>
              {saving ? 'שומר…' : 'שמור'}
            </Text>
          </Pressable>
        </View>

        {/* Title */}
        <View style={[styles.card, { backgroundColor: cardBg }]}>
          <TextInput
            style={[styles.titleInput, { color: txt }]}
            placeholder="כותרת האירוע"
            placeholderTextColor={muted}
            value={title}
            onChangeText={setTitle}
            autoFocus
            returnKeyType="done"
          />
        </View>

        {/* Type picker */}
        <SectionLabel label="סוג" muted={muted} />
        <ScrollView horizontal showsHorizontalScrollIndicator={false}
          style={{ marginHorizontal: Spacing.lg, marginBottom: Spacing.md }}>
          <View style={{ flexDirection: 'row', gap: 8 }}>
            {EVENT_TYPES.map(([key, meta]) => (
              <Pressable
                key={key}
                onPress={() => setType(key)}
                style={[
                  styles.typeChip,
                  type === key
                    ? { backgroundColor: meta.color + '33', borderColor: meta.color }
                    : { borderColor: border },
                ]}
              >
                <Text style={{ fontSize: 16 }}>{meta.emoji}</Text>
                <Text style={[styles.typeLabel, { color: type === key ? meta.color : muted }]}>{meta.label}</Text>
              </Pressable>
            ))}
          </View>
        </ScrollView>

        {/* Date & Time */}
        <SectionLabel label="התחלה" muted={muted} />
        <View style={{ marginHorizontal: Spacing.lg, marginBottom: Spacing.md }}>
          <DateInput value={startDate} onChange={setStartDate} mode="datetime" label="תאריך ושעת התחלה" />
        </View>

        <SectionLabel label="זמן סיום (אופציונלי)" muted={muted} />
        <View style={{ marginHorizontal: Spacing.lg, marginBottom: Spacing.md, flexDirection: 'row', gap: 8 }}>
          <Pressable
            onPress={() => setHasEnd(v => !v)}
            style={[
              styles.toggleBtn,
              hasEnd ? { backgroundColor: Colors.accent + '22', borderColor: Colors.accent } : { borderColor: border },
            ]}
          >
            <Text style={{ color: hasEnd ? Colors.accent : muted, fontWeight: '600' }}>
              {hasEnd ? '✓ יש זמן סיום' : 'ללא זמן סיום'}
            </Text>
          </Pressable>
        </View>
        {hasEnd && (
          <View style={{ marginHorizontal: Spacing.lg, marginBottom: Spacing.md }}>
            <DateInput value={endDate} onChange={setEndDate} mode="time" label="שעת סיום" />
          </View>
        )}

        {/* Child */}
        {children.length > 0 && (
          <>
            <SectionLabel label="ילד" muted={muted} />
            <ScrollView horizontal showsHorizontalScrollIndicator={false}
              style={{ marginHorizontal: Spacing.lg, marginBottom: Spacing.md }}>
              <View style={{ flexDirection: 'row', gap: 8 }}>
                <Pressable
                  onPress={() => setChildId(undefined)}
                  style={[styles.childChip, !childId && styles.childChipActive, { borderColor: border }]}
                >
                  <Text style={[styles.childChipTxt, { color: !childId ? Colors.accent : muted }]}>הכל</Text>
                </Pressable>
                {children.map(c => (
                  <Pressable
                    key={c.id}
                    onPress={() => setChildId(c.id)}
                    style={[
                      styles.childChip,
                      childId === c.id
                        ? { backgroundColor: c.colorHex + '22', borderColor: c.colorHex }
                        : { borderColor: border },
                    ]}
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
        <SectionLabel label="פרטים" muted={muted} />
        <View style={[styles.card, { backgroundColor: cardBg }]}>
          <TextInput
            style={[styles.fieldInput, { color: txt, borderBottomColor: border }]}
            placeholder="📍 מיקום (אופציונלי)"
            placeholderTextColor={muted}
            value={location}
            onChangeText={setLocation}
            returnKeyType="next"
            textAlign="right"
          />
          {(type === 'payment' || type === 'trip') && (
            <TextInput
              style={[styles.fieldInput, { color: txt, borderBottomColor: border }]}
              placeholder="💰 סכום בש״ח (אופציונלי)"
              placeholderTextColor={muted}
              value={amount}
              onChangeText={setAmount}
              keyboardType="decimal-pad"
              returnKeyType="next"
              textAlign="right"
            />
          )}
          <TextInput
            style={[styles.fieldInput, styles.notesInput, { color: txt }]}
            placeholder="📝 הערות (אופציונלי)"
            placeholderTextColor={muted}
            value={notes}
            onChangeText={setNotes}
            multiline
            numberOfLines={3}
            textAlignVertical="top"
            textAlign="right"
          />
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

function SectionLabel({ label, muted }: { label: string; muted: string }) {
  return <Text style={[styles.sectionLabel, { color: muted }]}>{label}</Text>;
}

const styles = StyleSheet.create({
  header: {
    flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between',
    paddingHorizontal: Spacing.lg, paddingVertical: 12,
  },
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
    borderWidth: 1.5, backgroundColor: '#88888811',
  },
  typeLabel: { fontSize: FontSize.sm, fontWeight: '600' },

  toggleBtn: {
    paddingHorizontal: 16, paddingVertical: 10, borderRadius: Radius.full, borderWidth: 1.5,
  },

  childChip: {
    flexDirection: 'row', alignItems: 'center', gap: 6,
    paddingHorizontal: 14, paddingVertical: 8, borderRadius: Radius.full, borderWidth: 1.5,
  },
  childChipActive: { borderColor: Colors.accent, backgroundColor: Colors.accent + '22' },
  childChipTxt: { fontSize: FontSize.sm, fontWeight: '600' },

  fieldInput: { padding: 14, fontSize: FontSize.md, borderBottomWidth: 0.5 },
  notesInput: { minHeight: 80 },
});
