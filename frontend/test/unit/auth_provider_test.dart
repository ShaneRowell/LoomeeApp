import 'package:flutter_test/flutter_test.dart';
import 'package:loomee/models/user.dart';
import 'package:loomee/providers/auth_provider.dart';
import 'package:loomee/services/api_client.dart';
import 'package:loomee/services/auth_service.dart';
import 'package:loomee/services/storage_service.dart';

// ---------------------------------------------------------------------------
// Fake StorageService — in-memory, no SharedPreferences dependency
// ---------------------------------------------------------------------------
class FakeStorageService extends StorageService {
  String? _token;

  @override
  Future<void> saveToken(String token) async => _token = token;

  @override
  Future<String?> getToken() async => _token;

  @override
  Future<void> deleteToken() async => _token = null;

  @override
  Future<bool> hasToken() async => _token != null && _token!.isNotEmpty;

  @override
  Future<void> setOnboardingCompleted() async {}

  @override
  Future<bool> isOnboardingCompleted() async => false;

  @override
  Future<void> saveThemeMode(String mode) async {}

  @override
  Future<String?> getThemeMode() async => null;
}

// ---------------------------------------------------------------------------
// Fake AuthService — returns pre-configured results, no HTTP calls made
// ---------------------------------------------------------------------------
class FakeAuthService extends AuthService {
  final bool loginSuccess;
  final bool registerSuccess;
  final String errorMessage;

  static final _fakeUser = User(
    id: 'user-123',
    email: 'test@example.com',
    name: 'Test User',
  );

  FakeAuthService({
    this.loginSuccess = true,
    this.registerSuccess = true,
    this.errorMessage = 'Request failed',
  }) : super(ApiClient(FakeStorageService()));

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    if (loginSuccess) {
      return {'token': 'fake-jwt-token', 'user': _fakeUser};
    }
    throw ApiException(errorMessage);
  }

  @override
  Future<Map<String, dynamic>> register(
      String email, String password, String name) async {
    if (registerSuccess) {
      return {'token': 'fake-jwt-token', 'user': _fakeUser};
    }
    throw ApiException(errorMessage);
  }

  @override
  Future<User> getMe() async {
    if (loginSuccess) return _fakeUser;
    throw UnauthorizedException('Invalid or expired token');
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------
void main() {
  group('AuthProvider - Initial State', () {
    test('status is uninitialized on creation', () {
      final provider = AuthProvider(FakeAuthService(), FakeStorageService());
      expect(provider.status, equals(AuthStatus.uninitialized));
      expect(provider.isAuthenticated, isFalse);
      expect(provider.user, isNull);
      expect(provider.error, isNull);
      expect(provider.isLoading, isFalse);
    });
  });

  group('AuthProvider - tryAutoLogin', () {
    test('sets unauthenticated when no token is stored', () async {
      final provider = AuthProvider(FakeAuthService(), FakeStorageService());
      await provider.tryAutoLogin();
      expect(provider.status, equals(AuthStatus.unauthenticated));
      expect(provider.isAuthenticated, isFalse);
    });

    test('sets authenticated when a valid token exists', () async {
      final storage = FakeStorageService();
      await storage.saveToken('existing-token');
      final provider = AuthProvider(FakeAuthService(loginSuccess: true), storage);
      await provider.tryAutoLogin();
      expect(provider.status, equals(AuthStatus.authenticated));
      expect(provider.isAuthenticated, isTrue);
      expect(provider.user, isNotNull);
    });

    test('sets unauthenticated and clears token when stored token is rejected', () async {
      final storage = FakeStorageService();
      await storage.saveToken('bad-token');
      final provider =
          AuthProvider(FakeAuthService(loginSuccess: false), storage);
      await provider.tryAutoLogin();
      expect(provider.status, equals(AuthStatus.unauthenticated));
      expect(await storage.hasToken(), isFalse);
    });

    test('isLoading is false once tryAutoLogin completes', () async {
      final provider = AuthProvider(FakeAuthService(), FakeStorageService());
      await provider.tryAutoLogin();
      expect(provider.isLoading, isFalse);
    });
  });

  group('AuthProvider - Login', () {
    test('returns true and sets authenticated on successful login', () async {
      final provider = AuthProvider(FakeAuthService(), FakeStorageService());
      final result = await provider.login('test@example.com', 'password');
      expect(result, isTrue);
      expect(provider.status, equals(AuthStatus.authenticated));
      expect(provider.user, isNotNull);
      expect(provider.isLoading, isFalse);
    });

    test('returns false and exposes error message on failed login', () async {
      final provider = AuthProvider(
        FakeAuthService(loginSuccess: false, errorMessage: 'Invalid credentials'),
        FakeStorageService(),
      );
      final result = await provider.login('bad@example.com', 'wrongpass');
      expect(result, isFalse);
      expect(provider.isAuthenticated, isFalse);
      expect(provider.error, equals('Invalid credentials'));
      expect(provider.isLoading, isFalse);
    });
  });

  group('AuthProvider - Register', () {
    test('returns true and sets authenticated on successful registration',
        () async {
      final provider = AuthProvider(FakeAuthService(), FakeStorageService());
      final result =
          await provider.register('new@example.com', 'password', 'New User');
      expect(result, isTrue);
      expect(provider.status, equals(AuthStatus.authenticated));
      expect(provider.isLoading, isFalse);
    });

    test('returns false and sets error when registration fails', () async {
      final provider = AuthProvider(
        FakeAuthService(
            registerSuccess: false, errorMessage: 'User already exists'),
        FakeStorageService(),
      );
      final result =
          await provider.register('taken@example.com', 'password', 'Name');
      expect(result, isFalse);
      expect(provider.error, equals('User already exists'));
    });
  });

  group('AuthProvider - Logout', () {
    test('clears user, token, and sets unauthenticated after logout', () async {
      final storage = FakeStorageService();
      final provider = AuthProvider(FakeAuthService(), storage);
      await provider.login('test@example.com', 'password');
      expect(provider.isAuthenticated, isTrue);

      await provider.logout();
      expect(provider.isAuthenticated, isFalse);
      expect(provider.user, isNull);
      expect(await storage.hasToken(), isFalse);
    });
  });

  group('AuthProvider - clearError', () {
    test('clears the error field', () async {
      final provider = AuthProvider(
        FakeAuthService(loginSuccess: false, errorMessage: 'Some error'),
        FakeStorageService(),
      );
      await provider.login('a@b.com', 'pass');
      expect(provider.error, isNotNull);

      provider.clearError();
      expect(provider.error, isNull);
    });
  });
}
