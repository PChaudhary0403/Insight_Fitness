import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/onboarding/presentation/pages/welcome_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_shell.dart';
import '../../features/dashboard/presentation/pages/home_page.dart';
import '../../features/analytics/presentation/pages/analytics_page.dart';
import '../../features/tick_sheet/presentation/pages/tick_sheet_page.dart';
import '../../features/ai_assistant/presentation/pages/ai_chat_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/hydration/presentation/pages/hydration_page.dart';
import '../../features/diet/presentation/pages/diet_page.dart';
import '../../features/activity/presentation/pages/activity_page.dart';
import '../../features/goals/presentation/pages/goals_page.dart';
import '../../features/health_assessment/presentation/pages/health_assessment_page.dart';
import '../../features/discipline/presentation/pages/discipline_page.dart';

/// App router configuration using GoRouter.
class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');
  static final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'shell');

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/welcome',
    routes: [
      // ─── Welcome / Splash ───────────────────────────────
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomePage(),
      ),

      // ─── Onboarding ─────────────────────────────────────
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),

      // ─── Auth ────────────────────────────────────────────
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),

      // ─── Health Assessment Onboarding ────────────────────
      GoRoute(
        path: '/health-assessment',
        builder: (context, state) => const HealthAssessmentPage(),
      ),

      // ─── Main App Shell (with bottom nav) ───────────────
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => DashboardShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomePage(),
            ),
          ),
          GoRoute(
            path: '/analytics',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AnalyticsPage(),
            ),
          ),
          GoRoute(
            path: '/tick-sheet',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TickSheetPage(),
            ),
          ),
          GoRoute(
            path: '/ai-chat',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AIChatPage(),
            ),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfilePage(),
            ),
          ),
        ],
      ),

      // ─── Feature Screens (Full-screen, outside shell) ───
      GoRoute(
        path: '/hydration',
        builder: (context, state) => const HydrationPage(),
      ),
      GoRoute(
        path: '/diet',
        builder: (context, state) => const DietPage(),
      ),
      GoRoute(
        path: '/activity',
        builder: (context, state) => const ActivityPage(),
      ),
      GoRoute(
        path: '/goals',
        builder: (context, state) => const GoalsPage(),
      ),
      GoRoute(
        path: '/discipline',
        builder: (context, state) => const DisciplinePage(),
      ),
    ],
  );
}
