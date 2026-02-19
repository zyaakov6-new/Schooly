import React, { useRef, useState } from 'react';
import {
  View, Text, StyleSheet, FlatList, Pressable,
  Dimensions, Animated,
} from 'react-native';
import { router } from 'expo-router';
import { LinearGradient } from 'expo-linear-gradient';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { STORAGE_KEYS } from '../utils/constants';
import { Colors, FontSize, Spacing } from '../utils/theme';

const { width } = Dimensions.get('window');

const PAGES = [
  { emoji: '👨‍👩‍👧‍👦', title: 'אפליקציה אחת.\nכל הילדים.\nאפס כאוס.', sub: 'החלף את הכאוס בוואטסאפ, פתקים ו-5 אפליקציות שונות — בדשבורד אחד יפה.', color: Colors.accent },
  { emoji: '📅', title: 'הכל במבט\nאחד.', sub: 'לוחות זמנים, מבחנים, פעילויות ותשלומים — גלויים בבת אחת לכל ילד.', color: '#10B981' },
  { emoji: '✅', title: 'החלק לסיום.\nנשום בקלות.', sub: 'החלק ימינה להשלמת משימות. תיבת הדואר החכמה מזהה תאריכים ואירועים מהודעות המורים.', color: '#8B5CF6' },
];

export default function OnboardingScreen() {
  const [index, setIndex] = useState(0);
  const listRef = useRef<FlatList>(null);

  const finish = async () => {
    await AsyncStorage.setItem(STORAGE_KEYS.onboarding, 'true');
    router.replace('/(auth)/login');
  };

  const next = () => {
    if (index < PAGES.length - 1) {
      listRef.current?.scrollToIndex({ index: index + 1, animated: true });
      setIndex(i => i + 1);
    } else {
      finish();
    }
  };

  const page = PAGES[index];

  return (
    <LinearGradient colors={['#0D1117', '#161B22']} style={styles.root}>
      {/* Skip */}
      <Pressable onPress={finish} style={styles.skip}>
        <Text style={styles.skipText}>דלג</Text>
      </Pressable>

      <FlatList
        ref={listRef}
        data={PAGES}
        keyExtractor={(_, i) => String(i)}
        horizontal pagingEnabled scrollEnabled={false}
        showsHorizontalScrollIndicator={false}
        renderItem={({ item }) => (
          <View style={styles.page}>
            <Text style={styles.emoji}>{item.emoji}</Text>
            <Text style={styles.title}>{item.title}</Text>
            <Text style={styles.sub}>{item.sub}</Text>
          </View>
        )}
      />

      {/* Dots */}
      <View style={styles.dots}>
        {PAGES.map((_, i) => (
          <Animated.View
            key={i}
            style={[styles.dot, {
              width: i === index ? 24 : 8,
              backgroundColor: i === index ? page.color : Colors.darkBorder,
            }]}
          />
        ))}
      </View>

      {/* CTA */}
      <Pressable onPress={next} style={[styles.cta, { backgroundColor: page.color }]}>
        <Text style={styles.ctaText}>{index < PAGES.length - 1 ? '← הבא' : 'בואו נתחיל'}</Text>
      </Pressable>
    </LinearGradient>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1 },
  skip: { alignSelf: 'flex-end', padding: Spacing.lg, marginTop: 40 },
  skipText: { color: Colors.darkMuted, fontSize: FontSize.md },
  page: { width, padding: 40, alignItems: 'center', justifyContent: 'center', flex: 1 },
  emoji: { fontSize: 96, marginBottom: 32 },
  title: { fontSize: FontSize['3xl'], fontWeight: '800', color: '#fff', textAlign: 'center', lineHeight: 40, marginBottom: 16 },
  sub: { fontSize: FontSize.base, color: Colors.darkMuted, textAlign: 'center', lineHeight: 24 },
  dots: { flexDirection: 'row', justifyContent: 'center', gap: 8, marginBottom: 24 },
  dot: { height: 8, borderRadius: 4 },
  cta: {
    marginHorizontal: 32, marginBottom: 48,
    padding: 18, borderRadius: 16, alignItems: 'center',
  },
  ctaText: { color: '#fff', fontSize: FontSize.lg, fontWeight: '800' },
});
