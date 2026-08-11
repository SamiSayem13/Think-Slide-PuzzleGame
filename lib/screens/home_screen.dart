import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/menu_button.dart';
import '../theme/theme_manager.dart';
import '../services/audio_manager.dart';
import 'difficulty_screen.dart';
import 'settings_screen.dart';
import 'daily_streak_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: ThemeManager.themeNotifier,
      builder: (context, currentTheme, child) {
        return Scaffold(
          body: Stack(
            children: [
              // Background
              Positioned.fill(
                child: Image.asset(
                  ThemeManager.getBackground(),
                  fit: BoxFit.cover,
                ),
              ),

              // Dark overlay
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.18),
                ),
              ),

              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    children: [
                      // ================= TOP BUTTONS =================

                      Align(
                        alignment: Alignment.topRight,
                        child: ValueListenableBuilder<bool>(
                          valueListenable: AudioManager.isMutedNotifier,
                          builder: (context, isMuted, child) {
                            return CircleAvatar(
                              radius: 22,
                              backgroundColor: Colors.white,
                              child: IconButton(
                                icon: Icon(
                                  isMuted ? Icons.volume_off : Icons.volume_up,
                                  color: Colors.black87,
                                ),
                                enableFeedback: false,
                                onPressed: () {
                                  AudioManager.playClick();
                                  AudioManager.toggleMute();
                                },
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 35),

                      // ================= THINK =================

                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            Color(0xFFFFD54F),
                            Color(0xFFFF9800),
                          ],
                        ).createShader(bounds),
                        child: const Text(
                          "THINK &",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                            shadows: [
                              Shadow(
                                color: Colors.black54,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ================= SLIDE =================

                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            Color(0xFF7EC8FF),
                            Color(0xFF2A7FFF),
                          ],
                        ).createShader(bounds),
                        child: const Text(
                          "SLIDE",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                            shadows: [
                              Shadow(
                                color: Colors.black54,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        "Relax. Slide. Solve!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // ================= START =================

                      MenuButton(
                        text: "START",
                        colors: const [
                          Color(0xFF0A1B03),
                          Color(0xFF0E2404),
                          Color(0xFF28670A),
                          Color(0xFF28670A),
                        ],
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DifficultyScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 18),

                      // ================= OPTION =================

                      MenuButton(
                        text: "OPTION",
                        colors: const [
                          Color(0xFF803F34),
                          Color(0xFFA8642E),
                          Color(0xFFFFCC00),
                          Color(0xFFFFCC00),
                        ],
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingsScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 18),

                      // ================= EXIT =================

                      MenuButton(
                        text: "EXIT",
                        colors: const [
                          Color(0xFFFFB547),
                          Color(0xFFE08A34),
                          Color(0xFF994518),
                          Color(0xFF994518),
                        ],
                        onPressed: () {
                          if (Platform.isAndroid) {
                            SystemNavigator.pop();
                          } else {
                            exit(0);
                          }
                        },
                      ),

                      const Spacer(),

                      // ================= DAILY STREAK =================

                      MenuButton(
                        text: "DAILY STREAK",
                        colors: const [
                          Color(0xFF00C0E8),
                          Color(0xFF1696C7),
                          Color(0xFF070D53),
                          Color(0xFF070D53),
                        ],
                        onPressed: () {
                          AudioManager.playClick();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DailyStreakScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
