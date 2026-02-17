import { Tabs } from 'expo-router';
import { useColorScheme } from 'react-native';
import { Colors } from '../../utils/theme';

const TAB_ICONS: Record<string, string> = {
  index: '⊞', calendar: '📅', tasks: '✓', kids: '👧', profile: '👤',
};

export default function AppLayout() {
  const dark = useColorScheme() === 'dark';

  return (
    <Tabs
      screenOptions={({ route }) => ({
        headerShown: false,
        tabBarStyle: {
          backgroundColor: dark ? Colors.darkSurface : Colors.lightSurface,
          borderTopColor: dark ? Colors.darkBorder : Colors.lightBorder,
          borderTopWidth: 0.5,
          height: 60,
          paddingBottom: 8,
        },
        tabBarActiveTintColor: Colors.accent,
        tabBarInactiveTintColor: dark ? Colors.darkMuted : Colors.lightMuted,
        tabBarLabel: (() => {
          const labels: Record<string, string> = {
            index: 'Home', calendar: 'Calendar', tasks: 'Tasks', kids: 'Kids', profile: 'Profile',
          };
          return labels[route.name] ?? route.name;
        })(),
      })}
    >
      <Tabs.Screen name="index"    options={{ title: 'Home' }} />
      <Tabs.Screen name="calendar" options={{ title: 'Calendar' }} />
      <Tabs.Screen name="tasks"    options={{ title: 'Tasks' }} />
      <Tabs.Screen name="kids"     options={{ title: 'Kids' }} />
      <Tabs.Screen name="profile"  options={{ title: 'Profile' }} />
      {/* Modal screens — hidden from tab bar */}
      <Tabs.Screen name="add-event" options={{ href: null }} />
      <Tabs.Screen name="add-task"  options={{ href: null }} />
      <Tabs.Screen name="inbox"     options={{ href: null }} />
    </Tabs>
  );
}
