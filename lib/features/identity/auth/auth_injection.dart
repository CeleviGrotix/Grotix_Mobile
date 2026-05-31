import 'package:grotix/features/identity/auth/presentation/providers/auth_provider.dart';
import 'domain/usecases/auth_usecases.dart';
import 'infrastructure/datasource/auth_local_datasource.dart';
import 'infrastructure/datasource/auth_remote_datasource.dart';
import 'infrastructure/repositories/auth_repository_impl.dart';

/// Devuelve un [AuthProvider] completamente cableado.
/// Llámalo una sola vez en main.dart dentro del MultiProvider.
AuthProvider buildAuthProvider() {
  final remote = AuthRemoteDatasource();
  final local = AuthLocalDatasource();
  final repo = AuthRepositoryImpl(remote: remote, local: local);

  return AuthProvider(
    loginUsecase: LoginUsecase(repo),
    logoutUsecase: LogoutUsecase(repo),
    checkAuthStatusUsecase: CheckAuthStatusUsecase(repo),
    registerUsecase: RegisterUsecase(repo),
  );
}