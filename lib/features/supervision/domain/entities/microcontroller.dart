enum MicrocontrollerStatus { active, inactive, error }

class Microcontroller {
  final int deviceId;
  final int zoneId;
  final String model;
  final String macAddress;
  final MicrocontrollerStatus status;
  final DateTime lastSeen;

  const Microcontroller({
    required this.deviceId,
    required this.zoneId,
    required this.model,
    required this.macAddress,
    required this.status,
    required this.lastSeen,
  });

  bool get isActive => status == MicrocontrollerStatus.active;
}