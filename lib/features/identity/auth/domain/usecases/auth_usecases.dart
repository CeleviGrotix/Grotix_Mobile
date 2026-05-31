
// ── Login ──────────────────────────────────────────────────────────────────

import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class LoginUsecase {
  final AuthRepository _repository;
  LoginUsecase(this._repository);

  /// Hace sign-in, guarda el token y trae el perfil.
  /// Devuelve la sesión completa con [UserEntity].
  Future<AuthSession> execute({
    required String email,
    required String password,
  }) async {
    final session = await _repository.signIn(email: email, password: password);
    await _repository.saveToken(session.token);
    final user = await _repository.getMe(session.token);
    return session.copyWith(user: user);
  }
}

// ── Logout ─────────────────────────────────────────────────────────────────

class LogoutUsecase {
  final AuthRepository _repository;
  LogoutUsecase(this._repository);

  Future<void> execute(String token) async {
    try {
      await _repository.signOut(token);
    } catch (_) {
      // Si el backend falla (token ya expirado, etc.) igual limpiamos local
    } finally {
      await _repository.clearToken();
    }
  }
}

// ── Register ───────────────────────────────────────────────────────────────

class RegisterUsecase {
  final AuthRepository _repository;
  RegisterUsecase(this._repository);

  Future<void> execute({
    required String email,
    required String password,
    required String inviteToken,
  }) async {
    await _repository.register(
      email: email,
      password: password,
      inviteToken: inviteToken,
    );
  }
}

// ── Check auth status (rehydrate) ──────────────────────────────────────────

class CheckAuthStatusUsecase {
  final AuthRepository _repository;
  CheckAuthStatusUsecase(this._repository);

  /// Intenta recuperar la sesión desde el token guardado.
  /// Devuelve null si no hay token o si está inválido.
  Future<AuthSession?> execute() async {
    final token = await _repository.getSavedToken();
    if (token == null || token.isEmpty) return null;

    try {
      final user = await _repository.getMe(token);
      return AuthSession(
        token: token,
        identityId: user.identityId,
        email: user.email,
        user: user,
      );
    } catch (_) {
      // Token expirado o inválido → limpiamos
      await _repository.clearToken();
      return null;
    }
  }
}