import { StyleSheet } from 'react-native';

export const Colors = {
  // Backgrounds
  darkBg:      '#0D1117',
  darkSurface: '#161B22',
  darkCard:    '#1C2128',
  darkBorder:  '#30363D',
  darkText:    '#F0F6FC',
  darkMuted:   '#8B949E',

  lightBg:      '#FAFBFD',
  lightSurface: '#FFFFFF',
  lightCard:    '#F3F4F8',
  lightBorder:  '#E5E7EB',
  lightText:    '#0D1117',
  lightMuted:   '#6B7280',

  // Accent
  accent:      '#1976D2',
  accentLight: '#1E88E5',
  accentGlow:  'rgba(25,118,210,0.2)',

  // Status
  success: '#10B981',
  warning: '#F59E0B',
  error:   '#EF4444',
  info:    '#3B82F6',

  // Child palette
  childColors: ['#1976D2','#E91E63','#4CAF50','#FF9800','#9C27B0','#00BCD4'],
} as const;

export const Radius = {
  sm: 8,
  md: 12,
  lg: 16,
  xl: 20,
  xxl: 24,
  full: 999,
} as const;

export const Spacing = {
  xs: 4,
  sm: 8,
  md: 12,
  lg: 16,
  xl: 24,
  xxl: 32,
} as const;

export const FontSize = {
  xs:  11,
  sm:  12,
  md:  14,
  base: 16,
  lg:  18,
  xl:  20,
  '2xl': 24,
  '3xl': 28,
  '4xl': 32,
} as const;

export const cardShadow = (dark: boolean) => ({
  shadowColor: '#000',
  shadowOffset: { width: 0, height: 4 },
  shadowOpacity: dark ? 0.35 : 0.08,
  shadowRadius: 8,
  elevation: 4,
});
