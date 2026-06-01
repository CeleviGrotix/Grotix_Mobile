import '../../domain/entities/zone.dart';
import '../../domain/repositories/zone_repository.dart';

class ZoneService {
  final ZoneRepository _repo;
  const ZoneService(this._repo);

  Future<Zone?> getZoneDetails(int zoneId) async {
    try {
      return await _repo.getById(zoneId);
    } catch (_) {
      return null;
    }
  }

  /// Cambia la fase actual de cultivo de una zona (ej. de Germinación a Vegetativa)
  Future<Zone?> updatePhase(int zoneId, ZonePhase newPhase) async {
    try {
      final data = {
        'currentPhase': newPhase.label,
        'phaseStartDate': DateTime.now().toIso8601String(),
      };
      return await _repo.update(zoneId, data);
    } catch (_) {
      return null;
    }
  }

  /// Filtra zonas que necesitan atención (ej. están en fase de cosecha)
  Future<List<Zone>> getZonesReadyToHarvest(int farmId) async {
    final all = await _repo.getByFarmId(farmId);
    return all.where((z) => z.phase == ZonePhase.harvest).toList();
  }
}