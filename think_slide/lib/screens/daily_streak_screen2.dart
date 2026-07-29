import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DailyStreakScreen extends StatelessWidget {
  const DailyStreakScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // --- FLAG VARIABLE ---
    int flag = 2;

    String backgroundImage = flag == 1 
        ? "assets/backgrounds/Theme1.jpg" 
        : "assets/backgrounds/Theme2.jpg";

    Color dailyStreakTextColor = flag == 1 
        ? const Color(0xFF225900) 
        : const Color(0xFFFF7A00);

    return PopScope(
      // This handles the Android System Back Button (the triangle)
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          SystemSound.play(SystemSoundType.click); // Play sound on system back
        }
      },
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Background Image with Blur
            Positioned(
              top: -20, left: -20, right: -20, bottom: -20,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Image.asset(backgroundImage, fit: BoxFit.cover),
              ),
            ),

            // 2. Main Content
            SafeArea(
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: [
                      // Back Button with Clicking Animation
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: _AnimatedBackButton(), // Custom animated widget below
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
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text("🔥", style: TextStyle(fontSize: 35)),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // 3. Main Card
                      Container(
                        width: 340,
                        height: 470,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E8),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x40000000),
                              blurRadius: 4,
                              offset: Offset(0, 4),
                            )
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Streak Number
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                const Text("🔥", style: TextStyle(fontSize: 110)),
                                Positioned(
                                  bottom: 20,
                                  child: Text(
                                    "1",
                                    style: TextStyle(
                                      fontSize: 52,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF4E342E),
                                      shadows: const [
                                        Shadow(offset: Offset(-1.5, -1.5), color: Color(0xFFAE9E22)),
                                        Shadow(offset: Offset(1.5, -1.5), color: Color(0xFFAE9E22)),
                                        Shadow(offset: Offset(1.5, 1.5), color: Color(0xFFAE9E22)),
                                        Shadow(offset: Offset(-1.5, 1.5), color: Color(0xFFAE9E22)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const Column(
                              children: [
                                Text(
                                  "DAY IN A ROW!",
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFFAA1B1B),
                                  ),
                                ),
                                Text(
                                  "Start again to reach the top!",
                                  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),

                            // Streak Dots
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildDot("Sat", 'missed'),
                                _buildDot("Sun", 'missed'),
                                _buildDot("Mon", 'missed'),
                                _buildDot("Tue", 'missed'),
                                _buildDot("Wed", 'current'),
                                _buildDot("Thu", 'upcoming'),
                                _buildDot("Fri", 'upcoming'),
                              ],
                            ),

                            // Play Button
                            Container(
                              width: double.infinity,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF8BC34A), Color(0xFF689F38)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x40000000),
                                    blurRadius: 4,
                                    offset: Offset(0, 4),
                                  )
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.play_arrow, color: Colors.white, size: 30),
                                    SizedBox(width: 8),
                                    Text(
                                      "PLAY TODAY",
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
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
      ),
    );
  }

  Widget _buildDot(String day, String status) {
    Widget icon;
    if (status == 'done') {
      icon = Container(
        width: 34, height: 34,
        decoration: const BoxDecoration(color: Color(0xFF8BC34A), shape: BoxShape.circle),
        child: const Icon(Icons.check, color: Colors.white, size: 20),
      );
    } else if (status == 'current') {
      icon = const Text("🔥", style: TextStyle(fontSize: 30));
    } else if (status == 'missed') {
      icon = Container(
        width: 34, height: 34,
        decoration: BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFEAEAEA), width: 2),
        ),
      );
    } else {
      icon = Container(
        width: 34, height: 34,
        decoration: const BoxDecoration(color: Color(0xFFEAEAEA), shape: BoxShape.circle),
      );
    }

    return Column(
      children: [
        icon,
        const SizedBox(height: 4),
        Text(day, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
      ],
    );
  }
}

// Custom widget to handle the Scale Animation for the Back Button
class _AnimatedBackButton extends StatefulWidget {
  @override
  State<_AnimatedBackButton> createState() => _AnimatedBackButtonState();
}

class _AnimatedBackButtonState extends State<_AnimatedBackButton> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    setState(() => _scale = 0.9); // Shrink slightly on press
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _scale = 1.0); // Reset size
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: () {
        SystemSound.play(SystemSoundType.click); // Play sound immediately on tap
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      },
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Color(0xFFE67E22),
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
