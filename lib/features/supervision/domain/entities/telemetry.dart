class Threshold {
  final String sensorType; // "SOIL_MOISTURE", "AIR_TEMPERATURE", etc.
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

class TelemetryUIModel {
  final DateTime updatedAt;
  final double temperature;
  final double moistureAir; // 0.0 a 1.0
  final double moistureSoil; // 0.0 a 1.0
  final double lightRadiation; // 0.0 a 1.0

  final String temperatureStatus;
  final String moistureAirStatus;
  final String moistureSoilStatus;
  final String lightStatus;

  final List<TelemetrySensor> sensors;

  TelemetryUIModel({
    required this.updatedAt,
    required this.temperature,
    required this.moistureAir,
    required this.moistureSoil,
    required this.lightRadiation,
    required this.temperatureStatus,
    required this.moistureAirStatus,
    required this.moistureSoilStatus,
    required this.lightStatus,
    required this.sensors,
  });

  // Helper mágico que compara el valor con los thresholds de Azure
  static String calculateStatus(double value, String type, List<Threshold> thresholds) {
    final t = thresholds.where((x) => x.sensorType == type).firstOrNull;
    if (t == null) return 'Unknown';

    if (value >= t.minValue && value <= t.maxValue) return 'Optimal';

    // Si está fuera del rango pero cerca (ej. 15% de margen), es Average
    final margin = (t.maxValue - t.minValue) * 0.15;
    if (value >= (t.minValue - margin) && value <= (t.maxValue + margin)) {
      return 'Average';
    }

    return 'Critical'; // Muy fuera de rango
  }
}