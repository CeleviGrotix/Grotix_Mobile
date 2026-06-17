import 'package:flutter/material.dart';
import 'package:grotix/features/supervision/domain/entities/zone.dart';
import 'package:grotix/features/supervision/presentation/providers/zone_provider.dart';

// ── Modelos mock de telemetría ────────────────────────────────────────────────

class MockSensorReading {
  final String id;
  final DateTime lastSeen;

  const MockSensorReading({
    required this.id,
    required this.lastSeen,
  });
}

class MockTelemetry {
  final double moistureAir;       // 0.0 - 1.0
  final double moistureSoil;       // 0.0 - 1.0
  final double temperature;    // °C
  final double lightRadiation; // 0.0 - 1.0
  final String moistureAirStatus;
  final String moistureSoilStatus;
  final String temperatureStatus;
  final String lightStatus;
  final List<MockSensorReading> sensors;
  final DateTime updatedAt;

  const MockTelemetry({
    required this.moistureAir,
    required this.moistureSoil,
    required this.temperature,
    required this.lightRadiation,
    required this.moistureAirStatus,
    required this.moistureSoilStatus,
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

    if (_selectedZone == null) {
      if (_zoneProvider.zones.isNotEmpty) {
        selectZone(_zoneProvider.zones.first);
      }
      return;
    }

    // Zone es inmutable: si la zona seleccionada fue actualizada en otro lado
    // (ej. ZoneProvider.updateIrrigationMode hizo copyWith), la lista tiene
    // una instancia NUEVA con el mismo id. Sincronizamos la referencia sin
    // regenerar telemetría (eso solo debe pasar al cambiar de zona, no al
    // refrescar un campo de la misma zona).
    Zone? updated;
    for (final z in _zoneProvider.zones) {
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

  Future<void> setAutoIrrigation(int zoneId, bool allowAuto) async {
    final mode = allowAuto ? IrrigationMode.automatic : IrrigationMode.manual;
    await _zoneProvider.updateIrrigationMode(zoneId, mode);
  }

  MockTelemetry _generateMockTelemetry(Zone zone) {
    final crop = zone.crop;
    final now = DateTime.now();

    // Valores mock basados en parámetros óptimos del crop si están disponibles
    final optimalHumidityAir = crop?.optimalHumidityAir ?? 65.0;
    final optimalHumiditySoil = crop?.optimalHumiditySoil ?? 27.0;
    final optimalTemp = crop?.optimalTemperature ?? 22.0;
    final optimalLight = crop?.optimalLight ?? 800.0;

    // Simula valores cercanos al óptimo con pequeña variación
    final mockMoistureAir = (optimalHumidityAir + _smallVariation()) / 100;
    final mockMoistureSoil = (optimalHumiditySoil + _smallVariation()) / 100;
    final mockTemp = optimalTemp + _smallVariation();
    final mockLight = ((optimalLight + _smallVariation() * 10) / optimalLight)
        .clamp(0.0, 1.0);

    return MockTelemetry(
      moistureAir: mockMoistureAir.clamp(0.0, 1.0),
      moistureSoil: mockMoistureSoil.clamp(0.0, 1.0),
      temperature: mockTemp,
      lightRadiation: mockLight,
      moistureAirStatus: _statusForRatio(mockMoistureAir),
      moistureSoilStatus: _statusForRatio(mockMoistureSoil),
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
        lastSeen: now.subtract(const Duration(minutes: 5)),
      ),
      MockSensorReading(
        id: mockId(zoneId * 1000 + 1),
        lastSeen: now.subtract(const Duration(minutes: 5)),
      ),
      MockSensorReading(
        id: mockId(zoneId * 1000 + 2),
        lastSeen: now.subtract(const Duration(minutes: 12)),
      ),
      MockSensorReading(
        id: mockId(zoneId * 1000 + 3),
        lastSeen: now.subtract(const Duration(minutes: 3)),
      ),
    ];
  }
}