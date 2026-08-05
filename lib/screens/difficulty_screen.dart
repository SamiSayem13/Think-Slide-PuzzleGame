import 'dart:ui';
import 'package:flutter/material.dart';
import '../widgets/difficulty_button.dart';
import '../theme/theme_manager.dart';
import '../services/audio_manager.dart';

class DifficultyScreen extends StatelessWidget {
  const DifficultyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: ThemeManager.themeNotifier,
      builder: (context, currentTheme, child) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // ================= BACKGROUND =================
              Positioned.fill(
                child: Image.asset(
                  ThemeManager.getBackground(),
                  fit: BoxFit.cover,
                ),
              ),

              // ================= BLUR EFFECT =================
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.18),
                  ),
                ),
              ),

              // ================= PAGE =================
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    children: [
                      // ================= BACK BUTTON =================
                      Align(
                        alignment: Alignment.topLeft,
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.white,
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Color(0xFFE46A16),
                              size: 20,
                            ),
                            enableFeedback: false,
                            onPressed: () {
                              AudioManager.playClick();
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // ================= TITLE =================
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            Color(0xFF8FD3FF),
                            Color(0xFF2A7FFF),
                          ],
                        ).createShader(bounds),
                        child: const Text(
                          "DIFFICULTY",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                      ),

                      const SizedBox(height: 60),

                      // ================= EASY =================
                      DifficultyButton(
                        title: "EASY",
                        subtitle: "3 × 3",
                        colors: const [
                          Color(0xFF0A1B03),
                          Color(0xFF0E2404),
                          Color(0xFF28670A),
                          Color(0xFF3D8F1B),
                        ],
                        onPressed: () {},
                      ),

                      const SizedBox(height: 24),

                      // ================= MEDIUM =================
                      DifficultyButton(
                        title: "MEDIUM",
                        subtitle: "4 × 4",
                        colors: const [
                          Color(0xFF803F34),
                          Color(0xFFA8642E),
                          Color(0xFFFFCC00),
                          Color(0xFFFFCC00),
                        ],
                        onPressed: () {},
                      ),

                      const SizedBox(height: 24),

                      // ================= HARD =================
                      DifficultyButton(
                        title: "HARD",
                        subtitle: "5 × 5",
                        colors: const [
                          Color(0xFFFFB547),
                          Color(0xFFE08A34),
                          Color(0xFF994518),
                          Color(0xFF994518),
                        ],
                        onPressed: () {},
                      ),

                      const Spacer(),
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
