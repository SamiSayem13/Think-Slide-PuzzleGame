import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  static final AudioPlayer _bgPlayer = AudioPlayer();
  static final ValueNotifier<bool> isMutedNotifier = ValueNotifier<bool>(false);
  static final ValueNotifier<bool> isVibrationEnabledNotifier = ValueNotifier<bool>(true);
  static final ValueNotifier<double> volumeNotifier = ValueNotifier<double>(0.7);
  static double _lastVolume = 0.7;
  static bool _shouldBePlaying = false;

  static Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    isMutedNotifier.value = prefs.getBool("isMuted") ?? false;
    isVibrationEnabledNotifier.value = prefs.getBool("isVibrationEnabled") ?? true;
    volumeNotifier.value = prefs.getDouble("musicVolume") ?? 0.7;
    _lastVolume = volumeNotifier.value > 0 ? volumeNotifier.value : 0.7;

    // Setup player
    await _bgPlayer.setReleaseMode(ReleaseMode.loop);
    
    // Set efficient audio context for Android
    if (defaultTargetPlatform == TargetPlatform.android) {
      await AudioPlayer.global.setAudioContext(AudioContext(
        android: const AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: false,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.game,
          audioFocus: AndroidAudioFocus.gain,
        ),
      ));
    }
    
    // Set initial volume before playing
    await _bgPlayer.setVolume(isMutedNotifier.value ? 0 : volumeNotifier.value);

    // Start background music
    try {
      _shouldBePlaying = true;
      // Always set the source so it's ready when unmuted
      await _bgPlayer.setSource(AssetSource('music/1.mp3'));
      
      if (!isMutedNotifier.value) {
        await _bgPlayer.resume();
      }
    } catch (e) {
      debugPrint("Error playing music: $e");
    }
  }

  static void _updateVolume() {
    // Run audio operations in background to avoid blocking main thread
    Future.microtask(() async {
      try {
        if (isMutedNotifier.value) {
          await _bgPlayer.setVolume(0);
          if (_bgPlayer.state == PlayerState.playing) {
            await _bgPlayer.pause();
          }
        } else {
          await _bgPlayer.setVolume(volumeNotifier.value);
          if (_shouldBePlaying && _bgPlayer.state != PlayerState.playing) {
            // Ensure source is set if it somehow got lost
            if (_bgPlayer.source == null) {
              await _bgPlayer.setSource(AssetSource('music/1.mp3'));
            }
            await _bgPlayer.resume();
          }
        }
      } catch (e) {
        debugPrint("AudioManager Error: $e");
      }
    });
  }

  static Future<void> setVolume(double volume) async {
    if (volumeNotifier.value == volume) return;
    
    volumeNotifier.value = volume;
    if (volume > 0) _lastVolume = volume;

    _updateVolume();

    // Persist in background
    SharedPreferences.getInstance().then((prefs) async {
      await prefs.setDouble("musicVolume", volume);
      bool shouldBeMuted = volume == 0;
      if (isMutedNotifier.value != shouldBeMuted) {
        isMutedNotifier.value = shouldBeMuted;
        await prefs.setBool("isMuted", shouldBeMuted);
      }
    });
  }

  static Future<void> toggleMute() async {
    bool newMuteStatus = !isMutedNotifier.value;
    isMutedNotifier.value = newMuteStatus;
    
    if (newMuteStatus) {
      volumeNotifier.value = 0;
    } else {
      volumeNotifier.value = _lastVolume;
    }
    _updateVolume();

    // Persist in background
    SharedPreferences.getInstance().then((prefs) async {
      await prefs.setBool("isMuted", newMuteStatus);
      await prefs.setDouble("musicVolume", volumeNotifier.value);
    });
  }

  static Future<void> toggleVibration() async {
    final prefs = await SharedPreferences.getInstance();
    isVibrationEnabledNotifier.value = !isVibrationEnabledNotifier.value;
    await prefs.setBool("isVibrationEnabled", isVibrationEnabledNotifier.value);
    
    // Quick double-pulse to confirm it's ON
    if (isVibrationEnabledNotifier.value) {
      playSlideVibration();
    }
  }

  static void playClick() {
    if (!isMutedNotifier.value) {
      SystemSound.play(SystemSoundType.click);
    }
    if (isVibrationEnabledNotifier.value) {
      // Single normal pulse for buttons
      HapticFeedback.mediumImpact();
    }
  }

  static void playSlideVibration() {
    if (isVibrationEnabledNotifier.value) {
      // System default long vibration - single pulse, maximum duration
      HapticFeedback.vibrate();
    }
  }

  static void handleAppBackground() {
    _bgPlayer.pause();
  }

  static void handleAppForeground() {
    if (_shouldBePlaying && !isMutedNotifier.value) {
      _bgPlayer.resume();
    }
  }

  static void pauseBackgroundMusic() {
    _bgPlayer.pause();
  }

  static void resumeBackgroundMusic() {
    if (_shouldBePlaying && !isMutedNotifier.value) {
      _bgPlayer.resume();
    }
  }
}
