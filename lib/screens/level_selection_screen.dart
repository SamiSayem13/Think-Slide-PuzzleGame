import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_play.dart';

class LevelSelectionScreen extends StatefulWidget {
  const LevelSelectionScreen({super.key});

  @override
  State<LevelSelectionScreen> createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen> {
  int completedLevels = 0;
  Map<int, Map<String, String>> levelStats = {};
  final int totalLevels = 10;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      completedLevels = prefs.getInt('completedLevels') ?? 0;
      levelStats = {};
      for (int i = 1; i <= totalLevels; i++) {
        String? moves = prefs.getString('level_${i}_moves');
        String? time = prefs.getString('level_${i}_time');
        if (moves != null && time != null) {
          levelStats[i] = {'moves': moves, 'time': time};
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    int currentLevel = completedLevels + 1;

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
                        childAspectRatio: 0.85,
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
                          onTap: isLocked
                              ? null
                              : () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          GamePlayScreen(level: level),
                                    ),
                                  );
                                  _loadData(); // Refresh when returning
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

    bool showPlayIcon = isCurrent && level <= 10;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(
              sigmaX: isLocked ? 10 : 0, sigmaY: isLocked ? 10 : 0),
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
                          style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w500),
                        ),
                        Text(
                          time!,
                          style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w500),
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
