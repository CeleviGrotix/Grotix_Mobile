import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grotix/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

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
  final double _aiTrustLevel = 1.00;

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
      healthScore: zone.healthScore,
      aiObservaciones: zone.aiObservaciones,
    );
  }

  Future<void> _onAnalyze(int zoneId) async {
    // 1. Preguntamos al usuario de dónde quiere sacar la foto
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Pequeña barra decorativa arriba
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Text(
                  'Seleccionar imagen',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const FaIcon(FontAwesomeIcons.camera, color: AppColors.greenEmerald),
                  title: const Text('Tomar foto', style: TextStyle(color: Colors.white70, fontSize: 16)),
                  onTap: () => Navigator.of(context).pop(ImageSource.camera),
                ),
                ListTile(
                  leading: const FaIcon(FontAwesomeIcons.image, color: AppColors.greenEmerald),
                  title: const Text('Elegir de la galería', style: TextStyle(color: Colors.white70, fontSize: 16)),
                  onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );

    // Si tocó fuera del menú y no eligió nada, cancelamos.
    if (source == null) return;

    // 2. Abrimos la cámara o galería según su elección
    final picker = ImagePicker();
    final XFile? photo = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1024,
    );

    if (photo == null) return;

    setState(() => _refreshingIds.add(zoneId));

    // Llamamos al provider con la foto seleccionada
    final aiResult = await context
        .read<ZoneProvider>()
        .analyzeZoneWithAi(zoneId, photo.path);

    if (!mounted) return;
    setState(() => _refreshingIds.remove(zoneId));

    final l10n = AppLocalizations.of(context)!;

    // Mostramos el diálogo con el resultado completo
    if (aiResult != null) {
      _showAiResultDialog(aiResult, l10n);
    } else {
      _showErrorDialog(l10n);
    }
  }

  void _showAiResultDialog(Map<String, dynamic> result, AppLocalizations l10n) {
    final String estado = result['estado_germinacion'] ?? 'unknown';
    final int score = (result['health_score'] as num?)?.toInt() ?? 0;
    final String obs = result['observaciones'] ?? '';

    Color scoreColor;
    if (score >= 75) {
      scoreColor = const Color(0xFF4CAF50);
    } else if (score >= 40) {
      scoreColor = const Color(0xFFFFC107);
    } else {
      scoreColor = const Color(0xFFF44336);
    }

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Título ────────────────────────────────────────────────
              Row(
                children: [
                  const FaIcon(FontAwesomeIcons.microchip,
                      color: AppColors.greenEmerald, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    l10n.aiAnalysisTitle,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close,
                        color: Colors.white54, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Estado de germinación ─────────────────────────────────
              _ResultRow(
                icon: FontAwesomeIcons.seedling,
                label: l10n.statusLabel,
                value: estado.toUpperCase(),
                valueColor: AppColors.greenEmerald,
              ),
              const SizedBox(height: 16),

              // ── Health Score ──────────────────────────────────────────
              Text(
                l10n.healthScoreLabel,
                style: TextStyle(
                  color: AppColors.white.withOpacity(0.6),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: score / 100,
                        minHeight: 10,
                        backgroundColor: Colors.white12,
                        valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$score/100',
                    style: TextStyle(
                      color: scoreColor,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Observaciones ─────────────────────────────────────────
              if (obs.isNotEmpty) ...[
                Text(
                  l10n.observationsLabel,
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.6),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  obs,
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.85),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // ── Botón ──────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.greenEmerald,
                    foregroundColor: AppColors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                  child: Text(
                    l10n.understood,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(l10n.errorTitle, style: const TextStyle(color: Colors.redAccent)),
        content: Text(
          l10n.aiConnectionError,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            child: Text(l10n.okButton,
                style: const TextStyle(color: AppColors.greenEmerald)),
          ),
        ],
      ),
    );
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
                        ? l10n.noZonesAvailable
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

// ── Widgets ──────────────────────────────────────────────────────────

class _ResultRow extends StatelessWidget {
  final FaIconData icon;
  final String label;
  final String value;
  final Color valueColor;

  const _ResultRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FaIcon(icon, size: 14, color: Colors.white38),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(color: Colors.white54, fontSize: 14),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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
