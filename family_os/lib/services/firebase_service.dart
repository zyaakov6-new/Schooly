import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:uuid/uuid.dart';
import '../models/child.dart';
import '../models/event.dart';
import '../models/family.dart';
import '../models/inbox_message.dart';
import '../models/task.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _uuid = const Uuid();

  // ─── Auth ─────────────────────────────────────────────────────────────────

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signInWithEmail(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  Future<UserCredential> registerWithEmail(String email, String password) =>
      _auth.createUserWithEmailAndPassword(email: email, password: password);

  Future<void> signOut() => _auth.signOut();

  Future<void> updateUserProfile(String name, {String? photoUrl}) =>
      _auth.currentUser!.updateDisplayName(name);

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  // ─── Family ───────────────────────────────────────────────────────────────

  Future<Family> createFamily(String name) async {
    final user = currentUser!;
    final code = AppHelpers.generateInviteCode();
    final familyRef = _firestore.collection(AppConstants.familiesCollection).doc();

    final member = FamilyMember(
      userId: user.uid,
      name: user.displayName ?? 'Parent',
      email: user.email,
      photoUrl: user.photoURL,
      role: MemberRole.admin,
      joinedAt: DateTime.now(),
    );

    final family = Family(
      id: familyRef.id,
      name: name,
      members: [member],
      inviteCode: code,
      primaryLanguage: 'he',
      createdAt: DateTime.now(),
    );

    await familyRef.set(family.toFirestore());

    // Save familyId to user doc
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .set({'familyId': familyRef.id, 'name': user.displayName ?? ''}, SetOptions(merge: true));

    return family;
  }

  Future<Family?> getFamilyByInviteCode(String code) async {
    final query = await _firestore
        .collection(AppConstants.familiesCollection)
        .where('inviteCode', isEqualTo: code.toUpperCase())
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;
    return Family.fromFirestore(query.docs.first);
  }

  Future<void> joinFamily(String familyId) async {
    final user = currentUser!;
    final member = FamilyMember(
      userId: user.uid,
      name: user.displayName ?? 'Parent',
      email: user.email,
      photoUrl: user.photoURL,
      role: MemberRole.parent,
      joinedAt: DateTime.now(),
    );

    await _firestore
        .collection(AppConstants.familiesCollection)
        .doc(familyId)
        .update({
      'members': FieldValue.arrayUnion([member.toMap()])
    });

    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .set({'familyId': familyId}, SetOptions(merge: true));
  }

  Stream<Family?> watchFamily(String familyId) => _firestore
      .collection(AppConstants.familiesCollection)
      .doc(familyId)
      .snapshots()
      .map((doc) => doc.exists ? Family.fromFirestore(doc) : null);

  Future<String?> getUserFamilyId(String userId) async {
    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .get();
    return doc.data()?['familyId'] as String?;
  }

  // ─── Children ─────────────────────────────────────────────────────────────

  Future<Child> addChild(String familyId, Child child) async {
    final ref = _firestore
        .collection(AppConstants.familiesCollection)
        .doc(familyId)
        .collection(AppConstants.childrenCollection)
        .doc();

    final newChild = child.copyWith(id: ref.id, familyId: familyId);
    await ref.set(newChild.toFirestore());
    return newChild;
  }

  Future<void> updateChild(String familyId, Child child) => _firestore
      .collection(AppConstants.familiesCollection)
      .doc(familyId)
      .collection(AppConstants.childrenCollection)
      .doc(child.id)
      .update(child.toFirestore());

  Future<void> deleteChild(String familyId, String childId) => _firestore
      .collection(AppConstants.familiesCollection)
      .doc(familyId)
      .collection(AppConstants.childrenCollection)
      .doc(childId)
      .delete();

  Stream<List<Child>> watchChildren(String familyId) => _firestore
      .collection(AppConstants.familiesCollection)
      .doc(familyId)
      .collection(AppConstants.childrenCollection)
      .orderBy('createdAt')
      .snapshots()
      .map((s) => s.docs.map(Child.fromFirestore).toList());

  // ─── Events ───────────────────────────────────────────────────────────────

  Future<FamilyEvent> addEvent(String familyId, FamilyEvent event) async {
    final ref = _firestore
        .collection(AppConstants.familiesCollection)
        .doc(familyId)
        .collection(AppConstants.eventsCollection)
        .doc();

    final newEvent = event.copyWith(
      id: ref.id,
      familyId: familyId,
      createdBy: currentUser!.uid,
    );
    await ref.set(newEvent.toFirestore());
    return newEvent;
  }

  Future<void> updateEvent(String familyId, FamilyEvent event) => _firestore
      .collection(AppConstants.familiesCollection)
      .doc(familyId)
      .collection(AppConstants.eventsCollection)
      .doc(event.id)
      .update(event.toFirestore());

  Future<void> deleteEvent(String familyId, String eventId) => _firestore
      .collection(AppConstants.familiesCollection)
      .doc(familyId)
      .collection(AppConstants.eventsCollection)
      .doc(eventId)
      .delete();

  Stream<List<FamilyEvent>> watchEvents(
    String familyId, {
    DateTime? from,
    DateTime? to,
    String? childId,
  }) {
    Query query = _firestore
        .collection(AppConstants.familiesCollection)
        .doc(familyId)
        .collection(AppConstants.eventsCollection);

    if (from != null) {
      query = query.where('startDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(from));
    }
    if (to != null) {
      query = query.where('startDate',
          isLessThanOrEqualTo: Timestamp.fromDate(to));
    }
    if (childId != null) {
      query = query.where('childId', isEqualTo: childId);
    }

    return query
        .orderBy('startDate')
        .snapshots()
        .map((s) => s.docs.map(FamilyEvent.fromFirestore).toList());
  }

  // ─── Tasks ────────────────────────────────────────────────────────────────

  Future<FamilyTask> addTask(String familyId, FamilyTask task) async {
    final ref = _firestore
        .collection(AppConstants.familiesCollection)
        .doc(familyId)
        .collection(AppConstants.tasksCollection)
        .doc();

    final newTask = task.copyWith(
      id: ref.id,
      familyId: familyId,
      createdBy: currentUser!.uid,
    );
    await ref.set(newTask.toFirestore());
    return newTask;
  }

  Future<void> updateTask(String familyId, FamilyTask task) => _firestore
      .collection(AppConstants.familiesCollection)
      .doc(familyId)
      .collection(AppConstants.tasksCollection)
      .doc(task.id)
      .update(task.toFirestore());

  Future<void> completeTask(String familyId, String taskId) => _firestore
      .collection(AppConstants.familiesCollection)
      .doc(familyId)
      .collection(AppConstants.tasksCollection)
      .doc(taskId)
      .update({
    'status': TaskStatus.done.name,
    'completedAt': Timestamp.fromDate(DateTime.now()),
  });

  Future<void> snoozeTask(String familyId, String taskId) => _firestore
      .collection(AppConstants.familiesCollection)
      .doc(familyId)
      .collection(AppConstants.tasksCollection)
      .doc(taskId)
      .update({'status': TaskStatus.snoozed.name});

  Future<void> deleteTask(String familyId, String taskId) => _firestore
      .collection(AppConstants.familiesCollection)
      .doc(familyId)
      .collection(AppConstants.tasksCollection)
      .doc(taskId)
      .delete();

  Stream<List<FamilyTask>> watchTasks(
    String familyId, {
    String? childId,
    TaskStatus? status,
    bool excludeDone = false,
  }) {
    Query query = _firestore
        .collection(AppConstants.familiesCollection)
        .doc(familyId)
        .collection(AppConstants.tasksCollection);

    if (childId != null) {
      query = query.where('childId', isEqualTo: childId);
    }
    if (status != null) {
      query = query.where('status', isEqualTo: status.name);
    }
    if (excludeDone) {
      query = query.where('status', isNotEqualTo: TaskStatus.done.name);
    }

    return query
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(FamilyTask.fromFirestore).toList());
  }

  // ─── Inbox ────────────────────────────────────────────────────────────────

  Future<InboxMessage> addInboxMessage(
    String familyId,
    InboxMessage message,
  ) async {
    final ref = _firestore
        .collection(AppConstants.familiesCollection)
        .doc(familyId)
        .collection(AppConstants.inboxCollection)
        .doc();

    final newMsg = InboxMessage(
      id: ref.id,
      familyId: familyId,
      source: message.source,
      content: message.content,
      childId: message.childId,
      isParsed: message.isParsed,
      parsedData: message.parsedData,
      timestamp: message.timestamp,
      createdBy: currentUser!.uid,
    );

    await ref.set(newMsg.toFirestore());
    return newMsg;
  }

  Stream<List<InboxMessage>> watchInbox(String familyId) => _firestore
      .collection(AppConstants.familiesCollection)
      .doc(familyId)
      .collection(AppConstants.inboxCollection)
      .orderBy('timestamp', descending: true)
      .limit(AppConstants.pageSize)
      .snapshots()
      .map((s) => s.docs.map(InboxMessage.fromFirestore).toList());

  // ─── FCM ──────────────────────────────────────────────────────────────────

  Future<String?> getFcmToken() async {
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (_) {
      return null;
    }
  }

  Future<void> saveFcmToken(String familyId, String token) => _firestore
      .collection(AppConstants.usersCollection)
      .doc(currentUser!.uid)
      .set({'fcmToken': token, 'familyId': familyId}, SetOptions(merge: true));
}
