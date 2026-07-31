import 'dart:ui';
import 'package:flutter/material.dart';

class DailyStreakScreen extends StatelessWidget {
  const DailyStreakScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand, // Ensures the background fills the whole screen
        children: [
          // 1. Background Image with Blur (Negative offsets prevent blurry edges from showing)
          Positioned(
            top: -20,
            left: -20,
            right: -20,
            bottom: -20,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: 8,
                sigmaY: 8,
              ),
              child: Image.asset(
                "assets/backgrounds/Theme1.jpg",
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 2. Main Content
          SafeArea(
            child: SingleChildScrollView( // Added scroll view to prevent overflow errors
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
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color(0xFFE67E22),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
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
                        const Text(
                          "DAILY STREAK",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFFF7A00),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text("🔥", style: TextStyle(fontSize: 35)),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // 3. Main Card (340x470)
                    Container(
                      width: 340,
                      height: 470,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E8),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0x40000000),
                            blurRadius: 4,
                            offset: const Offset(0, 4),
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
                                    // Simulated stroke using shadows if Paint() caused issues
                                    shadows: [
                                      Shadow(offset: const Offset(-1.5, -1.5), color: const Color(0xFFAE9E22)),
                                      Shadow(offset: const Offset(1.5, -1.5), color: const Color(0xFFAE9E22)),
                                      Shadow(offset: const Offset(1.5, 1.5), color: const Color(0xFFAE9E22)),
                                      Shadow(offset: const Offset(-1.5, 1.5), color: const Color(0xFFAE9E22)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          Column(
                            children: [
                              const Text(
                                "DAY IN A ROW!",
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFFAA1B1B),
                                ),
                              ),
                              const Text(
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
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0x40000000),
                                  blurRadius: 4,
                                  offset: const Offset(0, 4),
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
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.play_arrow, color: Colors.white, size: 30),
                                  const SizedBox(width: 8),
                                  Text(
                                    "PLAY TODAY",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          color: const Color(0x40000000),
                                          offset: const Offset(0, 4),
                                          blurRadius: 4,
                                        )
                                      ],
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
    );
  }

  Widget _buildDot(String day, String status) {
    Widget icon;
    if (status == 'done') {
      icon = Container(
        width: 34,
        height: 34,
        decoration: const BoxDecoration(color: Color(0xFF8BC34A), shape: BoxShape.circle),
        child: const Icon(Icons.check, color: Colors.white, size: 20),
      );
    } else if (status == 'current') {
      icon = const Text("🔥", style: TextStyle(fontSize: 30));
    } else if (status == 'missed') {
      icon = Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFEAEAEA), width: 2),
        ),
      );
    } else {
      icon = Container(
        width: 34,
        height: 34,
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
