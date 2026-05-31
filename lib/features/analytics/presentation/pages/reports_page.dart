import 'package:flutter/material.dart';

import '../../../../common/theme/app_colors.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.black,
      body: Center(child: Text("Dashboard Screen", style: TextStyle(color: Colors.white))),
    );
  }
}