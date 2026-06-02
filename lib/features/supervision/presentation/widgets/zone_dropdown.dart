import 'package:flutter/material.dart';
import 'package:grotix/common/theme/app_colors.dart';
import 'package:grotix/features/supervision/domain/entities/zone.dart';
import 'package:grotix/l10n/app_localizations.dart';

class ZoneDropdown extends StatelessWidget {
  final Zone? selectedZone;
  final List<Zone> zones;
  final ValueChanged<Zone> onChanged;

  const ZoneDropdown({
    super.key,
    required this.selectedZone,
    required this.zones,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // EL l10n DEBE IR AQUÍ, dentro del build
    final l10n = AppLocalizations.of(context)!;

    if (zones.isEmpty) {
      return Text(
        l10n.noZonesFound, // Usando l10n corregido
        style: const TextStyle(
            color: AppColors.white, fontSize: 24, fontWeight: FontWeight.bold),
      );
    }

    return GestureDetector(
      onTap: () => _showZonePicker(context, l10n), // Pasamos l10n al modal
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              selectedZone?.displayName ?? l10n.selectZone, // Usar l10n aquí también
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_drop_down,
              color: AppColors.greenEmerald, size: 32),
        ],
      ),
    );
  }

  void _showZonePicker(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.selectZone,
            style: const TextStyle(
                color: AppColors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          // Usamos un Flexible o LimitedBox por si la lista es muy larga
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: zones.map((zone) {
                final isSelected = zone.id == selectedZone?.id;
                return ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    onChanged(zone);
                  },
                  leading: _buildZoneImage(zone.imageUrl),
                  title: Text(
                    zone.displayName,
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    _getPhaseLabel(zone.phase, l10n), // Traducción de la fase
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle,
                      color: AppColors.greenEmerald, size: 20)
                      : null,
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildZoneImage(String? imageUrl) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white10,
        image: imageUrl != null
            ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
            : null,
      ),
      child: imageUrl == null
          ? const Icon(Icons.grass, color: Colors.white30, size: 20)
          : null,
    );
  }

  String _getPhaseLabel(ZonePhase phase, AppLocalizations l10n) {
    return switch (phase) {
      ZonePhase.seed => l10n.phaseSeed,
      ZonePhase.germination => l10n.phaseGermination,
      ZonePhase.vegetative => l10n.phaseVegetative,
      ZonePhase.flowering => l10n.phaseFlowering,
      ZonePhase.fruiting => l10n.phaseFruiting,
      ZonePhase.harvest => l10n.phaseHarvest,
      _ => l10n.phaseUnknown,
    };
  }
}