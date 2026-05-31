// lib/features/auth/presentation/pages/splash_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grotix/common/theme/app_colors.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  void _navigateToHome() async {
    // Simulamos un tiempo de carga corto para apreciar el Splash
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      // Bypass temporal: saltamos directo al dashboard de Grotix para probar la barra
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: Image.asset(
          'assets/images/logo.png',
          width: 150,
        ),
      ),
    );
  }
}