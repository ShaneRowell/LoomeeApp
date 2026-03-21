import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loomee/config/app_routes.dart';

void main() {
  group('AppRoutes - Route Name Constants', () {
    test('splash route is "/"', () {
      expect(AppRoutes.splash, equals('/'));
    });

    test('login route is "/login"', () {
      expect(AppRoutes.login, equals('/login'));
    });

    test('register route is "/register"', () {
      expect(AppRoutes.register, equals('/register'));
    });

    test('home route is "/home"', () {
      expect(AppRoutes.home, equals('/home'));
    });

    test('onboarding route is "/onboarding"', () {
      expect(AppRoutes.onboarding, equals('/onboarding'));
    });

    test('measurements route is "/measurements"', () {
      expect(AppRoutes.measurements, equals('/measurements'));
    });

    test('try-on route is "/try-on"', () {
      expect(AppRoutes.tryOn, equals('/try-on'));
    });

    test('profile route is "/profile"', () {
      expect(AppRoutes.profile, equals('/profile'));
    });

    test('all route names are unique — no two routes share the same path', () {
      final allRoutes = [
        AppRoutes.splash,
        AppRoutes.login,
        AppRoutes.register,
        AppRoutes.home,
        AppRoutes.clothingDetail,
        AppRoutes.measurements,
        AppRoutes.presetImages,
        AppRoutes.tryOn,
        AppRoutes.tryOnHistory,
        AppRoutes.tryOnResult,
        AppRoutes.fashionRecommendations,
        AppRoutes.completeOutfit,
        AppRoutes.profile,
        AppRoutes.onboarding,
      ];
      expect(allRoutes.toSet().length, equals(allRoutes.length));
    });

    test('all route names start with "/"', () {
      final allRoutes = [
        AppRoutes.splash,
        AppRoutes.login,
        AppRoutes.register,
        AppRoutes.home,
        AppRoutes.clothingDetail,
        AppRoutes.measurements,
        AppRoutes.presetImages,
        AppRoutes.tryOn,
        AppRoutes.tryOnHistory,
        AppRoutes.tryOnResult,
        AppRoutes.fashionRecommendations,
        AppRoutes.completeOutfit,
        AppRoutes.profile,
        AppRoutes.onboarding,
      ];
      for (final route in allRoutes) {
        expect(route.startsWith('/'), isTrue,
            reason: 'Route "$route" should start with /');
      }
    });
  });

  group('AppRoutes - generateRoute', () {
    test('returns a MaterialPageRoute for any recognised route name', () {
      final route = AppRoutes.generateRoute(
        const RouteSettings(name: AppRoutes.login),
      );
      expect(route, isA<MaterialPageRoute>());
    });

    test('returns a MaterialPageRoute for an unrecognised route name', () {
      final route = AppRoutes.generateRoute(
        const RouteSettings(name: '/this-route-does-not-exist'),
      );
      expect(route, isA<MaterialPageRoute>());
    });

    test('generateRoute handles null route name gracefully', () {
      final route = AppRoutes.generateRoute(const RouteSettings(name: null));
      expect(route, isA<MaterialPageRoute>());
    });
  });
}
