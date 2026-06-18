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
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return Zone.fromMap(jsonDecode(res.body) as Map<String, dynamic>);
    }
    throw Exception('HTTP ${res.statusCode}: ${res.reasonPhrase}');
  }

  @override
  Future<List<Zone>> getByFarmId(int farmId) async {
    final res = await _ds.getByFarmId(farmId);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final raw = jsonDecode(res.body) as List<dynamic>;
      return raw
          .map((e) => Zone.fromMap(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('HTTP ${res.statusCode}: ${res.reasonPhrase}');
  }

  @override
  Future<Zone> create(Map<String, dynamic> data) async {
    final res = await _ds.create(data);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return Zone.fromMap(jsonDecode(res.body) as Map<String, dynamic>);
    }
    throw Exception('HTTP ${res.statusCode}: ${res.reasonPhrase}');
  }

  @override
  Future<Zone> update(int zoneId, Map<String, dynamic> data) async {
    final res = await _ds.update(zoneId, data);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return Zone.fromMap(jsonDecode(res.body) as Map<String, dynamic>);
    }
    throw Exception('HTTP ${res.statusCode}: ${res.reasonPhrase}');
  }

  @override
  Future<void> createAnalysisReport(int zoneId, String detectedPhase, int healthScore) async {
    final res = await _ds.createAnalysisReport(zoneId, {
      "detectedPhase": detectedPhase,
      "healthScore": healthScore,
    });
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('HTTP ${res.statusCode}: ${res.reasonPhrase}');
    }
  }
}