import React, { useEffect, useRef } from 'react';
import { View, Animated, StyleSheet, useColorScheme } from 'react-native';
import { Colors, Radius } from '../utils/theme';

function ShimmerBox({ width, height, style }: { width: number | string; height: number; style?: any }) {
  const anim = useRef(new Animated.Value(0)).current;
  const dark = useColorScheme() === 'dark';

  useEffect(() => {
    Animated.loop(
      Animated.sequence([
        Animated.timing(anim, { toValue: 1, duration: 900, useNativeDriver: true }),
        Animated.timing(anim, { toValue: 0, duration: 900, useNativeDriver: true }),
      ]),
    ).start();
  }, []);

  const opacity = anim.interpolate({ inputRange: [0, 1], outputRange: [0.3, 0.7] });

  return (
    <Animated.View
      style={[
        {
          width: width as any, height,
          backgroundColor: dark ? Colors.darkBorder : Colors.lightBorder,
          borderRadius: Radius.sm,
          opacity,
        },
        style,
      ]}
    />
  );
}

export function TaskShimmer() {
  return (
    <View style={styles.taskRow}>
      <ShimmerBox width={28} height={28} style={{ borderRadius: 8 }} />
      <View style={{ flex: 1, gap: 8 }}>
        <ShimmerBox width="100%" height={14} />
        <ShimmerBox width={120} height={11} />
      </View>
      <ShimmerBox width={56} height={26} style={{ borderRadius: 8 }} />
    </View>
  );
}

export function ChildCardShimmer() {
  return (
    <View style={styles.childCard}>
      <ShimmerBox width={48} height={48} style={{ borderRadius: 16 }} />
      <ShimmerBox width={80} height={12} style={{ marginTop: 8 }} />
      <ShimmerBox width={56} height={10} style={{ marginTop: 4 }} />
    </View>
  );
}

export function EventShimmer() {
  return (
    <View style={styles.eventRow}>
      <ShimmerBox width={4} height={56} style={{ borderRadius: 2 }} />
      <View style={{ flex: 1, gap: 8 }}>
        <ShimmerBox width="100%" height={14} />
        <ShimmerBox width={80} height={11} />
      </View>
      <ShimmerBox width={40} height={40} style={{ borderRadius: 12 }} />
    </View>
  );
}

const styles = StyleSheet.create({
  taskRow: {
    flexDirection: 'row', alignItems: 'center',
    marginHorizontal: 16, marginVertical: 6, gap: 12,
  },
  childCard: {
    width: 150, padding: 14,
    borderRadius: 20, gap: 4,
    marginRight: 12,
  },
  eventRow: {
    flexDirection: 'row', alignItems: 'center',
    marginHorizontal: 16, marginVertical: 5, gap: 12,
  },
});
