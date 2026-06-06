class Crop {
  final int id;
  final String commonName;
  final String scientificName;
  final double optimalTemperature;
  final double optimalHumidityAir;
  final double optimalHumiditySoil;
  final double optimalLight;
  final int maxStressTime; // en minutos según backend
  final String? imageUrl;

  const Crop({
    required this.id,
    required this.commonName,
    required this.scientificName,
    required this.optimalTemperature,
    required this.optimalHumidityAir,
    required this.optimalHumiditySoil,
    required this.optimalLight,
    required this.maxStressTime,
    this.imageUrl,
  });

  factory Crop.fromMap(Map<String, dynamic> map) {
    return Crop(
      id: (map['id'] as num?)?.toInt() ?? 0,
      commonName: map['commonName'] as String? ?? '',
      scientificName: map['scientificName'] as String? ?? '',
      optimalTemperature: (map['optimalTemperature'] as num?)?.toDouble() ?? 0.0,
      optimalHumidityAir: (map['optimalHumidityAir'] as num?)?.toDouble() ?? 0.0,
      optimalHumiditySoil: (map['optimalHumiditySoil'] as num?)?.toDouble() ?? 0.0,
      optimalLight: (map['optimalLight'] as num?)?.toDouble() ?? 0.0,
      maxStressTime: (map['maxStressTime'] as num?)?.toInt() ?? 0,
      imageUrl: map['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'commonName': commonName,
    'scientificName': scientificName,
    'optimalTemperature': optimalTemperature,
    'optimalHumidityAir': optimalHumidityAir,
    'optimalHumiditySoil': optimalHumiditySoil,
    'optimalLight': optimalLight,
    'maxStressTime': maxStressTime,
    'imageUrl': imageUrl,
  };
}