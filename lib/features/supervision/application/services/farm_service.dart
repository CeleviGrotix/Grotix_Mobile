import '../../domain/entities/farm.dart';
import '../../domain/entities/zone.dart';
import '../../domain/repositories/farm_repository.dart';

class FarmService {
  final FarmRepository _repo;

  const FarmService(this._repo);

  /// Obtiene todas las granjas disponibles
  Future<List<Farm>> getAllFarms() => _repo.getAll();

  /// Busca una granja específica por su ID
  Future<Farm?> findById(int farmId) async {
    try {
      return await _repo.getById(farmId);
    } catch (e) {
      // Podrías registrar el error aquí si usas un logger
      return null;
    }
  }

  /// Obtiene las zonas asociadas a una granja
  /// Útil para la navegación Home -> Detalle de Granja
  Future<List<Zone>> getZonesByFarm(int farmId) async {
    try {
      return await _repo.getZonesByFarm(farmId);
    } catch (_) {
      return [];
    }
  }

  /// Lógica de negocio: Calcular el total de hectáreas o áreas de todas las granjas
  Future<double> getTotalSurface() async {
    final farms = await getAllFarms();
    // Asumiendo que Farm tiene un campo 'area' o similar
    // return farms.fold(0.0, (sum, farm) => sum + (farm.area ?? 0.0));
    return 0.0; // Implementar según los campos reales de tu entidad Farm
  }

  /// Filtrar granjas por nombre (búsqueda local)
  Future<List<Farm>> searchFarms(String query) async {
    final all = await getAllFarms();
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return all;

    return all
        .where((f) => f.name.toLowerCase().contains(q))
        .toList();
  }
}