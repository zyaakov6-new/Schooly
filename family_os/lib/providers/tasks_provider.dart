import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import 'auth_provider.dart';
import 'children_provider.dart';

// All active tasks
final tasksProvider = StreamProvider<List<FamilyTask>>((ref) {
  final familyIdAsync = ref.watch(familyIdProvider);
  final service = ref.watch(firebaseServiceProvider);
  final selectedChild = ref.watch(selectedChildIdProvider);

  return familyIdAsync.when(
    data: (id) {
      if (id == null) return const Stream.empty();
      return service.watchTasks(
        id,
        childId: selectedChild,
        excludeDone: false,
      );
    },
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
});

// Today's tasks (due today, not done)
final todayTasksProvider = Provider<List<FamilyTask>>((ref) {
  final tasks = ref.watch(tasksProvider).valueOrNull ?? [];
  return tasks
      .where((t) => t.isDueToday && !t.status.isComplete)
      .toList()
    ..sort((a, b) => a.priority.index.compareTo(b.priority.index));
});

// Pending tasks sorted by priority + due date
final pendingTasksProvider = Provider<List<FamilyTask>>((ref) {
  final tasks = ref.watch(tasksProvider).valueOrNull ?? [];
  return tasks.where((t) => t.status == TaskStatus.pending).toList()
    ..sort((a, b) {
      // Sort by priority (urgent first), then by due date
      final priorityComp =
          b.priority.index.compareTo(a.priority.index);
      if (priorityComp != 0) return priorityComp;
      if (a.dueDate == null && b.dueDate == null) return 0;
      if (a.dueDate == null) return 1;
      if (b.dueDate == null) return -1;
      return a.dueDate!.compareTo(b.dueDate!);
    });
});

// Overdue tasks
final overdueTasksProvider = Provider<List<FamilyTask>>((ref) {
  final tasks = ref.watch(tasksProvider).valueOrNull ?? [];
  return tasks.where((t) => t.isOverdue).toList();
});

// Tasks count per child
final childTaskCountProvider = Provider.family<int, String>((ref, childId) {
  final tasks = ref.watch(tasksProvider).valueOrNull ?? [];
  return tasks
      .where((t) => t.childId == childId && !t.status.isComplete)
      .length;
});

// Task filter state
final taskFilterProvider = StateProvider<TaskFilter>((ref) => const TaskFilter());

class TaskFilter {
  final String? childId;
  final TaskPriority? priority;
  final bool showCompleted;

  const TaskFilter({
    this.childId,
    this.priority,
    this.showCompleted = false,
  });

  TaskFilter copyWith({
    String? childId,
    TaskPriority? priority,
    bool? showCompleted,
  }) =>
      TaskFilter(
        childId: childId ?? this.childId,
        priority: priority ?? this.priority,
        showCompleted: showCompleted ?? this.showCompleted,
      );
}

// Filtered tasks
final filteredTasksProvider = Provider<List<FamilyTask>>((ref) {
  final tasks = ref.watch(tasksProvider).valueOrNull ?? [];
  final filter = ref.watch(taskFilterProvider);

  return tasks.where((t) {
    if (filter.childId != null && t.childId != filter.childId) return false;
    if (filter.priority != null && t.priority != filter.priority) return false;
    if (!filter.showCompleted && t.status.isComplete) return false;
    return true;
  }).toList();
});
