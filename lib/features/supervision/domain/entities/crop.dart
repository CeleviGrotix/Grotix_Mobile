class Crop {
  final int cropId;
  final String commonName;
  final String scientificName;
  final double optimalTemperature;
  final double optimalHumidity;
  final double optimalLight;
  final int maxStressTime;

  const Crop({
    required this.cropId,
    required this.commonName,
    required this.scientificName,
    required this.optimalTemperature,
    required this.optimalHumidity,
    required this.optimalLight,
    required this.maxStressTime,
  });
}