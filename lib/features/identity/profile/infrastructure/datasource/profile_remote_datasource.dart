import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:grotix/common/config/env.dart';

import '../../../auth/infrastructure/datasource/auth_local_datasource.dart';
import '../../domain/entities/user_profile.dart';

class ProfileRemoteDatasource {
  static const String _base = Env.apiBase;
  static const String _profilePath = '/api/v1/profile';

  final http.Client _client;
  ProfileRemoteDatasource({http.Client? client})
      : _client = client ?? http.Client();

  Future<Map<String, String>> _headers() async {
    final token = await AuthLocalDatasource().getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ── GET /profile/me ──────────────────────────────────────────────────────

  Future<UserProfile> getMe() async {
    final uri = Uri.parse('$_base$_profilePath/me');
    final headers = await _headers();

    debugPrint('🔵 [PROFILE] GET $uri');
    final response = await _client.get(uri, headers: headers);
    debugPrint('🟣 [PROFILE] ${response.statusCode}');

    if (response.statusCode == 200) {
      return UserProfile.fromMap(jsonDecode(response.body));
    }
    throw _error('getMe', response);
  }

  // ── PATCH /profile/{userId} ──────────────────────────────────────────────
  // Solo envía los campos no nulos

  Future<UserProfile> updateProfile({
    required int userId,
    String? name,
    String? taxId,
    String? phone,
    String? profilePicture,
  }) async {
    final uri = Uri.parse('$_base$_profilePath/$userId');
    final headers = await _headers();

    final body = <String, dynamic>{
      if (name != null) 'name': name,
      if (taxId != null) 'taxId': taxId,
      if (phone != null) 'phone': phone,
      if (profilePicture != null) 'profilePicture': profilePicture,
    };

    debugPrint('🔵 [PROFILE] PATCH $uri → $body');
    final response = await _client.patch(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );
    debugPrint('🟣 [PROFILE] ${response.statusCode}');

    if (response.statusCode == 200) {
      return UserProfile.fromMap(jsonDecode(response.body));
    }
    throw _error('updateProfile', response);
  }

  // ── PATCH /profile/{userId}/preferences ─────────────────────────────────

  Future<UserProfile> updatePreferences({
    required int userId,
    required Map<String, dynamic> preferences,
  }) async {
    final uri = Uri.parse('$_base$_profilePath/$userId/preferences');
    final headers = await _headers();

    debugPrint('🔵 [PROFILE] PATCH preferences $uri → $preferences');
    final response = await _client.patch(
      uri,
      headers: headers,
      body: jsonEncode(preferences),
    );
    debugPrint('🟣 [PROFILE] ${response.statusCode}');

    if (response.statusCode == 200) {
      return UserProfile.fromMap(jsonDecode(response.body));
    }
    throw _error('updatePreferences', response);
  }

  // ── GET /profile/me/notifications ────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getNotifications() async {
    final uri = Uri.parse('$_base$_profilePath/me/notifications');
    final headers = await _headers();

    debugPrint('🔵 [PROFILE] GET notifications $uri');
    final response = await _client.get(uri, headers: headers);
    debugPrint('🟣 [PROFILE] ${response.statusCode}');

    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List<dynamic>;
      return list.cast<Map<String, dynamic>>();
    }
    throw _error('getNotifications', response);
  }

  // ── GET /profile/me/notifications/unread-count ───────────────────────────

  Future<int> getUnreadNotificationCount() async {
    final uri = Uri.parse('$_base$_profilePath/me/notifications/unread-count');
    final headers = await _headers();

    debugPrint('🔵 [PROFILE] GET unread-count $uri');
    final response = await _client.get(uri, headers: headers);
    debugPrint('🟣 [PROFILE] ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['count'] as int? ?? 0;
    }
    throw _error('getUnreadCount', response);
  }

  // ── PATCH /profile/me/notifications/{notificationId}/read ────────────────

  Future<void> markNotificationRead(int notificationId) async {
    final uri = Uri.parse(
        '$_base$_profilePath/me/notifications/$notificationId/read');
    final headers = await _headers();

    debugPrint('🔵 [PROFILE] PATCH mark-read $uri');
    final response = await _client.patch(uri, headers: headers);
    debugPrint('🟣 [PROFILE] ${response.statusCode}');

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw _error('markNotificationRead', response);
    }
  }

  // ── PATCH /profile/me/notifications/read-all ─────────────────────────────

  Future<void> markAllNotificationsRead() async {
    final uri = Uri.parse('$_base$_profilePath/me/notifications/read-all');
    final headers = await _headers();

    debugPrint('🔵 [PROFILE] PATCH read-all $uri');
    final response = await _client.patch(uri, headers: headers);
    debugPrint('🟣 [PROFILE] ${response.statusCode}');

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw _error('markAllNotificationsRead', response);
    }
  }

  // ── Helper ───────────────────────────────────────────────────────────────

  Exception _error(String method, http.Response response) {
    debugPrint('🔴 [PROFILE] $method failed ${response.statusCode}: ${response.body}');
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return Exception(body['message'] ?? 'Request failed');
    } catch (_) {
      return Exception('Request failed (${response.statusCode})');
    }
  }
}