import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:grotix/common/theme/app_colors.dart';
import 'package:grotix/common/utils/app_icons.dart';

import 'curved_nav_bar.dart';

class MainShell extends StatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _calculateCurrentIndex(String location) {
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/ai-processing')) return 1;
    if (location.startsWith('/zones')) return 2;
    if (location.startsWith('/reports')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0: context.go('/dashboard'); break;
      case 1: context.go('/ai-processing'); break;
      case 2: context.go('/zones'); break;
      case 3: context.go('/reports'); break;
      case 4: context.go('/profile'); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    final int currentIndex = _calculateCurrentIndex(location);
    final Size size = MediaQuery.of(context).size;

    final double itemWidth = size.width / 5;
    // Centro X del ítem activo
    final double indicatorCenterX = (itemWidth * currentIndex) + (itemWidth / 2);

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        elevation: 0,
        title: Image.asset('assets/images/logo.png', height: 35),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const FaIcon(AppIcons.notifications, color: AppColors.white, size: 20),
            onPressed: () => context.push('/notifications'),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.white10, height: 1),
        ),
      ),
      body: widget.child,
      bottomNavigationBar: CurvedNavigationBar(
        index: currentIndex,
        backgroundColor: AppColors.black,
        color: AppColors.darkNavBarG,
        gradient: const LinearGradient(
          colors: [AppColors.darkNavBarG, AppColors.darkNavBarB],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        buttonBackgroundColor: AppColors.greenEmerald,
        buttonPadding: 16.0,
        height: 70,
        animationDuration: const Duration(milliseconds: 300),
        animationCurve: Curves.easeOutBack,
        items: const [
          FaIcon(AppIcons.dashboard, color: AppColors.white, size: 22),
          FaIcon(AppIcons.aiProcessing, color: AppColors.white, size: 22),
          FaIcon(AppIcons.zones, color: AppColors.white, size: 22),
          FaIcon(AppIcons.reports, color: AppColors.white, size: 22),
          FaIcon(AppIcons.profile, color: AppColors.white, size: 22),
        ],
        onTap: (index) => _onItemTapped(index, context),
      ),
    );
  }
}
