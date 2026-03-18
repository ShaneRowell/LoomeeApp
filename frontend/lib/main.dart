import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'config/app_theme.dart';
import 'config/app_routes.dart';
import 'services/storage_service.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';
import 'services/catalog_service.dart';
import 'services/measurement_service.dart';
import 'services/preset_image_service.dart';
import 'services/try_on_service.dart';
import 'services/size_recommendation_service.dart';
import 'services/fashion_recommendation_service.dart';
import 'providers/auth_provider.dart';
import 'providers/catalog_provider.dart';
import 'providers/measurement_provider.dart';
import 'providers/preset_image_provider.dart';
import 'providers/try_on_provider.dart';
import 'providers/recommendation_provider.dart';
import 'providers/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  final storageService = StorageService();
  final apiClient = ApiClient(storageService);

  // Load persisted theme before the first frame
  final themeProvider = ThemeProvider(storageService);
  await themeProvider.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            AuthService(apiClient),
            storageService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => CatalogProvider(CatalogService(apiClient)),
        ),
        ChangeNotifierProvider(
          create: (_) => MeasurementProvider(MeasurementService(apiClient)),
        ),
        ChangeNotifierProvider(
          create: (_) => PresetImageProvider(PresetImageService(apiClient)),
        ),
        ChangeNotifierProvider(
          create: (_) => TryOnProvider(TryOnService(apiClient)),
        ),
        ChangeNotifierProvider(
          create: (_) => RecommendationProvider(
            SizeRecommendationService(apiClient),
            FashionRecommendationService(apiClient),
          ),
        ),
      ],
      child: const LoomeeApp(),
    ),
  );
}

class LoomeeApp extends StatelessWidget {
  const LoomeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: 'Loomee',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          initialRoute: AppRoutes.splash,
          onGenerateRoute: AppRoutes.generateRoute,
        );
      },
    );
  }
}
