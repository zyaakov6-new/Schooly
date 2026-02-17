import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/child.dart';
import 'auth_provider.dart';

// All children for the family
final childrenProvider = StreamProvider<List<Child>>((ref) {
  final familyIdAsync = ref.watch(familyIdProvider);
  final service = ref.watch(firebaseServiceProvider);

  return familyIdAsync.when(
    data: (id) {
      if (id == null) return const Stream.empty();
      return service.watchChildren(id);
    },
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
});

// Single child by ID
final childByIdProvider = Provider.family<Child?, String>((ref, childId) {
  final children = ref.watch(childrenProvider).valueOrNull ?? [];
  try {
    return children.firstWhere((c) => c.id == childId);
  } catch (_) {
    return null;
  }
});

// Selected child for filtering
final selectedChildIdProvider = StateProvider<String?>((ref) => null);

// Currently viewed child in detail screen
final activeChildProvider = Provider<Child?>((ref) {
  final selectedId = ref.watch(selectedChildIdProvider);
  if (selectedId == null) return null;
  return ref.watch(childByIdProvider(selectedId));
});

// Children count
final childrenCountProvider = Provider<int>((ref) {
  return ref.watch(childrenProvider).valueOrNull?.length ?? 0;
});
