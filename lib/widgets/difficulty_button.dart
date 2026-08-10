import 'package:flutter/material.dart';
import '../services/audio_manager.dart';

class DifficultyButton extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<Color> colors;
  final VoidCallback onPressed;

  const DifficultyButton({
    super.key,
    required this.title,
    required this.subtitle,
    required this.colors,
    required this.onPressed,
  });

  @override
  State<DifficultyButton> createState() => _DifficultyButtonState();
}

class _DifficultyButtonState extends State<DifficultyButton> {
  double scale = 1;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => scale = 0.97);
      },
      onTapUp: (_) {
        setState(() => scale = 1);
        AudioManager.playClick();
        widget.onPressed();
      },
      onTapCancel: () {
        setState(() => scale = 1);
      },

      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 120),

        child: Container(
          width: 280,
          height: 72,

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),

            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: widget.colors,
            ),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.20),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),

          child: Stack(
            children: [

              // Top Highlight
              Positioned(
                top: 2,
                left: 10,
                right: 10,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.30),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),

              // Text
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      widget.subtitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}