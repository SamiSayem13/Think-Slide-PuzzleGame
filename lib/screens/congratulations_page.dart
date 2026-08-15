import 'package:flutter/material.dart';
import '../services/audio_manager.dart';

class CongratulationsPage extends StatelessWidget {
  final String time;
  final String moves;
  final String score;
  final VoidCallback? onNextPuzzle;
  final VoidCallback? onHome;

  const CongratulationsPage({
    super.key,
    this.time = "00:00",
    this.moves = "0",
    this.score = "0",
    this.onNextPuzzle,
    this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/background.png",
              fit: BoxFit.cover,
            ),
          ),

          /// Popup
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Container(
                  width: 340,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: const Color(0xffFFF8EF),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 15,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 10),
                      const _StarRow(),
                      const SizedBox(height: 25),
                      const Text(
                        "Congratulations!",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff6F4E37),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "You solved the puzzle!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 35),
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.timer_outlined,
                              title: "Time",
                              value: time,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.extension,
                              title: "Moves",
                              value: moves,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.emoji_events,
                              title: "Score",
                              value: score,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 35),
                      _GameButton(
                        text: "NEXT PUZZLE",
                        color: const Color(0xff5C9442),
                        onPressed: onNextPuzzle ?? () {},
                      ),
                      const SizedBox(height: 15),
                      _GameButton(
                        text: "BACK",
                        color: const Color(0xffD96863),
                        onPressed: onHome ?? () {},
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StarRow extends StatelessWidget {
  const _StarRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(
          Icons.star_rounded,
          color: Color(0xffFFC107),
          size: 42,
        ),
        SizedBox(width: 5),
        Icon(
          Icons.star_rounded,
          color: Color(0xffFFC107),
          size: 52,
        ),
        SizedBox(width: 5),
        Icon(
          Icons.star_rounded,
          color: Color(0xffFFC107),
          size: 42,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: const Color(0xffF4F1EB),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: const Color(0xffD89B1D),
            size: 30,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xff6F4E37),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xffD54C42),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _GameButton extends StatefulWidget {
  final String text;
  final Color color;
  final VoidCallback onPressed;

  const _GameButton({
    required this.text,
    required this.color,
    required this.onPressed,
  });

  @override
  State<_GameButton> createState() => _GameButtonState();
}

class _GameButtonState extends State<_GameButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
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
    // Darker version for shadow
    HSLColor hsl = HSLColor.fromColor(widget.color);
    Color shadowColor = hsl.withLightness((hsl.lightness - 0.15).clamp(0.0, 1.0)).toColor();

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        AudioManager.playClick();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                offset: const Offset(0, 5),
                blurRadius: 0,
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white24, width: 2),
            ),
            alignment: Alignment.center,
            child: Text(
              widget.text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 18,
                letterSpacing: 1.2,
                shadows: [Shadow(color: Colors.black26, offset: Offset(0, 1), blurRadius: 2)],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
