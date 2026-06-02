import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grotix/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../common/theme/app_colors.dart';
import '../../../../common/utils/app_icons.dart';
import '../../domain/entities/ai_processing_status.dart';
import '../../../supervision/domain/entities/zone.dart';
import '../../../supervision/presentation/providers/zone_provider.dart';
import '../widgets/ai_zone_card.dart';

class AiProcessingPage extends StatefulWidget {
  const AiProcessingPage({super.key});

  @override
  State<AiProcessingPage> createState() => _AiProcessingPageState();
}

class _AiProcessingPageState extends State<AiProcessingPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final Set<int> _refreshingIds = {};
  final double _aiTrustLevel = 0.80;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  AiZoneStatus _toAiStatus(Zone zone) {
    return AiZoneStatus(
      zoneId: zone.id,
      zoneName: zone.displayName,
      imageUrl: zone.imageUrl,
      lastUpdate: zone.phaseStartDate ?? DateTime.now(),
      currentStage: zone.phase.label,
      processingState: _refreshingIds.contains(zone.id)
          ? AiProcessingState.processing
          : AiProcessingState.idle,
    );
  }

  Future<void> _onAnalyze(int zoneId) async {
    setState(() => _refreshingIds.add(zoneId));
    await context.read<ZoneProvider>().refreshZone(zoneId);
    if (mounted) setState(() => _refreshingIds.remove(zoneId));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final zoneProvider = context.watch<ZoneProvider>();
    final allZones = zoneProvider.zones;

    final filtered = _searchQuery.isEmpty
        ? allZones
        : allZones
        .where((z) => z.displayName
        .toLowerCase()
        .contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                l10n.aiImageProcessing,
                style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _AiTrustLevelRow(
                  label: l10n.aiTrustLevel, trustLevel: _aiTrustLevel),
              const SizedBox(height: 24),
              Text(
                l10n.zoneStatus,
                style: const TextStyle(
                    color: AppColors.redCoral,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2),
              ),
              const SizedBox(height: 12),
              _SearchBar(
                hintText: l10n.searchZones,
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: zoneProvider.isLoading
                    ? const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.greenEmerald))
                    : filtered.isEmpty
                    ? _EmptyState(
                    message: allZones.isEmpty
                        ? 'No zones available'
                        : l10n.noZonesFound)
                    : ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final zone = filtered[i];
                    return AiZoneCard(
                      zone: _toAiStatus(zone),
                      onAnalyze: () => _onAnalyze(zone.id),
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
            Text(label,
                style: const TextStyle(
                    color: AppColors.greenEmerald,
                    fontSize: 18,
                    fontWeight: FontWeight.w500)),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(8)),
              child: Text('${(trustLevel * 100).round()} %',
                  style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(height: 1, color: AppColors.greenEmerald.withOpacity(0.4)),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar(
      {required this.hintText,
        required this.controller,
        required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
          color: Colors.white10, borderRadius: BorderRadius.circular(10)),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(color: AppColors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle:
          TextStyle(color: AppColors.white.withOpacity(0.35), fontSize: 14),
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: FaIcon(AppIcons.search,
                size: 16, color: AppColors.white.withOpacity(0.4)),
          ),
          prefixIconConstraints:
          const BoxConstraints(minWidth: 40, minHeight: 0),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(FontAwesomeIcons.microchip,
              size: 48, color: AppColors.white.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(message,
              style: TextStyle(
                  color: AppColors.white.withOpacity(0.4), fontSize: 16)),
        ],
      ),
    );
  }
}