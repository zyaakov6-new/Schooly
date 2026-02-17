import React, { useState } from 'react';
import {
  View, Text, TextInput, Pressable, StyleSheet,
  ScrollView, Alert, useColorScheme,
} from 'react-native';
import Slider from '@react-native-community/slider';
import { router, useLocalSearchParams } from 'expo-router';
import { firebaseService } from '../../services/firebaseService';
import { useAppStore } from '../../store';
import { CHILD_COLORS, CHILD_EMOJIS } from '../../models';
import { Colors, FontSize, Radius, Spacing } from '../../utils/theme';
import { hexToRgba } from '../../utils/helpers';

export default function AddChildScreen() {
  const dark   = useColorScheme() === 'dark';
  const bg     = dark ? Colors.darkBg   : Colors.lightBg;
  const cardBg = dark ? Colors.darkCard : Colors.lightCard;
  const txt    = dark ? Colors.darkText : Colors.lightText;
  const { first } = useLocalSearchParams<{ first?: string }>();

  const familyId = useAppStore(s => s.familyId) ?? '';

  const [name, setName]     = useState('');
  const [school, setSchool] = useState('');
  const [cls, setCls]       = useState('');
  const [age, setAge]       = useState(8);
  const [color, setColor]   = useState(CHILD_COLORS[0]);
  const [emoji, setEmoji]   = useState(CHILD_EMOJIS[0]);
  const [loading, setLoading] = useState(false);

  const save = async () => {
    if (name.trim().length < 2 || !school.trim() || !cls.trim()) {
      Alert.alert('Fill in all fields'); return;
    }
    setLoading(true);
    try {
      await firebaseService.addChild(familyId, {
        familyId, name: name.trim(), age,
        school: school.trim(), className: cls.trim(),
        colorHex: color, emoji, createdAt: new Date(),
      });
      if (first === 'true') router.replace('/(app)');
      else router.back();
    } catch (e: any) {
      Alert.alert('Error', e.message);
    } finally { setLoading(false); }
  };

  return (
    <ScrollView style={{ flex: 1, backgroundColor: bg }} contentContainerStyle={styles.container} keyboardShouldPersistTaps="handled">
      {first !== 'true' && (
        <Pressable onPress={() => router.back()} style={styles.back}>
          <Text style={[styles.backTxt, { color: txt }]}>← Back</Text>
        </Pressable>
      )}

      <Text style={[styles.h1, { color: txt }]}>
        {first === 'true' ? 'Add your first child 👶' : 'Add child'}
      </Text>

      {/* Avatar Preview */}
      <View style={[styles.avatarPreview, { backgroundColor: hexToRgba(color, 0.15), borderColor: color }]}>
        <Text style={{ fontSize: 40 }}>{emoji}</Text>
      </View>

      {/* Emoji picker */}
      <View style={styles.row}>
        {CHILD_EMOJIS.map(e => (
          <Pressable key={e} onPress={() => setEmoji(e)}
            style={[styles.emojiBtn, emoji === e && { backgroundColor: hexToRgba(Colors.accent, 0.15), borderColor: Colors.accent, borderWidth: 1.5 }]}>
            <Text style={{ fontSize: 22 }}>{e}</Text>
          </Pressable>
        ))}
      </View>

      {/* Color picker */}
      <View style={[styles.row, { marginBottom: Spacing.xl }]}>
        {CHILD_COLORS.map(c => (
          <Pressable key={c} onPress={() => setColor(c)}
            style={[styles.colorDot, { backgroundColor: c }, color === c && styles.colorDotSelected]} />
        ))}
      </View>

      {/* Fields */}
      {[
        { placeholder: "Child's name", value: name, set: setName, cap: 'words' },
        { placeholder: 'School name', value: school, set: setSchool, cap: 'words' },
        { placeholder: 'Class / Grade (e.g. 3B)', value: cls, set: setCls, cap: 'characters' },
      ].map(f => (
        <TextInput
          key={f.placeholder} value={f.value} onChangeText={f.set}
          placeholder={f.placeholder} placeholderTextColor={Colors.lightMuted}
          autoCapitalize={f.cap as any}
          style={[styles.input, { backgroundColor: cardBg, color: txt }]}
        />
      ))}

      <Text style={[styles.label, { color: txt }]}>Age: {age} years</Text>
      <View style={{ marginBottom: Spacing.xl }}>
        <Slider
          minimumValue={3} maximumValue={18} step={1} value={age}
          onValueChange={v => setAge(v)}
          minimumTrackTintColor={Colors.accent}
          maximumTrackTintColor={Colors.lightBorder}
          thumbTintColor={Colors.accent}
        />
      </View>

      <Pressable onPress={save} disabled={loading} style={[styles.btn, loading && { opacity: 0.6 }]}>
        <Text style={styles.btnText}>{loading ? 'Saving…' : 'Add child'}</Text>
      </Pressable>

      {first === 'true' && (
        <Pressable onPress={() => router.replace('/(app)')} style={{ marginTop: Spacing.lg }}>
          <Text style={[styles.link, { textAlign: 'center' }]}>Skip for now →</Text>
        </Pressable>
      )}
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: { padding: Spacing.xl, paddingTop: 60 },
  back: { marginBottom: Spacing.xl },
  backTxt: { fontSize: FontSize.base, fontWeight: '600' },
  h1: { fontSize: FontSize['2xl'], fontWeight: '800', marginBottom: Spacing.xl },
  avatarPreview: {
    width: 80, height: 80, borderRadius: 24, borderWidth: 2,
    alignItems: 'center', justifyContent: 'center',
    alignSelf: 'center', marginBottom: Spacing.lg,
  },
  row: { flexDirection: 'row', flexWrap: 'wrap', gap: 8, justifyContent: 'center', marginBottom: Spacing.md },
  emojiBtn: { width: 44, height: 44, alignItems: 'center', justifyContent: 'center', borderRadius: 12 },
  colorDot: { width: 32, height: 32, borderRadius: 16 },
  colorDotSelected: { borderWidth: 3, borderColor: '#fff', transform: [{ scale: 1.15 }] },
  input: {
    borderRadius: Radius.md, padding: 14, fontSize: FontSize.base,
    borderWidth: 1, borderColor: Colors.lightBorder, marginBottom: Spacing.md,
  },
  label: { fontSize: FontSize.md, fontWeight: '600', marginBottom: 4 },
  btn: {
    backgroundColor: Colors.accent, borderRadius: Radius.md,
    padding: 16, alignItems: 'center',
  },
  btnText: { color: '#fff', fontSize: FontSize.base, fontWeight: '700' },
  link: { color: Colors.accent, fontWeight: '600' },
});
