import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'providers/auth_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/create_family_screen.dart';
import 'screens/auth/add_child_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/tasks_screen.dart';
import 'screens/kids_screen.dart';
import 'screens/child_detail_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/add_event_screen.dart';
import 'screens/add_task_screen.dart';
import 'screens/inbox_screen.dart';
import 'utils/constants.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final familyId = ref.watch(familyIdProvider);
  final onboarding = ref.watch(onboardingDoneProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isDoneOnboarding = onboarding.valueOrNull ?? false;
      final hasFamilyId = familyId.valueOrNull != null;

      final loc = state.matchedLocation;

      // Allow splash always
      if (loc == AppRoutes.splash) return null;

      // Not logged in → auth flow
      if (!isLoggedIn) {
        if (loc.startsWith('/auth') || loc == AppRoutes.onboarding) {
          return null;
        }
        return isDoneOnboarding ? AppRoutes.login : AppRoutes.onboarding;
      }

      // Logged in but no family → create family
      if (isLoggedIn && !hasFamilyId) {
        if (loc == AppRoutes.createFamily || loc == AppRoutes.addChild) {
          return null;
        }
        return AppRoutes.createFamily;
      }

      // Logged in with family → to dashboard if on auth screens
      if (isLoggedIn && hasFamilyId) {
        if (loc.startsWith('/auth') ||
            loc == AppRoutes.onboarding ||
            loc == AppRoutes.createFamily) {
          return AppRoutes.dashboard;
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.createFamily,
        builder: (_, __) => const CreateFamilyScreen(),
      ),
      GoRoute(
        path: AppRoutes.addChild,
        builder: (context, state) {
          final isFirst = state.uri.queryParameters['first'] == 'true';
          return AddChildScreen(isFirst: isFirst);
        },
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (_, __) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.calendar,
        builder: (_, __) => const CalendarScreen(),
      ),
      GoRoute(
        path: AppRoutes.tasks,
        builder: (_, __) => const TasksScreen(),
      ),
      GoRoute(
        path: AppRoutes.kids,
        builder: (_, __) => const KidsScreen(),
      ),
      GoRoute(
        path: '/kids/:id',
        builder: (context, state) {
          final childId = state.pathParameters['id']!;
          return ChildDetailScreen(childId: childId);
        },
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (_, __) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.addEvent,
        builder: (context, state) {
          final childId = state.uri.queryParameters['childId'];
          return AddEventScreen(preselectedChildId: childId);
        },
      ),
      GoRoute(
        path: AppRoutes.addTask,
        builder: (context, state) {
          final childId = state.uri.queryParameters['childId'];
          return AddTaskScreen(preselectedChildId: childId);
        },
      ),
      GoRoute(
        path: AppRoutes.inbox,
        builder: (_, __) => const InboxScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Route not found: ${state.error}')),
    ),
  );
});
