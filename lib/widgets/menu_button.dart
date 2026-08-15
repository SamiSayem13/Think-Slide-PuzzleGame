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

class _MenuButtonState extends State<MenuButton> with SingleTickerProviderStateMixin {
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
    // Use the middle color as the main matte color
    Color mainColor = widget.colors.length > 2 ? widget.colors[2] : widget.colors.first;
    // Darker version for the chunky shadow
    Color shadowColor = widget.colors.first.withValues(alpha: 0.8);

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
          width: 280,
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            // The "Chunky Shadow" effect
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                offset: const Offset(0, 6),
                blurRadius: 0,
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              color: mainColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white24, width: 2),
            ),
            child: Center(
              child: Text(
                widget.text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.5,
                  shadows: [
                    Shadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 2),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
