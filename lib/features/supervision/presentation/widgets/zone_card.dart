import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grotix/common/theme/app_colors.dart';
import 'package:grotix/l10n/app_localizations.dart'; // Importante
import 'package:intl/intl.dart';

import '../../domain/entities/zone.dart';

/// <summary>
/// Widget reusable para el corto detalle de una zona en individual
/// </summary>
class ZoneCard extends StatelessWidget {
  final Zone zone;
  final VoidCallback? onTap;

  const ZoneCard({
    super.key,
    required this.zone,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.darkCardBg,
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.hardEdge,
        child: Row(
          children: [
            _ZoneImage(imageUrl: zone.imageUrl),
            const SizedBox(width: 12),
            Expanded(child: _ZoneInfo(zone: zone)),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}

class _ZoneImage extends StatelessWidget {
  final String? imageUrl;

  const _ZoneImage({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      height: 90,
      child: imageUrl != null
          ? Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      )
          : _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      color: Colors.white10,
      child: const Icon(Icons.image_not_supported_outlined,
          color: Colors.white24, size: 32),
    );
  }
}

class _ZoneInfo extends StatelessWidget {
  final Zone zone;

  const _ZoneInfo({required this.zone});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Formateamos la hora
    final timeString = zone.phaseStartDate != null
        ? DateFormat('HH:mm').format(zone.phaseStartDate!)
        : '--:--';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            zone.displayName,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            // Usamos la clave con placeholder {time}
            l10n.lastUpdate(timeString),
            style: TextStyle(
              color: AppColors.white.withOpacity(0.5),
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          _ZonePhaseBadge(phase: zone.phase),
        ],
      ),
    );
  }
}

class _ZonePhaseBadge extends StatelessWidget {
  final ZonePhase phase;

  const _ZonePhaseBadge({required this.phase});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Mapeamos cada fase a su icono y color correspondiente
    final (icon, color) = switch (phase) {
      ZonePhase.seed => (FontAwesomeIcons.seedling, Colors.brown),
      ZonePhase.germination => (FontAwesomeIcons.leaf, Colors.lightGreen),
      ZonePhase.vegetative => (FontAwesomeIcons.plantWilt, AppColors.greenEmerald),
      ZonePhase.flowering => (FontAwesomeIcons.clover, Colors.pinkAccent),
      ZonePhase.fruiting => (FontAwesomeIcons.appleWhole, Colors.orange),
      ZonePhase.harvest => (FontAwesomeIcons.wheatAwn, Colors.yellow),
      ZonePhase.unknown => (FontAwesomeIcons.question, Colors.grey),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FaIcon(icon, size: 12, color: color),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            _getPhaseLabel(phase, l10n),
            style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Helper para obtener el texto traducido de la fase
  String _getPhaseLabel(ZonePhase phase, AppLocalizations l10n) {
    return switch (phase) {
      ZonePhase.seed => l10n.phaseSeed,
      ZonePhase.germination => l10n.phaseGermination,
      ZonePhase.vegetative => l10n.phaseVegetative,
      ZonePhase.flowering => l10n.phaseFlowering,
      ZonePhase.fruiting => l10n.phaseFruiting,
      ZonePhase.harvest => l10n.phaseHarvest,
      ZonePhase.unknown => l10n.phaseUnknown,
    };
  }
}
