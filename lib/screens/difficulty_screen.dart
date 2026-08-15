import 'package:flutter/material.dart';
import 'level_selection_screen.dart';
import '../widgets/difficulty_button.dart';
import '../theme/theme_manager.dart';
import '../services/audio_manager.dart';

class DifficultyScreen extends StatelessWidget {
  const DifficultyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return ValueListenableBuilder<int>(
      valueListenable: ThemeManager.themeNotifier,
      builder: (context, currentTheme, child) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: SizedBox(
            width: screenSize.width,
            height: screenSize.height,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(ThemeManager.getBackground()),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.6),
                  ),
                ),
                SafeArea(
                  child: Stack(
                    children: [
                      // Centered content
                      Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 80),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 20), // Extra space from top back button
                              ShaderMask(
                                shaderCallback: (bounds) => const LinearGradient(
                                  colors: [Color(0xFF8FD3FF), Color(0xFF2A7FFF)],
                                ).createShader(bounds),
                                child: const Text(
                                  "DIFFICULTY",
                                  textAlign: TextAlign.center,
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
                                colors: const [Color(0xFF0A1B03), Color(0xFF0E2404), Color(0xFF28670A), Color(0xFF3D8F1B)],
                                onPressed: () {
                                  AudioManager.playClick();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LevelSelectionScreen(
                                        difficultyTitle: "Easy",
                                        rows: 3,
                                        cols: 3,
                                        assetFolder: "Easy",
                                        totalLevels: 10,
                                      ),
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(height: 24),

                              // ================= MEDIUM =================
                              DifficultyButton(
                                title: "MEDIUM",
                                subtitle: "4 × 4",
                                colors: const [Color(0xFF803F34), Color(0xFFA8642E), Color(0xFFFFCC00), Color(0xFFFFCC00)],
                                onPressed: () {
                                  AudioManager.playClick();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LevelSelectionScreen(
                                        difficultyTitle: "Medium",
                                        rows: 4,
                                        cols: 4,
                                        assetFolder: "Medium",
                                        totalLevels: 10,
                                      ),
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(height: 24),

                              // ================= HARD =================
                              DifficultyButton(
                                title: "HARD",
                                subtitle: "5 × 5",
                                colors: const [Color(0xFFFFB547), Color(0xFFE08A34), Color(0xFF994518), Color(0xFF994518)],
                                onPressed: () {
                                  AudioManager.playClick();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LevelSelectionScreen(
                                        difficultyTitle: "Hard",
                                        rows: 5,
                                        cols: 5,
                                        assetFolder: "Hard",
                                        totalLevels: 10,
                                      ),
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(height: 24),

                              // ================= FREE TO PLAY =================
                              DifficultyButton(
                                title: "FREE TO PLAY",
                                subtitle: "5 × 6",
                                colors: const [Color(0xFF006064), Color(0xFF00838F), Color(0xFF00ACC1), Color(0xFF26C6DA)],
                                onPressed: () {
                                  AudioManager.playClick();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LevelSelectionScreen(
                                        difficultyTitle: "Free To Play",
                                        rows: 5,
                                        cols: 6,
                                        assetFolder: "free_to_play",
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),

                      // Back Button always at top (Placed last in Stack to be on top layer)
                      Positioned(
                        left: 25,
                        top: 20,
                        child: GestureDetector(
                          onTap: () {
                            AudioManager.playClick();
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  offset: Offset(0, 4),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFE46A16), size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
