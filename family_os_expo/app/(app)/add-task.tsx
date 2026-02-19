import React, { useState } from 'react';
import {
  View, Text, StyleSheet, ScrollView, TextInput, Pressable,
  Alert, Switch, useColorScheme,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { router, useLocalSearchParams } from 'expo-router';
import { firebaseService } from '../../services/firebaseService';
import { useAppStore, useChildrenStore } from '../../store';
import { PRIORITY_META, type TaskPriority } from '../../models';
import { Colors, FontSize, Spacing, Radius } from '../../utils/theme';
import { DateInput } from '../../components/DateInput';

const PRIORITIES = Object.entries(PRIORITY_META) as [TaskPriority, typeof PRIORITY_META[TaskPriority]][];

export default function AddTaskScreen() {
  const dark    = useColorScheme() === 'dark';
  const bg      = dark ? Colors.darkBg   : Colors.lightBg;
  const cardBg  = dark ? Colors.darkCard : Colors.lightCard;
  const txt     = dark ? Colors.darkText : Colors.lightText;
  const muted   = dark ? Colors.darkMuted : Colors.lightMuted;
  const border  = dark ? Colors.darkBorder : Colors.lightBorder;

  const familyId = useAppStore(s => s.familyId) ?? '';
  const userId   = useAppStore(s => s.user)?.uid ?? '';
  const children = useChildrenStore(s => s.children);

  const params  = useLocalSearchParams<{ childId?: string }>();

  const [title, setTitle]         = useState('');
  const [description, setDesc]    = useState('');
  const [priority, setPriority]   = useState<TaskPriority>('medium');
  const [hasDue, setHasDue]       = useState(false);
  const [dueDate, setDueDate]     = useState(new Date());
  const [childId, setChildId]     = useState<string | undefined>(params.childId);
  const [hasAmount, setHasAmount] = useState(false);
  const [amount, setAmount]       = useState('');
  const [items, setItems]         = useState('');
  const [saving, setSaving]       = useState(false);

  const save = async () => {
    if (!title.trim()) { Alert.alert('כותרת חסרה', 'אנא הזן כותרת למשימה.'); return; }
    if (!familyId)     { Alert.alert('שגיאה', 'לא נמצאה משפחה.'); return; }
    setSaving(true);
    try {
      const parsedItems = items.split('\n').map(s => s.trim()).filter(Boolean);
      await firebaseService.addTask(familyId, {
        familyId,
        title: title.trim(),
        description: description.trim() || undefined,
        priority,
        status: 'pending',
        dueDate: hasDue ? dueDate : undefined,
        childId,
        amount: hasAmount && amount ? parseFloat(amount) : undefined,
        items: parsedItems.length ? parsedItems : undefined,
        createdAt: new Date(),
        createdBy: userId,
      });
      router.back();
    } catch (e: any) {
      Alert.alert('שגיאה', e.message ?? 'שמירת המשימה נכשלה.');
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
          <Text style={[styles.headerTitle, { color: txt }]}>משימה חדשה</Text>
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
            placeholder="כותרת המשימה"
            placeholderTextColor={muted}
            value={title}
            onChangeText={setTitle}
            autoFocus
            returnKeyType="next"
          />
        </View>

        {/* Priority */}
        <SectionLabel label="עדיפות" muted={muted} />
        <View style={[styles.priorityRow, { marginHorizontal: Spacing.lg, marginBottom: Spacing.md }]}>
          {PRIORITIES.map(([key, meta]) => (
            <Pressable
              key={key}
              onPress={() => setPriority(key)}
              style={[
                styles.priorityChip,
                { borderColor: priority === key ? meta.color : border },
                priority === key && { backgroundColor: meta.color + '22' },
              ]}
            >
              <View style={[styles.priorityDot, { backgroundColor: meta.color }]} />
              <Text style={[styles.priorityLabel, { color: priority === key ? meta.color : muted }]}>
                {meta.label}
              </Text>
            </Pressable>
          ))}
        </View>

        {/* Due date */}
        <SectionLabel label="תאריך יעד" muted={muted} />
        <View style={[styles.card, { backgroundColor: cardBg }]}>
          <View style={[styles.switchRow, { borderBottomColor: border, borderBottomWidth: hasDue ? 0.5 : 0 }]}>
            <Text style={[styles.switchLabel, { color: txt }]}>הגדר תאריך יעד</Text>
            <Switch value={hasDue} onValueChange={setHasDue} trackColor={{ true: Colors.accent }} />
          </View>
          {hasDue && (
            <View style={{ padding: 12 }}>
              <DateInput value={dueDate} onChange={setDueDate} mode="date" label="תאריך יעד" />
            </View>
          )}
        </View>

        {/* Child */}
        {children.length > 0 && (
          <>
            <SectionLabel label="שייך לילד" muted={muted} />
            <ScrollView horizontal showsHorizontalScrollIndicator={false}
              style={{ marginHorizontal: Spacing.lg, marginBottom: Spacing.md }}>
              <View style={{ flexDirection: 'row', gap: 8 }}>
                <Pressable
                  onPress={() => setChildId(undefined)}
                  style={[styles.childChip, !childId && styles.childChipActive, { borderColor: border }]}
                >
                  <Text style={[styles.childChipTxt, { color: !childId ? Colors.accent : muted }]}>כללי</Text>
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
            style={[styles.fieldInput, { color: txt, borderBottomColor: border, borderBottomWidth: 0.5 }]}
            placeholder="📝 תיאור (אופציונלי)"
            placeholderTextColor={muted}
            value={description}
            onChangeText={setDesc}
            multiline
            numberOfLines={2}
            textAlignVertical="top"
            textAlign="right"
          />
          <View style={[styles.switchRow, { borderBottomColor: border, borderBottomWidth: hasAmount ? 0.5 : 0 }]}>
            <Text style={[styles.switchLabel, { color: txt }]}>💰 תשלום נדרש</Text>
            <Switch value={hasAmount} onValueChange={setHasAmount} trackColor={{ true: Colors.accent }} />
          </View>
          {hasAmount && (
            <TextInput
              style={[styles.fieldInput, { color: txt, borderBottomColor: border, borderBottomWidth: 0.5 }]}
              placeholder="סכום בש״ח"
              placeholderTextColor={muted}
              value={amount}
              onChangeText={setAmount}
              keyboardType="decimal-pad"
              returnKeyType="next"
              textAlign="right"
            />
          )}
          <TextInput
            style={[styles.fieldInput, styles.checklistInput, { color: txt }]}
            placeholder={`✅ פריטי רשימה (שורה לכל פריט)\n- פריט 1\n- פריט 2`}
            placeholderTextColor={muted}
            value={items}
            onChangeText={setItems}
            multiline
            numberOfLines={4}
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

  priorityRow: { flexDirection: 'row', gap: 8 },
  priorityChip: {
    flex: 1, flexDirection: 'row', alignItems: 'center', justifyContent: 'center',
    gap: 6, paddingVertical: 10, borderRadius: Radius.md, borderWidth: 1.5,
  },
  priorityDot:   { width: 8, height: 8, borderRadius: 4 },
  priorityLabel: { fontSize: FontSize.sm, fontWeight: '600' },

  switchRow:  { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', padding: 14 },
  switchLabel: { fontSize: FontSize.md, fontWeight: '500' },

  childChip: {
    flexDirection: 'row', alignItems: 'center', gap: 6,
    paddingHorizontal: 14, paddingVertical: 8, borderRadius: Radius.full, borderWidth: 1.5,
  },
  childChipActive: { borderColor: Colors.accent, backgroundColor: Colors.accent + '22' },
  childChipTxt: { fontSize: FontSize.sm, fontWeight: '600' },

  fieldInput:     { padding: 14, fontSize: FontSize.md },
  checklistInput: { minHeight: 100 },
});
