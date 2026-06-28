import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grotix/common/theme/app_colors.dart';
import 'package:grotix/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:grotix/features/supervision/domain/entities/telemetry.dart';
import '../providers/dashboard_provider.dart';

class MainTabView extends StatelessWidget {
  final AppLocalizations l10n;

  const MainTabView({super.key, required this.l10n});

  String _getOptimalText(String sensorType, double? baseValue, List<GrotixThreshold> thresholds) {
    final t = thresholds.where((x) => x.sensorType == sensorType).firstOrNull;
    if (t != null && (t.minValue > 0 || t.maxValue > 0)) {
      return '${t.minValue.round()} - ${t.maxValue.round()}';
    }
    return baseValue != null ? baseValue.round().toString() : 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = context.watch<DashboardProvider>();
    final zone = dashboard.selectedZone;
    final telemetry = dashboard.telemetry;
    final crop = zone?.crop;

    // 1. Mostrar loading SOLO si realmente está cargando
    if (dashboard.isLoadingTelemetry) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 60),
          child: CircularProgressIndicator(color: AppColors.greenEmerald),
        ),
      );
    }

    // 2. Si ya cargó pero no hay datos (Endpoint regresó 404 o falló)
    if (telemetry == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 60),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.sensors_off, color: Colors.white24, size: 64),
              const SizedBox(height: 16),
              const Text(
                'Sin datos de sensores',
                style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Aún no se ha recibido telemetría\npara la zona seleccionada.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white38, fontSize: 14),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => dashboard.reloadNewData(),
                icon: const Icon(Icons.refresh, color: AppColors.black, size: 16),
                label: const Text("Reintentar", style: TextStyle(color: AppColors.black, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.greenEmerald),
              )
            ],
          ),
        ),
      );
    }

    // 3. ¡Si hay datos, dibujamos la interfaz!
    final timeStr = DateFormat('HH:mm').format(telemetry.updatedAt);

    // VALIDACIÓN A PRUEBA DE BALAS PARA LA IMAGEN
    final String? imgUrl = zone?.imageUrl;
    final bool hasValidImage = imgUrl != null && imgUrl.trim().isNotEmpty && imgUrl.startsWith('http');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (dashboard.hasNewDataAvailable)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => dashboard.reloadNewData(),
                icon: const Icon(Icons.refresh, color: AppColors.black, size: 20),
                label: const Text(
                  'Nuevos datos detectados. Toca para actualizar',
                  style: TextStyle(color: AppColors.black, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.greenEmerald,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 4,
                ),
              ),
            ),
          ),

        // ── Card info cultivo ───────────────────────────────
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.darkCardBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: hasValidImage
                    ? Image.network(
                  imgUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  // Si la URL falla al descargar, no explota, muestra este icono:
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 100,
                    height: 100,
                    color: Colors.white10,
                    child: const Icon(Icons.broken_image, color: Colors.white30, size: 40),
                  ),
                )
                    : Container(
                  width: 100,
                  height: 100,
                  color: Colors.white10,
                  child: const Icon(Icons.grass, color: Colors.white30, size: 40),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      crop?.commonName ?? zone?.displayName ?? '—',
                      style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.germinationStage(zone?.phase.label ?? '—'),
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 14),
                    ),
                    if (zone?.latitude != null)
                      Text(
                        l10n.latitude(_formatCoord(zone!.latitude!)),
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 14),
                      ),
                    if (zone?.longitude != null)
                      Text(
                        l10n.longitude(_formatCoord(zone!.longitude!)),
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 14),
                      ),
                    if (crop != null)
                      Text(
                        crop.scientificName,
                        style: TextStyle(
                          color: AppColors.white.withOpacity(0.4),
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ── Humedad Aire ─────────────────────────────────────────
        _buildSectionTitle(l10n.moistureAir),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: AppColors.darkCardBg,
              borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 64,
                    height: 64,
                    child: CircularProgressIndicator(
                      value: telemetry.moistureAir,
                      strokeWidth: 8,
                      color: _statusColor(telemetry.moistureAirStatus),
                      backgroundColor:
                      _statusColor(telemetry.moistureAirStatus).withOpacity(0.2),
                    ),
                  ),
                  Text(
                    '${(telemetry.moistureAir * 100).round()}%',
                    style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    telemetry.moistureAirStatus,
                    style: TextStyle(
                        color: _statusColor(telemetry.moistureAirStatus),
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    l10n.lastUpdate(timeStr),
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                  if (crop != null)
                    Text(
                      '${l10n.optimal}: ${_getOptimalText('AIR_HUMIDITY', crop.optimalHumidityAir, telemetry.thresholds)}%',
                      style: TextStyle(
                          color: AppColors.white.withOpacity(0.4),
                          fontSize: 12),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ── Humedad Soil ─────────────────────────────────────────
        _buildSectionTitle(l10n.moistureSoil),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: AppColors.darkCardBg,
              borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 64,
                    height: 64,
                    child: CircularProgressIndicator(
                      value: telemetry.moistureSoil,
                      strokeWidth: 8,
                      color: _statusColor(telemetry.moistureSoilStatus),
                      backgroundColor:
                      _statusColor(telemetry.moistureSoilStatus).withOpacity(0.2),
                    ),
                  ),
                  Text(
                    '${(telemetry.moistureSoil * 100).round()}%',
                    style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    telemetry.moistureSoilStatus,
                    style: TextStyle(
                        color: _statusColor(telemetry.moistureSoilStatus),
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    l10n.lastUpdate(timeStr),
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                  if (crop != null)
                    Text(
                      '${l10n.optimal}: ${_getOptimalText('SOIL_MOISTURE', crop.optimalHumiditySoil, telemetry.thresholds)}%',
                      style: TextStyle(
                          color: AppColors.white.withOpacity(0.4),
                          fontSize: 12),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

// ── Radiación (Forzado a Porcentaje) ──
        _buildSectionTitle(l10n.lightRadiation),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: AppColors.darkCardBg,
              borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    telemetry.lightStatus,
                    style: TextStyle(
                        color: _statusColor(telemetry.lightStatus),
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    l10n.lastUpdate(timeStr),
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${telemetry.lightRaw.round()}%',
                style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('0%', style: TextStyle(color: AppColors.white, fontSize: 12)),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: (telemetry.lightRaw / 100.0).clamp(0.0, 1.0),
                          minHeight: 14,
                          color: _statusColor(telemetry.lightStatus),
                          backgroundColor: Colors.white10,
                        ),
                      ),
                    ),
                  ),
                  const Text('100%', style: TextStyle(color: AppColors.white, fontSize: 12)),
                ],
              ),
              if (crop != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${l10n.optimal}: ${_getOptimalText('LIGHT_INTENSITY', crop.optimalLight > 100 ? 100 : crop.optimalLight, telemetry.thresholds)}%',
                    style: TextStyle(
                        color: AppColors.white.withOpacity(0.4),
                        fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ── Temperatura ──────────────────────────────────────
        _buildSectionTitle(l10n.temperature),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: AppColors.darkCardBg,
              borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              const FaIcon(FontAwesomeIcons.temperatureHalf,
                  color: AppColors.white, size: 24),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${telemetry.temperature.toStringAsFixed(1)}°C — ${telemetry.temperatureStatus}',
                    style: TextStyle(
                        color: _statusColor(telemetry.temperatureStatus),
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    l10n.lastUpdate(timeStr),
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 12),
                  ),
                  if (crop != null)
                    Text(
                      '${l10n.optimal}: ${_getOptimalText('AIR_TEMPERATURE', crop.optimalTemperature, telemetry.thresholds)}°C',
                      style: TextStyle(
                          color: AppColors.white.withOpacity(0.4),
                          fontSize: 12),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),


      ],
    );
  }

  String _formatCoord(double value) => value.toStringAsFixed(4);

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
            color: AppColors.blueCerulean,
            fontSize: 20,
            fontWeight: FontWeight.w600),
      ),
    );
  }

  Color _statusColor(String status) => switch (status.toLowerCase()) {
    'optimal' => AppColors.greenEmerald,
    'average' => Colors.orange,
    _ => Colors.redAccent,
  };
}
