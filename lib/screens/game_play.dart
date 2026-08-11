import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class GamePlayScreen extends StatefulWidget {
  final int level;

  const GamePlayScreen({super.key, required this.level});

  @override
  State<GamePlayScreen> createState() => _GamePlayScreenState();
}

class _GamePlayScreenState extends State<GamePlayScreen> {
  late List<int> tiles;
  int size = 3; // 3x3 for Easy
  bool isSolved = false;
  int moves = 0;
  int secondsElapsed = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _setupGame();
    _startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    timer?.cancel();
    secondsElapsed = 0;
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted) {
        setState(() {
          secondsElapsed++;
        });
      }
    });
  }

  void _setupGame() {
    tiles = List.generate(size * size, (index) => index);

    int emptyIndex = tiles.indexOf(size * size - 1);

    for (int i = 0; i < 200; i++) {
      List<int> neighbors = [];

      int row = emptyIndex ~/ size;
      int col = emptyIndex % size;

      if (row > 0) neighbors.add(emptyIndex - size); // Up
      if (row < size - 1) neighbors.add(emptyIndex + size); // Down
      if (col > 0) neighbors.add(emptyIndex - 1); // Left
      if (col < size - 1) neighbors.add(emptyIndex + 1); // Right

      neighbors.shuffle();

      int swapIndex = neighbors.first;

      int temp = tiles[emptyIndex];
      tiles[emptyIndex] = tiles[swapIndex];
      tiles[swapIndex] = temp;

      emptyIndex = swapIndex;
    }

    isSolved = false;
    moves = 0;
  }

  void _moveTile(int index) {
    if (isSolved) return;

    int emptyIndex = tiles.indexOf(size * size - 1);
    int row = index ~/ size;
    int col = index % size;
    int emptyRow = emptyIndex ~/ size;
    int emptyCol = emptyIndex % size;

    if ((row == emptyRow && (col - emptyCol).abs() == 1) ||
        (col == emptyCol && (row - emptyRow).abs() == 1)) {
      setState(() {
        tiles[emptyIndex] = tiles[index];
        tiles[index] = size * size - 1;
        moves++;
        _checkWin();
      });
    }
  }

  void _checkWin() {
    bool win = true;
    for (int i = 0; i < tiles.length; i++) {
      if (tiles[i] != i) {
        win = false;
        break;
      }
    }
    if (win) {
      setState(() {
        isSolved = true;
        timer?.cancel();
      });
      _saveProgress();
      _showWinDialog();
    }
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save completed level count if this is the highest level completed
    int completedLevels = prefs.getInt('completedLevels') ?? 0;
    if (widget.level > completedLevels) {
      await prefs.setInt('completedLevels', widget.level);
    }

    // Save stats for this level
    await prefs.setString('level_${widget.level}_moves', moves.toString());
    await prefs.setString('level_${widget.level}_time', '${secondsElapsed}s');
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Puzzle Solved!', textAlign: TextAlign.center, style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        content: Text('Level ${widget.level} completed in $moves moves and ${secondsElapsed}s!', textAlign: TextAlign.center),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to level selection
              },
              child: const Text('Back to Menu'),
            ),
          ),
        ],
      ),
    );
  }

  String _getAssetPath() {
    // Use the exact filenames found in the assets folder
    if (widget.level == 5 || widget.level == 7) {
      return 'assets/Easy/${widget.level}.png';
    }
    return 'assets/Easy/${widget.level}.jpg';
  }

  String _formatTime(int seconds) {
    int mins = seconds ~/ 60;
    int secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    String assetPath = _getAssetPath();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/backgrounds/Theme1.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFFD38E4A),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE8C872), Color(0xFFD38E4A)],
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.timer_outlined, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            _formatTime(secondsElapsed),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFA55A94),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.pause, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Game Grid
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5E1B0).withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFD38E4A), width: 2),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: size,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: tiles.length,
                      itemBuilder: (context, index) {
                        int tileValue = tiles[index];
                        // If it's the empty tile (8), show a placeholder
                        if (tileValue == size * size - 1 && !isSolved) {
                          return Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8C872).withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          );
                        }
                        return GestureDetector(
                          onTap: () => _moveTile(index),
                          child: TileWidget(
                            tileValue: tileValue,
                            size: size,
                            imagePath: assetPath,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Moves UI
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.format_list_numbered, color: Color(0xFF7B4E2B)),
                      const SizedBox(width: 8),
                      Text(
                        'Moves: $moves',
                        style: const TextStyle(color: Color(0xFF7B4E2B), fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              // Footer Buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _setupGame,
                        icon: const Icon(Icons.shuffle),
                        label: const Text('Shuffle'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8BC34A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.lightbulb_outline),
                        label: const Text('HINT'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF64B5F6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
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

class TileWidget extends StatelessWidget {
  final int tileValue;
  final int size;
  final String imagePath;

  const TileWidget({
    super.key,
    required this.tileValue,
    required this.size,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate alignment for the image piece
    // Tile 0 -> (-1, -1), Tile 8 -> (1, 1)
    double alignmentX = (tileValue % size) / (size - 1) * 2 - 1;
    double alignmentY = (tileValue ~/ size) / (size - 1) * 2 - 1;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            FractionallySizedBox(
              widthFactor: size.toDouble(),
              heightFactor: size.toDouble(),
              alignment: Alignment(alignmentX, alignmentY),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  );
                },
              ),
            ),
            // Semi-transparent number overlay
            Positioned(
              top: 5,
              left: 5,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${tileValue + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
