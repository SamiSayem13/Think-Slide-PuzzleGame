import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'theme/theme_manager.dart';
import 'services/audio_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeManager.loadTheme();
  await AudioManager.loadSettings();
  runApp(const ThinkAndSlideApp());
}

class ThinkAndSlideApp extends StatelessWidget {
  const ThinkAndSlideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: ThemeManager.themeNotifier,
      builder: (context, currentTheme, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Think & Slide",
          theme: ThemeData(
            brightness: currentTheme == 1 ? Brightness.light : Brightness.dark,
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}
