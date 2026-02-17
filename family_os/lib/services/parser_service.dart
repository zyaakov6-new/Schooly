import '../models/event.dart';
import '../models/task.dart';

/// Smart message parser – converts free text (WhatsApp, SMS, teacher notes)
/// into structured events and tasks using RegEx-based NLP.
class ParserService {
  // Hebrew/English date patterns
  static final _datePatterns = [
    // dd/mm/yyyy or dd/mm/yy
    RegExp(r'\b(\d{1,2})[./](\d{1,2})(?:[./](\d{2,4}))?\b'),
    // מחר (tomorrow)
    RegExp(r'\bמחר\b'),
    // היום (today)
    RegExp(r'\bהיום\b'),
    // יום ראשון/שני... (Sunday/Monday...)
    RegExp(r'\bיום\s+(ראשון|שני|שלישי|רביעי|חמישי|שישי|שבת)\b'),
    // next week
    RegExp(r'\bשבוע הבא\b'),
    // tomorrow in English
    RegExp(r'\btomorrow\b', caseSensitive: false),
    // today in English
    RegExp(r'\btoday\b', caseSensitive: false),
  ];

  // Time patterns (HH:MM or H:MM)
  static final _timePattern = RegExp(r'\b(\d{1,2}):(\d{2})\b');

  // Money patterns ₪50, 50 ש"ח, $20
  static final _moneyPattern =
      RegExp(r'(?:₪|ש["""]{0,1}ח|\$)\s*(\d+(?:\.\d{1,2})?)|(\d+(?:\.\d{1,2})?)\s*(?:₪|ש["""]{0,1}ח)');

  // Item list patterns (bullet points, dashes, numbered)
  static final _itemPattern =
      RegExp(r'(?:^|\n)\s*(?:[-•*]|\d+[.):])\s*(.+)', multiLine: true);

  // Return time pattern (חזור ב, חוזר ב)
  static final _returnTimePattern =
      RegExp(r'(?:חזור|חוזר|return|back)\s*(?:ב|at)?\s*(\d{1,2}:\d{2})', caseSensitive: false);

  // Payment reminder patterns
  static final _paymentWords = RegExp(
    r'(?:לשלם|תשלום|pay|payment|fee|דמי)',
    caseSensitive: false,
  );

  // Trip/excursion patterns
  static final _tripWords = RegExp(
    r'(?:טיול|excursion|trip|field trip)',
    caseSensitive: false,
  );

  // Test/exam patterns
  static final _testWords = RegExp(
    r'(?:מבחן|בחינה|test|exam|quiz)',
    caseSensitive: false,
  );

  ParseResult parse(String text, {String? familyId, String? childId}) {
    final parsedDate = _extractDate(text);
    final parsedTime = _extractTime(text);
    final amount = _extractAmount(text);
    final items = _extractItems(text);
    final returnTime = _extractReturnTime(text);

    final eventType = _detectEventType(text);
    final events = <FamilyEvent>[];
    final tasks = <FamilyTask>[];
    final reminders = <String>[];

    // Build primary event from date
    if (parsedDate != null) {
      DateTime startDate = parsedDate;
      if (parsedTime != null) {
        startDate = DateTime(
          parsedDate.year,
          parsedDate.month,
          parsedDate.day,
          parsedTime.hour,
          parsedTime.minute,
        );
      }

      DateTime? endDate;
      if (returnTime != null) {
        endDate = DateTime(
          parsedDate.year,
          parsedDate.month,
          parsedDate.day,
          returnTime.hour,
          returnTime.minute,
        );
      }

      events.add(FamilyEvent(
        id: '',
        familyId: familyId ?? '',
        title: _extractTitle(text),
        startDate: startDate,
        endDate: endDate,
        childId: childId,
        type: eventType,
        notes: text,
        amount: amount,
        createdAt: DateTime.now(),
        createdBy: '',
      ));
    }

    // Build tasks from items list
    for (final item in items) {
      tasks.add(FamilyTask(
        id: '',
        familyId: familyId ?? '',
        title: item,
        dueDate: parsedDate,
        childId: childId,
        priority: TaskPriority.medium,
        status: TaskStatus.pending,
        createdAt: DateTime.now(),
        createdBy: '',
      ));
    }

    // Payment reminder
    if (amount != null) {
      reminders.add('תשלום: ₪${amount.toStringAsFixed(0)}');
    }

    return ParseResult(
      events: events,
      tasks: tasks,
      items: items,
      amount: amount,
      parsedDate: parsedDate,
      reminders: reminders,
      rawText: text,
    );
  }

