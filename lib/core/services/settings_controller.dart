import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SettingsController extends ChangeNotifier {
  SettingsController._();

  static final SettingsController instance = SettingsController._();

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String _darkModeKey = 'settings_dark_mode';
  static const String _textSizeKey = 'settings_text_size';
  static const String _notificationsKey = 'settings_notifications';

  bool _isDarkMode = false;
  String _textSize = 'normal';
  bool _notificationsEnabled = true;
  bool _loaded = false;

  bool get isDarkMode => _isDarkMode;
  String get textSize => _textSize;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get isLoaded => _loaded;

  double get textScaleFactor {
    switch (_textSize) {
      case 'small':
        return 0.90;
      case 'large':
        return 1.15;
      default:
        return 1.0;
    }
  }

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  Future<String?> _readSafely(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeSafely(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (_) {
      // La preferencia continúa aplicada durante la sesión actual.
    }
  }

  Future<void> load() async {
    try {
      final darkMode = await _readSafely(_darkModeKey);
      final textSize = await _readSafely(_textSizeKey);
      final notifications = await _readSafely(_notificationsKey);

      _isDarkMode = darkMode == 'true';

      _textSize = ['small', 'normal', 'large'].contains(textSize)
          ? textSize!
          : 'normal';

      _notificationsEnabled = notifications == null
          ? true
          : notifications == 'true';
    } finally {
      _loaded = true;
      notifyListeners();
    }
  }

  Future<void> setDarkMode(bool value) async {
    if (_isDarkMode == value) return;

    _isDarkMode = value;
    notifyListeners();

    await _writeSafely(_darkModeKey, value.toString());
  }

  Future<void> setTextSize(String value) async {
    if (!['small', 'normal', 'large'].contains(value)) return;
    if (_textSize == value) return;

    _textSize = value;
    notifyListeners();

    await _writeSafely(_textSizeKey, value);
  }

  Future<void> setNotificationsEnabled(bool value) async {
    if (_notificationsEnabled == value) return;

    _notificationsEnabled = value;
    notifyListeners();

    await _writeSafely(_notificationsKey, value.toString());
  }

  Future<void> reset() async {
    _isDarkMode = false;
    _textSize = 'normal';
    _notificationsEnabled = true;

    notifyListeners();

    await Future.wait([
      _writeSafely(_darkModeKey, 'false'),
      _writeSafely(_textSizeKey, 'normal'),
      _writeSafely(_notificationsKey, 'true'),
    ]);
  }
}
