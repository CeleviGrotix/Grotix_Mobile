import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:grotix/common/config/env.dart';
import '../../../identity/auth/infrastructure/datasource/auth_local_datasource.dart';

class ZoneRemoteDatasource {
  static const String _base = Env.apiBase;
  static const String _path = '/api/v1/zones';

  final http.Client _client;
  ZoneRemoteDatasource({http.Client? client})
      : _client = client ?? http.Client();

  Future<Map<String, String>> _headers() async {
    final token = await AuthLocalDatasource().getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> getById(int zoneId) async {
    final uri = Uri.parse('$_base$_path/$zoneId');
    return _client.get(uri, headers: await _headers());
  }

  Future<http.Response> getByFarmId(int farmId) async {
    final uri = Uri.parse('$_base/api/v1/farms/$farmId/zones');
    return _client.get(uri, headers: await _headers());
  }

  Future<http.Response> create(Map<String, dynamic> data) async {
    final uri = Uri.parse('$_base$_path');
    return _client.post(
      uri,
      headers: await _headers(),
      body: jsonEncode(data),
    );
  }

  Future<http.Response> update(int zoneId, Map<String, dynamic> data) async {
    final uri = Uri.parse('$_base$_path/$zoneId');
    return _client.patch(
      uri,
      headers: await _headers(),
      body: jsonEncode(data),
    );
  }
}