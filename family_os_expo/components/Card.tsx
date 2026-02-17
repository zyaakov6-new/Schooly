import React from 'react';
import { Pressable, StyleSheet, type ViewStyle } from 'react-native';
import { Colors, Radius, cardShadow } from '../utils/theme';
import { useColorScheme } from 'react-native';

interface Props {
  children: React.ReactNode;
  style?: ViewStyle;
  onPress?: () => void;
  onLongPress?: () => void;
  color?: string;
}

export default function Card({ children, style, onPress, onLongPress, color }: Props) {
  const scheme = useColorScheme();
  const dark = scheme === 'dark';
  return (
    <Pressable
      onPress={onPress}
      onLongPress={onLongPress}
      style={({ pressed }) => [
        styles.card,
        { backgroundColor: color ?? (dark ? Colors.darkCard : Colors.lightCard) },
        cardShadow(dark),
        { opacity: pressed ? 0.92 : 1 },
        style,
      ]}
    >
      {children}
    </Pressable>
  );
}

const styles = StyleSheet.create({
  card: {
    borderRadius: Radius.lg,
    padding: 16,
  },
});
