import 'package:flutter/material.dart';
import 'congratulations_page.dart';

void main() {
  runApp(const PuzzleGame());
}

class PuzzleGame extends StatelessWidget {
  const PuzzleGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Puzzle Game',
      home: const CongratulationsPage(
        time: "01:28",
        moves: "47",
      ),
    );
  }
}
