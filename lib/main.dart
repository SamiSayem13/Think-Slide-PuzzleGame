import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'firebase_options.dart';
import 'screens/auth_wrapper.dart';
import 'theme/theme_manager.dart';
import 'services/audio_manager.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set to immersive full screen
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  // Force portrait mode for consistent game experience
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await ThemeManager.loadTheme();
  await AuthService.init();
  await AudioManager.loadSettings();

  // Log an app start event
  await FirebaseAnalytics.instance.logAppOpen();

  runApp(const ThinkSlideApp());
}

class ThinkSlideApp extends StatefulWidget {
  const ThinkSlideApp({super.key});

  @override
  State<ThinkSlideApp> createState() => _ThinkSlideAppState();
}

class _ThinkSlideAppState extends State<ThinkSlideApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Force immersive mode immediately
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      AudioManager.handleAppBackground();
    } else if (state == AppLifecycleState.resumed) {
      AudioManager.handleAppForeground();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pre-cache primary background images to prevent lag during navigation
    precacheImage(const AssetImage("assets/images/homebackground1.png"), context);
    precacheImage(const AssetImage("assets/images/homebackground2.png"), context);
  }

  @override
  Widget build(BuildContext context) {
    // Re-apply immersive mode and style on build
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ));
    
    return ValueListenableBuilder<int>(
      valueListenable: ThemeManager.themeNotifier,
      builder: (context, currentTheme, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Think Slide",
          theme: ThemeData(
            brightness: currentTheme == 1 ? Brightness.light : Brightness.dark,
          ),
          home: const AuthWrapper(),
        );
      },
    );
  }
}
