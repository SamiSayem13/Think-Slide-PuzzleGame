import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import '../services/streak_manager.dart';
import '../services/audio_manager.dart';
import '../theme/theme_manager.dart';
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

    return ValueListenableBuilder<int>(
      valueListenable: ThemeManager.themeNotifier,
      builder: (context, currentTheme, child) {
        final String backgroundImage = ThemeManager.getBackground();
        
        // Dynamic colors based on theme
        final Color dailyStreakTextColor = currentTheme == 1 
            ? const Color(0xFFFF7A00) 
            : const Color(0xFF225900);
            
        final Color backButtonColor = currentTheme == 1 
            ? const Color(0xFFE67E22) 
            : const Color(0xFF4F7942);

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
                            child: _HeaderCartoonButton(
                              icon: Icons.arrow_back,
                              color: Colors.white,
                              iconColor: backButtonColor,
                              onTap: () => Navigator.pop(context),
                            ),
                          ),
                        ),

                        // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("🔥", style: TextStyle(fontSize: 30)),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              "DAILY STREAK",
                              style: TextStyle(
                                fontSize: 28,
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
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text("🔥", style: TextStyle(fontSize: 30)),
                        ],
                      ),
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
                              _PlayNowButton(
                                onPressed: () {
                                  AudioManager.playClick();
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => const DifficultyScreen()),
                                  );
                                },
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
      },
    );
  }
}

class _HeaderCartoonButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  const _HeaderCartoonButton({
    required this.icon,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  @override
  State<_HeaderCartoonButton> createState() => _HeaderCartoonButtonState();
}

class _HeaderCartoonButtonState extends State<_HeaderCartoonButton> with SingleTickerProviderStateMixin {
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
        AudioManager.playClick();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(scale: _scaleAnimation.value, child: child),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(color: Colors.black26, offset: Offset(0, 4), blurRadius: 0),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black12, width: 2),
            ),
            child: Icon(widget.icon, color: widget.iconColor, size: 24),
          ),
        ),
      ),
    );
  }
}

class _PlayNowButton extends StatefulWidget {
  final VoidCallback onPressed;
  const _PlayNowButton({required this.onPressed});

  @override
  State<_PlayNowButton> createState() => _PlayNowButtonState();
}

class _PlayNowButtonState extends State<_PlayNowButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
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
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(scale: _scaleAnimation.value, child: child),
        child: Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(color: Color(0xFF558B2F), offset: Offset(0, 5), blurRadius: 0),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF8BC34A),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white24, width: 2),
            ),
            alignment: Alignment.center,
            child: const Text(
              "PLAY NOW",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1.5,
                shadows: [Shadow(color: Colors.black26, offset: Offset(0, 1), blurRadius: 2)],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
