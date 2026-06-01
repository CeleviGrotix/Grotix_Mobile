import '../entities/zone.dart';

abstract class ZoneRepository {
  /// Obtiene el detalle de una zona específica.
  Future<Zone> getById(int zoneId);

  /// Actualiza los datos de una zona (fase, coordenadas, etc).
  Future<Zone> update(int zoneId, Map<String, dynamic> data);

  /// Obtiene todas las zonas de una granja específica.
  Future<List<Zone>> getByFarmId(int farmId);
}