import { BlurView } from 'expo-blur';
import React from 'react';
import { StyleSheet, Pressable, type ViewStyle } from 'react-native';
import { Colors, Radius } from '../utils/theme';

interface Props {
  children: React.ReactNode;
  style?: ViewStyle;
  onPress?: () => void;
  onLongPress?: () => void;
  intensity?: number;
}

export default function GlassCard({ children, style, onPress, onLongPress, intensity = 20 }: Props) {
  return (
    <Pressable onPress={onPress} onLongPress={onLongPress} style={({ pressed }) => [{ opacity: pressed ? 0.9 : 1 }]}>
      <BlurView intensity={intensity} tint="dark" style={[styles.card, style]}>
        {children}
      </BlurView>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  card: {
    borderRadius: Radius.lg,
    overflow: 'hidden',
    borderWidth: 1,
    borderColor: 'rgba(255,255,255,0.12)',
    padding: 16,
  },
});
