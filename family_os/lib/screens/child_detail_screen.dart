import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/children_provider.dart';
import '../providers/events_provider.dart';
import '../providers/tasks_provider.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../utils/theme.dart';
import '../widgets/event_tile.dart';
import '../widgets/task_tile.dart';

class ChildDetailScreen extends ConsumerWidget {
  final String childId;

  const ChildDetailScreen({super.key, required this.childId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final child = ref.watch(childByIdProvider(childId));
    final familyIdAsync = ref.watch(familyIdProvider);
    final familyId = familyIdAsync.valueOrNull ?? '';
    final allEvents = ref.watch(allEventsProvider).valueOrNull ?? [];
    final allTasks = ref.watch(tasksProvider).valueOrNull ?? [];

    if (child == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final childEvents = allEvents
        .where((e) => e.childId == childId)
        .toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));

    final childTasks = allTasks
        .where((t) => t.childId == childId && !t.status.isComplete)
        .toList();

    final color = AppHelpers.hexToColor(child.colorHex);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ─── Hero Header ───────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => context.push(AppRoutes.addChild),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.8), color],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // Avatar
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(24),
                          border:
                              Border.all(color: Colors.white, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            child.emoji,
                            style: const TextStyle(fontSize: 40),
                          ),
                        ),
                      ).animate().scale(
                            begin: const Offset(0.8, 0.8),
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOutBack,
                          ),
                      const SizedBox(height: 12),
                      Text(
                        child.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '${child.age} years • ${child.school} • ${child.className}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ─── Stats row ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _StatCard(
                    value: '${childEvents.length}',
                    label: 'Events',
                    icon: Icons.event_rounded,
                    color: color,
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    value: '${childTasks.length}',
                    label: 'Tasks',
                    icon: Icons.task_alt_rounded,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    value: child.age.toString(),
                    label: 'Years old',
                    icon: Icons.cake_outlined,
                    color: AppColors.success,
                  ),
                ],
              ),
            ),
          ),

          // ─── Quick Actions ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context
                          .push('${AppRoutes.addEvent}?childId=$childId'),
                      icon: const Icon(Icons.event_outlined, size: 18),
                      label: const Text('Add event'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context
                          .push('${AppRoutes.addTask}?childId=$childId'),
                      icon: const Icon(Icons.add_task_rounded, size: 18),
                      label: const Text('Add task'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Upcoming Events ───────────────────────────────────────────
          if (childEvents.isNotEmpty) ...[
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text(
                  'Upcoming Events',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => EventTile(event: childEvents[i], index: i),
                childCount: childEvents.take(5).length,
              ),
            ),
          ],

          // ─── Active Tasks ──────────────────────────────────────────────
          if (childTasks.isNotEmpty) ...[
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text(
                  'Pending Tasks',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => TaskTile(
                  task: childTasks[i],
                  familyId: familyId,
                ),
                childCount: childTasks.length,
              ),
            ),
          ],

          // Allergies / notes
          if (child.allergies != null && child.allergies!.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: AppColors.error.withOpacity(0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('⚠️', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Allergies & Medical',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.error,
                                  ),
                            ),
                            Text(
                              child.allergies!,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
