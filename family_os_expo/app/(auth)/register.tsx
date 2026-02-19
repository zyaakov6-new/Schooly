import React, { useState } from 'react';
import {
  View, Text, TextInput, Pressable, StyleSheet,
  ScrollView, Alert, KeyboardAvoidingView, Platform, useColorScheme,
} from 'react-native';
import { router } from 'expo-router';
import { firebaseService } from '../../services/firebaseService';
import { Colors, FontSize, Radius, Spacing } from '../../utils/theme';

export default function RegisterScreen() {
  const dark = useColorScheme() === 'dark';
  const bg   = dark ? Colors.darkBg   : Colors.lightBg;
  const cardBg = dark ? Colors.darkCard : Colors.lightCard;
  const txt  = dark ? Colors.darkText : Colors.lightText;

  const [name, setName]         = useState('');
  const [email, setEmail]       = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading]   = useState(false);

  const register = async () => {
    if (name.trim().length < 2 || !email.includes('@') || password.length < 6) {
      Alert.alert('קלט שגוי', 'יש למלא את כל השדות כראוי.');
      return;
    }
    setLoading(true);
    try {
      await firebaseService.register(email.trim(), password, name.trim());
    } catch (e: any) {
      Alert.alert('ההרשמה נכשלה', e.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <KeyboardAvoidingView behavior={Platform.OS === 'ios' ? 'padding' : undefined} style={{ flex: 1, backgroundColor: bg }}>
      <ScrollView contentContainerStyle={[styles.container, { backgroundColor: bg }]} keyboardShouldPersistTaps="handled">
        <Pressable onPress={() => router.back()} style={styles.back}>
          <Text style={{ fontSize: 22 }}>→</Text>
        </Pressable>

        <Text style={[styles.h1, { color: txt }]}>יצירת חשבון</Text>
        <Text style={[styles.sub, { color: Colors.lightMuted }]}>הצטרף ל-FamilyOS ופשט את חיי המשפחה</Text>

        <View style={styles.form}>
          {[
            { label: 'שמך', value: name, set: setName, type: 'default', key: 'name' },
            { label: 'דואר אלקטרוני', value: email, set: setEmail, type: 'email-address', key: 'email' },
            { label: 'סיסמה (לפחות 6)', value: password, set: setPassword, type: 'default', key: 'pw', secure: true },
          ].map(f => (
            <TextInput
              key={f.key}
              value={f.value} onChangeText={f.set}
              placeholder={f.label} placeholderTextColor={Colors.lightMuted}
              keyboardType={f.type as any}
              autoCapitalize="none"
              secureTextEntry={f.secure}
              textAlign="right"
              style={[styles.input, { backgroundColor: cardBg, color: txt }]}
            />
          ))}

          <Pressable onPress={register} disabled={loading} style={[styles.btn, loading && { opacity: 0.6 }]}>
            <Text style={styles.btnText}>{loading ? 'יוצר…' : 'יצירת חשבון'}</Text>
          </Pressable>
        </View>

        <View style={styles.footer}>
          <Text style={{ color: Colors.lightMuted }}>כבר יש לך חשבון? </Text>
          <Pressable onPress={() => router.replace('/(auth)/login')}>
            <Text style={{ color: Colors.accent, fontWeight: '600' }}>כניסה</Text>
          </Pressable>
        </View>
      </ScrollView>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  container: { flexGrow: 1, padding: Spacing.xl, paddingTop: 60 },
  back: { marginBottom: Spacing.xl },
  h1:   { fontSize: FontSize['2xl'], fontWeight: '800', marginBottom: 4 },
  sub:  { fontSize: FontSize.base, marginBottom: Spacing.xxl, color: Colors.lightMuted },
  form: { gap: Spacing.md },
  input: {
    borderRadius: Radius.md, padding: 14, fontSize: FontSize.base,
    borderWidth: 1, borderColor: Colors.lightBorder,
  },
  btn: {
    backgroundColor: Colors.accent, borderRadius: Radius.md,
    padding: 16, alignItems: 'center', marginTop: 4,
  },
  btnText: { color: '#fff', fontSize: FontSize.base, fontWeight: '700' },
  footer: { flexDirection: 'row', justifyContent: 'center', marginTop: Spacing.xl },
});
