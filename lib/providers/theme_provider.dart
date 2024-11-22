import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static const String _key = 'theme_mode';
  late SharedPreferences _prefs;
  late ThemeMode _themeMode;

  ThemeProvider() {
    _themeMode = ThemeMode.system;
    _loadThemeMode();
  }

  ThemeMode get themeMode => _themeMode;

  Future<void> _loadThemeMode() async {
    _prefs = await SharedPreferences.getInstance();
    final value = _prefs.getString(_key);
    if (value != null) {
      _themeMode = value == ThemeMode.light.toString()
          ? ThemeMode.light
          : ThemeMode.dark;
      notifyListeners();
    } else {
      _themeMode = ThemeMode.system;
    }
  }

  Future<void> toggleThemeMode() async {
    _themeMode = _themeMode == ThemeMode.light || _themeMode == ThemeMode.system
        ? ThemeMode.dark
        : ThemeMode.light;
    await _prefs.setString(_key, _themeMode.toString());
    notifyListeners();
  }
}
