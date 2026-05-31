import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grotix/common/theme/app_colors.dart';
import 'package:grotix/l10n/app_localizations.dart'; // Importante
import 'package:intl/intl.dart';

import '../../domain/entities/zone.dart';

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
    final timeString = zone.lastUpdate != null
        ? DateFormat('HH:mm').format(zone.lastUpdate!)
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
          _SensorStatusBadge(status: zone.sensorStatus),
        ],
      ),
    );
  }
}

class _SensorStatusBadge extends StatelessWidget {
  final ZoneSensorStatus status;

  const _SensorStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Mapeamos el estado a ícono, texto traducido y color
    final (icon, label, color) = switch (status) {
      ZoneSensorStatus.allActive => (
      FontAwesomeIcons.circleCheck,
      l10n.allSensorsActive,
      AppColors.greenEmerald,
      ),
      ZoneSensorStatus.someFailing => (
      FontAwesomeIcons.triangleExclamation,
      l10n.someSensorsFailing,
      AppColors.redCoral,
      ),
      ZoneSensorStatus.allInactive => (
      FontAwesomeIcons.circleXmark,
      l10n.noActiveSensors,
      Colors.orange,
      ),
    };

    return Row(
      children: [
        FaIcon(icon, size: 12, color: color),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            label,
            style: TextStyle(color: color, fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}