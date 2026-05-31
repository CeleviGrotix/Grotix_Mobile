// ─── Widgets ─────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../common/theme/app_colors.dart';

class AuthField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final IconData icon;
  final Widget? suffixIcon;

  const AuthField({
    required this.label,
    required this.controller,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
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
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.07),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: const TextStyle(color: AppColors.white, fontSize: 15),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: FaIcon(icon,
                    size: 16, color: AppColors.white.withOpacity(0.4)),
              ),
              suffixIcon: suffixIcon != null
                  ? Padding(
                padding: const EdgeInsets.only(right: 14),
                child: suffixIcon,
              )
                  : null,
              prefixIconConstraints:
              const BoxConstraints(minWidth: 0, minHeight: 0),
              suffixIconConstraints:
              const BoxConstraints(minWidth: 0, minHeight: 0),
            ),
          ),
        ),
      ],
    );
  }
}