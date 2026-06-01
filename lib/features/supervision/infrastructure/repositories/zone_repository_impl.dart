import 'dart:convert';
import '../../domain/entities/zone.dart';
import '../../domain/repositories/zone_repository.dart';
import '../datasource/zone_datasource.dart';

class ZoneRepositoryImpl implements ZoneRepository {
  final ZoneRemoteDatasource _ds;
  const ZoneRepositoryImpl(this._ds);

  @override
  Future<Zone> getById(int zoneId) async {
    final res = await _ds.getById(zoneId);
    if (res.statusCode == 200) {
      return Zone.fromMap(jsonDecode(res.body));
    }
    throw Exception('Error al obtener zona $zoneId');
  }

  @override
  Future<Zone> update(int zoneId, Map<String, dynamic> data) async {
    final res = await _ds.update(zoneId, data);
    if (res.statusCode == 200) {
      return Zone.fromMap(jsonDecode(res.body));
    }
    throw Exception('Error al actualizar zona');
  }

  @override
  Future<List<Zone>> getByFarmId(int farmId) async {
    final res = await _ds.getByFarmId(farmId);
    if (res.statusCode == 200) {
      final List<dynamic> raw = jsonDecode(res.body);
      return raw.map((e) => Zone.fromMap(e)).toList();
    }
    return [];
  }
}