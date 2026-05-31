import 'package:flutter/material.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/usecases/auth_usecases.dart';

enum AuthStatus { checking, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final LoginUsecase _loginUsecase;
  final LogoutUsecase _logoutUsecase;
  final CheckAuthStatusUsecase _checkAuthStatusUsecase;
  final RegisterUsecase _registerUsecase;

  AuthStatus _status = AuthStatus.checking;
  AuthSession? _session;
  String? _errorMessage;
  bool _isLoading = false;

  AuthProvider({
    required LoginUsecase loginUsecase,
    required LogoutUsecase logoutUsecase,
    required CheckAuthStatusUsecase checkAuthStatusUsecase,
    required RegisterUsecase registerUsecase,
  })  : _loginUsecase = loginUsecase,
        _logoutUsecase = logoutUsecase,
        _checkAuthStatusUsecase = checkAuthStatusUsecase,
        _registerUsecase = registerUsecase {
    checkStatus(); // rehydrate al crear el provider
  }

  // ── Getters ──────────────────────────────────────────────────────────────

  AuthStatus get status => _status;
  AuthSession? get session => _session;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  String? get token => _session?.token;

  // ── Acciones ─────────────────────────────────────────────────────────────

  Future<void> checkStatus() async {
    _status = AuthStatus.checking;
    notifyListeners();

    final session = await _checkAuthStatusUsecase.execute();

    if (session != null) {
      _session = session;
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _session = await _loginUsecase.execute(email: email, password: password);
      _status = AuthStatus.authenticated;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStatus.unauthenticated;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _logoutUsecase.execute(_session?.token ?? '');

    _session = null;
    _status = AuthStatus.unauthenticated;
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> register({
    required String email,
    required String password,
    required String inviteToken,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _registerUsecase.execute(
        email: email,
        password: password,
        inviteToken: inviteToken,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}