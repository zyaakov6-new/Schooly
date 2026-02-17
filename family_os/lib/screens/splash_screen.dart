import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;

    final user = ref.read(currentUserProvider);
    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool(AppConstants.keyOnboardingDone) ?? false;

    if (user == null) {
      context.go(onboardingDone ? AppRoutes.login : AppRoutes.onboarding);
    } else {
      final familyId = prefs.getString(AppConstants.keyFamilyId);
      context.go(familyId != null ? AppRoutes.dashboard : AppRoutes.createFamily);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.accent, AppColors.accentLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.5),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Center(
                child: Text('👨‍👩‍👧‍👦', style: TextStyle(fontSize: 44)),
              ),
            )
                .animate()
                .scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1, 1),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutBack,
                )
                .fadeIn(),

            const SizedBox(height: 28),

            // App name
            Text(
              'FamilyOS',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
            )
                .animate(delay: const Duration(milliseconds: 400))
                .fadeIn(duration: const Duration(milliseconds: 400))
                .slideY(begin: 0.3, end: 0),

            const SizedBox(height: 8),

            Text(
              'One app. All kids. Zero chaos.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.darkTextSecondary,
                  ),
            )
                .animate(delay: const Duration(milliseconds: 600))
                .fadeIn(duration: const Duration(milliseconds: 400)),

            const SizedBox(height: 60),

            // Loading indicator
            SizedBox(
              width: 120,
              child: LinearProgressIndicator(
                backgroundColor: AppColors.darkBorder,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                borderRadius: BorderRadius.circular(4),
              ),
            )
                .animate(delay: const Duration(milliseconds: 800))
                .fadeIn(),
          ],
        ),
      ),
    );
  }
}
