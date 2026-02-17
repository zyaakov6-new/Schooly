import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/task.dart';
import '../providers/auth_provider.dart';
import '../providers/children_provider.dart';
import '../providers/tasks_provider.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../utils/theme.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/child_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/shimmer_loader.dart';
import '../widgets/task_tile.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final familyIdAsync = ref.watch(familyIdProvider);
    final familyId = familyIdAsync.valueOrNull ?? '';
    final children = ref.watch(childrenProvider).valueOrNull ?? [];
    final selectedChild = ref.watch(selectedChildIdProvider);

    return Scaffold(
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.addTask),
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Row(
                children: [
                  Text(
                    'Tasks',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.message_outlined),
                    onPressed: () => context.push(AppRoutes.inbox),
                    tooltip: 'Smart Inbox',
                  ),
                ],
              ),
            ),

            // Child filter chips
            if (children.isNotEmpty)
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: [
                    _FilterChip(
                      label: 'All',
                      isSelected: selectedChild == null,
                      onTap: () =>
                          ref.read(selectedChildIdProvider.notifier).state =
                              null,
                    ),
                    ...children.map(
                      (c) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChildAvatarChip(
                          child: c,
                          isSelected: selectedChild == c.id,
                          onTap: () {
                            ref.read(selectedChildIdProvider.notifier).state =
                                selectedChild == c.id ? null : c.id;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Tabs
            TabBar(
              controller: _tabController,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              tabs: const [
                Tab(text: 'Pending'),
                Tab(text: 'In Progress'),
                Tab(text: 'Done'),
              ],
              labelColor: AppColors.accent,
              unselectedLabelColor: AppColors.lightTextSecondary,
              indicatorColor: AppColors.accent,
              dividerColor: Colors.transparent,
            ),

            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _TaskList(
                    familyId: familyId,
                    status: TaskStatus.pending,
                  ),
                  _TaskList(
                    familyId: familyId,
                    status: TaskStatus.inProgress,
                  ),
                  _TaskList(
                    familyId: familyId,
                    status: TaskStatus.done,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskList extends ConsumerWidget {
  final String familyId;
  final TaskStatus status;

  const _TaskList({required this.familyId, required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider);
    final selectedChild = ref.watch(selectedChildIdProvider);

    return tasksAsync.when(
      loading: () => const TaskShimmerList(),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (allTasks) {
        final tasks = allTasks
            .where((t) =>
                t.status == status &&
                (selectedChild == null || t.childId == selectedChild))
            .toList()
          ..sort((a, b) => b.priority.index.compareTo(a.priority.index));

        if (tasks.isEmpty) {
          return EmptyState(
            emoji: status == TaskStatus.done ? '🎉' : '✅',
            title: status == TaskStatus.done
                ? 'Nothing completed yet'
                : 'No ${status.name} tasks',
            subtitle: status == TaskStatus.pending
                ? 'Add a task to get started'
                : status == TaskStatus.inProgress
                    ? 'Start working on a task'
                    : 'Complete some tasks first',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            return TaskTile(
              task: tasks[index],
              familyId: familyId,
              key: ValueKey(tasks[index].id),
            );
          },
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : AppColors.accent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.accent,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
