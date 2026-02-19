/**
 * DateInput — a lightweight date/time picker that works in Expo Go
 * without any extra native dependencies. Shows a bottom-sheet modal
 * with day/month/year (and hour/minute) number inputs.
 */
import React, { useState } from 'react';
import {
  View, Text, TextInput, Pressable, Modal, StyleSheet,
  useColorScheme, KeyboardAvoidingView, Platform,
} from 'react-native';
import { Colors, FontSize, Spacing, Radius } from '../utils/theme';

interface Props {
  value: Date;
  onChange: (date: Date) => void;
  mode?: 'date' | 'time' | 'datetime';
  label?: string;
}

export function DateInput({ value, onChange, mode = 'date', label }: Props) {
  const dark   = useColorScheme() === 'dark';
  const bg     = dark ? Colors.darkCard  : Colors.lightCard;
  const txt    = dark ? Colors.darkText  : Colors.lightText;
  const muted  = dark ? Colors.darkMuted : Colors.lightMuted;
  const border = dark ? Colors.darkBorder : Colors.lightBorder;
  const sheet  = dark ? '#1C2128' : '#F4F6F8';

  const [visible, setVisible] = useState(false);

  // Local editable state while the modal is open
  const [day,    setDay]    = useState(String(value.getDate()).padStart(2, '0'));
  const [month,  setMonth]  = useState(String(value.getMonth() + 1).padStart(2, '0'));
  const [year,   setYear]   = useState(String(value.getFullYear()));
  const [hour,   setHour]   = useState(String(value.getHours()).padStart(2, '0'));
  const [minute, setMinute] = useState(String(value.getMinutes()).padStart(2, '0'));

  const open = () => {
    setDay(String(value.getDate()).padStart(2, '0'));
    setMonth(String(value.getMonth() + 1).padStart(2, '0'));
    setYear(String(value.getFullYear()));
    setHour(String(value.getHours()).padStart(2, '0'));
    setMinute(String(value.getMinutes()).padStart(2, '0'));
    setVisible(true);
  };

  const confirm = () => {
    const d = parseInt(day,   10) || 1;
    const m = parseInt(month, 10) || 1;
    const y = parseInt(year,  10) || new Date().getFullYear();
    const h = parseInt(hour,  10) || 0;
    const min = parseInt(minute, 10) || 0;
    const clamped = new Date(y, Math.min(m - 1, 11), Math.min(d, 31), h, min);
    onChange(clamped);
    setVisible(false);
  };

  // Friendly display
  const displayDate = value.toLocaleDateString('en-GB', { day: '2-digit', month: 'short', year: 'numeric' });
  const displayTime = value.toLocaleTimeString('en-GB', { hour: '2-digit', minute: '2-digit' });
  const display =
    mode === 'date'     ? displayDate :
    mode === 'time'     ? displayTime :
    `${displayDate}  ${displayTime}`;

  return (
    <>
      <Pressable onPress={open} style={[styles.trigger, { borderColor: border, backgroundColor: bg }]}>
        {label && <Text style={[styles.triggerLabel, { color: muted }]}>{label}</Text>}
        <Text style={[styles.triggerValue, { color: Colors.accent }]}>{display}</Text>
      </Pressable>

      <Modal visible={visible} transparent animationType="slide" onRequestClose={() => setVisible(false)}>
        <Pressable style={styles.overlay} onPress={() => setVisible(false)} />
        <KeyboardAvoidingView behavior={Platform.OS === 'ios' ? 'padding' : undefined}>
          <View style={[styles.sheet, { backgroundColor: sheet }]}>
            <View style={[styles.handle, { backgroundColor: muted }]} />
            <Text style={[styles.sheetTitle, { color: txt }]}>{label ?? (mode === 'time' ? 'Set time' : 'Set date')}</Text>

            {(mode === 'date' || mode === 'datetime') && (
              <View style={styles.row}>
                <Field label="Day"   value={day}   onChange={setDay}   max={2} hint="DD" txt={txt} muted={muted} border={border} bg={bg} />
                <Separator txt={muted} />
                <Field label="Month" value={month} onChange={setMonth} max={2} hint="MM" txt={txt} muted={muted} border={border} bg={bg} />
                <Separator txt={muted} />
                <Field label="Year"  value={year}  onChange={setYear}  max={4} hint="YYYY" txt={txt} muted={muted} border={border} bg={bg} flex={2} />
              </View>
            )}

            {(mode === 'time' || mode === 'datetime') && (
              <View style={[styles.row, mode === 'datetime' && { marginTop: 8 }]}>
                <Field label="Hour" value={hour} onChange={setHour} max={2} hint="HH" txt={txt} muted={muted} border={border} bg={bg} />
                <Separator txt={muted} char=":" />
                <Field label="Min"  value={minute} onChange={setMinute} max={2} hint="MM" txt={txt} muted={muted} border={border} bg={bg} />
              </View>
            )}

            <Pressable onPress={confirm} style={styles.confirmBtn}>
              <Text style={styles.confirmTxt}>Confirm</Text>
            </Pressable>
          </View>
        </KeyboardAvoidingView>
      </Modal>
    </>
  );
}

function Separator({ txt, char = '/' }: { txt: string; char?: string }) {
  return <Text style={[styles.sep, { color: txt }]}>{char}</Text>;
}

function Field({ label, value, onChange, max, hint, txt, muted, border, bg, flex = 1 }: {
  label: string; value: string; onChange: (v: string) => void;
  max: number; hint: string; txt: string; muted: string; border: string; bg: string; flex?: number;
}) {
  return (
    <View style={{ flex, alignItems: 'center' }}>
      <Text style={[styles.fieldLabel, { color: muted }]}>{label}</Text>
      <TextInput
        style={[styles.fieldInput, { color: txt, borderColor: border, backgroundColor: bg }]}
        value={value}
        onChangeText={onChange}
        keyboardType="number-pad"
        maxLength={max}
        placeholder={hint}
        placeholderTextColor={muted}
        textAlign="center"
        selectTextOnFocus
      />
    </View>
  );
}

const styles = StyleSheet.create({
  trigger: {
    flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between',
    padding: 14, borderRadius: Radius.md, borderWidth: 1,
  },
  triggerLabel: { fontSize: FontSize.md, fontWeight: '500' },
  triggerValue: { fontSize: FontSize.md, fontWeight: '600' },

  overlay: { flex: 1, backgroundColor: '#00000055' },
  sheet: {
    borderTopLeftRadius: 24, borderTopRightRadius: 24,
    padding: Spacing.lg, paddingBottom: 40, alignItems: 'center',
  },
  handle: { width: 36, height: 4, borderRadius: 2, marginBottom: 16 },
  sheetTitle: { fontSize: FontSize.lg, fontWeight: '700', marginBottom: 24 },

  row: { flexDirection: 'row', alignItems: 'flex-end', gap: 4, width: '100%' },
  sep: { fontSize: 28, fontWeight: '300', paddingBottom: 8 },

  fieldLabel: { fontSize: FontSize.xs, marginBottom: 4, letterSpacing: 0.5 },
  fieldInput: {
    width: '100%', height: 56, borderRadius: Radius.md, borderWidth: 1.5,
    fontSize: FontSize.xl, fontWeight: '700',
  },

  confirmBtn: {
    marginTop: 24, backgroundColor: Colors.accent, borderRadius: Radius.lg,
    paddingVertical: 14, width: '100%', alignItems: 'center',
  },
  confirmTxt: { color: '#fff', fontWeight: '700', fontSize: FontSize.base },
});
