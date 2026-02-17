import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event.dart';
import '../utils/helpers.dart';
import 'auth_provider.dart';
import 'children_provider.dart';

// Selected date for calendar
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

// All events for the family (unbounded stream – use date filters below for UI)
final allEventsProvider = StreamProvider<List<FamilyEvent>>((ref) {
  final familyIdAsync = ref.watch(familyIdProvider);
  final service = ref.watch(firebaseServiceProvider);

  return familyIdAsync.when(
    data: (id) {
      if (id == null) return const Stream.empty();
      return service.watchEvents(id);
    },
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
});

// Events for the current month (for calendar)
final monthEventsProvider = StreamProvider.family<List<FamilyEvent>, DateTime>(
  (ref, month) {
    final familyIdAsync = ref.watch(familyIdProvider);
    final service = ref.watch(firebaseServiceProvider);
    final selectedChild = ref.watch(selectedChildIdProvider);

    final from = DateTime(month.year, month.month, 1);
    final to = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    return familyIdAsync.when(
      data: (id) {
        if (id == null) return const Stream.empty();
        return service.watchEvents(
          id,
          from: from,
          to: to,
          childId: selectedChild,
        );
      },
      loading: () => const Stream.empty(),
      error: (_, __) => const Stream.empty(),
    );
  },
);

// Events for a specific day
final dayEventsProvider = Provider.family<List<FamilyEvent>, DateTime>(
  (ref, day) {
    final events = ref.watch(allEventsProvider).valueOrNull ?? [];
    return events
        .where((e) => AppHelpers.isSameDay(e.startDate, day))
        .toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
  },
);

// Today's events
final todayEventsProvider = Provider<List<FamilyEvent>>((ref) {
  return ref.watch(dayEventsProvider(DateTime.now()));
});

// This week's events
final weekEventsProvider = Provider<List<FamilyEvent>>((ref) {
  final now = DateTime.now();
  final weekStart = now.subtract(Duration(days: now.weekday - 1));
  final weekEnd = weekStart.add(const Duration(days: 7));

  final events = ref.watch(allEventsProvider).valueOrNull ?? [];
  return events
      .where((e) =>
          e.startDate.isAfter(weekStart) && e.startDate.isBefore(weekEnd))
      .toList()
    ..sort((a, b) => a.startDate.compareTo(b.startDate));
});

// Events map for table_calendar (keyed by normalized DateTime)
final eventsMapProvider =
    Provider<Map<DateTime, List<FamilyEvent>>>((ref) {
  final events = ref.watch(allEventsProvider).valueOrNull ?? [];
  final map = <DateTime, List<FamilyEvent>>{};

  for (final event in events) {
    final key = AppHelpers.startOfDay(event.startDate);
    map.putIfAbsent(key, () => []).add(event);
  }

  return map;
});
