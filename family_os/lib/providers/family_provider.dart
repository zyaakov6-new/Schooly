import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/family.dart';
import 'auth_provider.dart';

// Family stream
final familyProvider = StreamProvider<Family?>((ref) {
  final familyIdAsync = ref.watch(familyIdProvider);
  final service = ref.watch(firebaseServiceProvider);

  return familyIdAsync.when(
    data: (id) {
      if (id == null) return const Stream.empty();
      return service.watchFamily(id);
    },
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
});

// Computed: invite code
final inviteCodeProvider = Provider<String?>((ref) {
  return ref.watch(familyProvider).valueOrNull?.inviteCode;
});

// Computed: family members
final familyMembersProvider = Provider<List<FamilyMember>>((ref) {
  return ref.watch(familyProvider).valueOrNull?.members ?? [];
});
