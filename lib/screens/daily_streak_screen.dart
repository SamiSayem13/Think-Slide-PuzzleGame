import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/streak_manager.dart';
import '../services/audio_manager.dart';
import 'difficulty_screen.dart';

class DailyStreakScreen extends StatefulWidget {
  const DailyStreakScreen({super.key});

  @override
  State<DailyStreakScreen> createState() => _DailyStreakScreenState();
}

class _DailyStreakScreenState extends State<DailyStreakScreen> {
  int _currentStreak = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStreak();
  }

  Future<void> _loadStreak() async {
    int streak = await StreakManager.getStreak();
    if (mounted) {
      setState(() {
        _currentStreak = streak;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFFFF8E8),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    const String backgroundImage = "assets/images/homebackground1.png";
    const Color dailyStreakTextColor = Color(0xFFFF7A00);
    const Color backButtonColor = Color(0xFFE67E22);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Background Image with Blur
          Image.asset(backgroundImage, fit: BoxFit.cover),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(color: Colors.black.withValues(alpha: 0.3)),
          ),

          // 2. Main Content
          SafeArea(
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    // Back Button
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: GestureDetector(
                          onTap: () {
                            AudioManager.playClick();
                            Navigator.pop(context);
                          },
                          child: CircleAvatar(
                            backgroundColor: backButtonColor,
                            radius: 22,
                            child: const Icon(Icons.arrow_back, color: Colors.white),
                          ),
                        ),
                      ),
                    ),

                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("🔥", style: TextStyle(fontSize: 35)),
                        const SizedBox(width: 10),
                        Text(
                          "DAILY STREAK",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: dailyStreakTextColor,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text("🔥", style: TextStyle(fontSize: 35)),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // 3. Main Card
                    Container(
                      width: 320,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E8),
                        borderRadius: const BorderRadius.all(Radius.circular(28)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          )
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Streak Icon and Number
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                Icons.local_fire_department,
                                size: 140,
                                color: _currentStreak > 0 ? Colors.orange : Colors.grey.shade400,
                              ),
                              Positioned(
                                bottom: 25,
                                child: Text(
                                  "$_currentStreak",
                                  style: TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: _currentStreak > 0 ? const Color(0xFF4E342E) : Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          Text(
                            _currentStreak == 1 ? "DAY STREAK!" : "DAYS STREAK!",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: _currentStreak > 0 ? const Color(0xFFAA1B1B) : Colors.grey,
                            ),
                          ),
                          
                          const SizedBox(height: 10),

                          Text(
                            _currentStreak > 0 
                                ? "Keep solving to increase your streak!" 
                                : "Solve a puzzle today to start your streak!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Play Button
                          GestureDetector(
                            onTap: () {
                              AudioManager.playClick();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const DifficultyScreen()),
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              height: 55,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(Radius.circular(18)),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF8BC34A), Color(0xFF689F38)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                              ),
                              child: const Center(
                                child: Text(
                                  "PLAY NOW",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
