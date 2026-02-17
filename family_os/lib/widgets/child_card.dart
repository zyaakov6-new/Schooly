import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/child.dart';
import '../providers/tasks_provider.dart';
import '../providers/events_provider.dart';
import '../utils/helpers.dart';
import '../utils/theme.dart';
import 'glass_card.dart';

class ChildCard extends ConsumerWidget {
  final Child child;
  final VoidCallback? onTap;
  final int index;

  const ChildCard({
    super.key,
    required this.child,
    this.onTap,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskCount = ref.watch(childTaskCountProvider(child.id));
    final todayEvents = ref.watch(todayEventsProvider);
    final childEvents =
        todayEvents.where((e) => e.childId == child.id).toList();
    final color = AppHelpers.hexToColor(child.colorHex);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar + status row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ChildAvatar(child: child, color: color),
                _StatusDot(taskCount: taskCount, color: color),
              ],
            ),
            const SizedBox(height: 10),

            // Name
            Text(
              child.name,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),

            // School + class
            Text(
              '${child.school} • ${child.className}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            // Today's event or task count
            if (childEvents.isNotEmpty)
              _EventChip(
                label: childEvents.first.title,
                color: color,
              )
            else if (taskCount > 0)
              _EventChip(
                label: '$taskCount task${taskCount != 1 ? 's' : ''}',
                color: color,
                isTask: true,
              )
            else
              _EventChip(
                label: 'All clear',
                color: AppColors.success,
                isGood: true,
              ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 80))
        .fadeIn(duration: const Duration(milliseconds: 400))
        .slideY(begin: 0.1, end: 0);
  }
}

class _ChildAvatar extends StatelessWidget {
  final Child child;
  final Color color;

  const _ChildAvatar({required this.child, required this.color});

  @override
  Widget build(BuildContext context) {
    if (child.photoUrl != null && child.photoUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage(child.photoUrl!),
        backgroundColor: color.withOpacity(0.2),
      );
    }
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          child.emoji,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final int taskCount;
  final Color color;

  const _StatusDot({required this.taskCount, required this.color});

  @override
  Widget build(BuildContext context) {
    final statusColor = taskCount == 0
        ? AppColors.success
        : taskCount < 3
            ? AppColors.warning
            : AppColors.error;

    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: statusColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.5),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}

class _EventChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isTask;
  final bool isGood;

  const _EventChip({
    required this.label,
    required this.color,
    this.isTask = false,
    this.isGood = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

// Compact version for horizontal scroll
class ChildAvatarChip extends ConsumerWidget {
  final Child child;
  final bool isSelected;
  final VoidCallback onTap;

  const ChildAvatarChip({
    super.key,
    required this.child,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = AppHelpers.hexToColor(child.colorHex);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: color,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(child.emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              child.name,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: isSelected ? Colors.white : color,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
