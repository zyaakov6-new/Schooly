import 'package:flutter_test/flutter_test.dart';
import '../lib/services/parser_service.dart';
import '../lib/utils/helpers.dart';

void main() {
  group('ParserService', () {
    final parser = ParserService();

    test('parses Hebrew "מחר" as tomorrow', () {
      final result = parser.parse('מחר יש טיול לים');
      expect(result.parsedDate, isNotNull);
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      expect(result.parsedDate!.day, equals(tomorrow.day));
    });

    test('extracts amount with ₪ sign', () {
      final result = parser.parse('לשלם 75 ש"ח עד יום שישי');
      expect(result.amount, equals(75.0));
    });

    test('extracts date from dd/mm format', () {
      final result = parser.parse('הטיול יהיה ב-15/06');
      expect(result.parsedDate, isNotNull);
      expect(result.parsedDate!.day, equals(15));
      expect(result.parsedDate!.month, equals(6));
    });

    test('detects test/exam event type', () {
      final result = parser.parse('מחר יש מבחן במתמטיקה');
      expect(result.events.isNotEmpty, isTrue);
    });

    test('parses item list', () {
      final result = parser.parse(
          'צריך להביא:\n- כובע\n- מים\n- 50 ש"ח\n- נעלי ספורט');
      expect(result.items.length, greaterThanOrEqualTo(3));
      expect(result.amount, equals(50.0));
    });
  });

  group('AppHelpers', () {
    test('generates 6-char invite code', () {
      final code = AppHelpers.generateInviteCode();
      expect(code.length, equals(6));
      expect(RegExp(r'^[A-Z0-9]+$').hasMatch(code), isTrue);
    });

    test('formatAmount formats correctly', () {
      expect(AppHelpers.formatAmount(50), equals('₪50'));
      expect(AppHelpers.formatAmount(50.5), equals('₪50.5'));
    });

    test('isSameDay returns true for same day', () {
      final a = DateTime(2024, 3, 15, 8, 0);
      final b = DateTime(2024, 3, 15, 22, 30);
      expect(AppHelpers.isSameDay(a, b), isTrue);
    });

    test('isRtl returns true for Hebrew', () {
      expect(AppHelpers.isRtl('he'), isTrue);
      expect(AppHelpers.isRtl('en'), isFalse);
    });
  });
}
