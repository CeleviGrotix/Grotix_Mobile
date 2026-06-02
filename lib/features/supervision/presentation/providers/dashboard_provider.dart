import 'package:flutter/material.dart';
import 'package:grotix/features/supervision/domain/entities/zone.dart';
import 'package:grotix/features/supervision/presentation/providers/zone_provider.dart';

// ── Modelos mock de telemetría ────────────────────────────────────────────────

class MockSensorReading {
  final String id;
  final double value;
  final String unit;
  final String type;
  final DateTime lastSeen;

  const MockSensorReading({
    required this.id,
    required this.value,
    required this.unit,
    required this.type,
    required this.lastSeen,
  });
}

class MockTelemetry {
  final double moisture;       // 0.0 - 1.0
  final double temperature;    // °C
  final double lightRadiation; // 0.0 - 1.0
  final String moistureStatus;
  final String temperatureStatus;
  final String lightStatus;
  final List<MockSensorReading> sensors;
  final DateTime updatedAt;

  const MockTelemetry({
    required this.moisture,
    required this.temperature,
    required this.lightRadiation,
    required this.moistureStatus,
    required this.temperatureStatus,
    required this.lightStatus,
    required this.sensors,
    required this.updatedAt,
  });
}

// ── Provider ──────────────────────────────────────────────────────────────────

class DashboardProvider extends ChangeNotifier {
  final ZoneProvider _zoneProvider;

  DashboardProvider({required ZoneProvider zoneProvider})
      : _zoneProvider = zoneProvider {
    debugPrint('🔵 [DashboardProvider] created — zones already: ${zoneProvider.zones.length}');
    _zoneProvider.addListener(_onZonesUpdated);
    // Si ya hay zonas cuando se crea el provider, selecciona inmediatamente
    if (_zoneProvider.zones.isNotEmpty) {
      selectZone(_zoneProvider.zones.first);
    }
  }

  Zone? _selectedZone;
  MockTelemetry? _telemetry;
  bool _isLoadingTelemetry = false;

  Zone? get selectedZone => _selectedZone;
  MockTelemetry? get telemetry => _telemetry;
  bool get isLoadingTelemetry => _isLoadingTelemetry;
  List<Zone> get availableZones => _zoneProvider.zones;

  void _onZonesUpdated() {
    debugPrint('🔵 [Dashboard] _onZonesUpdated — zones: ${_zoneProvider.zones.length}, selected: $_selectedZone');
    if (_selectedZone == null && _zoneProvider.zones.isNotEmpty) {
      selectZone(_zoneProvider.zones.first);
    }
  }

  @override
  void dispose() {
    _zoneProvider.removeListener(_onZonesUpdated);
    super.dispose();
  }

  /// Selecciona zona y genera telemetría mock según los parámetros óptimos del crop
  Future<void> selectZone(Zone zone) async {
    _selectedZone = zone;
    _isLoadingTelemetry = true;
    notifyListeners();

    // Simula latencia de red
    await Future.delayed(const Duration(milliseconds: 600));

    _telemetry = _generateMockTelemetry(zone);
    _isLoadingTelemetry = false;
    notifyListeners();
  }

  /// Selecciona la primera zona disponible automáticamente
  void selectFirstZoneIfNeeded() {
    debugPrint('🔵 [Dashboard] selectFirstZoneIfNeeded — zones: ${_zoneProvider.zones.length}');
    if (_selectedZone == null && availableZones.isNotEmpty) {
      selectZone(availableZones.first);
    }
  }

  MockTelemetry _generateMockTelemetry(Zone zone) {
    final crop = zone.crop;
    final now = DateTime.now();

    // Valores mock basados en parámetros óptimos del crop si están disponibles
    final optimalHumidity = crop?.optimalHumidity ?? 65.0;
    final optimalTemp = crop?.optimalTemperature ?? 22.0;
    final optimalLight = crop?.optimalLight ?? 800.0;

    // Simula valores cercanos al óptimo con pequeña variación
    final mockMoisture = (optimalHumidity + _smallVariation()) / 100;
    final mockTemp = optimalTemp + _smallVariation();
    final mockLight = ((optimalLight + _smallVariation() * 10) / optimalLight)
        .clamp(0.0, 1.0);

    return MockTelemetry(
      moisture: mockMoisture.clamp(0.0, 1.0),
      temperature: mockTemp,
      lightRadiation: mockLight,
      moistureStatus: _statusForRatio(mockMoisture),
      temperatureStatus: 'Optimal',
      lightStatus: _statusForRatio(mockLight),
      sensors: _generateMockSensors(zone.id, now),
      updatedAt: now,
    );
  }

  double _smallVariation() => (DateTime.now().millisecond % 20) - 10.0;

  String _statusForRatio(double ratio) {
    if (ratio >= 0.65) return 'Optimal';
    if (ratio >= 0.40) return 'Average';
    return 'Critical';
  }

  List<MockSensorReading> _generateMockSensors(int zoneId, DateTime now) {
    String mockId(int seed) {
      // padLeft garantiza mínimo 6 caracteres antes del substring
      return '#${seed.toRadixString(16).toUpperCase().padLeft(6, '0')}';
    }

    return [
      MockSensorReading(
        id: mockId(zoneId * 1000 + 1),
        value: 72.5,
        unit: '%',
        type: 'SOIL_MOISTURE',
        lastSeen: now.subtract(const Duration(minutes: 5)),
      ),
      MockSensorReading(
        id: mockId(zoneId * 1000 + 2),
        value: 21.8,
        unit: '°C',
        type: 'TEMPERATURE',
        lastSeen: now.subtract(const Duration(minutes: 12)),
      ),
      MockSensorReading(
        id: mockId(zoneId * 1000 + 3),
        value: 780.0,
        unit: 'lux',
        type: 'LIGHT',
        lastSeen: now.subtract(const Duration(minutes: 3)),
      ),
    ];
  }
}