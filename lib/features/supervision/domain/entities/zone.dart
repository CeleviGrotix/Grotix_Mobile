import 'crop.dart';

enum ZonePhase {
  seed,
  germination,
  vegetative,
  flowering,
  fruiting,
  harvest,
  unknown;

  static ZonePhase fromString(String? value) {
    return switch (value?.toUpperCase()) {
      'SEED' => ZonePhase.seed,
      'GERMINATION' => ZonePhase.germination,
      'VEGETATIVE' => ZonePhase.vegetative,
      'FLOWERING' => ZonePhase.flowering,
      'FRUITING' => ZonePhase.fruiting,
      'HARVEST' => ZonePhase.harvest,
      _ => ZonePhase.unknown,
    };
  }

  String get label => switch (this) {
    ZonePhase.seed => 'SEED',
    ZonePhase.germination => 'GERMINATION',
    ZonePhase.vegetative => 'VEGETATIVE',
    ZonePhase.flowering => 'FLOWERING',
    ZonePhase.fruiting => 'FRUITING',
    ZonePhase.harvest => 'HARVEST',
    ZonePhase.unknown => 'UNKNOWN',
  };
}

class Zone {
  final int id;
  final int farmId;
  final int cropId;
  final String? name;
  final String currentPhase;
  final DateTime? phaseStartDate;
  final String? imageUrl;
  final double? latitude;
  final double? longitude;

  // Relación opcional — se carga junto a la zona cuando el backend la incluye
  final Crop? crop;

  const Zone({
    required this.id,
    required this.farmId,
    required this.cropId,
    this.name,
    required this.currentPhase,
    this.phaseStartDate,
    this.imageUrl,
    this.latitude,
    this.longitude,
    this.crop,
  });

  factory Zone.fromMap(Map<String, dynamic> map, {Crop? crop}) {
    return Zone(
      id: (map['id'] as num?)?.toInt() ?? 0,
      farmId: (map['farmId'] as num?)?.toInt() ?? 0,
      cropId: (map['cropId'] as num?)?.toInt() ?? 0,
      name: map['name'] as String?,
      currentPhase: map['currentPhase'] as String? ?? 'UNKNOWN',
      phaseStartDate: map['phaseStartDate'] != null
          ? DateTime.parse(map['phaseStartDate'] as String)
          : null,
      imageUrl: map['imageUrl'] as String?,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      crop: crop,
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'cropId': cropId,
    'currentPhase': currentPhase,
    'phaseStartDate': phaseStartDate?.toIso8601String(),
    'imageUrl': imageUrl,
    'latitude': latitude,
    'longitude': longitude,
  };

  Zone copyWith({
    String? name,
    int? cropId,
    String? currentPhase,
    DateTime? phaseStartDate,
    String? imageUrl,
    double? latitude,
    double? longitude,
    Crop? crop,
  }) {
    return Zone(
      id: id,
      farmId: farmId,
      cropId: cropId ?? this.cropId,
      name: name ?? this.name,
      currentPhase: currentPhase ?? this.currentPhase,
      phaseStartDate: phaseStartDate ?? this.phaseStartDate,
      imageUrl: imageUrl ?? this.imageUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      crop: crop ?? this.crop,
    );
  }

  // ── Getters útiles para la UI ─────────────────────────────────────────────

  ZonePhase get phase => ZonePhase.fromString(currentPhase);

  /// Prioridad: name del backend → commonName del crop → fallback Zone #id
  String get displayName => name ?? crop?.commonName ?? 'Zone #$id';

  /// Días desde que empezó la fase actual
  int? get daysInPhase => phaseStartDate != null
      ? DateTime.now().difference(phaseStartDate!).inDays
      : null;
}