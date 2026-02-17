import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';

class _OnboardingPage {
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;

  const _OnboardingPage({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardingPage(
      emoji: '👨‍👩‍👧‍👦',
      title: 'One app.\nAll kids.\nZero chaos.',
      subtitle:
          'Replace WhatsApp chaos, paper notes, and 5 different apps with one beautiful dashboard.',
      color: AppColors.accent,
    ),
    _OnboardingPage(
      emoji: '📅',
      title: 'See everything\nin one glance.',
      subtitle:
          'School schedules, tests, activities, and payments — all visible at a glance for every child.',
      color: Color(0xFF10B981),
    ),
    _OnboardingPage(
      emoji: '✅',
      title: 'Swipe done.\nBreathe easy.',
      subtitle:
          'Swipe right to complete tasks. Smart inbox parses teacher messages into events automatically.',
      color: Color(0xFF8B5CF6),
    ),
  ];

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyOnboardingDone, true);
    if (mounted) context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: _finish,
                  child: Text(
                    'Skip',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.darkTextSecondary,
                        ),
                  ),
                ),
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _OnboardingPageView(page: _pages[index]);
                },
              ),
            ),

            // Indicators + CTA
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  // Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (i) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == i ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == i
                              ? _pages[_currentPage].color
                              : AppColors.darkBorder,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 32),

                  // CTA button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage < _pages.length - 1) {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          _finish();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _pages[_currentPage].color,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        _currentPage < _pages.length - 1
                            ? 'Next →'
                            : 'Get Started',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
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

class _OnboardingPageView extends StatelessWidget {
  final _OnboardingPage page;

  const _OnboardingPageView({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Big emoji
          Text(
            page.emoji,
            style: const TextStyle(fontSize: 96),
          )
              .animate()
              .scale(
                begin: const Offset(0, 0),
                end: const Offset(1, 1),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutBack,
              )
              .fadeIn(),

          const SizedBox(height: 40),

          Text(
            page.title,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
            textAlign: TextAlign.center,
          )
              .animate(delay: const Duration(milliseconds: 200))
              .fadeIn(duration: const Duration(milliseconds: 400))
              .slideY(begin: 0.2, end: 0),

          const SizedBox(height: 20),

          Text(
            page.subtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.darkTextSecondary,
                  height: 1.6,
                ),
            textAlign: TextAlign.center,
          )
              .animate(delay: const Duration(milliseconds: 350))
              .fadeIn(duration: const Duration(milliseconds: 400)),
        ],
      ),
    );
  }
}
