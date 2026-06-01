import '../../domain/entities/crop.dart';
import '../../domain/repositories/crop_repository.dart';

class CropService {
  final CropRepository _repo;
  const CropService(this._repo);

  Future<List<Crop>> getAllCrops() => _repo.getAll();

  Future<Crop?> findById(int cropId) async {
    try {
      return await _repo.getById(cropId);
    } catch (_) {
      return null;
    }
  }

  /// Búsqueda por nombre común (case-insensitive)
  Future<List<Crop>> search(String query) async {
    final all = await getAllCrops();
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return all;
    return all
        .where((c) => c.commonName.toLowerCase().contains(q))
        .toList();
  }

  /// Devuelve un mapa id → Crop para lookups rápidos desde Zone
  Future<Map<int, Crop>> getCropMap() async {
    final all = await getAllCrops();
    return {for (final c in all) c.id: c};
  }
}