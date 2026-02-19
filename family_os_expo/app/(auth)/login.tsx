import React, { useState } from 'react';
import {
  View, Text, TextInput, Pressable, StyleSheet,
  ScrollView, Alert, KeyboardAvoidingView, Platform, useColorScheme,
} from 'react-native';
import { router } from 'expo-router';
import { firebaseService } from '../../services/firebaseService';
import { Colors, FontSize, Radius, Spacing } from '../../utils/theme';

export default function LoginScreen() {
  const dark = useColorScheme() === 'dark';
  const [email, setEmail]       = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading]   = useState(false);
  const [showPw, setShowPw]     = useState(false);

  const login = async () => {
    if (!email.includes('@') || password.length < 6) {
      Alert.alert('קלט שגוי', 'יש להזין כתובת מייל וסיסמה תקינים (לפחות 6 תווים)');
      return;
    }
    setLoading(true);
    try {
      await firebaseService.login(email.trim(), password);
      // _layout.tsx will handle the redirect
    } catch (e: any) {
      Alert.alert('הכניסה נכשלה', e.message);
    } finally {
      setLoading(false);
    }
  };

  const bg  = dark ? Colors.darkBg      : Colors.lightBg;
  const cardBg = dark ? Colors.darkCard : Colors.lightCard;
  const txt = dark ? Colors.darkText    : Colors.lightText;

  return (
    <KeyboardAvoidingView behavior={Platform.OS === 'ios' ? 'padding' : undefined} style={{ flex: 1, backgroundColor: bg }}>
      <ScrollView contentContainerStyle={[styles.container, { backgroundColor: bg }]} keyboardShouldPersistTaps="handled">
        <Text style={styles.hero}>👋</Text>
        <Text style={[styles.h1, { color: txt }]}>ברוך שובך</Text>
        <Text style={[styles.sub, { color: Colors.lightMuted }]}>כניסה לחשבון המשפחה</Text>

        <View style={styles.form}>
          <TextInput
            value={email} onChangeText={setEmail}
            placeholder="דואר אלקטרוני" placeholderTextColor={Colors.lightMuted}
            keyboardType="email-address" autoCapitalize="none" returnKeyType="next"
            textAlign="right"
            style={[styles.input, { backgroundColor: cardBg, color: txt }]}
          />
          <View style={styles.pwWrap}>
            <TextInput
              value={password} onChangeText={setPassword}
              placeholder="סיסמה" placeholderTextColor={Colors.lightMuted}
              secureTextEntry={!showPw} returnKeyType="done" onSubmitEditing={login}
              textAlign="right"
              style={[styles.input, { backgroundColor: cardBg, color: txt, flex: 1 }]}
            />
            <Pressable onPress={() => setShowPw(v => !v)} style={styles.eyeBtn}>
              <Text style={{ fontSize: 18 }}>{showPw ? '🙈' : '👁'}</Text>
            </Pressable>
          </View>

          <Pressable onPress={login} disabled={loading} style={[styles.btn, loading && { opacity: 0.6 }]}>
            <Text style={styles.btnText}>{loading ? 'מתחבר…' : 'כניסה'}</Text>
          </Pressable>

          <Pressable onPress={() => firebaseService.resetPassword(email.trim())}>
            <Text style={styles.link}>שכחת סיסמה?</Text>
          </Pressable>
        </View>

        <View style={styles.footer}>
          <Text style={{ color: Colors.lightMuted }}>חדש ב-FamilyOS? </Text>
          <Pressable onPress={() => router.push('/(auth)/register')}>
            <Text style={styles.link}>יצירת חשבון</Text>
          </Pressable>
        </View>
      </ScrollView>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  container: { flexGrow: 1, padding: Spacing.xl, paddingTop: 80 },
  hero: { fontSize: 52, marginBottom: Spacing.lg },
  h1:   { fontSize: FontSize['3xl'], fontWeight: '800', marginBottom: 4 },
  sub:  { fontSize: FontSize.base, marginBottom: Spacing.xxl },
  form: { gap: Spacing.md },
  input: {
    borderRadius: Radius.md, padding: 14, fontSize: FontSize.base,
    borderWidth: 1, borderColor: Colors.lightBorder,
  },
  pwWrap: { flexDirection: 'row', alignItems: 'center', gap: 8 },
  eyeBtn: { padding: 12 },
  btn: {
    backgroundColor: Colors.accent, borderRadius: Radius.md,
    padding: 16, alignItems: 'center', marginTop: 4,
  },
  btnText: { color: '#fff', fontSize: FontSize.base, fontWeight: '700' },
  link: { color: Colors.accent, fontWeight: '600', fontSize: FontSize.md },
  footer: { flexDirection: 'row', justifyContent: 'center', marginTop: Spacing.xl },
});
