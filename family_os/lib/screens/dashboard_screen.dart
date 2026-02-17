import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/children_provider.dart';
import '../providers/events_provider.dart';
import '../providers/tasks_provider.dart';
import '../providers/family_provider.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../utils/theme.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/child_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/event_tile.dart';
import '../widgets/shimmer_loader.dart';
import '../widgets/task_tile.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final familyIdAsync = ref.watch(familyIdProvider);
    final familyId = familyIdAsync.valueOrNull ?? '';
    final locale = ref.watch(localeProvider);

    return Scaffold(
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
      floatingActionButton: _DashboardFAB(),
      body: CustomScrollView(
        slivers: [
          // ─── App Bar ──────────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              title: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppHelpers.getGreeting(locale: locale),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    DateFormat('EEEE, d MMMM', locale == 'he' ? 'he' : 'en')
                        .format(DateTime.now()),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.search_rounded),
                onPressed: () {},
              ),
            ],
          ),

          // ─── Children Grid ────────────────────────────────────────────────
          const SliverToBoxAdapter(child: _ChildrenSection()),

          // ─── Today's Events ───────────────────────────────────────────────
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: _SectionHeader(
                title: "Today's Schedule",
                icon: Icons.calendar_today_rounded,
              ),
            ),
          ),

          SliverToBoxAdapter(child: _TodayEventsSection(familyId: familyId)),

          // ─── Upcoming Tasks ───────────────────────────────────────────────
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: _SectionHeader(
                title: 'Pending Tasks',
                icon: Icons.check_circle_outline_rounded,
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: _TasksSection(familyId: familyId),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _DashboardFAB extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton.extended(
      onPressed: () => _showAddSheet(context),
      backgroundColor: AppColors.accent,
      icon: const Icon(Icons.add_rounded, color: Colors.white),
      label: const Text('Add', style: TextStyle(color: Colors.white)),
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddSheet(),
    );
  }
}

class _AddSheet extends StatelessWidget {
  const _AddSheet();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            'What would you like to add?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _AddSheetOption(
                icon: Icons.event_rounded,
                label: 'Event',
                color: AppColors.accent,
                onTap: () {
                  Navigator.pop(context);
                  context.push(AppRoutes.addEvent);
                },
              ),
              _AddSheetOption(
                icon: Icons.task_alt_rounded,
                label: 'Task',
                color: AppColors.success,
                onTap: () {
                  Navigator.pop(context);
                  context.push(AppRoutes.addTask);
                },
              ),
              _AddSheetOption(
                icon: Icons.message_outlined,
                label: 'Inbox',
                color: AppColors.warning,
                onTap: () {
                  Navigator.pop(context);
                  context.push(AppRoutes.inbox);
                },
              ),
              _AddSheetOption(
                icon: Icons.child_care_outlined,
                label: 'Child',
                color: AppColors.error,
                onTap: () {
                  Navigator.pop(context);
                  context.push(AppRoutes.addChild);
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _AddSheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AddSheetOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _ChildrenSection extends ConsumerWidget {
  const _ChildrenSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childrenAsync = ref.watch(childrenProvider);

    return childrenAsync.when(
      loading: () => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Row(
          children: List.generate(
            3,
            (_) => const Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: 12),
                child: ChildCardShimmer(),
              ),
            ),
          ),
        ),
      ),
      error: (e, _) => const SizedBox.shrink(),
      data: (children) {
        if (children.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: EmptyState(
              emoji: '👶',
              title: 'No children yet',
              subtitle: 'Add your first child to get started',
              actionLabel: 'Add child',
              onAction: () => context.push(AppRoutes.addChild),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 0, 0),
          child: SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: children.length + 1,
              itemBuilder: (context, index) {
                if (index == children.length) {
                  return _AddChildButton();
                }
                final child = children[index];
                return SizedBox(
                  width: 150,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: ChildCard(
                      child: child,
                      index: index,
                      onTap: () => context.push('/kids/${child.id}'),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _AddChildButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => context.push(AppRoutes.addChild),
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.accent.withOpacity(0.3),
            width: 1.5,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.add_rounded, color: AppColors.accent, size: 28),
            ),
            const SizedBox(height: 10),
            Text(
              'Add child',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayEventsSection extends ConsumerWidget {
  final String familyId;
  const _TodayEventsSection({required this.familyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(allEventsProvider);

    return eventsAsync.when(
      loading: () => const EventShimmerList(count: 2),
      error: (_, __) => const SizedBox.shrink(),
      data: (events) {
        final today = events
            .where((e) => AppHelpers.isSameDay(e.startDate, DateTime.now()))
            .toList()
          ..sort((a, b) => a.startDate.compareTo(b.startDate));

        if (today.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkCard
                    : AppColors.lightCard,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Text('🎉', style: TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Free day!',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          'No events scheduled for today',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return AnimationLimiter(
          child: Column(
            children: today
                .asMap()
                .entries
                .map(
                  (entry) => AnimationConfiguration.staggeredList(
                    position: entry.key,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      verticalOffset: 20,
                      child: FadeInAnimation(
                        child: EventTile(
                          event: entry.value,
                          index: entry.key,
                          onTap: () {},
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}

class _TasksSection extends ConsumerWidget {
  final String familyId;
  const _TasksSection({required this.familyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider);

    return tasksAsync.when(
      loading: () => const TaskShimmerList(count: 4),
      error: (_, __) => const SizedBox.shrink(),
      data: (tasks) {
        final pending = tasks
            .where((t) => !t.status.isComplete)
            .toList()
          ..sort((a, b) => b.priority.index.compareTo(a.priority.index));

        if (pending.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkCard
                    : AppColors.lightCard,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Text('✅', style: TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'All caught up!',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          'No pending tasks',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: pending
              .take(5)
              .toList()
              .asMap()
              .entries
              .map(
                (e) => TaskTile(
                  task: e.value,
                  familyId: familyId,
                  key: ValueKey(e.value.id),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onSeeAll;

  const _SectionHeader({
    required this.title,
    required this.icon,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.accent),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const Spacer(),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
            ),
            child: const Text('See all'),
          ),
      ],
    );
  }
}
