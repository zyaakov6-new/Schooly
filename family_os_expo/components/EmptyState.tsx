import React from 'react';
import { View, Text, Pressable, StyleSheet, useColorScheme } from 'react-native';
import { Colors, FontSize, Spacing } from '../utils/theme';

interface Props {
  emoji: string;
  title: string;
  subtitle: string;
  actionLabel?: string;
  onAction?: () => void;
}

export default function EmptyState({ emoji, title, subtitle, actionLabel, onAction }: Props) {
  const dark = useColorScheme() === 'dark';
  return (
    <View style={styles.container}>
      <Text style={styles.emoji}>{emoji}</Text>
      <Text style={[styles.title, { color: dark ? Colors.darkText : Colors.lightText }]}>{title}</Text>
      <Text style={styles.sub}>{subtitle}</Text>
      {actionLabel && onAction && (
        <Pressable onPress={onAction} style={styles.btn}>
          <Text style={styles.btnText}>+ {actionLabel}</Text>
        </Pressable>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, alignItems: 'center', justifyContent: 'center', padding: 32, gap: Spacing.md },
  emoji: { fontSize: 64 },
  title: { fontSize: FontSize.xl, fontWeight: '700', textAlign: 'center' },
  sub: { fontSize: FontSize.md, color: Colors.lightMuted, textAlign: 'center', lineHeight: 22 },
  btn: {
    marginTop: 8, backgroundColor: Colors.accent,
    paddingHorizontal: 24, paddingVertical: 12,
    borderRadius: 12,
  },
  btnText: { color: '#fff', fontWeight: '700', fontSize: FontSize.base },
});
