import 'package:cloud_firestore/cloud_firestore.dart';
import 'event.dart';
import 'task.dart';

class ParsedData {
  final List<FamilyEvent> events;
  final List<FamilyTask> tasks;
  final List<String> items;
  final double? amount;
  final DateTime? parsedDate;

  const ParsedData({
    this.events = const [],
    this.tasks = const [],
    this.items = const [],
    this.amount,
    this.parsedDate,
  });
}

class InboxMessage {
  final String id;
  final String familyId;
  final String source; // whatsapp, sms, email, manual
  final String content;
  final String? childId;
  final bool isParsed;
  final ParsedData? parsedData;
  final DateTime timestamp;
  final String createdBy;

  const InboxMessage({
    required this.id,
    required this.familyId,
    required this.source,
    required this.content,
    this.childId,
    this.isParsed = false,
    this.parsedData,
    required this.timestamp,
    required this.createdBy,
  });

  factory InboxMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InboxMessage(
      id: doc.id,
      familyId: data['familyId'] as String? ?? '',
      source: data['source'] as String? ?? 'manual',
      content: data['content'] as String? ?? '',
      childId: data['childId'] as String?,
      isParsed: data['isParsed'] as bool? ?? false,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: data['createdBy'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() => {
        'familyId': familyId,
        'source': source,
        'content': content,
        'childId': childId,
        'isParsed': isParsed,
        'timestamp': Timestamp.fromDate(timestamp),
        'createdBy': createdBy,
      };
}
