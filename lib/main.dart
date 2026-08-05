import 'package:flutter/material.dart';
import 'package:think_slide/screens/daily_streak_screen.dart';

void main() {
  runApp(const ThinkSlideApp());
}

class ThinkSlideApp extends StatelessWidget {
  const ThinkSlideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const DailyStreakScreen(),
    );
  }
}
