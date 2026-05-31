

import 'crop.dart';
import 'microcontroller.dart';

enum ZoneSensorStatus { allActive, someFailing, allInactive }

class Zone {
  final int zoneId;
  final int farmId;
  final int cropId;
  final String currentPhase;
  final DateTime phaseStartDate;
  final String? imageUrl;

  final Crop? crop;
  final List<Microcontroller> microcontrollers;
  final DateTime? lastUpdate;

  const Zone({
    required this.zoneId,
    required this.farmId,
    required this.cropId,
    required this.currentPhase,
    required this.phaseStartDate,
    this.imageUrl,
    this.crop,
    this.microcontrollers = const [],
    this.lastUpdate,
  });

  /// Nombre a mostrar: usa el nombre del cultivo si está disponible
  String get displayName => crop?.commonName ?? 'Zone #$zoneId';

  /// Estado general de sensores basado en los microcontroladores
  ZoneSensorStatus get sensorStatus {
    if (microcontrollers.isEmpty) return ZoneSensorStatus.allInactive;

    final activeCount =
        microcontrollers.where((m) => m.isActive).length;

    if (activeCount == microcontrollers.length) {
      return ZoneSensorStatus.allActive;
    } else if (activeCount == 0) {
      return ZoneSensorStatus.allInactive;
    } else {
      return ZoneSensorStatus.someFailing;
    }
  }

  bool get hasActiveSensors => sensorStatus == ZoneSensorStatus.allActive;
}