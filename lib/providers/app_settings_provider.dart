import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_theme.dart';

class AppSettingsProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('fr', 'FR');

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  AppSettingsProvider() {
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('themeMode') ?? 0;
    _themeMode = ThemeMode.values[themeIndex];

    final languageCode = prefs.getString('languageCode') ?? 'fr';
    final countryCode = prefs.getString('countryCode') ?? 'FR';
    _locale = Locale(languageCode, countryCode);

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    _themeMode = themeMode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', themeMode.index);
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);
    await prefs.setString('countryCode', locale.countryCode ?? '');
  }

  ThemeData get currentTheme {
    if (_themeMode == ThemeMode.dark) {
      return AppTheme.darkTheme();
    }
    return AppTheme.lightTheme();
  }
}