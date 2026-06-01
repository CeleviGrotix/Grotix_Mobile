import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../../common/config/env.dart';
import '../../domain/entities/auth_session.dart';
import '../model/user_model.dart';

class AuthRemoteDatasource {
  static const String _base = Env.apiBase;
  static const String _baseUrl = '$_base/api/v1';

  final http.Client _client;
  AuthRemoteDatasource({http.Client? client})
      : _client = client ?? http.Client();

  Map<String, String> _headers({String? token}) => {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  // ── Sign in ──────────────────────────────────────────────────────────────

  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/auth/sign-in'),
      headers: _headers(),
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200 && data['success'] == true) {
      return AuthSession(
        token: data['token'] as String,
        identityId: data['identityId'] as int,
        email: data['email'] as String,
      );
    }

    // 401 u otro error — el backend devuelve success: false con mensaje
    final message = data['message'] as String? ?? 'Invalid credentials';
    throw AuthException(message);
  }

  // ── Register ─────────────────────────────────────────────────────────────

  Future<void> register({
    required String email,
    required String password,
    required String inviteToken,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/auth/register'),
      headers: _headers(),
      body: jsonEncode({
        'email': email,
        'password': password,
        'inviteToken': inviteToken,
      }),
    );

    if (response.statusCode != 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      throw AuthException(data['message'] as String? ?? 'Registration failed');
    }
  }

  // ── Sign out ─────────────────────────────────────────────────────────────

  Future<void> signOut(String token) async {
    await _client.post(
      Uri.parse('$_baseUrl/auth/sign-out'),
      headers: _headers(token: token),
    );
    // 204 o cualquier respuesta — no importa, limpiamos igual
  }

  // ── GET /profile/me ──────────────────────────────────────────────────────

  Future<UserModel> getMe(String token) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/profile/me'),
      headers: _headers(token: token),
    );

    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }

    // AGREGA ESTO PARA DEPURAR:
    print('Error en getMe: ${response.statusCode} - ${response.body}');

    if (response.statusCode == 401) throw AuthException('Session expired');
    throw AuthException('Failed to load profile: ${response.statusCode}');
  }
}

// ── Excepción de dominio auth ─────────────────────────────────────────────

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}