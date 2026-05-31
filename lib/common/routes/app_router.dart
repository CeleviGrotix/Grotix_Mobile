import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

import '../../features/analytics/presentation/pages/reports_page.dart';
import '../../features/connectivity/presentation/pages/notifications_page.dart';
import '../../features/identity/auth/presentation/pages/login_page.dart';
import '../../features/identity/auth/presentation/pages/register_page.dart';
import '../../features/identity/auth/presentation/pages/splash_page.dart';
import '../../features/identity/auth/presentation/providers/auth_provider.dart';
import '../../features/identity/profile/presentation/pages/profile_page.dart';
import '../../features/intelligence/presentation/pages/ai_processing_page.dart';
import '../../features/supervision/presentation/pages/dashboard_page.dart';
import '../../features/supervision/presentation/pages/zones_page.dart';
import '../widgets/main_shell.dart';


final appRouter = GoRouter(
  initialLocation: '/dashboard',
  redirect: (context, state) {
    final auth = context.read<AuthProvider>();
    final isChecking = auth.status == AuthStatus.checking;
    final isAuth = auth.isAuthenticated;
    final isAuthRoute = state.matchedLocation == '/login' ||
        state.matchedLocation == '/register';

    if (isChecking) return '/splash'; // muestra splash mientras revisa token
    if (!isAuth && !isAuthRoute) return '/login';
    if (isAuth && isAuthRoute) return '/dashboard';
    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),
    GoRoute(path: '/splash', builder: (_, __) => const SplashPage()),
    ShellRoute(
      builder: (_, __, child) => MainShell(child: child),
      routes: [
        GoRoute(path: '/dashboard', builder: (_, __) => const DashboardPage()),
        GoRoute(path: '/ai-processing', builder: (_, __) => const AiProcessingPage()),
        GoRoute(path: '/zones', builder: (_, __) => const ZonesPage()),
        GoRoute(path: '/reports', builder: (_, __) => const ReportsPage()),
        GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
      ],
    ),
  ],
);