import 'package:flutter/material.dart';
import 'package:grotix/common/theme/app_colors.dart';

class LanguageSelector extends StatelessWidget {
  final bool isSpanish;
  final ValueChanged<bool> onChanged; // true = español

  const LanguageSelector({
    super.key,
    required this.isSpanish,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _LangOption(
          label: 'English',
          flagEmoji: '🇺🇸',
          selected: !isSpanish,
          onTap: () => onChanged(false),
        ),
        const SizedBox(width: 10),
        _LangOption(
          label: 'Español',
          flagEmoji: '🇪🇸',
          selected: isSpanish,
          onTap: () => onChanged(true),
        ),
      ],
    );
  }
}

class _LangOption extends StatelessWidget {
  final String label;
  final String flagEmoji;
  final bool selected;
  final VoidCallback onTap;

  const _LangOption({
    required this.label,
    required this.flagEmoji,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.blueCerulean : Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.blueCerulean : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Text(flagEmoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.white : AppColors.white.withOpacity(0.6),
                fontSize: 15,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}