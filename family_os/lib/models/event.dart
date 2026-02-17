import 'package:cloud_firestore/cloud_firestore.dart';

enum EventType { school, test, activity, family, payment, trip }

extension EventTypeExtension on EventType {
  String get label {
    switch (this) {
      case EventType.school:
        return 'School';
      case EventType.test:
        return 'Test';
      case EventType.activity:
        return 'Activity';
      case EventType.family:
        return 'Family';
      case EventType.payment:
        return 'Payment';
      case EventType.trip:
        return 'Trip';
    }
  }

  String get emoji {
    switch (this) {
      case EventType.school:
        return '🏫';
      case EventType.test:
        return '📝';
      case EventType.activity:
        return '⚽';
      case EventType.family:
        return '👨‍👩‍👧‍👦';
      case EventType.payment:
        return '💰';
      case EventType.trip:
        return '🚌';
    }
  }

  String get colorHex {
    switch (this) {
      case EventType.school:
        return '#1976D2';
      case EventType.test:
        return '#EF4444';
      case EventType.activity:
        return '#10B981';
      case EventType.family:
        return '#F59E0B';
      case EventType.payment:
        return '#8B5CF6';
      case EventType.trip:
        return '#06B6D4';
    }
  }
}

class RecurringRule {
  final String frequency; // daily, weekly, monthly
  final int interval;
  final List<int>? daysOfWeek;
  final DateTime? until;

  const RecurringRule({
    required this.frequency,
    this.interval = 1,
    this.daysOfWeek,
    this.until,
  });

  factory RecurringRule.fromMap(Map<String, dynamic> map) => RecurringRule(
        frequency: map['frequency'] as String? ?? 'weekly',
        interval: (map['interval'] as num?)?.toInt() ?? 1,
        daysOfWeek:
            (map['daysOfWeek'] as List?)?.map((e) => e as int).toList(),
        until: (map['until'] as Timestamp?)?.toDate(),
      );

  Map<String, dynamic> toMap() => {
        'frequency': frequency,
        'interval': interval,
        'daysOfWeek': daysOfWeek,
        'until': until != null ? Timestamp.fromDate(until!) : null,
      };
}

class FamilyEvent {
  final String id;
  final String familyId;
  final String title;
  final DateTime startDate;
  final DateTime? endDate;
  final String? childId;
  final EventType type;
  final String? location;
  final String? notes;
  final double? amount;
  final bool isRecurring;
  final RecurringRule? recurringRule;
  final DateTime createdAt;
  final String createdBy;

  const FamilyEvent({
    required this.id,
    required this.familyId,
    required this.title,
    required this.startDate,
    this.endDate,
    this.childId,
    required this.type,
    this.location,
    this.notes,
    this.amount,
    this.isRecurring = false,
    this.recurringRule,
    required this.createdAt,
    required this.createdBy,
  });

  factory FamilyEvent.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FamilyEvent(
      id: doc.id,
      familyId: data['familyId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      startDate:
          (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (data['endDate'] as Timestamp?)?.toDate(),
      childId: data['childId'] as String?,
      type: EventType.values.firstWhere(
        (e) => e.name == (data['type'] as String? ?? 'school'),
        orElse: () => EventType.school,
      ),
      location: data['location'] as String?,
      notes: data['notes'] as String?,
      amount: (data['amount'] as num?)?.toDouble(),
      isRecurring: data['isRecurring'] as bool? ?? false,
      recurringRule: data['recurringRule'] != null
          ? RecurringRule.fromMap(
              data['recurringRule'] as Map<String, dynamic>)
          : null,
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: data['createdBy'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() => {
        'familyId': familyId,
        'title': title,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
        'childId': childId,
        'type': type.name,
        'location': location,
        'notes': notes,
        'amount': amount,
        'isRecurring': isRecurring,
        'recurringRule': recurringRule?.toMap(),
        'createdAt': Timestamp.fromDate(createdAt),
        'createdBy': createdBy,
      };

  FamilyEvent copyWith({
    String? id,
    String? familyId,
    String? title,
    DateTime? startDate,
    DateTime? endDate,
    String? childId,
    EventType? type,
    String? location,
    String? notes,
    double? amount,
    bool? isRecurring,
    RecurringRule? recurringRule,
    DateTime? createdAt,
    String? createdBy,
  }) =>
      FamilyEvent(
        id: id ?? this.id,
        familyId: familyId ?? this.familyId,
        title: title ?? this.title,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        childId: childId ?? this.childId,
        type: type ?? this.type,
        location: location ?? this.location,
        notes: notes ?? this.notes,
        amount: amount ?? this.amount,
        isRecurring: isRecurring ?? this.isRecurring,
        recurringRule: recurringRule ?? this.recurringRule,
        createdAt: createdAt ?? this.createdAt,
        createdBy: createdBy ?? this.createdBy,
      );

  bool get isToday {
    final now = DateTime.now();
    return startDate.year == now.year &&
        startDate.month == now.month &&
        startDate.day == now.day;
  }
}
