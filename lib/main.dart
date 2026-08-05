import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const GamePausedApp());
}

class GamePausedApp extends StatelessWidget {
  const GamePausedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Game Paused',
      theme: ThemeData(fontFamily: 'Arial'),
      home: const PauseMenuScreen(),
    );
  }
}

class PauseMenuScreen extends StatelessWidget {
  const PauseMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/background.png', fit: BoxFit.cover),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: Container(color: Colors.black.withOpacity(0.30)),
          ),
          Center(
            child: PauseCard(
              // Put your actual game actions in these callbacks.
              onResume: () {},
              onRestart: () {},
              onSettings: () {},
              onHome: () {},
            ),
          ),
        ],
      ),
    );
  }
}

class PauseCard extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onSettings;
  final VoidCallback onHome;

  const PauseCard({
    super.key,
    required this.onResume,
    required this.onRestart,
    required this.onSettings,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xffFFF4E5),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.pause_circle, size: 25, color: Colors.brown),
              SizedBox(width: 8),
              Text(
                'GAME PAUSED',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          MenuButton(
            icon: Icons.play_arrow,
            text: 'Resume',
            color: Colors.green,
            onTap: onResume,
          ),
          const SizedBox(height: 12),
          MenuButton(
            icon: Icons.refresh,
            text: 'Restart',
            color: Colors.orange,
            onTap: onRestart,
          ),
          const SizedBox(height: 12),
          MenuButton(
            icon: Icons.settings,
            text: 'Settings',
            color: Colors.blue,
            onTap: onSettings,
          ),
          const SizedBox(height: 12),
          MenuButton(
            icon: Icons.home,
            text: 'Home',
            color: Colors.red,
            onTap: onHome,
          ),
        ],
      ),
    );
  }
}

class MenuButton extends StatefulWidget {
  final IconData icon;
  final String text;
  final Color color;
  final VoidCallback onTap;

  const MenuButton({
    super.key,
    required this.icon,
    required this.text,
    required this.color,
    required this.onTap,
  });

  @override
  State<MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<MenuButton> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (mounted) setState(() => _isPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        splashColor: widget.color.withOpacity(0.28),
        highlightColor: widget.color.withOpacity(0.14),
        onHighlightChanged: _setPressed,
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          decoration: BoxDecoration(
            color: _isPressed ? widget.color.withOpacity(0.16) : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _isPressed ? widget.color : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(widget.icon, color: widget.color, size: 25),
              const SizedBox(width: 15),
              Text(
                widget.text,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: widget.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
