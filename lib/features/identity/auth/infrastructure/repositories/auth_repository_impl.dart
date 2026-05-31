import '../../domain/entities/auth_session.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasource/auth_local_datasource.dart';
import '../datasource/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _remote;
  final AuthLocalDatasource _local;

  AuthRepositoryImpl({
    required AuthRemoteDatasource remote,
    required AuthLocalDatasource local,
  })  : _remote = remote,
        _local = local;

  @override
  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) => _remote.signIn(email: email, password: password);

  @override
  Future<void> register({
    required String email,
    required String password,
    required String inviteToken,
  }) => _remote.register(email: email, password: password, inviteToken: inviteToken);

  @override
  Future<void> signOut(String token) => _remote.signOut(token);

  @override
  Future<UserEntity> getMe(String token) => _remote.getMe(token);

  @override
  Future<void> saveToken(String token) => _local.saveToken(token);

  @override
  Future<String?> getSavedToken() => _local.getToken();

  @override
  Future<void> clearToken() => _local.clearToken();
}