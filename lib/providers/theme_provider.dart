import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Dark/light theme — mirrors `ThemeContext.js`.
class ThemeProvider extends ChangeNotifier {
  ThemeProvider() {
    _load();
  }

  static const _key = 'theme';
  bool _isDarkMode = true;

  bool get isDarkMode => _isDarkMode;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    if (saved != null) {
      _isDarkMode = saved == 'true' || saved == 'dark';
      notifyListeners();
    }
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, _isDarkMode.toString());
  }

}