  DateTime? _extractDate(String text) {
    final now = DateTime.now();

    if (RegExp(r'\bהיום\b|\btoday\b', caseSensitive: false).hasMatch(text)) {
      return now;
    }

    if (RegExp(r'\bמחר\b|\btomorrow\b', caseSensitive: false).hasMatch(text)) {
      return now.add(const Duration(days: 1));
    }

    if (RegExp(r'\bשבוע הבא\b').hasMatch(text)) {
      return now.add(const Duration(days: 7));
    }

    // Hebrew day names
    final hebrewDays = {
      'ראשון': DateTime.sunday,
      'שני': DateTime.monday,
      'שלישי': DateTime.tuesday,
      'רביעי': DateTime.wednesday,
      'חמישי': DateTime.thursday,
      'שישי': DateTime.friday,
      'שבת': DateTime.saturday,
    };

    for (final entry in hebrewDays.entries) {
      if (text.contains(entry.key)) {
        int daysUntil = (entry.value - now.weekday + 7) % 7;
        if (daysUntil == 0) daysUntil = 7;
        return now.add(Duration(days: daysUntil));
      }
    }

    // dd/mm or dd/mm/yyyy
    final match = RegExp(r'\b(\d{1,2})[./](\d{1,2})(?:[./](\d{2,4}))?\b')
        .firstMatch(text);
    if (match != null) {
      final day = int.parse(match.group(1)!);
      final month = int.parse(match.group(2)!);
      int year = now.year;
      if (match.group(3) != null) {
        year = int.parse(match.group(3)!);
        if (year < 100) year += 2000;
      }
      return DateTime(year, month, day);
    }

    return null;
  }

  DateTime? _extractTime(String text) {
    final match = _timePattern.firstMatch(text);
    if (match == null) return null;
    final hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    if (hour > 23 || minute > 59) return null;
    return DateTime(2000, 1, 1, hour, minute);
  }

  DateTime? _extractReturnTime(String text) {
    final match = _returnTimePattern.firstMatch(text);
    if (match == null) return null;
    final parts = match.group(1)!.split(':');
    return DateTime(2000, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
  }

  double? _extractAmount(String text) {
    final match = _moneyPattern.firstMatch(text);
    if (match == null) return null;
    final raw = match.group(1) ?? match.group(2);
    return raw != null ? double.tryParse(raw) : null;
  }

  List<String> _extractItems(String text) {
    final items = <String>[];
    for (final match in _itemPattern.allMatches(text)) {
      final item = match.group(1)?.trim();
      if (item != null && item.isNotEmpty) items.add(item);
    }
    return items;
  }

  EventType _detectEventType(String text) {
    if (_tripWords.hasMatch(text)) return EventType.trip;
    if (_testWords.hasMatch(text)) return EventType.test;
    if (_paymentWords.hasMatch(text)) return EventType.payment;
    if (RegExp(r'כדורגל|כדורסל|שחייה|ספורט|soccer|football|swim', caseSensitive: false).hasMatch(text)) {
      return EventType.activity;
    }
    return EventType.school;
  }

  String _extractTitle(String text) {
    // Take the first meaningful line
    final lines = text.split('\n').where((l) => l.trim().isNotEmpty).toList();
    if (lines.isEmpty) return text.substring(0, text.length.clamp(0, 50));
    final firstLine = lines.first.trim();
    return firstLine.length > 60 ? '${firstLine.substring(0, 57)}...' : firstLine;
  }
}

class ParseResult {
  final List<FamilyEvent> events;
  final List<FamilyTask> tasks;
  final List<String> items;
  final double? amount;
  final DateTime? parsedDate;
  final List<String> reminders;
  final String rawText;

  const ParseResult({
    required this.events,
    required this.tasks,
    required this.items,
    this.amount,
    this.parsedDate,
    required this.reminders,
    required this.rawText,
  });

  bool get hasContent =>
      events.isNotEmpty || tasks.isNotEmpty || items.isNotEmpty || amount != null;
}
