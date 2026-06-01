import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:grotix/common/config/env.dart';

import '../../../auth/infrastructure/datasource/auth_local_datasource.dart';
import '../../domain/entities/association.dart';

class AssociationRemoteDatasource {
  static const String _base = Env.apiBase;
  static const String _associationsPath = '/api/v1/associations';

  final http.Client _client;
  AssociationRemoteDatasource({http.Client? client})
      : _client = client ?? http.Client();

  Future<Map<String, String>> _headers() async {
    final token = await AuthLocalDatasource().getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ── GET /associations ───────────────────────────────────────────────────

  Future<List<Association>> getAssociations() async {
    final uri = Uri.parse('$_base$_associationsPath');
    final headers = await _headers();

    debugPrint('🔵 [ASSOCIATION] GET $uri');
    final response = await _client.get(uri, headers: headers);
    debugPrint('🟣 [ASSOCIATION] ${response.statusCode}');

    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List<dynamic>;
      return list.map((e) => Association.fromMap(e as Map<String, dynamic>)).toList();
    }
    throw _error('getAssociations', response);
  }

  // ── POST /associations ──────────────────────────────────────────────────

  Future<Association> createAssociation({
    required String name,
    required String email,
  }) async {
    final uri = Uri.parse('$_base$_associationsPath');
    final headers = await _headers();

    final body = {
      'name': name,
      'email': email,
    };

    debugPrint('🔵 [ASSOCIATION] POST $uri → $body');
    final response = await _client.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );
    debugPrint('🟣 [ASSOCIATION] ${response.statusCode}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Association.fromMap(jsonDecode(response.body));
    }
    throw _error('createAssociation', response);
  }

  // ── GET /associations/{associationId} ───────────────────────────────────

  Future<Association> getAssociationById(int associationId) async {
    final uri = Uri.parse('$_base$_associationsPath/$associationId');
    final headers = await _headers();

    debugPrint('🔵 [ASSOCIATION] GET $uri');
    final response = await _client.get(uri, headers: headers);
    debugPrint('🟣 [ASSOCIATION] ${response.statusCode}');

    if (response.statusCode == 200) {
      return Association.fromMap(jsonDecode(response.body));
    }
    throw _error('getAssociationById', response);
  }

  // ── PATCH /associations/{associationId} ─────────────────────────────────

  Future<Association> updateAssociation({
    required int associationId,
    String? name,
    String? email,
  }) async {
    final uri = Uri.parse('$_base$_associationsPath/$associationId');
    final headers = await _headers();

    final body = <String, dynamic>{
      if (name != null) 'name': name,
      if (email != null) 'email': email,
    };

    debugPrint('🔵 [ASSOCIATION] PATCH $uri → $body');
    final response = await _client.patch(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );
    debugPrint('🟣 [ASSOCIATION] ${response.statusCode}');

    if (response.statusCode == 200) {
      return Association.fromMap(jsonDecode(response.body));
    }
    throw _error('updateAssociation', response);
  }

  // ── Helper ──────────────────────────────────────────────────────────────

  Exception _error(String method, http.Response response) {
    debugPrint('🔴 [ASSOCIATION] $method failed ${response.statusCode}: ${response.body}');
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return Exception(body['message'] ?? 'Request failed');
    } catch (_) {
      return Exception('Request failed (${response.statusCode})');
    }
  }
}