import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grotix/common/theme/app_colors.dart';
import 'package:grotix/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/dashboard_provider.dart';

class MainTabView extends StatelessWidget {
  final AppLocalizations l10n;

  const MainTabView({super.key, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final dashboard = context.watch<DashboardProvider>();
    final zone = dashboard.selectedZone;
    final telemetry = dashboard.telemetry;
    final crop = zone?.crop;

    if (dashboard.isLoadingTelemetry || telemetry == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 60),
          child: CircularProgressIndicator(color: AppColors.greenEmerald),
        ),
      );
    }

    final timeStr = DateFormat('HH:mm').format(telemetry.updatedAt);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                child: zone?.imageUrl != null
                    ? Image.network(zone!.imageUrl!,
                    width: 100, height: 100, fit: BoxFit.cover)
                    : Container(
                  width: 100,
                  height: 100,
                  color: Colors.white10,
                  child: const Icon(Icons.grass,
                      color: Colors.white30, size: 40),
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
                      '${l10n.optimal}: ${crop.optimalHumidityAir.round()}%',
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
                      '${l10n.optimal}: ${crop.optimalHumiditySoil.round()}%',
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

        // ── Radiación ────────────────────────────────────────
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
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('0%',
                      style: TextStyle(color: AppColors.white, fontSize: 12)),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: telemetry.lightRadiation,
                          minHeight: 14,
                          color: _statusColor(telemetry.lightStatus),
                          backgroundColor: Colors.white10,
                        ),
                      ),
                    ),
                  ),
                  const Text('100%',
                      style: TextStyle(color: AppColors.white, fontSize: 12)),
                ],
              ),
              if (crop != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${l10n.optimal}: ${crop.optimalLight.round()} lux',
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
                      '${l10n.optimal}: ${crop.optimalTemperature.round()}°C',
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

        // ── Sensores ─────────────────────────────────────────
        _buildSectionTitle(l10n.sensors),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.darkCardBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Lista de sensores
              Expanded(
                flex: 4,
                child: Column(
                  children: telemetry.sensors
                      .asMap()
                      .entries
                      .map((entry) => Column(
                    children: [
                      if (entry.key > 0)
                        const Divider(
                            color: Colors.white10, height: 20),
                      _SensorListItem(
                        id: entry.value.id,
                        update: DateFormat('dd/MM/yyyy HH:mm')
                            .format(entry.value.lastSeen),
                        l10n: l10n,
                      ),
                    ],
                  ))
                      .toList(),
                ),
              ),

              // Divisor
              Container(
                height: 200,
                width: 1,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                color: Colors.white10,
              ),

              // Formulario añadir sensor
              Expanded(
                flex: 5,
                child: _AddSensorForm(l10n: l10n),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
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

// ─── Widgets privados ─────────────────────────────────────────────────────────

class _SensorListItem extends StatelessWidget {
  final String id;
  final String update;
  final AppLocalizations l10n;

  const _SensorListItem({
    required this.id,
    required this.update,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(id,
            style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        Text(l10n.lastUpdate(update),
            style: const TextStyle(color: Colors.white54, fontSize: 14)),
      ],
    );
  }
}

class _AddSensorForm extends StatefulWidget {
  final AppLocalizations l10n;
  const _AddSensorForm({required this.l10n});

  @override
  State<_AddSensorForm> createState() => _AddSensorFormState();
}

class _AddSensorFormState extends State<_AddSensorForm> {
  final _idController = TextEditingController();
  final _ssidController = TextEditingController();
  final _passController = TextEditingController();

  @override
  void dispose() {
    _idController.dispose();
    _ssidController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.l10n.addSensor,
          style: const TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _SensorField(hint: '# ID', controller: _idController),
        const SizedBox(height: 8),
        _SensorField(hint: 'SSID', controller: _ssidController),
        const SizedBox(height: 8),
        _SensorField(
            hint: widget.l10n.password,
            controller: _passController,
            isPassword: true),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: () {
              // TODO: conectar con hardware datasource
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.greenEmerald,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
            ),
            child: const Text('ADD',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 12)),
          ),
        ),
      ],
    );
  }
}

class _SensorField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final bool isPassword;

  const _SensorField({
    required this.hint,
    required this.controller,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white10),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: AppColors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
          const TextStyle(color: Colors.white24, fontSize: 14),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );
  }
}