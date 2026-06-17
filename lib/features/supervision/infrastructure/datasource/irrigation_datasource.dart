import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:grotix/common/config/env.dart';
import '../../../identity/auth/infrastructure/datasource/auth_local_datasource.dart';

class IrrigationDatasource {
  static const String _base = Env.apiBase;
  final http.Client _client;
  final AuthLocalDatasource _authLocal;

  // Así lo puedes instanciar vacío en el main.dart y él mismo se configura
  IrrigationDatasource({http.Client? client, AuthLocalDatasource? authLocal})
      : _client = client ?? http.Client(),
        _authLocal = authLocal ?? AuthLocalDatasource();

  Future<Map<String, String>> _headers() async {
    final token = await _authLocal.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> startManual(int zoneId, double? volume, int? duration) async {
    final url = Uri.parse('$_base/api/v1/irrigation/start/$zoneId');
    final body = jsonEncode({
      if (volume != null) "volumeLiters": volume,
      if (duration != null) "durationMinutes": duration,
    });

    return await _client.post(url, headers: await _headers(), body: body);
  }

  Future<http.Response> stopManual(int zoneId, String? reason) async {
    final url = Uri.parse('$_base/api/v1/irrigation/stop/$zoneId');
    final body = jsonEncode({
      if (reason != null) "reason": reason,
    });

    return await _client.post(url, headers: await _headers(), body: body);
  }
}