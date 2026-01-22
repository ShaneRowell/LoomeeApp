import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../services/api_client.dart';

enum AuthStatus { uninitialized, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final StorageService _storageService;

  User? _user;
  AuthStatus _status = AuthStatus.uninitialized;
  bool _isLoading = false;
  String? _error;

  AuthProvider(this._authService, this._storageService);

  User? get user => _user;
  AuthStatus get status => _status;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  String? get error => _error;

  Future<void> tryAutoLogin() async {
    _isLoading = true;
    notifyListeners();

    try {
      final hasToken = await _storageService.hasToken();
      if (!hasToken) {
        _status = AuthStatus.unauthenticated;
        _isLoading = false;
        notifyListeners();
        return;
      }

      _user = await _authService.getMe();
      _status = AuthStatus.authenticated;
    } on UnauthorizedException {
      await _storageService.deleteToken();
      _status = AuthStatus.unauthenticated;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.login(email, password);
      await _storageService.saveToken(result['token']);
      _user = result['user'];
      _status = AuthStatus.authenticated;
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password, String name) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.register(email, password, name);
      await _storageService.saveToken(result['token']);
      _user = result['user'];
      _status = AuthStatus.authenticated;
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _storageService.deleteToken();
    _user = null;
    _status = AuthStatus.unauthenticated;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
