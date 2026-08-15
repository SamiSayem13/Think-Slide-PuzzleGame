import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager {
  static final ValueNotifier<int> themeNotifier = ValueNotifier<int>(1);

  static Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    themeNotifier.value = prefs.getInt("theme") ?? 1;
  }

  static Future<void> saveTheme(int theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("theme", theme);
    themeNotifier.value = theme;
  }

  static String getBackground() {
    return themeNotifier.value == 1
        ? "assets/images/homebackground1.png"
        : "assets/images/homebackground2.png";
  }
}
