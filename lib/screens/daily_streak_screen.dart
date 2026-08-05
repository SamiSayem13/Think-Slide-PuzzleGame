import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    _updateStreak();
  }

  Future<void> _updateStreak() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      int lastPlayedTimestamp = prefs.getInt('last_played_date') ?? 0;
      int streak = prefs.getInt('current_streak') ?? 0;

      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);
      
      int currentStatus = streak;

      if (lastPlayedTimestamp != 0) {
        DateTime lastPlayedDate = DateTime.fromMillisecondsSinceEpoch(lastPlayedTimestamp);
        DateTime lastPlayedDay = DateTime(lastPlayedDate.year, lastPlayedDate.month, lastPlayedDate.day);

        int differenceInDays = today.difference(lastPlayedDay).inDays;

        if (differenceInDays > 1) {
          // Missed a day or more -> Reset to 0
          currentStatus = 0;
          await prefs.setInt('current_streak', 0);
        }
      } else {
        // First time ever -> 0
        currentStatus = 0;
      }

      if (mounted) {
        setState(() {
          _currentStreak = currentStatus;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error updating streak: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handlePlayAction() async {
    final prefs = await SharedPreferences.getInstance();
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    
    int lastPlayedTimestamp = prefs.getInt('last_played_date') ?? 0;
    DateTime lastPlayedDate = DateTime.fromMillisecondsSinceEpoch(lastPlayedTimestamp);
    DateTime lastPlayedDay = DateTime(lastPlayedDate.year, lastPlayedDate.month, lastPlayedDate.day);

    // Only increment if we haven't played yet today
    if (lastPlayedTimestamp == 0 || today.difference(lastPlayedDay).inDays >= 1) {
      int newStreak = _currentStreak + 1;
      await prefs.setInt('current_streak', newStreak);
      await prefs.setInt('last_played_date', today.millisecondsSinceEpoch);
      
      setState(() {
        _currentStreak = newStreak;
      });
      
      SystemSound.play(SystemSoundType.click);
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

    // --- FLAG VARIABLES ---
    const int flag = 2; // Theme flag (1 = Orange, 2 = Green)
    const int manualStreakOverride = 0; // Set to -1 for AUTO. Set 0 or more to FORCE a number.

    const String backgroundImage = flag == 1
        ? "assets/backgrounds/Theme1.jpg"
        : "assets/backgrounds/Theme2.jpg";

    const Color dailyStreakTextColor = flag == 1
        ? Color(0xFF225900)
        : Color(0xFFFF7A00);

    const Color backButtonColor = flag == 2
        ? Color(0xFF4F7942)
        : Color(0xFFE67E22);

    final int displayStreak = manualStreakOverride >= 0 ? manualStreakOverride : _currentStreak;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          SystemSound.play(SystemSoundType.click);
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
                      // Back Button
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: _AnimatedBackButton(color: backButtonColor),
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
                        height: 400,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFF8E8),
                          borderRadius: BorderRadius.all(Radius.circular(28)),
                          boxShadow: [
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
                                    "$displayStreak",
                                    style: const TextStyle(
                                      fontSize: 52,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF4E342E),
                                      shadows: [
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

                            Column(
                              children: [
                                Text(
                                  displayStreak == 1 ? "DAY IN A ROW!" : "DAYS IN A ROW!",
                                  style: const TextStyle(
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

                            // Play Button
                            Container(
                              width: double.infinity,
                              height: 60,
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(20)),
                                gradient: LinearGradient(
                                  colors: [Color(0xFF8BC34A), Color(0xFF689F38)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0x40000000),
                                    blurRadius: 4,
                                    offset: Offset(0, 4),
                                  )
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _handlePlayAction,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.play_arrow, color: Colors.white, size: 28),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        "PLAY TODAY",
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        overflow: TextOverflow.ellipsis,
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
}

class _AnimatedBackButton extends StatefulWidget {
  final Color color;
  const _AnimatedBackButton({required this.color});

  @override
  State<_AnimatedBackButton> createState() => _AnimatedBackButtonState();
}

class _AnimatedBackButtonState extends State<_AnimatedBackButton> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    setState(() => _scale = 0.9);
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _scale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: () {
        SystemSound.play(SystemSoundType.click);
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      },
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
