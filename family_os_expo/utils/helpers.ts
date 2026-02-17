import { format, isToday, isTomorrow, isYesterday } from 'date-fns';
import { he, enUS } from 'date-fns/locale';
import * as Haptics from 'expo-haptics';

export function formatDate(date: Date, locale = 'he') {
  return format(date, 'dd/MM/yyyy', { locale: locale === 'he' ? he : enUS });
}

export function formatTime(date: Date) {
  return format(date, 'HH:mm');
}

export function formatRelative(date: Date, locale = 'he') {
  if (isToday(date))     return locale === 'he' ? 'היום'   : 'Today';
  if (isTomorrow(date))  return locale === 'he' ? 'מחר'    : 'Tomorrow';
  if (isYesterday(date)) return locale === 'he' ? 'אתמול'  : 'Yesterday';
  return format(date, 'dd/MM', { locale: locale === 'he' ? he : enUS });
}

export function formatAmount(amount: number) {
  return `₪${Number.isInteger(amount) ? amount : amount.toFixed(2)}`;
}

export function generateInviteCode() {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  return Array.from({ length: 6 }, () => chars[Math.floor(Math.random() * chars.length)]).join('');
}

export function hexToRgba(hex: string, alpha: number) {
  const r = parseInt(hex.slice(1, 3), 16);
  const g = parseInt(hex.slice(3, 5), 16);
  const b = parseInt(hex.slice(5, 7), 16);
  return `rgba(${r},${g},${b},${alpha})`;
}

export function startOfDay(d: Date) {
  return new Date(d.getFullYear(), d.getMonth(), d.getDate());
}

export const haptic = {
  light:     () => Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light),
  medium:    () => Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium),
  heavy:     () => Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Heavy),
  selection: () => Haptics.selectionAsync(),
  success:   () => Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success),
};

export function getGreeting(locale = 'he') {
  const h = new Date().getHours();
  if (locale === 'he') {
    if (h < 12) return 'בוקר טוב';
    if (h < 17) return 'צהריים טובים';
    if (h < 21) return 'ערב טוב';
    return 'לילה טוב';
  }
  if (h < 12) return 'Good morning';
  if (h < 17) return 'Good afternoon';
  if (h < 21) return 'Good evening';
  return 'Good night';
}

export function isSameDay(a: Date, b: Date) {
  return a.getFullYear() === b.getFullYear() &&
         a.getMonth()    === b.getMonth()    &&
         a.getDate()     === b.getDate();
}
