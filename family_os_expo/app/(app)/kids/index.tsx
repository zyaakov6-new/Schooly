import React from 'react';
import { View, Text, StyleSheet, FlatList, Pressable, useColorScheme, Share } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { router } from 'expo-router';
import { useChildrenStore, useFamilyStore } from '../../../store';
import { Colors, FontSize, Spacing, Radius, cardShadow } from '../../../utils/theme';
import { hexToRgba } from '../../../utils/helpers';
import EmptyState from '../../../components/EmptyState';

export default function KidsScreen() {
  const dark      = useColorScheme() === 'dark';
  const bg        = dark ? Colors.darkBg   : Colors.lightBg;
  const txt       = dark ? Colors.darkText : Colors.lightText;
  const children  = useChildrenStore(s => s.children);
  const family    = useFamilyStore(s => s.family);

  const shareInvite = async () => {
    if (!family?.inviteCode) return;
    await Share.share({
      message: `הצטרף למשפחה שלנו ב-FamilyOS! השתמש בקוד ההזמנה: ${family.inviteCode}`,
      title: 'הזמנה ל-FamilyOS',
    });
  };

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: bg }}>
      <View style={styles.header}>
        <Text style={[styles.title, { color: txt }]}>הילדים שלי</Text>
        <Pressable onPress={shareInvite} style={styles.inviteBtn}>
          <Text style={{ fontSize: 18 }}>👥</Text>
        </Pressable>
      </View>

      {children.length === 0 ? (
        <EmptyState
          emoji="👶" title="אין ילדים עדיין"
          subtitle="הוסף את ילדך הראשון והתחל לנהל את הלוח שלו"
          actionLabel="הוסף ילד" onAction={() => router.push('/(auth)/add-child')}
        />
      ) : (
        <FlatList
          data={children}
          keyExtractor={c => c.id}
          contentContainerStyle={{ padding: Spacing.lg, gap: 12, paddingBottom: 40 }}
          renderItem={({ item }) => {
            const color = item.colorHex;
            return (
              <Pressable
                onPress={() => router.push(`/(app)/kids/${item.id}`)}
                style={[
                  styles.row,
                  { backgroundColor: dark ? Colors.darkCard : Colors.lightCard },
                  { borderColor: hexToRgba(color, 0.25) },
                  cardShadow(dark),
                ]}
              >
                <View style={[styles.avatar, { backgroundColor: hexToRgba(color, 0.12), borderRadius: 18 }]}>
                  <Text style={{ fontSize: 28 }}>{item.emoji}</Text>
                </View>
                <View style={{ flex: 1 }}>
                  <Text style={[styles.name, { color: txt }]}>{item.name}</Text>
                  <Text style={styles.sub}>{item.age} שנים · {item.school} · {item.className}</Text>
                </View>
                <Text style={[styles.chevron, { color: dark ? Colors.darkMuted : Colors.lightMuted }]}>›</Text>
              </Pressable>
            );
          }}
        />
      )}

      <Pressable onPress={() => router.push('/(auth)/add-child')} style={styles.fab}>
        <Text style={styles.fabTxt}>＋ הוסף ילד</Text>
      </Pressable>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  header: {
    flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between',
    paddingHorizontal: Spacing.lg, paddingTop: Spacing.lg, paddingBottom: Spacing.sm,
  },
  title: { fontSize: FontSize['2xl'], fontWeight: '800' },
  inviteBtn: { padding: 8 },
  row: {
    flexDirection: 'row', alignItems: 'center', gap: 14,
    padding: 16, borderRadius: Radius.xl, borderWidth: 1.5,
  },
  avatar: { width: 56, height: 56, alignItems: 'center', justifyContent: 'center' },
  name:   { fontSize: FontSize.base, fontWeight: '700' },
  sub:    { fontSize: FontSize.sm, color: Colors.lightMuted, marginTop: 2 },
  chevron: { fontSize: 22, fontWeight: '300' },
  fab: {
    position: 'absolute', bottom: 24, right: 20,
    backgroundColor: Colors.accent, paddingHorizontal: 20, paddingVertical: 14,
    borderRadius: Radius.full, shadowColor: Colors.accent,
    shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.5, shadowRadius: 12, elevation: 8,
  },
  fabTxt: { color: '#fff', fontWeight: '700', fontSize: FontSize.base },
});
