import 'user_entity.dart';

class AuthSession {
  final String token;
  final int identityId;
  final String email;
  final UserEntity? user; // se carga tras el login con GET /profile/me

  const AuthSession({
    required this.token,
    required this.identityId,
    required this.email,
    this.user,
  });

  AuthSession copyWith({UserEntity? user}) {
    return AuthSession(
      token: token,
      identityId: identityId,
      email: email,
      user: user ?? this.user,
    );
  }
}