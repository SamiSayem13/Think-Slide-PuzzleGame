import 'package:flutter/material.dart';
import 'screens/level_selection_screen.dart';

void main() {
  runApp(const ThinkSlideApp());
}

class ThinkSlideApp extends StatelessWidget {
  const ThinkSlideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Think Slide',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const LevelSelectionScreen(),
    );
  }
}
