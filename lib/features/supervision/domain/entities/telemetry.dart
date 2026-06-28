class GrotixThreshold {
  final String sensorType;
  final double minValue;
  final double maxValue;

  GrotixThreshold({required this.sensorType, required this.minValue, required this.maxValue});

  factory GrotixThreshold.fromMap(Map<String, dynamic> map) {
    return GrotixThreshold(
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
  final double moistureAir;
  final double moistureSoil;
  final double lightRadiation;
  final double lightRaw;
  final bool lightUsesPercentScale;
  final String temperatureStatus;
  final String moistureAirStatus;
  final String moistureSoilStatus;
  final String lightStatus;
  final List<TelemetrySensor> sensors;
  final List<GrotixThreshold> thresholds;

  TelemetryUIModel({
    required this.updatedAt,
    required this.temperature,
    required this.moistureAir,
    required this.moistureSoil,
    required this.lightRadiation,
    required this.lightRaw,
    required this.lightUsesPercentScale,
    required this.temperatureStatus,
    required this.moistureAirStatus,
    required this.moistureSoilStatus,
    required this.lightStatus,
    required this.sensors,
    required this.thresholds,
  });

  static String calculateStatus(double value, String type, List<GrotixThreshold> thresholds) {
    if (thresholds.isEmpty) return 'Average';
    final t = thresholds.where((x) => x.sensorType == type).firstOrNull;
    if (t == null) return 'Unknown';
    if (value >= t.minValue && value <= t.maxValue) return 'Optimal';
    final margin = (t.maxValue - t.minValue) * 0.15;
    if (value >= (t.minValue - margin) && value <= (t.maxValue + margin)) return 'Average';
    return 'Critical';
  }

  static bool usesPercentScale(List<GrotixThreshold> thresholds) {
    final t = thresholds.where((x) => x.sensorType == 'LIGHT_INTENSITY').firstOrNull;
    return t == null || t.maxValue <= 100;
  }

  static double optimalLightDisplay(double optimalLight, bool percentScale) {
    if (!percentScale) return optimalLight;
    if (optimalLight <= 100) return optimalLight;
    return (optimalLight / 1000 * 100).clamp(0, 100);
  }
}