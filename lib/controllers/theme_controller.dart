import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  static const String _storageKey = 'selected_theme_mode';

  final SharedPreferencesAsync _preferences = SharedPreferencesAsync();

  ThemeMode _themeMode = ThemeMode.system;
  bool _initialized = false;

  ThemeMode get themeMode => _themeMode;
  bool get initialized => _initialized;

  bool get isDarkSelected => _themeMode == ThemeMode.dark;
  bool get isLightSelected => _themeMode == ThemeMode.light;
  bool get isSystemSelected => _themeMode == ThemeMode.system;

  Future<void> initialize() async {
    final savedMode = await _preferences.getString(_storageKey);

    switch (savedMode) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      case 'system':
      default:
        _themeMode = ThemeMode.system;
        break;
    }

    _initialized = true;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    await _preferences.setString(_storageKey, mode.name);
  }

  Future<void> useSystemTheme() async {
    await setThemeMode(ThemeMode.system);
  }

  Future<void> useLightTheme() async {
    await setThemeMode(ThemeMode.light);
  }

  Future<void> useDarkTheme() async {
    await setThemeMode(ThemeMode.dark);
  }
}
