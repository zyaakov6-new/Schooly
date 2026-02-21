import React, { useState, useRef } from 'react';
import {
  View, Text, StyleSheet, ScrollView, TextInput, Pressable,
  Alert, useColorScheme, Animated, KeyboardAvoidingView, Platform,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { router, useLocalSearchParams } from 'expo-router';
import { LinearGradient } from 'expo-linear-gradient';
import { firebaseService } from '../../services/firebaseService';
import { useAppStore, useChildrenStore } from '../../store';
import { EVENT_META, type EventType } from '../../models';
import { Colors, FontSize, Spacing, Radius, cardShadow } from '../../utils/theme';
import { DateInput } from '../../components/DateInput';

const EVENT_TYPES = Object.entries(EVENT_META) as [EventType, typeof EVENT_META[EventType]][];

export default function AddEventScreen() {
  const dark    = useColorScheme() === 'dark';
  const bg      = dark ? Colors.darkBg   : Colors.lightBg;
  const cardBg  = dark ? Colors.darkCard : Colors.lightCard;
  const txt     = dark ? Colors.darkText : Colors.lightText;
  const muted   = dark ? Colors.darkMuted : Colors.lightMuted;
  const border  = dark ? Colors.darkBorder : Colors.lightBorder;
  const surface = dark ? Colors.darkSurface : Colors.lightSurface;

  const familyId = useAppStore(s => s.familyId) ?? '';
  const userId   = useAppStore(s => s.user)?.uid ?? '';
  const children = useChildrenStore(s => s.children);

  const params   = useLocalSearchParams<{ date?: string; childId?: string }>();
  const initDate = params.date ? new Date(params.date) : new Date();

  const [title, setTitle]         = useState('');
  const [type, setType]           = useState<EventType>('school');
  const [startDate, setStartDate] = useState(initDate);
  const [hasEnd, setHasEnd]       = useState(false);
  const [endDate, setEndDate]     = useState<Date>(initDate);
  const [childId, setChildId]     = useState<string | undefined>(params.childId);
  const [location, setLocation]   = useState('');
  const [notes, setNotes]         = useState('');
  const [amount, setAmount]       = useState('');
  const [saving, setSaving]       = useState(false);

  const activeMeta = EVENT_META[type];

  // Animated scale for type card press
  const scaleRef = useRef(new Animated.Value(1)).current;
  const pressIn  = () => Animated.spring(scaleRef, { toValue: 0.97, useNativeDriver: true }).start();
  const pressOut = () => Animated.spring(scaleRef, { toValue: 1,    useNativeDriver: true }).start();

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
    <SafeAreaView style={{ flex: 1, backgroundColor: bg }} edges={['bottom']}>
      <KeyboardAvoidingView style={{ flex: 1 }} behavior={Platform.OS === 'ios' ? 'padding' : undefined}>
        <ScrollView
          contentContainerStyle={{ paddingBottom: 120 }}
          keyboardShouldPersistTaps="handled"
          showsVerticalScrollIndicator={false}
        >
          {/* ── Hero Header ── */}
          <LinearGradient
            colors={[activeMeta.color + 'EE', activeMeta.color + '99', bg]}
            style={styles.hero}
          >
            {/* Top bar */}
            <View style={styles.topBar}>
              <Pressable onPress={() => router.back()} style={styles.topBtn}>
                <Text style={styles.topBtnTxt}>✕</Text>
              </Pressable>
              <Text style={styles.heroTitle}>אירוע חדש</Text>
              <View style={{ width: 40 }} />
            </View>

            {/* Big emoji */}
            <Animated.View style={[styles.heroBadge, { transform: [{ scale: scaleRef }] }]}>
              <Text style={styles.heroEmoji}>{activeMeta.emoji}</Text>
            </Animated.View>

            {/* Title input right in the hero */}
            <TextInput
              style={[styles.heroTitleInput, { color: '#fff' }]}
              placeholder="שם האירוע…"
              placeholderTextColor="rgba(255,255,255,0.6)"
              value={title}
              onChangeText={setTitle}
              autoFocus
              returnKeyType="done"
              textAlign="center"
              selectionColor="#fff"
            />
          </LinearGradient>

          {/* ── Event Type Grid ── */}
          <View style={styles.section}>
            <SectionLabel label="סוג אירוע" muted={muted} />
            <View style={styles.typeGrid}>
              {EVENT_TYPES.map(([key, meta]) => {
                const active = type === key;
                return (
                  <Pressable
                    key={key}
                    onPress={() => { setType(key); pressIn(); setTimeout(pressOut, 150); }}
                    style={[
                      styles.typeCard,
                      { backgroundColor: cardBg, borderColor: active ? meta.color : border },
                      active && { backgroundColor: meta.color + '18' },
                      cardShadow(dark),
                    ]}
                  >
                    {active && (
                      <View style={[styles.typeCardDot, { backgroundColor: meta.color }]} />
                    )}
                    <Text style={styles.typeCardEmoji}>{meta.emoji}</Text>
                    <Text style={[styles.typeCardLabel, { color: active ? meta.color : muted }]}>
                      {meta.label}
                    </Text>
                  </Pressable>
                );
              })}
            </View>
          </View>

          {/* ── Date & Time ── */}
          <View style={styles.section}>
            <SectionLabel label="תאריך ושעה" muted={muted} />
            <View style={[styles.card, { backgroundColor: cardBg, borderColor: border }, cardShadow(dark)]}>
              <Row icon="📅" label="התחלה">
                <DateInput value={startDate} onChange={setStartDate} mode="datetime" />
              </Row>

              <View style={[styles.divider, { backgroundColor: border }]} />

              <Row icon="🏁" label="סיום">
                <Pressable
                  onPress={() => setHasEnd(v => !v)}
                  style={[
                    styles.togglePill,
                    { borderColor: hasEnd ? activeMeta.color : border },
                    hasEnd && { backgroundColor: activeMeta.color + '18' },
                  ]}
                >
                  <Text style={[styles.togglePillTxt, { color: hasEnd ? activeMeta.color : muted }]}>
                    {hasEnd ? '✓ יש סיום' : '+ הוסף'}
                  </Text>
                </Pressable>
              </Row>

              {hasEnd && (
                <>
                  <View style={[styles.divider, { backgroundColor: border }]} />
                  <Row icon="⏰" label="שעת סיום">
                    <DateInput value={endDate} onChange={setEndDate} mode="time" />
                  </Row>
                </>
              )}
            </View>
          </View>

          {/* ── Assign to Child ── */}
          {children.length > 0 && (
            <View style={styles.section}>
              <SectionLabel label="שייך לילד" muted={muted} />
              <ScrollView horizontal showsHorizontalScrollIndicator={false}>
                <View style={styles.childRow}>
                  <Pressable
                    onPress={() => setChildId(undefined)}
                    style={[
                      styles.childChip,
                      { borderColor: !childId ? activeMeta.color : border },
                      !childId && { backgroundColor: activeMeta.color + '18' },
                    ]}
                  >
                    <Text style={{ fontSize: 18 }}>👨‍👩‍👧‍👦</Text>
                    <Text style={[styles.childChipTxt, { color: !childId ? activeMeta.color : muted }]}>כולם</Text>
                  </Pressable>

                  {children.map(c => (
                    <Pressable
                      key={c.id}
                      onPress={() => setChildId(childId === c.id ? undefined : c.id)}
                      style={[
                        styles.childChip,
                        { borderColor: childId === c.id ? c.colorHex : border },
                        childId === c.id && { backgroundColor: c.colorHex + '18' },
                      ]}
                    >
                      <View style={[styles.childAvatar, { backgroundColor: c.colorHex + '30' }]}>
                        <Text style={{ fontSize: 16 }}>{c.emoji}</Text>
                      </View>
                      <Text style={[styles.childChipTxt, { color: childId === c.id ? c.colorHex : txt }]}>
                        {c.name}
                      </Text>
                    </Pressable>
                  ))}
                </View>
              </ScrollView>
            </View>
          )}

          {/* ── Details ── */}
          <View style={styles.section}>
            <SectionLabel label="פרטים נוספים" muted={muted} />
            <View style={[styles.card, { backgroundColor: cardBg, borderColor: border }, cardShadow(dark)]}>
              <Row icon="📍" label="מיקום">
                <TextInput
                  style={[styles.inlineInput, { color: txt }]}
                  placeholder="הזן מיקום…"
                  placeholderTextColor={muted}
                  value={location}
                  onChangeText={setLocation}
                  returnKeyType="next"
                  textAlign="right"
                />
              </Row>

              {(type === 'payment' || type === 'trip') && (
                <>
                  <View style={[styles.divider, { backgroundColor: border }]} />
                  <Row icon="💰" label="סכום (₪)">
                    <TextInput
                      style={[styles.inlineInput, { color: txt }]}
                      placeholder="0.00"
                      placeholderTextColor={muted}
                      value={amount}
                      onChangeText={setAmount}
                      keyboardType="decimal-pad"
                      returnKeyType="next"
                      textAlign="right"
                    />
                  </Row>
                </>
              )}

              <View style={[styles.divider, { backgroundColor: border }]} />

              <View style={styles.rowWrap}>
                <Text style={[styles.rowIcon]}>📝</Text>
                <TextInput
                  style={[styles.notesInput, { color: txt }]}
                  placeholder="הערות לאירוע…"
                  placeholderTextColor={muted}
                  value={notes}
                  onChangeText={setNotes}
                  multiline
                  numberOfLines={3}
                  textAlignVertical="top"
                  textAlign="right"
                />
              </View>
            </View>
          </View>
        </ScrollView>

        {/* ── Fixed Save Button ── */}
        <View style={[styles.footer, { backgroundColor: bg, borderTopColor: border }]}>
          <Pressable
            onPress={save}
            disabled={saving || !title.trim()}
            style={[
              styles.saveBtn,
              { backgroundColor: activeMeta.color },
              (saving || !title.trim()) && { opacity: 0.5 },
            ]}
          >
            <Text style={styles.saveBtnTxt}>
              {saving ? 'שומר…' : `שמור ${activeMeta.emoji} ${activeMeta.label}`}
            </Text>
          </Pressable>
        </View>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}

/* ── Sub-components ────────────────────────────────── */

function SectionLabel({ label, muted }: { label: string; muted: string }) {
  return <Text style={[styles.sectionLabel, { color: muted }]}>{label}</Text>;
}

function Row({ icon, label, children }: { icon: string; label: string; children: React.ReactNode }) {
  return (
    <View style={styles.row}>
      <Text style={styles.rowIcon}>{icon}</Text>
      <Text style={styles.rowLabel}>{label}</Text>
      <View style={styles.rowValue}>{children}</View>
    </View>
  );
}

/* ── Styles ─────────────────────────────────────────── */

const styles = StyleSheet.create({
  /* Hero */
  hero: {
    paddingTop: 56, paddingBottom: 32, paddingHorizontal: Spacing.xl,
    alignItems: 'center', gap: 12,
  },
  topBar: {
    flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between',
    width: '100%', marginBottom: 8,
  },
  topBtn: {
    width: 40, height: 40, borderRadius: 20,
    backgroundColor: 'rgba(255,255,255,0.2)',
    alignItems: 'center', justifyContent: 'center',
  },
  topBtnTxt: { color: '#fff', fontSize: 16, fontWeight: '700' },
  heroTitle: { color: '#fff', fontSize: FontSize.lg, fontWeight: '700' },

  heroBadge: {
    width: 72, height: 72, borderRadius: 22,
    backgroundColor: 'rgba(255,255,255,0.25)',
    alignItems: 'center', justifyContent: 'center',
    borderWidth: 2, borderColor: 'rgba(255,255,255,0.5)',
  },
  heroEmoji: { fontSize: 36 },

  heroTitleInput: {
    fontSize: FontSize['2xl'], fontWeight: '700',
    textAlign: 'center', width: '100%',
    paddingVertical: 8, letterSpacing: -0.3,
    borderBottomWidth: 1.5, borderBottomColor: 'rgba(255,255,255,0.4)',
  },

  /* Layout */
  section: { paddingHorizontal: Spacing.lg, marginTop: Spacing.xl },
  sectionLabel: {
    fontSize: FontSize.xs, letterSpacing: 1.4, fontWeight: '700',
    textTransform: 'uppercase', marginBottom: Spacing.sm,
  },

  /* Type grid — 3 columns */
  typeGrid: { flexDirection: 'row', flexWrap: 'wrap', gap: 10 },
  typeCard: {
    width: '31%', paddingVertical: 16, borderRadius: Radius.xl,
    alignItems: 'center', gap: 6, borderWidth: 1.5,
    position: 'relative', overflow: 'hidden',
  },
  typeCardDot: {
    position: 'absolute', top: 8, right: 8,
    width: 8, height: 8, borderRadius: 4,
  },
  typeCardEmoji: { fontSize: 26 },
  typeCardLabel: { fontSize: FontSize.sm, fontWeight: '700' },

  /* Card shell for rows */
  card: { borderRadius: Radius.xl, borderWidth: 1, overflow: 'hidden' },
  divider: { height: StyleSheet.hairlineWidth, marginHorizontal: Spacing.md },

  /* Row inside card */
  row: {
    flexDirection: 'row', alignItems: 'center',
    paddingHorizontal: Spacing.md, paddingVertical: 14, gap: 10,
  },
  rowWrap: {
    flexDirection: 'row', alignItems: 'flex-start',
    paddingHorizontal: Spacing.md, paddingVertical: 12, gap: 10,
  },
  rowIcon: { fontSize: 18, width: 24, textAlign: 'center' },
  rowLabel: { fontSize: FontSize.md, fontWeight: '600', color: '#6B7280', width: 72 },
  rowValue: { flex: 1, alignItems: 'flex-end' },

  /* Inline text input (right side of row) */
  inlineInput: { flex: 1, fontSize: FontSize.md, textAlign: 'right', paddingVertical: 0 },
  notesInput: { flex: 1, fontSize: FontSize.md, minHeight: 72, paddingVertical: 4 },

  /* Toggle pill */
  togglePill: {
    paddingHorizontal: 14, paddingVertical: 6,
    borderRadius: Radius.full, borderWidth: 1.5,
  },
  togglePillTxt: { fontSize: FontSize.sm, fontWeight: '700' },

  /* Child chips */
  childRow: { flexDirection: 'row', gap: 10, paddingRight: Spacing.lg },
  childChip: {
    flexDirection: 'row', alignItems: 'center', gap: 8,
    paddingHorizontal: 14, paddingVertical: 10,
    borderRadius: Radius.xl, borderWidth: 1.5,
  },
  childAvatar: { width: 28, height: 28, borderRadius: 10, alignItems: 'center', justifyContent: 'center' },
  childChipTxt: { fontSize: FontSize.sm, fontWeight: '700' },

  /* Footer save button */
  footer: {
    paddingHorizontal: Spacing.lg, paddingVertical: Spacing.md,
    paddingBottom: Spacing.xl, borderTopWidth: StyleSheet.hairlineWidth,
  },
  saveBtn: {
    borderRadius: Radius.xl, paddingVertical: 16,
    alignItems: 'center', justifyContent: 'center',
    shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.35,
    shadowRadius: 10, elevation: 6,
  },
  saveBtnTxt: { color: '#fff', fontWeight: '800', fontSize: FontSize.base, letterSpacing: 0.3 },
});
