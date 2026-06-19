import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:grotix/common/config/env.dart';
import 'package:grotix/features/identity/auth/infrastructure/datasource/auth_local_datasource.dart';
import 'package:grotix/features/supervision/domain/entities/zone.dart';
import 'package:grotix/features/supervision/presentation/providers/zone_provider.dart';

// ── Entidades de Telemetría ────────

class Threshold {
  final String sensorType;
  final double minValue;
  final double maxValue;

  Threshold({required this.sensorType, required this.minValue, required this.maxValue});

  factory Threshold.fromMap(Map<String, dynamic> map) {
    return Threshold(
      sensorType: map['sensorType'] ?? '',
      minValue: (map['minValue'] as num?)?.toDouble() ?? 0.0,
      maxValue: (map['maxValue'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class TelemetrySensor {
  final String id;
  final DateTime lastSeen;
  TelemetrySensor(this.id, this.lastSeen);
}

class ZoneTelemetry {
  final double moistureAir;
  final double moistureSoil;
  final double temperature;
  final double lightRadiation; // 0–1 bar (humedad/luz %); lux crudo si sensor en lux
  final bool lightUsesPercentScale;
  final double lightRaw; // valor API sin escalar
  final String moistureAirStatus;
  final String moistureSoilStatus;
  final String temperatureStatus;
  final String lightStatus;
  final List<TelemetrySensor> sensors;
  final DateTime updatedAt;

  const ZoneTelemetry({
    required this.moistureAir,
    required this.moistureSoil,
    required this.temperature,
    required this.lightRadiation,
    required this.lightUsesPercentScale,
    required this.lightRaw,
    required this.moistureAirStatus,
    required this.moistureSoilStatus,
    required this.temperatureStatus,
    required this.lightStatus,
    required this.sensors,
    required this.updatedAt,
  });

  static String calculateStatus(double value, String type, List<Threshold> thresholds) {
    if (thresholds.isEmpty) return 'Average';

    final t = thresholds.where((x) => x.sensorType == type).firstOrNull;
    if (t == null) return 'Unknown';

    if (value >= t.minValue && value <= t.maxValue) return 'Optimal';

    final margin = (t.maxValue - t.minValue) * 0.15;
    if (value >= (t.minValue - margin) && value <= (t.maxValue + margin)) {
      return 'Average';
    }

    return 'Critical';
  }

  static bool usesPercentScale(List<Threshold> thresholds) {
    final t = thresholds.where((x) => x.sensorType == 'LIGHT_INTENSITY').firstOrNull;
    return t == null || t.maxValue <= 100;
  }

  static double optimalLightDisplay(double optimalLight, bool percentScale) {
    if (!percentScale) return optimalLight;
    if (optimalLight <= 100) return optimalLight;
    return (optimalLight / 1000 * 100).clamp(0, 100);
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

class DashboardProvider extends ChangeNotifier {
  final ZoneProvider _zoneProvider;
  final http.Client _client = http.Client();

  DashboardProvider({required ZoneProvider zoneProvider})
      : _zoneProvider = zoneProvider {
    _zoneProvider.addListener(_onZonesUpdated);
    // Si ya hay zonas cuando se crea el provider, selecciona inmediatamente
    if (_zoneProvider.zones.isNotEmpty) {
      selectZone(_zoneProvider.zones.first);
    }
  }

  Zone? _selectedZone;
  ZoneTelemetry? _telemetry;
  bool _isLoadingTelemetry = false;

  bool _hasNewDataAvailable = false;
  Timer? _silentPoller;

  Zone? get selectedZone => _selectedZone;
  ZoneTelemetry? get telemetry => _telemetry;
  bool get isLoadingTelemetry => _isLoadingTelemetry;
  bool get hasNewDataAvailable => _hasNewDataAvailable;
  List<Zone> get availableZones => _zoneProvider.zones;

  void _onZonesUpdated() {
    final zones = _zoneProvider.zones;

    if (zones.isEmpty) {
      _selectedZone = null;
      _telemetry = null;
      _hasNewDataAvailable = false;
      _silentPoller?.cancel();
      notifyListeners();
      return;
    }

    if (_selectedZone == null ||
        !zones.any((z) => z.id == _selectedZone!.id)) {
      selectZone(zones.first);
      return;
    }

    Zone? updated;
    for (final z in zones) {
      if (z.id == _selectedZone!.id) {
        updated = z;
        break;
      }
    }

    if (updated != null && !identical(updated, _selectedZone)) {
      _selectedZone = updated;
      notifyListeners();
    }
  }

  void reset() {
    _selectedZone = null;
    _telemetry = null;
    _hasNewDataAvailable = false;
    _isLoadingTelemetry = false;
    _silentPoller?.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    _zoneProvider.removeListener(_onZonesUpdated);
    _silentPoller?.cancel();
    _client.close();
    super.dispose();
  }

  Future<Map<String, String>> _headers() async {
    final token = await AuthLocalDatasource().getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<void> selectZone(Zone zone) async {
    _selectedZone = zone;
    _hasNewDataAvailable = false;
    _silentPoller?.cancel();
    _telemetry = null;

    await _fetchFullTelemetry(showLoading: true);
    _startSilentPolling();
  }

  void selectFirstZoneIfNeeded() {
    if (_selectedZone == null && availableZones.isNotEmpty) {
      selectZone(availableZones.first);
    }
  }

  void reloadNewData() {
    _fetchFullTelemetry(showLoading: true);
  }

  Future<void> _fetchFullTelemetry({bool showLoading = false}) async {
    if (_selectedZone == null) return;
    if (showLoading) {
      _isLoadingTelemetry = true;
      notifyListeners();
    }

    try {
      final zoneId = _selectedZone!.id;
      final baseUrl = Env.apiBase;
      final headers = await _headers();

      // 1. Traer umbrales
      final threshUrl = '$baseUrl/api/v1/telemetry/zones/$zoneId/thresholds';
      final threshRes = await _client.get(Uri.parse(threshUrl), headers: headers);

      List<Threshold> thresholds = [];
      if (threshRes.statusCode == 200) {
        final List rawThresh = jsonDecode(threshRes.body);
        thresholds = rawThresh.map((e) => Threshold.fromMap(e)).toList();
      }

      // 2. Traer telemetría (Usamos la ruta correcta y le pedimos solo el más reciente con limit=1)
      final telemetryUrl = '$baseUrl/api/v1/telemetry/zones/$zoneId?limit=1';
      final telemetryRes = await _client.get(Uri.parse(telemetryUrl), headers: headers);

      if (telemetryRes.statusCode == 200) {
        final jsonResponse = jsonDecode(telemetryRes.body);
        final readings = jsonResponse['readings'] as List<dynamic>? ?? [];

        if (readings.isNotEmpty) {
          // Extraemos el primer elemento (el más reciente) del arreglo
          final rawData = readings.first;

          final temp = (rawData['temperature'] as num).toDouble();
          final humAir = (rawData['humidityAir'] as num).toDouble();
          final humSoil = (rawData['humiditySoil'] as num).toDouble();
          final light = (rawData['lightIntensity'] as num).toDouble();
          final timestamp = DateTime.parse(rawData['timestamp']).toLocal();
          final deviceId = rawData['deviceId'].toString();
          final lightPercent = ZoneTelemetry.usesPercentScale(thresholds);

          _telemetry = ZoneTelemetry(
            temperature: temp,
            moistureAir: humAir / 100.0,
            moistureSoil: humSoil / 100.0,
            lightRaw: light,
            lightUsesPercentScale: lightPercent,
            lightRadiation: lightPercent ? light / 100.0 : light,
            temperatureStatus: ZoneTelemetry.calculateStatus(temp, 'AIR_TEMPERATURE', thresholds),
            moistureAirStatus: ZoneTelemetry.calculateStatus(humAir, 'AIR_HUMIDITY', thresholds),
            moistureSoilStatus: ZoneTelemetry.calculateStatus(humSoil, 'SOIL_MOISTURE', thresholds),
            lightStatus: ZoneTelemetry.calculateStatus(light, 'LIGHT_INTENSITY', thresholds),
            updatedAt: timestamp,
            sensors: [TelemetrySensor('ESP32-$deviceId', timestamp)],
          );
        } else {
          _telemetry = null; // El arreglo de lecturas llegó vacío
        }
      } else {
        _telemetry = null; // Status no fue 200
      }
    } catch (e) {
      debugPrint("💥 [Telemetry] Error: $e");
      _telemetry = null;
    } finally {
      _isLoadingTelemetry = false;
      _hasNewDataAvailable = false;
      notifyListeners();
    }
  }

  Future<void> setAutoIrrigation(int zoneId, bool allowAuto) async {
    final mode = allowAuto ? IrrigationMode.automatic : IrrigationMode.manual;
    await _zoneProvider.updateIrrigationMode(zoneId, mode);
  }



  void _startSilentPolling() {
    _silentPoller?.cancel();
    _silentPoller = Timer.periodic(const Duration(seconds: 15), (timer) async {
      if (_selectedZone == null || _telemetry == null || _hasNewDataAvailable) return;

      try {
        // Usamos la ruta correcta con limit=1
        final telemetryUrl = '${Env.apiBase}/api/v1/telemetry/zones/${_selectedZone!.id}?limit=1';
        final telemetryRes = await _client.get(
          Uri.parse(telemetryUrl),
          headers: await _headers(),
        );

        if (telemetryRes.statusCode == 200) {
          final jsonResponse = jsonDecode(telemetryRes.body);
          final readings = jsonResponse['readings'] as List<dynamic>? ?? [];

          if (readings.isNotEmpty) {
            final rawData = readings.first;
            final dbTime = DateTime.parse(rawData['timestamp']).toLocal();

            // Si la fecha del registro en BD es más nueva que la que tenemos en pantalla...
            if (dbTime.isAfter(_telemetry!.updatedAt)) {
              _hasNewDataAvailable = true;
              notifyListeners();
            }
          }
        }
      } catch (_) {}
    });
  }
}