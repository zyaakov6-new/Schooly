import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../utils/theme.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;

  const AppBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.grid_view_rounded,
                label: 'Home',
                labelHe: 'בית',
                isSelected: currentIndex == 0,
                onTap: () {
                  AppHelpers.hapticSelection();
                  context.go(AppRoutes.dashboard);
                },
              ),
              _NavItem(
                icon: Icons.calendar_month_rounded,
                label: 'Calendar',
                labelHe: 'לוח שנה',
                isSelected: currentIndex == 1,
                onTap: () {
                  AppHelpers.hapticSelection();
                  context.go(AppRoutes.calendar);
                },
              ),
              _NavItem(
                icon: Icons.check_circle_outline_rounded,
                label: 'Tasks',
                labelHe: 'משימות',
                isSelected: currentIndex == 2,
                onTap: () {
                  AppHelpers.hapticSelection();
                  context.go(AppRoutes.tasks);
                },
              ),
              _NavItem(
                icon: Icons.people_outline_rounded,
                label: 'Kids',
                labelHe: 'ילדים',
                isSelected: currentIndex == 3,
                onTap: () {
                  AppHelpers.hapticSelection();
                  context.go(AppRoutes.kids);
                },
              ),
              _NavItem(
                icon: Icons.person_outline_rounded,
                label: 'Profile',
                labelHe: 'פרופיל',
                isSelected: currentIndex == 4,
                onTap: () {
                  AppHelpers.hapticSelection();
                  context.go(AppRoutes.profile);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String labelHe;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.labelHe,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isSelected ? AppColors.accent : AppColors.lightTextSecondary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(icon, size: 24, color: color),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
