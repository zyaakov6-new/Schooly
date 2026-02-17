import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class AppHelpers {
  static String formatDate(DateTime date, {String locale = 'he'}) {
    return DateFormat('dd/MM/yyyy', locale).format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  static String formatDateFull(DateTime date, {String locale = 'he'}) {
    return DateFormat('EEEE, dd MMMM yyyy', locale).format(date);
  }

  static String formatRelative(DateTime date, {String locale = 'he'}) {
    final now = DateTime.now();
    final diff = date.difference(now);
    final absDiff = diff.abs();

    if (absDiff.inDays == 0) {
      if (locale == 'he') return 'היום';
      return 'Today';
    } else if (absDiff.inDays == 1) {
      if (diff.isNegative) {
        return locale == 'he' ? 'אתמול' : 'Yesterday';
      }
      return locale == 'he' ? 'מחר' : 'Tomorrow';
    } else if (absDiff.inDays < 7) {
      return DateFormat('EEEE', locale).format(date);
    } else {
      return DateFormat('dd/MM', locale).format(date);
    }
  }

  static String generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();
    return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
  }

  static void hapticLight() => HapticFeedback.lightImpact();
  static void hapticMedium() => HapticFeedback.mediumImpact();
  static void hapticHeavy() => HapticFeedback.heavyImpact();
  static void hapticSelection() => HapticFeedback.selectionClick();

  static Color hexToColor(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  static String colorToHex(Color color) =>
      '#${color.value.toRadixString(16).substring(2).toUpperCase()}';

  static bool isRtl(String locale) => locale == 'he' || locale == 'ar';

  static String formatAmount(double amount) {
    return '₪${amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2)}';
  }

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static DateTime startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static DateTime endOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day, 23, 59, 59);

  static String getGreeting({String locale = 'he'}) {
    final hour = DateTime.now().hour;
    if (locale == 'he') {
      if (hour < 12) return 'בוקר טוב';
      if (hour < 17) return 'צהריים טובים';
      if (hour < 21) return 'ערב טוב';
      return 'לילה טוב';
    } else {
      if (hour < 12) return 'Good morning';
      if (hour < 17) return 'Good afternoon';
      if (hour < 21) return 'Good evening';
      return 'Good night';
    }
  }

  static void showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

extension StringExtension on String {
  bool get isHebrew => contains(RegExp(r'[\u0590-\u05FF]'));
  String get capitalize =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}

extension DateTimeExtension on DateTime {
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  bool get isPast => isBefore(DateTime.now());
  bool get isFuture => isAfter(DateTime.now());
}
