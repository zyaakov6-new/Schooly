import 'package:cloud_firestore/cloud_firestore.dart';

enum MemberRole { admin, parent, viewer }

class FamilyMember {
  final String userId;
  final String name;
  final String? email;
  final String? photoUrl;
  final MemberRole role;
  final DateTime joinedAt;

  const FamilyMember({
    required this.userId,
    required this.name,
    this.email,
    this.photoUrl,
    required this.role,
    required this.joinedAt,
  });

  factory FamilyMember.fromMap(Map<String, dynamic> map) => FamilyMember(
        userId: map['userId'] as String? ?? '',
        name: map['name'] as String? ?? '',
        email: map['email'] as String?,
        photoUrl: map['photoUrl'] as String?,
        role: MemberRole.values.firstWhere(
          (e) => e.name == (map['role'] as String? ?? 'parent'),
          orElse: () => MemberRole.parent,
        ),
        joinedAt: (map['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'name': name,
        'email': email,
        'photoUrl': photoUrl,
        'role': role.name,
        'joinedAt': Timestamp.fromDate(joinedAt),
      };
}

class Family {
  final String id;
  final String name;
  final List<FamilyMember> members;
  final String inviteCode;
  final String primaryLanguage;
  final DateTime createdAt;

  const Family({
    required this.id,
    required this.name,
    required this.members,
    required this.inviteCode,
    required this.primaryLanguage,
    required this.createdAt,
  });

  factory Family.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Family(
      id: doc.id,
      name: data['name'] as String? ?? 'My Family',
      members: (data['members'] as List?)
              ?.map((m) => FamilyMember.fromMap(m as Map<String, dynamic>))
              .toList() ??
          [],
      inviteCode: data['inviteCode'] as String? ?? '',
      primaryLanguage: data['primaryLanguage'] as String? ?? 'he',
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'members': members.map((m) => m.toMap()).toList(),
        'inviteCode': inviteCode,
        'primaryLanguage': primaryLanguage,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  Family copyWith({
    String? id,
    String? name,
    List<FamilyMember>? members,
    String? inviteCode,
    String? primaryLanguage,
    DateTime? createdAt,
  }) =>
      Family(
        id: id ?? this.id,
        name: name ?? this.name,
        members: members ?? this.members,
        inviteCode: inviteCode ?? this.inviteCode,
        primaryLanguage: primaryLanguage ?? this.primaryLanguage,
        createdAt: createdAt ?? this.createdAt,
      );
}
