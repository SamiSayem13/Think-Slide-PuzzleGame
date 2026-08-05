import 'package:flutter/material.dart';

class PauseMenu extends StatelessWidget {
  const PauseMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              "assets/images/background.png",
            ),
            fit: BoxFit.cover,
          ),
        ),

        child: Center(
          child: Container(
            padding: const EdgeInsets.all(30),

            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
            ),

            child: const Text(
              "GAME PAUSED",
              style: TextStyle(
                color: Colors.white,
                fontSize: 35,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}