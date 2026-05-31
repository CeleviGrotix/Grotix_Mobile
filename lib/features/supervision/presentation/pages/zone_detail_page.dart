import 'package:flutter/material.dart';

import '../../../../common/theme/app_colors.dart';

class ZoneDetailPage extends StatelessWidget {
  const ZoneDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.black,
      body: Center(child: Text("Zone Screen", style: TextStyle(color: Colors.white))),
    );
  }
}