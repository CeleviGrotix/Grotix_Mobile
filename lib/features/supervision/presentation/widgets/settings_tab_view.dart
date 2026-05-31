import 'package:flutter/material.dart';
import 'package:grotix/common/theme/app_colors.dart';
import 'package:grotix/l10n/app_localizations.dart';

class SettingsTabView extends StatelessWidget {
  final AppLocalizations l10n;
  final bool allowAuto;
  final bool manualIrrigation;
  final String maxTime;
  final ValueChanged<bool> onAutoChanged;
  final ValueChanged<bool> onManualChanged;
  final ValueChanged<String?> onTimeChanged;

  const SettingsTabView({
    super.key,
    required this.l10n,
    required this.allowAuto,
    required this.manualIrrigation,
    required this.maxTime,
    required this.onAutoChanged,
    required this.onManualChanged,
    required this.onTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.darkCardBg, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(l10n.irrigation),
          SwitchListTile(
            title: Text(l10n.allowAutoIrrigation, style: const TextStyle(color: AppColors.white, fontSize: 15)),
            value: allowAuto,
            activeThumbColor: AppColors.greenEmerald,
            inactiveThumbColor: AppColors.redCoral,
            inactiveTrackColor:  AppColors.coralFaded,
            onChanged: onAutoChanged,
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            title: Text(l10n.startManualIrrigation, style: const TextStyle(color: AppColors.white, fontSize: 15)),
            value: manualIrrigation,
            activeThumbColor: AppColors.greenEmerald,
            inactiveThumbColor: AppColors.redCoral,
            inactiveTrackColor:  AppColors.coralFaded,
            onChanged: onManualChanged,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 16),

          _buildSectionTitle(l10n.maxTimeIrrigation),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: maxTime,
                dropdownColor: AppColors.darkCardBg,
                style: const TextStyle(color: AppColors.white),
                isExpanded: true,
                onChanged: onTimeChanged,
                items: ['15 min', '30 min', '45 min']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 24),

          _buildSectionTitle(l10n.criticalLevels),
          _CriticalLevelRow(label: l10n.moisture, value: '20 %'),
          _CriticalLevelRow(label: l10n.lightRadiation, value: '10 %'),
          _CriticalLevelRow(label: l10n.temperature, value: '15°', secondValue: '27°'),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(color: AppColors.blueCerulean, fontSize: 18, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _CriticalLevelRow extends StatelessWidget {
  final String label;
  final String value;
  final String? secondValue;

  const _CriticalLevelRow({required this.label, required this.value, this.secondValue});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.white, fontSize: 15)),
          Row(
            children: [
              _ValueBox(text: value),
              if (secondValue != null) ...[
                const SizedBox(width: 8),
                _ValueBox(text: secondValue!),
              ]
            ],
          )
        ],
      ),
    );
  }
}

class _ValueBox extends StatelessWidget {
  final String text;
  const _ValueBox({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: const TextStyle(color: AppColors.white, fontSize: 13, fontWeight: FontWeight.w600)),
    );
  }
}