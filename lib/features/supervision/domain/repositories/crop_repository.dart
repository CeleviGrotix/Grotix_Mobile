import '../entities/crop.dart';

abstract class CropRepository {
  Future<List<Crop>> getAll();
  Future<Crop> getById(int cropId);
}