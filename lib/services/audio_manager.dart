import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioManager {
  static final ValueNotifier<bool> isMutedNotifier = ValueNotifier<bool>(false);

  static Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    isMutedNotifier.value = prefs.getBool("isMuted") ?? false;
  }

  static Future<void> toggleMute() async {
    final prefs = await SharedPreferences.getInstance();
    isMutedNotifier.value = !isMutedNotifier.value;
    await prefs.setBool("isMuted", isMutedNotifier.value);
  }

  static void playClick() {
    if (!isMutedNotifier.value) {
      SystemSound.play(SystemSoundType.click);
      HapticFeedback.lightImpact();
    }
  }
}
