import '../../domain/entities/zone.dart';
import '../../domain/repositories/zone_repository.dart';

class ZoneService {
  final ZoneRepository _repo;
  const ZoneService(this._repo);

  /// Obtiene todas las zonas de una granja específica
  Future<List<Zone>> getZonesByFarm(int farmId) async {
    try {
      return await _repo.getByFarmId(farmId);
    } catch (e) {
      // Log error si es necesario
      return [];
    }
  }

  /// Obtiene el detalle de una zona específica
  Future<Zone?> getZoneDetails(int zoneId) async {
    try {
      return await _repo.getById(zoneId);
    } catch (_) {
      return null;
    }
  }

  /// Actualiza la fase de cultivo (lógica de negocio)
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

  /// Filtra zonas listas para cosecha
  Future<List<Zone>> getZonesReadyToHarvest(int farmId) async {
    final all = await getZonesByFarm(farmId);
    return all.where((z) => z.phase == ZonePhase.harvest).toList();
  }
}