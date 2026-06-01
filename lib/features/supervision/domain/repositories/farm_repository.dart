import '../entities/farm.dart';
import '../entities/zone.dart';

abstract class FarmRepository {
  Future<List<Farm>> getAll();
  Future<Farm> getById(int farmId);
  Future<List<Zone>> getZonesByFarm(int farmId);
}