import 'dart:ui';

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
  final Crop? crop;

  // ── Campos de IA ─────────────────────────────────────────────────────────
  final int? healthScore;
  final String? aiObservaciones;

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
    this.healthScore,
    this.aiObservaciones,
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
      healthScore: null,
      aiObservaciones: null,
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
    int? healthScore,
    String? aiObservaciones,
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
      healthScore: healthScore ?? this.healthScore,
      aiObservaciones: aiObservaciones ?? this.aiObservaciones,
    );
  }

  // ── Getters útiles para la UI ─────────────────────────────────────────────

  ZonePhase get phase => ZonePhase.fromString(currentPhase);

  String get displayName => name ?? crop?.commonName ?? 'Zone #$id';

  int? get daysInPhase => phaseStartDate != null
      ? DateTime.now().difference(phaseStartDate!).inDays
      : null;

  /// Color del health score para la UI
  Color get healthColor {
    if (healthScore == null) return const Color(0xFF9E9E9E); // gris
    if (healthScore! >= 75) return const Color(0xFF4CAF50);  // verde
    if (healthScore! >= 40) return const Color(0xFFFFC107);  // amarillo
    return const Color(0xFFF44336);                           // rojo
  }
}