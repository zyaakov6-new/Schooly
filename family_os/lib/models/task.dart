import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskPriority { low, medium, high, urgent }

enum TaskStatus { pending, inProgress, done, snoozed }

extension TaskPriorityExtension on TaskPriority {
  String get label {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.urgent:
        return 'Urgent';
    }
  }

  String get colorHex {
    switch (this) {
      case TaskPriority.low:
        return '#10B981';
      case TaskPriority.medium:
        return '#F59E0B';
      case TaskPriority.high:
        return '#EF4444';
      case TaskPriority.urgent:
        return '#DC2626';
    }
  }
}

extension TaskStatusExtension on TaskStatus {
  bool get isComplete => this == TaskStatus.done;
}

class FamilyTask {
  final String id;
  final String familyId;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final String? childId;
  final String? assigneeId;
  final TaskPriority priority;
  final TaskStatus status;
  final DateTime? reminderDate;
  final String? relatedEventId;
  final double? amount;
  final List<String> items;
  final DateTime createdAt;
  final String createdBy;
  final DateTime? completedAt;

  const FamilyTask({
    required this.id,
    required this.familyId,
    required this.title,
    this.description,
    this.dueDate,
    this.childId,
    this.assigneeId,
    required this.priority,
    required this.status,
    this.reminderDate,
    this.relatedEventId,
    this.amount,
    this.items = const [],
    required this.createdAt,
    required this.createdBy,
    this.completedAt,
  });

  factory FamilyTask.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FamilyTask(
      id: doc.id,
      familyId: data['familyId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String?,
      dueDate: (data['dueDate'] as Timestamp?)?.toDate(),
      childId: data['childId'] as String?,
      assigneeId: data['assigneeId'] as String?,
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == (data['priority'] as String? ?? 'medium'),
        orElse: () => TaskPriority.medium,
      ),
      status: TaskStatus.values.firstWhere(
        (e) => e.name == (data['status'] as String? ?? 'pending'),
        orElse: () => TaskStatus.pending,
      ),
      reminderDate: (data['reminderDate'] as Timestamp?)?.toDate(),
      relatedEventId: data['relatedEventId'] as String?,
      amount: (data['amount'] as num?)?.toDouble(),
      items: (data['items'] as List?)?.map((e) => e as String).toList() ?? [],
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: data['createdBy'] as String? ?? '',
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'familyId': familyId,
        'title': title,
        'description': description,
        'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
        'childId': childId,
        'assigneeId': assigneeId,
        'priority': priority.name,
        'status': status.name,
        'reminderDate':
            reminderDate != null ? Timestamp.fromDate(reminderDate!) : null,
        'relatedEventId': relatedEventId,
        'amount': amount,
        'items': items,
        'createdAt': Timestamp.fromDate(createdAt),
        'createdBy': createdBy,
        'completedAt':
            completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      };

  FamilyTask copyWith({
    String? id,
    String? familyId,
    String? title,
    String? description,
    DateTime? dueDate,
    String? childId,
    String? assigneeId,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? reminderDate,
    String? relatedEventId,
    double? amount,
    List<String>? items,
    DateTime? createdAt,
    String? createdBy,
    DateTime? completedAt,
  }) =>
      FamilyTask(
        id: id ?? this.id,
        familyId: familyId ?? this.familyId,
        title: title ?? this.title,
        description: description ?? this.description,
        dueDate: dueDate ?? this.dueDate,
        childId: childId ?? this.childId,
        assigneeId: assigneeId ?? this.assigneeId,
        priority: priority ?? this.priority,
        status: status ?? this.status,
        reminderDate: reminderDate ?? this.reminderDate,
        relatedEventId: relatedEventId ?? this.relatedEventId,
        amount: amount ?? this.amount,
        items: items ?? this.items,
        createdAt: createdAt ?? this.createdAt,
        createdBy: createdBy ?? this.createdBy,
        completedAt: completedAt ?? this.completedAt,
      );

  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }

  bool get isOverdue {
    if (dueDate == null || status.isComplete) return false;
    return dueDate!.isBefore(DateTime.now());
  }
}
