import '../entities/user_entity.dart';
import '../entities/auth_session.dart';

abstract class AuthRepository {
  /// Login con email y password. Devuelve la sesión con token.
  Future<AuthSession> signIn({
    required String email,
    required String password,
  });

  /// Registrar con token de invitación.
  Future<void> register({
    required String email,
    required String password,
    required String inviteToken,
  });

  /// Invalida el token en el backend y borra la sesión local.
  Future<void> signOut(String token);

  /// Obtiene el perfil del usuario autenticado.
  Future<UserEntity> getMe(String token);

  /// Persiste el token localmente.
  Future<void> saveToken(String token);

  /// Lee el token guardado (para rehydrate en arranque).
  Future<String?> getSavedToken();

  /// Borra el token local.
  Future<void> clearToken();
}