import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  ThemeProvider() {
    // Mengambil preferensi tema dari Hive
    var box = Hive.box('settings');
    _isDarkMode = box.get('isDarkMode', defaultValue: false);
  }

  bool get isDarkMode => _isDarkMode;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    var box = Hive.box('settings');
    box.put('isDarkMode', _isDarkMode);
    notifyListeners();
  }
}
