import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/children_provider.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../utils/theme.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/child_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/shimmer_loader.dart';

class KidsScreen extends ConsumerWidget {
  const KidsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childrenAsync = ref.watch(childrenProvider);

    return Scaffold(
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addChild),
        backgroundColor: AppColors.accent,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add child', style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              title: Text(
                'My Kids',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.group_add_outlined),
                  onPressed: () => _showInviteSheet(context),
                  tooltip: 'Invite partner',
                ),
              ],
            ),

            childrenAsync.when(
              loading: () => SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: ChildCardShimmer(),
                    ),
                    childCount: 3,
                  ),
                ),
              ),
              error: (_, __) => const SliverToBoxAdapter(
                child: Center(child: Text('Error loading children')),
              ),
              data: (children) {
                if (children.isEmpty) {
                  return SliverFillRemaining(
                    child: EmptyState(
                      emoji: '👶',
                      title: 'No children yet',
                      subtitle:
                          'Add your first child and start managing their schedule',
                      actionLabel: 'Add child',
                      onAction: () => context.push(AppRoutes.addChild),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final child = children[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _ChildListCard(
                            child: child,
                            index: index,
                            onTap: () => context.push('/kids/${child.id}'),
                            onEdit: () => context.push(
                              AppRoutes.addChild,
                            ),
                          ),
                        );
                      },
                      childCount: children.length,
                    ),
                  ),
                );
              },
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  void _showInviteSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _InviteSheet(),
    );
  }
}

class _ChildListCard extends StatelessWidget {
  final dynamic child;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const _ChildListCard({
    required this.child,
    required this.index,
    required this.onTap,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = AppHelpers.hexToColor(child.colorHex as String);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: Text(
                  child.emoji as String,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    child.name as String,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${child.age} years • ${child.school} • ${child.className}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Edit button
            IconButton(
              icon: Icon(Icons.edit_outlined,
                  size: 20,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary),
              onPressed: onEdit,
            ),

            Icon(Icons.chevron_right_rounded,
                color:
                    isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 80))
        .fadeIn(duration: const Duration(milliseconds: 350))
        .slideY(begin: 0.1, end: 0);
  }
}

class _InviteSheet extends ConsumerWidget {
  const _InviteSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('📨', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            'Invite your partner',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Share this code so they can join your family',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Invite code display
          Consumer(
            builder: (_, ref, __) {
              // We'd get the code from the familyProvider in production
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.accent.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'ABC123',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 4,
                          ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded,
                          color: AppColors.accent),
                      onPressed: () {
                        AppHelpers.hapticLight();
                        AppHelpers.showSnackBar(
                            context, 'Invite code copied!');
                      },
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
