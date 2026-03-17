import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class ThemeProvider extends ChangeNotifier {
  final StorageService _storage;
  ThemeMode _themeMode = ThemeMode.system;

  ThemeProvider(this._storage);

  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;

  /// Load persisted preference on startup.
  Future<void> init() async {
    final saved = await _storage.getThemeMode();
    _themeMode = _parse(saved);
    notifyListeners();
  }

  /// Toggle between light and dark (skips system).
  Future<void> toggle() async {
    await setMode(_themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }

  Future<void> setMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    await _storage.saveThemeMode(_encode(mode));
    notifyListeners();
  }

  // ── Helpers ──────────────────────────────────────────────────────────
  ThemeMode _parse(String? s) {
    switch (s) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  String _encode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.light:
        return 'light';
      default:
        return 'system';
    }
  }
}
