import 'package:flutter/material.dart';
import '../services/audio_manager.dart';

class MenuButton extends StatefulWidget {
  final String text;
  final List<Color> colors;
  final VoidCallback onPressed;

  const MenuButton({
    super.key,
    required this.text,
    required this.colors,
    required this.onPressed,
  });

  @override
  State<MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<MenuButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        AudioManager.playClick();
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _pressed = false),

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        transform: Matrix4.translationValues(0, _pressed ? 4 : 0, 0),

        width: 280,
        height: 64,

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),

          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: widget.colors,
            stops: const [
              0.00,
              0.15,
              0.81,
              0.92,
            ],
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.20),
              offset: const Offset(0, 8),
              blurRadius: 18,
            ),
          ],
        ),

        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),

          child: Stack(
            children: [
              // Top highlight
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  height: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  color: Colors.white.withOpacity(.35),
                ),
              ),

              // Bottom dark shade
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(.15),
                      ],
                    ),
                  ),
                ),
              ),

              // Center text
              Center(
                child: Text(
                  widget.text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}