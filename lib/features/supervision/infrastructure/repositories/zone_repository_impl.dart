import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/zone.dart';
import '../../domain/repositories/zone_repository.dart';
import '../datasource/zone_datasource.dart';

class ZoneRepositoryImpl implements ZoneRepository {
  final ZoneRemoteDatasource _ds;
  const ZoneRepositoryImpl(this._ds);

  /// Construye una excepción priorizando el mensaje que envía el backend
  /// (ej. los BadRequest de ZonesController devuelven { "message": "..." }).
  /// Si el body viene vacío o no es JSON (ej. un Forbid sin contenido),
  /// cae al fallback con el statusCode/reasonPhrase.
  Exception _toException(http.Response res) {
    try {
      final body = jsonDecode(res.body);
      if (body is Map && body['message'] != null) {
        return Exception(body['message'] as String);
      }
    } catch (_) {
      // body vacío o no es JSON válido — usamos el fallback de abajo
    }
    return Exception('HTTP ${res.statusCode}: ${res.reasonPhrase}');
  }

  @override
  Future<Zone> getById(int zoneId) async {
    final res = await _ds.getById(zoneId);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return Zone.fromMap(jsonDecode(res.body) as Map<String, dynamic>);
    }
    throw _toException(res);
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
    throw _toException(res);
  }

  @override
  Future<Zone> create(Map<String, dynamic> data) async {
    final res = await _ds.create(data);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return Zone.fromMap(jsonDecode(res.body) as Map<String, dynamic>);
    }
    throw _toException(res);
  }

  @override
  Future<Zone> update(int zoneId, Map<String, dynamic> data) async {
    final res = await _ds.update(zoneId, data);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return Zone.fromMap(jsonDecode(res.body) as Map<String, dynamic>);
    }
    throw _toException(res);
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