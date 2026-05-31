import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/analytics/presentation/pages/reports_page.dart';
import '../../features/connectivity/presentation/pages/notifications_page.dart';
import '../../features/identity/auth/presentation/pages/login_page.dart';
import '../../features/identity/auth/presentation/pages/splash_page.dart';
import '../../features/identity/profile/presentation/pages/profile_page.dart';
import '../../features/intelligence/presentation/pages/ai_processing_page.dart';
import '../../features/supervision/presentation/pages/dashboard_page.dart';
import '../../features/supervision/presentation/pages/zones_page.dart';
import '../widgets/main_shell.dart';


final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // --- Rutas fuera del Shell (Auth & Splash) ---
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),

    // --- Rutas principales con Bottom Navigation Bar ---
    ShellRoute(
      builder: (context, state, child) {
        return MainShell(child: child);
      },
      routes: [
        // 1. Dashboard / Main (Icono de Gráficos)
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardPage(),
        ),

        // 2. AI Image Processing (Icono de Destello/AI)
        GoRoute(
          path: '/ai-processing',
          builder: (context, state) => const AiProcessingPage(),
        ),

        // 3. Cultivation Areas / Zones (Icono de Planta - Central)
        GoRoute(
          path: '/zones',
          builder: (context, state) => const ZonesPage(),
          /*routes: [
            // Detalle de una zona específica (p.ej. Zona Tomatitos)
            GoRoute(
              path: 'details/:zoneId',
              builder: (context, state) {
                final zoneId = state.pathParameters['zoneId'] ?? '';
                return ZoneDetailPage(zoneId: zoneId);
              },
            ),
          ],*/
        ),

        // 4. Reports (Icono de Documento)
        GoRoute(
          path: '/reports',
          builder: (context, state) => const ReportsPage(),
        ),

        // 5. Profile (Icono de Usuario)
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
        ),
      ],
    ),

    // --- Rutas Modales o Independientes ---
    GoRoute(
      path: '/notifications',
      pageBuilder: (context, state) => const MaterialPage(
        fullscreenDialog: true,
        child: NotificationsPage(),
      ),
    ),
  ],
);