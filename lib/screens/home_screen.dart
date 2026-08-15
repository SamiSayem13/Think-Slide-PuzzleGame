import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../widgets/menu_button.dart';
import '../theme/theme_manager.dart';
import '../services/audio_manager.dart';
import 'difficulty_screen.dart';
import 'settings_screen.dart';
import 'daily_streak_screen.dart';
import 'ranking_screen.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<DocumentSnapshot>? _userDataFuture;

  @override
  void initState() {
    super.initState();
    if (AuthService.currentUser != null) {
      _userDataFuture = DatabaseService.getUserData(AuthService.currentUser!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return ValueListenableBuilder<int>(
      valueListenable: ThemeManager.themeNotifier,
      builder: (context, currentTheme, child) {
        return MediaQuery.removePadding(
          context: context,
          removeTop: true,
          removeBottom: true,
          removeLeft: true,
          removeRight: true,
          child: Scaffold(
            backgroundColor: const Color(0xFF1B0900), // Dark base color
            extendBody: true,
            extendBodyBehindAppBar: true,
            resizeToAvoidBottomInset: false,
            body: SizedBox(
              width: screenSize.width,
              height: screenSize.height,
              child: Stack(
                children: [
                  // Background
                  Positioned(
                    left: 0,
                    top: 0,
                    width: screenSize.width,
                    height: screenSize.height,
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(ThemeManager.getBackground()),
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                        ),
                      ),
                    ),
                  ),

                  // Dark overlay
                  Positioned(
                    left: 0,
                    top: 0,
                    width: screenSize.width,
                    height: screenSize.height,
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.18),
                    ),
                  ),

                SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // ================= USER INFO =================
                          if (AuthService.currentUser != null && _userDataFuture != null) ...[
                            FutureBuilder<DocumentSnapshot>(
                              future: _userDataFuture,
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return const SizedBox.shrink();
                                }

                                String username = "Player";
                                String? photoUrl;

                                if (snapshot.hasData && snapshot.data!.exists) {
                                  final data = snapshot.data!.data() as Map<String, dynamic>?;
                                  if (data != null) {
                                    username = data['displayName'] ?? "Player";
                                    photoUrl = data['photoUrl'];
                                  }
                                }

                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircleAvatar(
                                        radius: 12,
                                        backgroundColor: Colors.orangeAccent,
                                        backgroundImage: photoUrl != null
                                            ? NetworkImage(photoUrl)
                                            : null,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        username,
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 25),
                          ],

                          // ================= TITLE =================
                          Column(
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) => const LinearGradient(
                                  colors: [Color(0xFFFFD54F), Color(0xFFFF9800)],
                                ).createShader(bounds),
                                child: const Text(
                                  "THINK &",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 42,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1,
                                    shadows: [
                                      Shadow(color: Colors.black54, blurRadius: 8, offset: Offset(0, 4)),
                                    ],
                                  ),
                                ),
                              ),
                              ShaderMask(
                                shaderCallback: (bounds) => const LinearGradient(
                                  colors: [Color(0xFF7EC8FF), Color(0xFF2A7FFF)],
                                ).createShader(bounds),
                                child: const Text(
                                  "SLIDE",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 42,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1,
                                    shadows: [
                                      Shadow(color: Colors.black54, blurRadius: 8, offset: Offset(0, 4)),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "Relax. Slide. Solve!",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  shadows: [
                                    Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 2)),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 50),

                          // ================= MAIN MENU =================
                          MenuButton(
                            text: "START",
                            colors: const [Color(0xFF0A1B03), Color(0xFF0E2404), Color(0xFF28670A), Color(0xFF28670A)],
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const DifficultyScreen()));
                            },
                          ),
                          const SizedBox(height: 16),
                          MenuButton(
                            text: "OPTION",
                            colors: const [Color(0xFF803F34), Color(0xFFA8642E), Color(0xFFFFCC00), Color(0xFFFFCC00)],
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
                            },
                          ),
                          const SizedBox(height: 16),
                          MenuButton(
                            text: "EXIT",
                            colors: const [Color(0xFFFFB547), Color(0xFFE08A34), Color(0xFF994518), Color(0xFF994518)],
                            onPressed: () {
                              AudioManager.playClick();
                              Future.delayed(const Duration(milliseconds: 200), () {
                                exit(0);
                              });
                            },
                          ),

                          const SizedBox(height: 80), // Balanced bottom spacing
                        ],
                      ),
                    ),
                  ),
                ),

                // ================= BOTTOM CORNER BUTTONS =================
              Positioned(
                  left: 20,
                  bottom: 30,
                  child: _RoundCornerButton(
                    icon: Icons.emoji_events_rounded, // Changed from leaderboard_rounded
                    color: const Color(0xFF8E44AD),
                    shadowColor: const Color(0xFF6D3285),
                    onTap: () {
                      AudioManager.playClick();
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const RankingScreen()));
                    },
                  ),
                ),

                Positioned(
                  right: 20,
                  bottom: 30,
                  child: _AnimatedFireButton(
                    onTap: () {
                      AudioManager.playClick();
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const DailyStreakScreen()));
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
}

class _RoundCornerButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final Color shadowColor;
  final VoidCallback onTap;

  const _RoundCornerButton({
    required this.icon,
    required this.color,
    required this.shadowColor,
    required this.onTap,
  });

  @override
  State<_RoundCornerButton> createState() => _RoundCornerButtonState();
}

class _RoundCornerButtonState extends State<_RoundCornerButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 65,
          height: 65,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: widget.shadowColor,
                offset: const Offset(0, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Icon(widget.icon, color: Colors.white, size: 32),
        ),
      ),
    );
  }
}

class _AnimatedFireButton extends StatefulWidget {
  final VoidCallback onTap;

  const _AnimatedFireButton({required this.onTap});

  @override
  State<_AnimatedFireButton> createState() => _AnimatedFireButtonState();
}

class _AnimatedFireButtonState extends State<_AnimatedFireButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 65,
        height: 65,
        decoration: BoxDecoration(
          gradient: const RadialGradient(
            colors: [
              Color(0xFF4E1D00), // Deep burnt orange/red
              Color(0xFF1B0900), // Near black
            ],
            center: Alignment(0, 0.2), // Shifted slightly down for "embers" look
            radius: 0.8,
          ),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              offset: const Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 1. Floating Sparks (Particles)
            ...List.generate(4, (index) {
              return _FireSpark(controller: _controller, index: index);
            }),
            
            // 2. The Fire Icon (Static)
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.deepOrange, Colors.orange, Colors.yellow],
              ).createShader(bounds),
              child: const Icon(
                Icons.whatshot_rounded,
                color: Colors.white,
                size: 34,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FireSpark extends StatelessWidget {
  final AnimationController controller;
  final int index;

  const _FireSpark({required this.controller, required this.index});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        // Staggered timing for each spark
        double progress = (controller.value + (index / 4)) % 1.0;
        
        // Movement: Start from bottom center, drift up and slightly side-to-side
        double verticalOffset = 15 - (45 * progress);
        double horizontalOffset = math.sin(progress * 8 + index) * 10;
        
        // Appearance: Fade out and shrink as they rise
        double opacity = (1.0 - progress).clamp(0.0, 1.0);
        double size = 5.0 * (1.0 - progress);

        return Transform.translate(
          offset: Offset(horizontalOffset, verticalOffset),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.yellowAccent.withValues(alpha: opacity),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withValues(alpha: opacity * 0.5),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
