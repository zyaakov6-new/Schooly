import 'package:cloud_firestore/cloud_firestore.dart';

enum ChildStatus { onTime, attention, urgent }

class Child {
  final String id;
  final String familyId;
  final String name;
  final int age;
  final String school;
  final String className;
  final String? photoUrl;
  final String? allergies;
  final String? medicalNotes;
  final String colorHex;
  final String emoji;
  final DateTime createdAt;

  const Child({
    required this.id,
    required this.familyId,
    required this.name,
    required this.age,
    required this.school,
    required this.className,
    this.photoUrl,
    this.allergies,
    this.medicalNotes,
    required this.colorHex,
    required this.emoji,
    required this.createdAt,
  });

  factory Child.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Child(
      id: doc.id,
      familyId: data['familyId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      age: (data['age'] as num?)?.toInt() ?? 0,
      school: data['school'] as String? ?? '',
      className: data['className'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      allergies: data['allergies'] as String?,
      medicalNotes: data['medicalNotes'] as String?,
      colorHex: data['colorHex'] as String? ?? '#1976D2',
      emoji: data['emoji'] as String? ?? '👦',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'familyId': familyId,
        'name': name,
        'age': age,
        'school': school,
        'className': className,
        'photoUrl': photoUrl,
        'allergies': allergies,
        'medicalNotes': medicalNotes,
        'colorHex': colorHex,
        'emoji': emoji,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  Child copyWith({
    String? id,
    String? familyId,
    String? name,
    int? age,
    String? school,
    String? className,
    String? photoUrl,
    String? allergies,
    String? medicalNotes,
    String? colorHex,
    String? emoji,
    DateTime? createdAt,
  }) =>
      Child(
        id: id ?? this.id,
        familyId: familyId ?? this.familyId,
        name: name ?? this.name,
        age: age ?? this.age,
        school: school ?? this.school,
        className: className ?? this.className,
        photoUrl: photoUrl ?? this.photoUrl,
        allergies: allergies ?? this.allergies,
        medicalNotes: medicalNotes ?? this.medicalNotes,
        colorHex: colorHex ?? this.colorHex,
        emoji: emoji ?? this.emoji,
        createdAt: createdAt ?? this.createdAt,
      );

  // Predefined child color palette
  static const List<String> colors = [
    '#1976D2', // Blue
    '#E91E63', // Pink
    '#4CAF50', // Green
    '#FF9800', // Orange
    '#9C27B0', // Purple
    '#00BCD4', // Cyan
  ];

  static const List<String> emojis = [
    '👦', '👧', '🧒', '👶', '🎓', '⭐',
  ];
}
