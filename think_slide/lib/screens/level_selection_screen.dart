import 'dart:ui';
import 'package:flutter/material.dart';
import 'game_play.dart';

class LevelSelectionScreen extends StatelessWidget {
  const LevelSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for demonstration
    int completedLevels = 0;
    int currentLevel = completedLevels + 1;
    int totalLevels = 10;

    // Mock stats for completed levels
    final Map<int, Map<String, String>> levelStats = {
      1: {'moves': '24', 'time': '12s'},
      2: {'moves': '31', 'time': '18s'},
      3: {'moves': '45', 'time': '25s'},
      4: {'moves': '38', 'time': '20s'},
    };

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/backgrounds/Theme1.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  CircleAvatar(
                    backgroundColor: Colors.white.withValues(alpha: 0.8),
                    child: IconButton(
                      icon: const Icon(Icons.chevron_left, color: Colors.black),
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Center(
                    child: Column(
                      children: [
                        Text(
                          'Easy',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '3 × 3 · Warm up puzzles',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    children: [
                      Text(
                        '$completedLevels / $totalLevels',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: completedLevels / totalLevels,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.orangeAccent),
                            minHeight: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.85, // Slightly taller for stats
                      ),
                      itemCount: totalLevels,
                      itemBuilder: (context, index) {
                        int level = index + 1;
                        bool isCompleted = level <= completedLevels;
                        bool isCurrent = level == currentLevel;
                        bool isLocked = level > currentLevel;

                        return LevelButton(
                          level: level,
                          isCompleted: isCompleted,
                          isCurrent: isCurrent,
                          isLocked: isLocked,
                          moves: levelStats[level]?['moves'],
                          time: levelStats[level]?['time'],
                          onTap: isLocked ? null : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GamePlayScreen(level: level),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LevelButton extends StatelessWidget {
  final int level;
  final bool isCompleted;
  final bool isCurrent;
  final bool isLocked;
  final String? moves;
  final String? time;
  final VoidCallback? onTap;

  const LevelButton({
    super.key,
    required this.level,
    required this.isCompleted,
    required this.isCurrent,
    required this.isLocked,
    this.moves,
    this.time,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    if (isCompleted) {
      bgColor = Colors.orange;
    } else if (isCurrent) {
      bgColor = Colors.yellow;
    } else {
      bgColor = Colors.white.withValues(alpha: 0.1);
    }

    // Don't show play icon if it's the current level but beyond level 10
    bool showPlayIcon = isCurrent && level <= 10;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: isLocked ? 10 : 0, sigmaY: isLocked ? 10 : 0),
          child: Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$level',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (isCompleted && moves != null && time != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Column(
                      children: [
                        Text(
                          '$moves moves',
                          style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          time!,
                          style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                if (showPlayIcon)
                  const Icon(
                    Icons.play_arrow,
                    color: Colors.black,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
