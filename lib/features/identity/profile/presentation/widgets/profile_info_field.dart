import 'package:flutter/material.dart';
import 'package:grotix/common/theme/app_colors.dart';

class ProfileInfoField extends StatelessWidget {
  final String label;
  final String? value;
  final bool enabled;
  final TextEditingController? controller;

  const ProfileInfoField({
    super.key,
    required this.label,
    this.value,
    this.enabled = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.white.withOpacity(0.6),
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 48,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.07),
            borderRadius: BorderRadius.circular(10),
          ),
          child: enabled
              ? TextField(
            controller: controller,
            style: const TextStyle(color: AppColors.white, fontSize: 18),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding:
              EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          )
              : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Text(
              value ?? '',
              style: TextStyle(
                color: AppColors.white.withOpacity(0.5),
                fontSize: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}