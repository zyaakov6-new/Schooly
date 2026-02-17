import React, { useState, useRef } from 'react';
import {
  View, Text, StyleSheet, TextInput, Pressable, ScrollView,
  Animated, Alert, useColorScheme, KeyboardAvoidingView, Platform,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { router } from 'expo-router';
import { firebaseService } from '../../services/firebaseService';
import { parseMessage } from '../../services/parserService';
import { useAppStore, useChildrenStore } from '../../store';
import { EVENT_META, PRIORITY_META } from '../../models';
import { Colors, FontSize, Spacing, Radius } from '../../utils/theme';
import { formatDate, formatTime, formatAmount, haptic } from '../../utils/helpers';

export default function InboxScreen() {
  const dark    = useColorScheme() === 'dark';
  const bg      = dark ? Colors.darkBg   : Colors.lightBg;
  const cardBg  = dark ? Colors.darkCard : Colors.lightCard;
  const txt     = dark ? Colors.darkText : Colors.lightText;
  const muted   = dark ? Colors.darkMuted : Colors.lightMuted;
  const border  = dark ? Colors.darkBorder : Colors.lightBorder;

  const familyId = useAppStore(s => s.familyId) ?? '';
  const userId   = useAppStore(s => s.user)?.uid ?? '';
  const children = useChildrenStore(s => s.children);

  const [text, setText]           = useState('');
  const [parsed, setParsed]       = useState<ReturnType<typeof parseMessage> | null>(null);
  const [selectedChild, setChild] = useState<string | undefined>(undefined);
  const [saving, setSaving]       = useState(false);

  // Animation for the parse result card sliding in
  const slideAnim = useRef(new Animated.Value(40)).current;
  const opacAnim  = useRef(new Animated.Value(0)).current;

  const showResult = (r: ReturnType<typeof parseMessage>) => {
    setParsed(r);
    Animated.parallel([
      Animated.spring(slideAnim, { toValue: 0, useNativeDriver: true }),
      Animated.timing(opacAnim,  { toValue: 1, duration: 250, useNativeDriver: true }),
    ]).start();
  };

  const parse = () => {
    if (!text.trim()) return;
    haptic.selection();
    const result = parseMessage(text, { familyId, childId: selectedChild, userId });
    showResult(result);
  };

  const saveAll = async () => {
    if (!parsed) return;
    if (!familyId) { Alert.alert('Error', 'No family found.'); return; }
    const hasAnything = parsed.events.length > 0 || parsed.tasks.length > 0;
    if (!hasAnything) {
      Alert.alert('Nothing to save', 'No events or tasks were detected in this message.');
      return;
    }
    setSaving(true);
    try {
      await Promise.all([
        ...parsed.events.map(e => firebaseService.addEvent(familyId, e)),
        ...parsed.tasks.map(t => firebaseService.addTask(familyId, t)),
      ]);
      haptic.success();
      Alert.alert(
        '✅ Saved!',
        [
          parsed.events.length ? `${parsed.events.length} event${parsed.events.length > 1 ? 's' : ''}` : '',
          parsed.tasks.length  ? `${parsed.tasks.length} task${parsed.tasks.length > 1 ? 's' : ''}` : '',
        ].filter(Boolean).join(' and ') + ' added to your family.',
        [{ text: 'OK', onPress: () => { setText(''); setParsed(null); router.back(); } }],
      );
    } catch (e: any) {
      Alert.alert('Error', e.message ?? 'Failed to save.');
    } finally {
      setSaving(false);
    }
  };

  const clear = () => {
    setText('');
    setParsed(null);
    opacAnim.setValue(0);
    slideAnim.setValue(40);
  };

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: bg }}>
      <KeyboardAvoidingView style={{ flex: 1 }} behavior={Platform.OS === 'ios' ? 'padding' : undefined}>
        {/* Header */}
        <View style={styles.header}>
          <Pressable onPress={() => router.back()}>
            <Text style={{ color: Colors.accent, fontSize: FontSize.base }}>← Back</Text>
          </Pressable>
          <Text style={[styles.headerTitle, { color: txt }]}>Smart Inbox</Text>
          <View style={{ width: 60 }} />
        </View>

        <ScrollView contentContainerStyle={{ paddingBottom: 40, flexGrow: 1 }} keyboardShouldPersistTaps="handled">
          {/* Intro */}
          <View style={{ paddingHorizontal: Spacing.lg, marginBottom: Spacing.md }}>
            <Text style={[styles.intro, { color: muted }]}>
              Paste a school message, WhatsApp text, or note. FamilyOS will extract dates, events, and tasks automatically.
            </Text>
          </View>

          {/* Child selector */}
          {children.length > 0 && (
            <ScrollView horizontal showsHorizontalScrollIndicator={false}
              style={{ marginHorizontal: Spacing.lg, marginBottom: Spacing.md }}>
              <View style={{ flexDirection: 'row', gap: 8 }}>
                <Pressable
                  onPress={() => setChild(undefined)}
                  style={[styles.childChip, !selectedChild && styles.childChipActive, { borderColor: border }]}
                >
                  <Text style={[styles.childChipTxt, { color: !selectedChild ? Colors.accent : muted }]}>All kids</Text>
                </Pressable>
                {children.map(c => (
                  <Pressable
                    key={c.id}
                    onPress={() => setChild(c.id)}
                    style={[
                      styles.childChip,
                      selectedChild === c.id
                        ? { backgroundColor: c.colorHex + '22', borderColor: c.colorHex }
                        : { borderColor: border },
                    ]}
                  >
                    <Text>{c.emoji}</Text>
                    <Text style={[styles.childChipTxt, { color: selectedChild === c.id ? c.colorHex : muted }]}>
                      {c.name}
                    </Text>
                  </Pressable>
                ))}
              </View>
            </ScrollView>
          )}

          {/* Text input */}
          <View style={[styles.inputCard, { backgroundColor: cardBg, borderColor: border }]}>
            <TextInput
              style={[styles.textInput, { color: txt }]}
              placeholder={`Paste or type a message…\n\nExamples:\n• מחר יש מבחן מתמטיקה ב-09:00\n• Trip on 15/03, return at 17:00, ₪80\n• Reminder: buy: milk, bread, eggs`}
              placeholderTextColor={muted}
              value={text}
              onChangeText={t => { setText(t); if (parsed) { setParsed(null); opacAnim.setValue(0); slideAnim.setValue(40); } }}
              multiline
              textAlignVertical="top"
              autoCorrect={false}
            />
            {text.length > 0 && (
              <Pressable onPress={clear} style={styles.clearBtn}>
                <Text style={{ color: muted, fontSize: 18 }}>✕</Text>
              </Pressable>
            )}
          </View>

          {/* Parse button */}
          <Pressable
            onPress={parse}
            disabled={!text.trim()}
            style={[styles.parseBtn, !text.trim() && { opacity: 0.4 }]}
          >
            <Text style={styles.parseBtnTxt}>✨ Parse message</Text>
          </Pressable>

          {/* Parse result */}
          {parsed && (
            <Animated.View style={{ transform: [{ translateY: slideAnim }], opacity: opacAnim }}>

              {/* Summary banner */}
              <View style={[styles.summaryBanner, {
                backgroundColor: (parsed.events.length + parsed.tasks.length) > 0
                  ? Colors.accent + '22' : Colors.error + '22',
              }]}>
                <Text style={[styles.summaryTxt, {
                  color: (parsed.events.length + parsed.tasks.length) > 0 ? Colors.accent : Colors.error,
                }]}>
                  {(parsed.events.length + parsed.tasks.length) > 0
                    ? `Found ${parsed.events.length} event${parsed.events.length !== 1 ? 's' : ''} · ${parsed.tasks.length} task${parsed.tasks.length !== 1 ? 's' : ''}`
                    : 'No events or tasks detected'}
                </Text>
                {parsed.parsedDate && (
                  <Text style={[styles.summaryDate, { color: muted }]}>
                    📅 {formatDate(parsed.parsedDate)}
                  </Text>
                )}
                {parsed.amount != null && (
                  <Text style={[styles.summaryDate, { color: muted }]}>
                    💰 {formatAmount(parsed.amount)}
                  </Text>
                )}
              </View>

              {/* Events */}
              {parsed.events.length > 0 && (
                <>
                  <SectionLabel label="EVENTS DETECTED" muted={muted} />
                  {parsed.events.map((e, i) => {
                    const meta = EVENT_META[e.type];
                    return (
                      <View key={i} style={[styles.resultCard, { backgroundColor: cardBg, borderLeftColor: meta.color }]}>
                        <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8, marginBottom: 4 }}>
                          <Text style={{ fontSize: 20 }}>{meta.emoji}</Text>
                          <Text style={[styles.resultTitle, { color: txt }]}>{e.title}</Text>
                        </View>
                        <View style={styles.resultMeta}>
                          <Text style={[styles.resultMetaTxt, { color: muted }]}>
                            📅 {formatDate(e.startDate)}
                            {e.startDate.getHours() !== 0 && `  ⏰ ${formatTime(e.startDate)}`}
                            {e.endDate && `  → ${formatTime(e.endDate)}`}
                          </Text>
                        </View>
                        {e.amount != null && (
                          <Text style={[styles.resultMetaTxt, { color: muted }]}>💰 {formatAmount(e.amount)}</Text>
                        )}
                        <View style={[styles.typeTag, { backgroundColor: meta.color + '22' }]}>
                          <Text style={[styles.typeTagTxt, { color: meta.color }]}>{meta.label}</Text>
                        </View>
                      </View>
                    );
                  })}
                </>
              )}

              {/* Tasks */}
              {parsed.tasks.length > 0 && (
                <>
                  <SectionLabel label="TASKS DETECTED" muted={muted} />
                  {parsed.tasks.map((t, i) => {
                    const pMeta = PRIORITY_META[t.priority];
                    return (
                      <View key={i} style={[styles.resultCard, { backgroundColor: cardBg, borderLeftColor: pMeta.color }]}>
                        <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8 }}>
                          <View style={[styles.priorityDot, { backgroundColor: pMeta.color }]} />
                          <Text style={[styles.resultTitle, { color: txt }]}>{t.title}</Text>
                        </View>
                        {t.dueDate && (
                          <Text style={[styles.resultMetaTxt, { color: muted }]}>📅 Due {formatDate(t.dueDate)}</Text>
                        )}
                        <View style={[styles.typeTag, { backgroundColor: pMeta.color + '22' }]}>
                          <Text style={[styles.typeTagTxt, { color: pMeta.color }]}>{pMeta.label} priority</Text>
                        </View>
                      </View>
                    );
                  })}
                </>
              )}

              {/* Items list (if any, not converted to tasks) */}
              {parsed.items.length > 0 && parsed.tasks.length === 0 && (
                <>
                  <SectionLabel label="LIST ITEMS" muted={muted} />
                  <View style={[styles.resultCard, { backgroundColor: cardBg, borderLeftColor: Colors.accent }]}>
                    {parsed.items.map((item, i) => (
                      <View key={i} style={styles.listItem}>
                        <Text style={{ color: Colors.accent }}>•</Text>
                        <Text style={[styles.listItemTxt, { color: txt }]}>{item}</Text>
                      </View>
                    ))}
                  </View>
                </>
              )}

              {/* Save / Dismiss */}
              {(parsed.events.length + parsed.tasks.length) > 0 && (
                <View style={styles.actionRow}>
                  <Pressable onPress={clear} style={[styles.dismissBtn, { borderColor: border }]}>
                    <Text style={[styles.dismissTxt, { color: muted }]}>Dismiss</Text>
                  </Pressable>
                  <Pressable onPress={saveAll} disabled={saving} style={[styles.saveAllBtn, saving && { opacity: 0.5 }]}>
                    <Text style={styles.saveAllTxt}>{saving ? 'Saving…' : '✅ Save all'}</Text>
                  </Pressable>
                </View>
              )}
            </Animated.View>
          )}
        </ScrollView>
      </KeyboardAvoidingView>
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
  intro: { fontSize: FontSize.sm, lineHeight: 20 },

  inputCard: {
    marginHorizontal: Spacing.lg, borderRadius: Radius.lg, borderWidth: 1,
    marginBottom: Spacing.md, position: 'relative',
  },
  textInput: {
    minHeight: 160, padding: Spacing.md, fontSize: FontSize.md,
    lineHeight: 22, paddingRight: 44,
  },
  clearBtn: { position: 'absolute', top: 12, right: 12 },

  parseBtn: {
    marginHorizontal: Spacing.lg, backgroundColor: Colors.accent, borderRadius: Radius.lg,
    paddingVertical: 14, alignItems: 'center', marginBottom: Spacing.lg,
  },
  parseBtnTxt: { color: '#fff', fontWeight: '700', fontSize: FontSize.base },

  sectionLabel: {
    fontSize: FontSize.xs, letterSpacing: 1.2, fontWeight: '600',
    paddingHorizontal: Spacing.lg, marginBottom: 6, marginTop: 4,
  },

  summaryBanner: {
    marginHorizontal: Spacing.lg, borderRadius: Radius.md, padding: 12,
    marginBottom: Spacing.md, flexDirection: 'row', alignItems: 'center', flexWrap: 'wrap', gap: 8,
  },
  summaryTxt:  { fontWeight: '700', fontSize: FontSize.sm },
  summaryDate: { fontSize: FontSize.sm },

  resultCard: {
    marginHorizontal: Spacing.lg, borderRadius: Radius.md, padding: 14,
    marginBottom: 8, borderLeftWidth: 4, gap: 4,
  },
  resultTitle:   { fontSize: FontSize.md, fontWeight: '600', flex: 1 },
  resultMeta:    { flexDirection: 'row', flexWrap: 'wrap', gap: 4 },
  resultMetaTxt: { fontSize: FontSize.sm },
  typeTag:       { alignSelf: 'flex-start', borderRadius: Radius.full, paddingHorizontal: 10, paddingVertical: 3, marginTop: 4 },
  typeTagTxt:    { fontSize: FontSize.xs, fontWeight: '700' },

  priorityDot: { width: 8, height: 8, borderRadius: 4 },

  listItem:    { flexDirection: 'row', gap: 8, paddingVertical: 4 },
  listItemTxt: { fontSize: FontSize.md, flex: 1 },

  actionRow:   { flexDirection: 'row', gap: 12, marginHorizontal: Spacing.lg, marginTop: Spacing.md },
  dismissBtn:  {
    flex: 1, paddingVertical: 14, borderRadius: Radius.lg,
    borderWidth: 1.5, alignItems: 'center',
  },
  dismissTxt:  { fontWeight: '600', fontSize: FontSize.base },
  saveAllBtn:  { flex: 2, paddingVertical: 14, borderRadius: Radius.lg, backgroundColor: Colors.accent, alignItems: 'center' },
  saveAllTxt:  { color: '#fff', fontWeight: '700', fontSize: FontSize.base },

  childChip: {
    flexDirection: 'row', alignItems: 'center', gap: 6,
    paddingHorizontal: 14, paddingVertical: 8, borderRadius: Radius.full, borderWidth: 1.5,
  },
  childChipActive: { borderColor: Colors.accent, backgroundColor: Colors.accent + '22' },
  childChipTxt: { fontSize: FontSize.sm, fontWeight: '600' },
});
