

import '../../domain/entities/crop.dart';
import '../../domain/entities/zone.dart';
import '../../domain/repositories/zone_repository.dart';

class ZoneService {
  final ZoneRepository _repo;
  const ZoneService(this._repo);

  Future<List<Zone>> getZonesByFarm(int farmId) async {
    try {
      return await _repo.getByFarmId(farmId);
    } catch (_) {
      return [];
    }
  }

  Future<Zone?> getZoneDetails(int zoneId) async {
    try {
      return await _repo.getById(zoneId);
    } catch (_) {
      return null;
    }
  }

  Future<Zone?> createZone({
    required int farmId,
    required int cropId,
    required ZonePhase phase,
    String? imageUrl,
  }) async {
    try {
      return await _repo.create({
        'farmId': farmId,
        'cropId': cropId,
        'currentPhase': phase.label,
        'phaseStartDate': DateTime.now().toIso8601String(),
        if (imageUrl != null) 'imageUrl': imageUrl,
      });
    } catch (_) {
      return null;
    }
  }

  Future<Zone?> updatePhase(int zoneId, ZonePhase newPhase) async {
    try {
      // 1. Primero buscamos la zona actual para no perder datos
      final currentZone = await getZoneDetails(zoneId);
      if (currentZone == null) return null;

      // 2. Preparamos el payload completo exactamente como lo pide el Swagger
      final updatePayload = {
        "name": currentZone.name,
        "cropId": currentZone.cropId,
        "latitude": currentZone.latitude,
        "longitude": currentZone.longitude,
        "currentPhase": newPhase.label, // El dato nuevo de la IA
        "phaseStartDate": DateTime.now().toUtc().toIso8601String(), // El tiempo nuevo de la IA (UTC como pide C#)
        "imageUrl": currentZone.imageUrl,
        "irrigationMode": "MANUAL", // O el campo que uses por defecto/tengas guardado
      };

      // 3. Enviamos el PATCH con todo completo
      return await _repo.update(zoneId, updatePayload);
    } catch (e) {
      print("Error en ZoneService.updatePhase: $e");
      return null;
    }
  }

  Future<Zone?> updateZone(int zoneId, Map<String, dynamic> data) async {
    try {
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

  /// Enriquece las zonas con su Crop usando un mapa precargado
  List<Zone> enrichWithCrops(List<Zone> zones, Map<int, Crop> cropMap) {
    return zones.map((z) => z.copyWith(crop: cropMap[z.cropId])).toList();
  }

  Future<bool> createAnalysisReport(int zoneId, String detectedPhase, int healthScore) async {
    try {
      await _repo.createAnalysisReport(zoneId, detectedPhase, healthScore);
      return true;
    } catch (e) {
      print("Error en createAnalysisReport: $e");
      return false;
    }
  }
}