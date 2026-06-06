import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:grotix/common/config/env.dart';
import '../../../identity/auth/infrastructure/datasource/auth_local_datasource.dart';
import '../../domain/entities/member.dart';

class MembersRemoteDatasource {
  // Zone members → Cultivation :5102
  static const String _cultivationBase = Env.apiBase;
  // Association members → Profiles :5101
  static const String _profilesBase = Env.apiBase;

  final http.Client _client;
  MembersRemoteDatasource({http.Client? client})
      : _client = client ?? http.Client();

  Future<Map<String, String>> _headers() async {
    final token = await AuthLocalDatasource().getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ── GET /zones/{zoneId}/members ──────────────────────────────────────────

  Future<List<ZoneMember>> getZoneMembers(int zoneId) async {
    final uri =
    Uri.parse('$_cultivationBase/api/v1/zones/$zoneId/members');
    debugPrint('🔵 [MEMBERS] GET $uri');
    final res = await _client.get(uri, headers: await _headers());
    debugPrint('🟣 [MEMBERS] ${res.statusCode}');

    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List<dynamic>;
      return list
          .map((e) => ZoneMember.fromMap(e as Map<String, dynamic>))
          .toList();
    }
    throw _error('getZoneMembers', res);
  }

  // ── POST /zones/{zoneId}/members ─────────────────────────────────────────

  Future<void> addZoneMember(int zoneId, int userId) async {
    final uri =
    Uri.parse('$_cultivationBase/api/v1/zones/$zoneId/members');
    debugPrint('🔵 [MEMBERS] POST $uri → userId: $userId');
    final res = await _client.post(
      uri,
      headers: await _headers(),
      body: jsonEncode({'userId': userId}),
    );
    debugPrint('🟣 [MEMBERS] ${res.statusCode}');

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw _error('addZoneMember', res);
    }
  }

  // ── DELETE /zones/{zoneId}/members/{userId} ──────────────────────────────

  Future<void> removeZoneMember(int zoneId, int userId) async {
    final uri = Uri.parse(
        '$_cultivationBase/api/v1/zones/$zoneId/members/$userId');
    debugPrint('🔵 [MEMBERS] DELETE $uri');
    final res = await _client.delete(uri, headers: await _headers());
    debugPrint('🟣 [MEMBERS] ${res.statusCode}');

    if (res.statusCode != 200 && res.statusCode != 204) {
      throw _error('removeZoneMember', res);
    }
  }

  // ── GET /associations/{associationId}/members ────────────────────────────

  Future<List<ZoneMember>> getAssociationMembers(
      int associationId) async {
    final uri = Uri.parse(
        '$_profilesBase/api/v1/associations/$associationId/members');
    debugPrint('🔵 [MEMBERS] GET $uri');
    final res = await _client.get(uri, headers: await _headers());
    debugPrint('🟣 [MEMBERS] ${res.statusCode}');

    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List<dynamic>;
      return list
          .map((e) =>
          ZoneMember.fromMap(e as Map<String, dynamic>))
          .toList();
    }
    throw _error('getAssociationMembers', res);
  }

  // ── Helper ───────────────────────────────────────────────────────────────

  Exception _error(String method, http.Response res) {
    debugPrint('🔴 [MEMBERS] $method failed ${res.statusCode}: ${res.body}');
    try {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return Exception(body['message'] ?? 'Request failed');
    } catch (_) {
      return Exception('Request failed (${res.statusCode})');
    }
  }
}