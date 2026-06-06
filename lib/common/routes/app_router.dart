import 'package:go_router/go_router.dart';
import '../../features/analytics/presentation/pages/reports_page.dart';
import '../../features/identity/auth/presentation/pages/login_page.dart';
import '../../features/identity/auth/presentation/pages/register_page.dart';
import '../../features/identity/auth/presentation/pages/splash_page.dart';
import '../../features/identity/auth/presentation/providers/auth_provider.dart';
import '../../features/identity/profile/presentation/pages/profile_page.dart';
import '../../features/intelligence/presentation/pages/ai_processing_page.dart';
import '../../features/supervision/domain/entities/zone.dart';
import '../../features/supervision/presentation/pages/dashboard_page.dart';
import '../../features/supervision/presentation/pages/zone_detail_page.dart';
import '../../features/supervision/presentation/pages/zones_page.dart';
import '../widgets/main_shell.dart';

// El router recibe el AuthProvider para poder escucharlo
GoRouter buildAppRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: authProvider,
    redirect: (context, state) {
      final status = authProvider.status;
      final location = state.uri.path;

      // Todavía verificando token guardado → splash
      if (status == AuthStatus.checking) return '/splash';

      final isAuthRoute =
          location == '/login' || location == '/register';

      // No autenticado y tratando de acceder a ruta protegida → login
      if (status == AuthStatus.unauthenticated && !isAuthRoute) {
        return '/login';
      }

      // Ya autenticado y todavía en ruta de auth → dashboard
      if (status == AuthStatus.authenticated && isAuthRoute) {
        return '/dashboard';
      }

      // En splash pero ya resolvió → redirige según estado
      if (location == '/splash' && status != AuthStatus.checking) {
        return status == AuthStatus.authenticated ? '/dashboard' : '/login';
      }

      return null; // sin redirección
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (_, __) => const RegisterPage(),
      ),
      ShellRoute(
        builder: (_, __, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (_, __) => const DashboardPage(),
          ),
          GoRoute(
            path: '/ai-processing',
            builder: (_, __) => const AiProcessingPage(),
          ),
          GoRoute(
            path: '/zones',
            builder: (_, __) => const ZonesPage(),
          ),
          GoRoute(
            path: '/zones/:id',
            builder: (context, state) => ZoneDetailPage(
              zone: state.extra as Zone,
            ),
          ),
          GoRoute(
            path: '/reports',
            builder: (_, __) => const ReportsPage(),
          ),
          GoRoute(
            path: '/profile',
            builder: (_, __) => const ProfilePage(),
          ),
        ],
      ),
    ],
  );
}