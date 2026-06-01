import 'package:http/http.dart' as http;
import 'package:grotix/common/config/env.dart';

import '../../../identity/auth/infrastructure/datasource/auth_local_datasource.dart';

class CropRemoteDatasource {
  static const String _base = Env.apiBase;
  static const String _path = '/api/v1/catalog/crops';

  final http.Client _client;
  CropRemoteDatasource({http.Client? client})
      : _client = client ?? http.Client();

  Future<Map<String, String>> _headers() async {
    final token = await AuthLocalDatasource().getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> getAll() async {
    final uri = Uri.parse('$_base$_path');
    return _client.get(uri, headers: await _headers());
  }

  Future<http.Response> getById(int cropId) async {
    final uri = Uri.parse('$_base$_path/$cropId');
    return _client.get(uri, headers: await _headers());
  }
}