import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grotix/l10n/app_localizations.dart'; // Importante para i18n

import '../../../../common/theme/app_colors.dart';
import '../../../../common/utils/app_icons.dart';
import '../../domain/entities/ai_processing_status.dart';
import '../widgets/ai_zone_card.dart';

class AiProcessingPage extends StatefulWidget {
  const AiProcessingPage({super.key});

  @override
  State<AiProcessingPage> createState() => _AiProcessingPageState();
}

class _AiProcessingPageState extends State<AiProcessingPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // TODO: reemplazar con provider/repositorio real
  final double _aiTrustLevel = 0.80;

  List<AiZoneStatus> _zones = [
    AiZoneStatus(
      zoneId: 1,
      zoneName: 'Zona Tomatitos',
      lastUpdate: DateTime.now().subtract(const Duration(minutes: 5)),
      currentStage: 'SEED',
      processingState: AiProcessingState.idle,
    ),
    AiZoneStatus(
      zoneId: 2,
      zoneName: 'Área de Zanahorias',
      lastUpdate: DateTime.now().subtract(const Duration(minutes: 16)),
      currentStage: 'GERMINATION',
      processingState: AiProcessingState.idle,
    ),
    AiZoneStatus(
      zoneId: 3,
      zoneName: 'Zona de Albahaca',
      lastUpdate: DateTime.now().subtract(const Duration(hours: 1)),
      currentStage: 'GERMINATION',
      processingState: AiProcessingState.idle,
    ),
  ];

  List<AiZoneStatus> get _filteredZones {
    if (_searchQuery.isEmpty) return _zones;
    return _zones
        .where((z) =>
        z.zoneName.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  void _onAnalyze(int zoneId) async {
    setState(() {
      _zones = _zones.map((z) {
        if (z.zoneId == zoneId) {
          return AiZoneStatus(
            zoneId: z.zoneId,
            zoneName: z.zoneName,
            imageUrl: z.imageUrl,
            lastUpdate: z.lastUpdate,
            currentStage: z.currentStage,
            processingState: AiProcessingState.processing,
          );
        }
        return z;
      }).toList();
    });

    // Simulación de análisis IA
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _zones = _zones.map((z) {
        if (z.zoneId == zoneId) {
          return AiZoneStatus(
            zoneId: z.zoneId,
            zoneName: z.zoneName,
            imageUrl: z.imageUrl,
            lastUpdate: DateTime.now(),
            currentStage: z.currentStage,
            processingState: AiProcessingState.done,
          );
        }
        return z;
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Título Internacionalizado
              Text(
                l10n.aiImageProcessing,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // AI Trust Level
              _AiTrustLevelRow(
                label: l10n.aiTrustLevel,
                trustLevel: _aiTrustLevel,
              ),
              const SizedBox(height: 24),

              // Sección ZONE STATUS Internacionalizada
              Text(
                l10n.zoneStatus,
                style: const TextStyle(
                  color: AppColors.redCoral,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),

              // Buscador
              _SearchBar(
                hintText: l10n.searchZones,
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
              const SizedBox(height: 16),

              // Lista de zonas
              Expanded(
                child: _filteredZones.isEmpty
                    ? const _EmptyState()
                    : ListView.separated(
                  itemCount: _filteredZones.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final zone = _filteredZones[i];
                    return AiZoneCard(
                      zone: zone,
                      onAnalyze: () => _onAnalyze(zone.zoneId),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── AI Trust Level ──────────────────────────────────────────────────────────

class _AiTrustLevelRow extends StatelessWidget {
  final String label;
  final double trustLevel;

  const _AiTrustLevelRow({required this.label, required this.trustLevel});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.greenEmerald,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${(trustLevel * 100).round()} %',
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(height: 1, color: AppColors.greenEmerald.withOpacity(0.4)),
      ],
    );
  }
}

// ─── Search bar ──────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar({
    required this.hintText,
    required this.controller,
    required this.onChanged
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(color: AppColors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: AppColors.white.withOpacity(0.35), fontSize: 14),

          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: FaIcon(AppIcons.search,
                size: 16, color: AppColors.white.withOpacity(0.4)),
          ),

          prefixIconConstraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 0,
          ),

          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

// ─── Empty state ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(FontAwesomeIcons.microchip,
              size: 48, color: AppColors.white.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(
            l10n.noZonesFound,
            style: TextStyle(
                color: AppColors.white.withOpacity(0.4), fontSize: 16),
          ),
        ],
      ),
    );
  }
}