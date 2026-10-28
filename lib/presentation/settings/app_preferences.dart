
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  AppPreferences._();

  static const String _themeKey = 'farmadi_settings_dark_mode';
  static const String _languageKey = 'farmadi_settings_language';
  static const String _textSizeKey = 'farmadi_settings_text_size';

  static final ValueNotifier<ThemeMode> themeMode =
      ValueNotifier<ThemeMode>(ThemeMode.light);

  static final ValueNotifier<Locale> locale =
      ValueNotifier<Locale>(const Locale('es'));

  // 0.90 = pequeño, 1.00 = normal, 1.12 = grande.
  static final ValueNotifier<double> textScale =
      ValueNotifier<double>(1.0);

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    themeMode.value = prefs.getBool(_themeKey) == true
        ? ThemeMode.dark
        : ThemeMode.light;

    final language = prefs.getString(_languageKey) ?? 'es';
    locale.value = Locale(language == 'en' ? 'en' : 'es');

    final scale = prefs.getDouble(_textSizeKey) ?? 1.0;
    textScale.value = _normalizeScale(scale);
  }

  static Future<void> setDarkMode(bool enabled) async {
    themeMode.value = enabled ? ThemeMode.dark : ThemeMode.light;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, enabled);
  }

  static Future<void> setLanguage(String language) async {
    final normalized = language == 'en' ? 'en' : 'es';
    locale.value = Locale(normalized);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, normalized);
  }

  static Future<void> setTextScale(double scale) async {
    final normalized = _normalizeScale(scale);
    textScale.value = normalized;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_textSizeKey, normalized);
  }

  static double _normalizeScale(double value) {
    if (value < 0.95) return 0.90;
    if (value > 1.05) return 1.12;
    return 1.0;
  }

  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();

    // Elimina solamente las preferencias propias de Ajustes.
    await prefs.remove(_themeKey);
    await prefs.remove(_languageKey);
    await prefs.remove(_textSizeKey);

    themeMode.value = ThemeMode.light;
    locale.value = const Locale('es');
    textScale.value = 1.0;
  }
}
