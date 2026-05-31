// lib/features/auth/presentation/pages/splash_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grotix/common/theme/app_colors.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Center(
        child: Image.asset('assets/images/logo.png', height: 60),
      ),
    );
  }
}