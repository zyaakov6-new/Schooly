import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import '../models/task.dart';
import '../providers/auth_provider.dart';
import '../providers/tasks_provider.dart';
import '../utils/helpers.dart';
import '../utils/theme.dart';

class TaskTile extends ConsumerStatefulWidget {
  final FamilyTask task;
  final String familyId;
  final VoidCallback? onTap;
  final bool animate;

  const TaskTile({
    super.key,
    required this.task,
    required this.familyId,
    this.onTap,
    this.animate = true,
  });

  @override
  ConsumerState<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends ConsumerState<TaskTile> {
  late ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  Future<void> _complete() async {
    AppHelpers.hapticMedium();
    _confetti.play();
    final service = ref.read(firebaseServiceProvider);
    await service.completeTask(widget.familyId, widget.task.id);
  }

  Future<void> _snooze() async {
    AppHelpers.hapticLight();
    final service = ref.read(firebaseServiceProvider);
    await service.snoozeTask(widget.familyId, widget.task.id);
  }

  Future<void> _delete() async {
    AppHelpers.hapticHeavy();
    final service = ref.read(firebaseServiceProvider);
    await service.deleteTask(widget.familyId, widget.task.id);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final task = widget.task;
    final isComplete = task.status.isComplete;

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        ConfettiWidget(
          confettiController: _confetti,
          blastDirection: pi / 2,
          emissionFrequency: 0.6,
          numberOfParticles: 20,
          gravity: 0.3,
          colors: AppColors.childColors,
        ),
        Slidable(
          key: ValueKey(task.id),
          startActionPane: ActionPane(
            motion: const BehindMotion(),
            extentRatio: 0.25,
            children: [
              SlidableAction(
                onPressed: (_) => _complete(),
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                icon: Icons.check_rounded,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(16),
                ),
              ),
            ],
          ),
          endActionPane: ActionPane(
            motion: const BehindMotion(),
            extentRatio: 0.5,
            children: [
              SlidableAction(
                onPressed: (_) => _snooze(),
                backgroundColor: AppColors.warning,
                foregroundColor: Colors.white,
                icon: Icons.snooze_rounded,
                label: 'Later',
              ),
              SlidableAction(
                onPressed: (_) => _delete(),
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                icon: Icons.delete_outline_rounded,
                label: 'Delete',
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(16),
                ),
              ),
            ],
          ),
          child: GestureDetector(
            onTap: widget.onTap,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(16),
                border: isComplete
                    ? Border.all(
                        color: AppColors.success.withOpacity(0.4), width: 1)
                    : null,
              ),
              child: Row(
                children: [
                  // Completion checkbox
                  GestureDetector(
                    onTap: isComplete ? null : _complete,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isComplete
                            ? AppColors.success
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isComplete
                              ? AppColors.success
                              : AppColors.accent.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: isComplete
                          ? const Icon(Icons.check_rounded,
                              size: 16, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                decoration: isComplete
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: isComplete
                                    ? Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color
                                    : null,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (task.dueDate != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.schedule_rounded,
                                size: 12,
                                color: task.isOverdue
                                    ? AppColors.error
                                    : AppColors.accent,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                AppHelpers.formatRelative(task.dueDate!),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: task.isOverdue
                                          ? AppColors.error
                                          : AppColors.accent,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                              if (task.amount != null) ...[
                                const SizedBox(width: 8),
                                Text(
                                  AppHelpers.formatAmount(task.amount!),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: AppColors.warning,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Priority indicator
                  _PriorityBadge(priority: task.priority),
                ],
              ),
            ),
          ),
        ),
      ],
    ).animate(target: widget.animate ? 1 : 0).fadeIn(
          duration: const Duration(milliseconds: 300),
        );
  }
}

class _PriorityBadge extends StatelessWidget {
  final TaskPriority priority;

  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    if (priority == TaskPriority.low) return const SizedBox.shrink();

    final color = AppHelpers.hexToColor(priority.colorHex);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        priority.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
