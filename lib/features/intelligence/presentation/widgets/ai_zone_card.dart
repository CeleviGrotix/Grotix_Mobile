import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grotix/common/theme/app_colors.dart';
import 'package:grotix/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/ai_processing_status.dart';

class AiZoneCard extends StatelessWidget {
  final AiZoneStatus zone;
  final VoidCallback? onAnalyze;

  const AiZoneCard({
    super.key,
    required this.zone,
    this.onAnalyze,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkCardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          // ── Fila principal ────────────────────────────────────────────────
          Row(
            children: [
              _ZoneImage(imageUrl: zone.imageUrl),
              const SizedBox(width: 12),
              Expanded(child: _ZoneInfo(zone: zone)),
              _AnalyzeButton(zone: zone, onTap: onAnalyze),
              const SizedBox(width: 12),
            ],
          ),

          // ── Panel de resultado IA (solo si ya tiene datos) ────────────────
          if (zone.healthScore != null) _AiResultPanel(zone: zone),
        ],
      ),
    );
  }
}

// ── Imagen ────────────────────────────────────────────────────────────────────

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

  Widget _placeholder() => Container(
    color: Colors.white10,
    child: const Icon(Icons.image_not_supported_outlined,
        color: Colors.white24, size: 32),
  );
}

// ── Info de zona ──────────────────────────────────────────────────────────────

class _ZoneInfo extends StatelessWidget {
  final AiZoneStatus zone;
  const _ZoneInfo({required this.zone});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lastUpdateTime = DateFormat('HH:mm').format(zone.lastUpdate);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            zone.zoneName,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            l10n.lastUpdate(lastUpdateTime),
            style: TextStyle(
              color: AppColors.white.withOpacity(0.5),
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.stage(zone.currentStage),
            style: const TextStyle(
              color: AppColors.greenEmerald,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Botón de analizar ─────────────────────────────────────────────────────────

class _AnalyzeButton extends StatelessWidget {
  final AiZoneStatus zone;
  final VoidCallback? onTap;

  const _AnalyzeButton({required this.zone, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (zone.isProcessing) {
      return const SizedBox(
        width: 36,
        height: 36,
        child: Padding(
          padding: EdgeInsets.all(4.0),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.greenEmerald,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.greenEmerald, width: 1.5),
        ),
        child: const Center(
          child: FaIcon(
            FontAwesomeIcons.arrowsRotate,
            size: 15,
            color: AppColors.greenEmerald,
          ),
        ),
      ),
    );
  }
}

// ── Panel de resultado IA ─────────────────────────────────────────────────────

class _AiResultPanel extends StatelessWidget {
  final AiZoneStatus zone;
  const _AiResultPanel({required this.zone});

  Color get _scoreColor {
    final score = zone.healthScore ?? 0;
    if (score >= 75) return const Color(0xFF4CAF50); // verde
    if (score >= 40) return const Color(0xFFFFC107); // amarillo
    return const Color(0xFFF44336);                  // rojo
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Score bar ──────────────────────────────────────────────────
          Row(
            children: [
              const Text(
                'Health Score',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                '${zone.healthScore}/100',
                style: TextStyle(
                  color: _scoreColor,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (zone.healthScore ?? 0) / 100,
              minHeight: 6,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(_scoreColor),
            ),
          ),

          // ── Observaciones ──────────────────────────────────────────────
          if (zone.aiObservaciones != null &&
              zone.aiObservaciones!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              zone.aiObservaciones!,
              style: TextStyle(
                color: AppColors.white.withOpacity(0.6),
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}