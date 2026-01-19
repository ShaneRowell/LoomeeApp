import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/catalog/clothing_detail_screen.dart';
import '../screens/measurements/measurements_screen.dart';
import '../screens/preset_images/preset_images_screen.dart';
import '../screens/try_on/try_on_screen.dart';
import '../screens/try_on/try_on_result_screen.dart';
import '../screens/try_on/try_on_history_screen.dart';
import '../screens/recommendations/fashion_recommendations_screen.dart';
import '../screens/recommendations/complete_outfit_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String clothingDetail = '/clothing-detail';
  static const String measurements = '/measurements';
  static const String presetImages = '/preset-images';
  static const String tryOn = '/try-on';
  static const String tryOnHistory = '/try-on-history';
  static const String tryOnResult = '/try-on-result';
  static const String fashionRecommendations = '/fashion-recommendations';
  static const String completeOutfit = '/complete-outfit';
  static const String profile = '/profile';
  static const String onboarding = '/onboarding';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case clothingDetail:
        final clothingId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => ClothingDetailScreen(clothingId: clothingId),
        );
      case measurements:
        return MaterialPageRoute(builder: (_) => const MeasurementsScreen());
      case presetImages:
        return MaterialPageRoute(builder: (_) => const PresetImagesScreen());
      case tryOn:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => TryOnScreen(
            clothingId: args?['clothingId'] as String?,
            clothingName: args?['clothingName'] as String?,
            clothingImage: args?['clothingImage'] as String?,
          ),
        );
      case tryOnHistory:
        return MaterialPageRoute(builder: (_) => const TryOnHistoryScreen());
      case tryOnResult:
        final tryOnId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => TryOnResultScreen(tryOnId: tryOnId),
        );
      case fashionRecommendations:
        return MaterialPageRoute(
          builder: (_) => const FashionRecommendationsScreen(),
        );
      case completeOutfit:
        return MaterialPageRoute(
          builder: (_) => const CompleteOutfitScreen(),
        );
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Route not found: ${settings.name}')),
          ),
        );
    }
  }
}
