import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../providers/family_provider.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../utils/theme.dart';
import '../widgets/app_bottom_nav.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final familyAsync = ref.watch(familyProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      bottomNavigationBar: const AppBottomNav(currentIndex: 4),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              title: Text(
                'Profile',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),

            SliverToBoxAdapter(
              child: Column(
                children: [
                  // Profile header
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Avatar
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.accent, AppColors.accentLight],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Center(
                            child: Text(
                              (user?.displayName?.isNotEmpty == true
                                      ? user!.displayName![0]
                                      : user?.email?[0] ?? '?')
                                  .toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ).animate().scale(
                              begin: const Offset(0.8, 0.8),
                              duration: 400.ms,
                              curve: Curves.easeOutBack,
                            ),

                        const SizedBox(height: 12),

                        Text(
                          user?.displayName ?? 'Parent',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          user?.email ?? '',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                        ),

                        // Family name badge
                        familyAsync.when(
                          data: (family) {
                            if (family == null) return const SizedBox.shrink();
                            return Container(
                              margin: const EdgeInsets.only(top: 12),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '🏠 ${family.name}',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            );
                          },
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),

                  // Settings sections
                  _SettingsSection(
                    title: 'Appearance',
                    children: [
                      _SettingsTile(
                        icon: Icons.brightness_4_rounded,
                        title: 'Theme',
                        trailing: _ThemeToggle(
                          mode: themeMode,
                          onChanged: (v) =>
                              ref.read(themeModeProvider.notifier).setMode(v),
                        ),
                      ),
                      _SettingsTile(
                        icon: Icons.language_rounded,
                        title: 'Language',
                        trailing: _LangToggle(
                          locale: locale,
                          onChanged: (v) =>
                              ref.read(localeProvider.notifier).setLocale(v),
                        ),
                      ),
                    ],
                  ),

                  _SettingsSection(
                    title: 'Family',
                    children: [
                      _SettingsTile(
                        icon: Icons.group_outlined,
                        title: 'Family settings',
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () {},
                      ),
                      _SettingsTile(
                        icon: Icons.share_outlined,
                        title: 'Invite partner',
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () {},
                      ),
                    ],
                  ),

                  _SettingsSection(
                    title: 'Notifications',
                    children: [
                      _SettingsTile(
                        icon: Icons.notifications_outlined,
                        title: 'Daily summary',
                        trailing: Switch.adaptive(
                          value: true,
                          onChanged: (_) {},
                          activeColor: AppColors.accent,
                        ),
                      ),
                      _SettingsTile(
                        icon: Icons.alarm_rounded,
                        title: 'Task reminders',
                        trailing: Switch.adaptive(
                          value: true,
                          onChanged: (_) {},
                          activeColor: AppColors.accent,
                        ),
                      ),
                    ],
                  ),

                  _SettingsSection(
                    title: 'Data',
                    children: [
                      _SettingsTile(
                        icon: Icons.download_outlined,
                        title: 'Export data',
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () {},
                      ),
                      _SettingsTile(
                        icon: Icons.delete_outline_rounded,
                        title: 'Delete account',
                        titleColor: AppColors.error,
                        trailing: const Icon(Icons.chevron_right_rounded,
                            color: AppColors.error),
                        onTap: () => _confirmDelete(context, ref),
                      ),
                    ],
                  ),

                  // Sign out
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _signOut(context, ref),
                        icon: const Icon(Icons.logout_rounded,
                            color: AppColors.error),
                        label: const Text(
                          'Sign out',
                          style: TextStyle(color: AppColors.error),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.error),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'FamilyOS v1.0.0',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await ref.read(firebaseServiceProvider).signOut();
    if (context.mounted) context.go(AppRoutes.login);
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text(
            'This will permanently delete your account and all family data. This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 4),
            child: Text(
              title.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? titleColor;
  final Widget trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.titleColor,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.accent),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: titleColor,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  final int mode;
  final ValueChanged<int> onChanged;

  const _ThemeToggle({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ThemeButton(icon: Icons.brightness_auto_rounded, mode: 0, current: mode, onTap: onChanged),
        _ThemeButton(icon: Icons.brightness_high_rounded, mode: 1, current: mode, onTap: onChanged),
        _ThemeButton(icon: Icons.brightness_2_rounded, mode: 2, current: mode, onTap: onChanged),
      ],
    );
  }
}

class _ThemeButton extends StatelessWidget {
  final IconData icon;
  final int mode;
  final int current;
  final ValueChanged<int> onTap;

  const _ThemeButton({
    required this.icon,
    required this.mode,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = mode == current;
    return GestureDetector(
      onTap: () => onTap(mode),
      child: AnimatedContainer(
        duration: 200.ms,
        padding: const EdgeInsets.all(6),
        margin: const EdgeInsets.only(left: 4),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color: selected ? Colors.white : AppColors.lightTextSecondary,
        ),
      ),
    );
  }
}

class _LangToggle extends StatelessWidget {
  final String locale;
  final ValueChanged<String> onChanged;

  const _LangToggle({required this.locale, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _LangButton(lang: 'he', label: 'עב', current: locale, onTap: onChanged),
        _LangButton(lang: 'en', label: 'EN', current: locale, onTap: onChanged),
      ],
    );
  }
}

class _LangButton extends StatelessWidget {
  final String lang;
  final String label;
  final String current;
  final ValueChanged<String> onTap;

  const _LangButton({
    required this.lang,
    required this.label,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = lang == current;
    return GestureDetector(
      onTap: () => onTap(lang),
      child: AnimatedContainer(
        duration: 200.ms,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        margin: const EdgeInsets.only(left: 4),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.lightTextSecondary,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

extension on Duration {
  Duration get ms => Duration(milliseconds: inMilliseconds);
}
