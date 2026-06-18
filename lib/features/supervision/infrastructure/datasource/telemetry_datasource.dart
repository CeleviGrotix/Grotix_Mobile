import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:grotix/common/config/env.dart';
import '../../../identity/auth/infrastructure/datasource/auth_local_datasource.dart';
import '../../domain/entities/telemetry.dart';

class TelemetryDatasource {
  static const String _base = Env.apiBase; // Tu Azure URL
  final http.Client _client = http.Client();

  Future<Map<String, String>> _headers() async {
    final token = await AuthLocalDatasource().getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // 1. Traer los umbrales
  Future<List<Threshold>> getThresholds(int zoneId) async {
    final uri = Uri.parse('$_base/api/v1/telemetry/zones/$zoneId/thresholds');
    final res = await _client.get(uri, headers: await _headers());
    if (res.statusCode == 200) {
      final List raw = jsonDecode(res.body);
      return raw.map((e) => Threshold.fromMap(e)).toList();
    }
    return [];
  }

  // 2. Traer la ÚLTIMA telemetría de la zona
  Future<Map<String, dynamic>?> getLatestTelemetry(int zoneId) async {
    // Ajusta esta ruta si en tu Swagger es distinta (ej: /api/v1/zones/1/telemetry/latest)
    final uri = Uri.parse('$_base/api/v1/telemetry/zones/$zoneId/latest');
    final res = await _client.get(uri, headers: await _headers());
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    return null;
  }
}