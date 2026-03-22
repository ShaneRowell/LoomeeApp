import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loomee/services/storage_service.dart';

void main() {
  late StorageService storageService;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    storageService = StorageService();
  });

  group('StorageService - Token Management', () {
    test('hasToken returns false when no token has been saved', () async {
      expect(await storageService.hasToken(), isFalse);
    });

    test('hasToken returns true after a token is saved', () async {
      await storageService.saveToken('my-jwt-token');
      expect(await storageService.hasToken(), isTrue);
    });

    test('getToken returns the exact token that was saved', () async {
      await storageService.saveToken('my-jwt-token');
      expect(await storageService.getToken(), equals('my-jwt-token'));
    });

    test('getToken returns null when no token exists', () async {
      expect(await storageService.getToken(), isNull);
    });

    test('deleteToken removes the saved token', () async {
      await storageService.saveToken('my-jwt-token');
      await storageService.deleteToken();
      expect(await storageService.getToken(), isNull);
      expect(await storageService.hasToken(), isFalse);
    });

    test('saving a new token overwrites the previous one', () async {
      await storageService.saveToken('token-v1');
      await storageService.saveToken('token-v2');
      expect(await storageService.getToken(), equals('token-v2'));
    });
  });

  group('StorageService - Onboarding Flag', () {
    test('isOnboardingCompleted returns false initially', () async {
      expect(await storageService.isOnboardingCompleted(), isFalse);
    });

    test('isOnboardingCompleted returns true after setOnboardingCompleted', () async {
      await storageService.setOnboardingCompleted();
      expect(await storageService.isOnboardingCompleted(), isTrue);
    });
  });

  group('StorageService - Theme Mode', () {
    test('getThemeMode returns null when nothing is saved', () async {
      expect(await storageService.getThemeMode(), isNull);
    });

    test('getThemeMode returns the saved theme mode', () async {
      await storageService.saveThemeMode('dark');
      expect(await storageService.getThemeMode(), equals('dark'));
    });

    test('saveThemeMode can overwrite previous value', () async {
      await storageService.saveThemeMode('dark');
      await storageService.saveThemeMode('light');
      expect(await storageService.getThemeMode(), equals('light'));
    });
  });
}
