import React, { useState } from 'react';
import {
  View, Text, TextInput, Pressable, StyleSheet,
  ScrollView, Alert, KeyboardAvoidingView, Platform, useColorScheme,
} from 'react-native';
import { router } from 'expo-router';
import { firebaseService } from '../../services/firebaseService';
import { useAppStore } from '../../store';
import { Colors, FontSize, Radius, Spacing } from '../../utils/theme';

export default function CreateFamilyScreen() {
  const dark   = useColorScheme() === 'dark';
  const bg     = dark ? Colors.darkBg   : Colors.lightBg;
  const cardBg = dark ? Colors.darkCard : Colors.lightCard;
  const txt    = dark ? Colors.darkText : Colors.lightText;

  const setFamilyId = useAppStore(s => s.setFamilyId);
  const [familyName, setFamilyName] = useState('');
  const [inviteCode, setInviteCode] = useState('');
  const [mode, setMode] = useState<'create' | 'join'>('create');
  const [loading, setLoading] = useState(false);

  const create = async () => {
    if (familyName.trim().length < 2) { Alert.alert('Enter a family name'); return; }
    setLoading(true);
    try {
      const family = await firebaseService.createFamily(familyName.trim());
      await setFamilyId(family.id);
      router.replace('/(auth)/add-child?first=true');
    } catch (e: any) {
      Alert.alert('Error', e.message);
    } finally { setLoading(false); }
  };

  const join = async () => {
    if (inviteCode.trim().length !== 6) { Alert.alert('Enter a valid 6-character code'); return; }
    setLoading(true);
    try {
      const family = await firebaseService.getFamilyByCode(inviteCode.trim());
      if (!family) { Alert.alert('Invalid code', 'No family found with that code.'); return; }
      await firebaseService.joinFamily(family.id);
      await setFamilyId(family.id);
      router.replace('/(app)');
    } catch (e: any) {
      Alert.alert('Error', e.message);
    } finally { setLoading(false); }
  };

  return (
    <KeyboardAvoidingView behavior={Platform.OS === 'ios' ? 'padding' : undefined} style={{ flex: 1, backgroundColor: bg }}>
      <ScrollView contentContainerStyle={[styles.container, { backgroundColor: bg }]} keyboardShouldPersistTaps="handled">
        <Text style={styles.icon}>🏠</Text>
        <Text style={[styles.h1, { color: txt }]}>{mode === 'create' ? 'Create your family' : 'Join family'}</Text>
        <Text style={[styles.sub, { color: Colors.lightMuted }]}>
          {mode === 'create' ? 'Set up your family space in FamilyOS' : 'Enter the invite code your partner shared'}
        </Text>

        {mode === 'create' ? (
          <>
            <TextInput
              value={familyName} onChangeText={setFamilyName}
              placeholder="Family name (e.g. The Cohen Family)"
              placeholderTextColor={Colors.lightMuted}
              autoCapitalize="words"
              style={[styles.input, { backgroundColor: cardBg, color: txt }]}
            />
            <Pressable onPress={create} disabled={loading} style={[styles.btn, loading && { opacity: 0.6 }]}>
              <Text style={styles.btnText}>{loading ? 'Creating…' : 'Create Family'}</Text>
            </Pressable>
          </>
        ) : (
          <>
            <TextInput
              value={inviteCode} onChangeText={v => setInviteCode(v.toUpperCase())}
              placeholder="ABC123" placeholderTextColor={Colors.lightMuted}
              maxLength={6} autoCapitalize="characters"
              style={[styles.input, { backgroundColor: cardBg, color: txt, letterSpacing: 6, fontSize: 24, textAlign: 'center' }]}
            />
            <Pressable onPress={join} disabled={loading} style={[styles.btn, loading && { opacity: 0.6 }]}>
              <Text style={styles.btnText}>{loading ? 'Joining…' : 'Join Family'}</Text>
            </Pressable>
          </>
        )}

        <Pressable onPress={() => setMode(m => m === 'create' ? 'join' : 'create')} style={{ marginTop: Spacing.xl }}>
          <Text style={[styles.link, { textAlign: 'center' }]}>
            {mode === 'create' ? 'Have an invite code? Join family →' : 'Create a new family instead'}
          </Text>
        </Pressable>
      </ScrollView>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  container: { flexGrow: 1, padding: Spacing.xl, paddingTop: 80 },
  icon: { fontSize: 56, marginBottom: Spacing.lg },
  h1:   { fontSize: FontSize['2xl'], fontWeight: '800', marginBottom: 4 },
  sub:  { fontSize: FontSize.base, marginBottom: Spacing.xxl, color: Colors.lightMuted },
  input: {
    borderRadius: Radius.md, padding: 14, fontSize: FontSize.base,
    borderWidth: 1, borderColor: Colors.lightBorder, marginBottom: Spacing.md,
  },
  btn: {
    backgroundColor: Colors.accent, borderRadius: Radius.md,
    padding: 16, alignItems: 'center',
  },
  btnText: { color: '#fff', fontSize: FontSize.base, fontWeight: '700' },
  link: { color: Colors.accent, fontWeight: '600' },
});
