import 'dart:convert';

import '../../domain/entities/farm.dart';
import '../../domain/entities/zone.dart';
import '../../domain/repositories/farm_repository.dart';
import '../datasource/farm_datasource.dart';


class FarmRepositoryImpl implements FarmRepository {
  final FarmRemoteDatasource _ds;
  const FarmRepositoryImpl(this._ds);

  @override
  Future<List<Farm>> getAll() async {
    final res = await _ds.getAll();
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final raw = jsonDecode(res.body) as List<dynamic>;
      return raw
          .map((e) => Farm.fromMap(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('HTTP ${res.statusCode}: ${res.reasonPhrase}');
  }

  @override
  Future<Farm> getById(int farmId) async {
    final res = await _ds.getById(farmId);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return Farm.fromMap(jsonDecode(res.body) as Map<String, dynamic>);
    }
    throw Exception('HTTP ${res.statusCode}: ${res.reasonPhrase}');
  }

  @override
  Future<List<Zone>> getZonesByFarm(int farmId) async {
    final res = await _ds.getZonesByFarm(farmId);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final raw = jsonDecode(res.body) as List<dynamic>;
      return raw
          .map((e) => Zone.fromMap(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('HTTP ${res.statusCode}: ${res.reasonPhrase}');
  }
}