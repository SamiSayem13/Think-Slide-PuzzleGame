import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/theme_manager.dart';
import '../services/streak_manager.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import '../services/audio_manager.dart';
import 'pause_menu.dart';
import 'settings_screen.dart';
import 'home_screen.dart';
import 'congratulations_page.dart';

class GamePlayScreen extends StatefulWidget {
  final int level;
  final int rows;
  final int cols;
  final String assetFolder;
  final String difficultyTitle;
  final int totalLevels;

  const GamePlayScreen({
    super.key,
    required this.level,
    required this.rows,
    required this.cols,
    required this.assetFolder,
    required this.difficultyTitle,
    required this.totalLevels,
  });

  @override
  State<GamePlayScreen> createState() => _GamePlayScreenState();
}

class _GamePlayScreenState extends State<GamePlayScreen> {
  late List<int> tiles;
  late int rows;
  late int cols;
  bool isSolved = false;
  bool showHint = false;
  int moves = 0;
  final ValueNotifier<int> _secondsNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> _movesNotifier = ValueNotifier<int>(0);
  Timer? timer;

  @override
  void initState() {
    super.initState();
    rows = widget.rows;
    cols = widget.cols;
    _setupGame();
    _startTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pre-cache the image to prevent frame skips during animations
    precacheImage(AssetImage(_getAssetPath()), context);
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    timer?.cancel();
    _secondsNotifier.value = 0;
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted) {
        _secondsNotifier.value++;
      }
    });
  }

  bool _isShuffling = false;
  Duration _tileDuration = const Duration(milliseconds: 80);
  Curve _tileCurve = Curves.linear;

  Future<void> _setupGame({bool animated = false}) async {
    if (_isShuffling) return;
    _isShuffling = true;

    if (animated) {
      // New Shuffle Animation: Scatter tiles first
      setState(() {
        isSolved = false;
        moves = 0;
        _movesNotifier.value = 0;
        _tileDuration = const Duration(milliseconds: 400);
        _tileCurve = Curves.easeInOutBack;
        
        // Randomize list completely for a "scatter" visual
        tiles.shuffle();
      });
      
      await Future.delayed(const Duration(milliseconds: 500));

      // Logical shuffle to ensure solvability
      List<int> solvedTiles = List.generate(rows * cols, (index) => index);
      int emptyIndex = solvedTiles.indexOf(rows * cols - 1);
      int shuffleMoves = rows * cols * 10; // Enough moves to look random
      
      for (int i = 0; i < shuffleMoves; i++) {
        List<int> neighbors = [];
        int r = emptyIndex ~/ cols;
        int c = emptyIndex % cols;

        if (r > 0) neighbors.add(emptyIndex - cols);
        if (r < rows - 1) neighbors.add(emptyIndex + cols);
        if (c > 0) neighbors.add(emptyIndex - 1);
        if (c < cols - 1) neighbors.add(emptyIndex + 1);

        neighbors.shuffle();
        int swapIndex = neighbors.first;

        int temp = solvedTiles[emptyIndex];
        solvedTiles[emptyIndex] = solvedTiles[swapIndex];
        solvedTiles[swapIndex] = temp;
        emptyIndex = swapIndex;
      }

      setState(() {
        tiles = List.from(solvedTiles);
      });

      await Future.delayed(const Duration(milliseconds: 600));
    } else {
      // Instant setup
      List<int> solvedTiles = List.generate(rows * cols, (index) => index);
      int emptyIndex = solvedTiles.indexOf(rows * cols - 1);
      int shuffleMoves = 200; 
      for (int i = 0; i < shuffleMoves; i++) {
        List<int> neighbors = [];
        int r = emptyIndex ~/ cols;
        int c = emptyIndex % cols;

        if (r > 0) neighbors.add(emptyIndex - cols);
        if (r < rows - 1) neighbors.add(emptyIndex + cols);
        if (c > 0) neighbors.add(emptyIndex - 1);
        if (c < cols - 1) neighbors.add(emptyIndex + 1);

        neighbors.shuffle();
        int swapIndex = neighbors.first;

        int temp = solvedTiles[emptyIndex];
        solvedTiles[emptyIndex] = solvedTiles[swapIndex];
        solvedTiles[swapIndex] = temp;
        emptyIndex = swapIndex;
      }
      
      setState(() {
        tiles = solvedTiles;
        isSolved = false;
        moves = 0;
        _movesNotifier.value = 0;
      });
    }

    // Reset to snappy animation for gameplay
    setState(() {
      _tileDuration = const Duration(milliseconds: 80);
      _tileCurve = Curves.linear;
    });

    _isShuffling = false;
  }

  void _moveTile(int index) {
    if (isSolved) return;

    int emptyIndex = tiles.indexOf(rows * cols - 1);
    int r = index ~/ cols;
    int c = index % cols;
    int emptyRow = emptyIndex ~/ cols;
    int emptyCol = emptyIndex % cols;

    if ((r == emptyRow && (c - emptyCol).abs() == 1) ||
        (c == emptyCol && (r - emptyRow).abs() == 1)) {
      AudioManager.playSlideVibration(); // Success vibration
      setState(() {
        tiles[emptyIndex] = tiles[index];
        tiles[index] = rows * cols - 1;
        moves++;
        _movesNotifier.value = moves;
        _checkWin();
      });
    } else {
      AudioManager.playClick(); // Feedback for "I heard your tap but this tile can't move"
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
      _showCongratulations();
    }
  }

  void _showCongratulations() {
    // Calculate the new score based on the formula: 100 - (moves * 0.25) - (seconds * 0.05)
    double calculatedScore = 100 - (moves * 0.25) - (_secondsNotifier.value * 0.05);
    int finalScore = calculatedScore.round();
    if (finalScore < 0) finalScore = 0;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CongratulationsPage(
          time: _formatTime(_secondsNotifier.value),
          moves: moves.toString(),
          score: finalScore.toString(),
          onNextPuzzle: () {
            int nextLevel = widget.level + 1;
            if (nextLevel <= widget.totalLevels) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => GamePlayScreen(
                    level: nextLevel,
                    rows: widget.rows,
                    cols: widget.cols,
                    assetFolder: widget.assetFolder,
                    difficultyTitle: widget.difficultyTitle,
                    totalLevels: widget.totalLevels,
                  ),
                ),
              );
            } else {
              Navigator.pop(context);
            }
          },
          onHome: () {
            Navigator.pop(context); // This will take user back to LevelSelectionScreen
          },
        ),
      ),
    );
  }

  void _showPauseMenu() {
    timer?.cancel();
    AudioManager.pauseBackgroundMusic();
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (context) => PauseMenu(
        onResume: () {
          Navigator.pop(context);
          AudioManager.resumeBackgroundMusic();
          _resumeTimer();
        },
        onRestart: () {
          Navigator.pop(context);
          AudioManager.resumeBackgroundMusic();
          _setupGame();
          _startTimer();
        },
        onSettings: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingsScreen()),
          );
        },
        onHome: () {
          AudioManager.resumeBackgroundMusic();
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
          );
        },
      ),
    );
  }

  void _resumeTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted) {
        _secondsNotifier.value++;
      }
    });
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save completed level count if this is the highest level completed for this difficulty
    int completedLevels = prefs.getInt('completedLevels_${widget.difficultyTitle}') ?? 0;
    if (widget.level > completedLevels) {
      await prefs.setInt('completedLevels_${widget.difficultyTitle}', widget.level);
    }

    // Save stats for this level under difficulty prefix
    await prefs.setString('level_${widget.difficultyTitle}_${widget.level}_moves', moves.toString());
    await prefs.setString('level_${widget.difficultyTitle}_${widget.level}_time', '${_secondsNotifier.value}s');

    // Update daily streak
    await StreakManager.updateStreak();

    // ================= FIREBASE SCORING =================
    // Calculate the score based on the formula: 100 - (moves * 0.25) - (seconds * 0.05)
    double calculatedScore = 100 - (moves * 0.25) - (_secondsNotifier.value * 0.05);
    int points = calculatedScore.round();
    if (points < 0) points = 0;

    final user = AuthService.currentUser;
    if (user != null) {
      await DatabaseService.saveLevelProgress(
        uid: user.uid,
        difficulty: widget.difficultyTitle,
        level: widget.level,
        score: points,
        moves: moves,
        time: '${_secondsNotifier.value}s',
      );
    }
  }

  String _getAssetPath() {
    // Handle specific file extensions for each folder based on what's available
    String folder = widget.assetFolder;
    int lvl = widget.level;

    if (folder == "Easy") {
      if (lvl == 5 || lvl == 7) return 'assets/Easy/$lvl.png';
      return 'assets/Easy/$lvl.jpg';
    } else if (folder == "Medium") {
      if (lvl == 5) return 'assets/Medium/$lvl.png';
      return 'assets/Medium/$lvl.jpg';
    } else if (folder == "Hard") {
      if (lvl == 9) return 'assets/Hard/$lvl.png';
      return 'assets/Hard/$lvl.jpg';
    } else if (folder == "free_to_play") {
      if (lvl == 13) return 'assets/free_to_play/$lvl.png';
      return 'assets/free_to_play/$lvl.jpg';
    }
    
    return 'assets/$folder/$lvl.jpg';
  }

  String _formatTime(int seconds) {
    int mins = seconds ~/ 60;
    int secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    String assetPath = _getAssetPath();

    return ValueListenableBuilder<int>(
      valueListenable: ThemeManager.themeNotifier,
      builder: (context, currentTheme, child) {
        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(ThemeManager.getBackground()),
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
                        HeaderCartoonButton(
                          onTap: () => Navigator.pop(context),
                          icon: Icons.arrow_back,
                          color: const Color(0xFFD38E4A),
                          shadowColor: const Color(0xFF915F2D),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAEBCD),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: const Color(0xFFD38E4A), width: 2),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0xFFD38E4A),
                                offset: Offset(0, 3),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.timer_outlined, color: Color(0xFF7B4E2B)),
                              const SizedBox(width: 8),
                              ValueListenableBuilder<int>(
                                valueListenable: _secondsNotifier,
                                builder: (context, seconds, child) {
                                  return Text(
                                    _formatTime(seconds),
                                    style: const TextStyle(
                                        color: Color(0xFF7B4E2B),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        HeaderCartoonButton(
                          onTap: _showPauseMenu,
                          icon: Icons.pause,
                          color: const Color(0xFFA55A94),
                          shadowColor: const Color(0xFF743A66),
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
                        aspectRatio: cols / rows,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            double gap = 2.0;
                            double totalHorizontalGap = (cols - 1) * gap;
                            double tileSize = (constraints.maxWidth - totalHorizontalGap) / cols;
                            
                            return RepaintBoundary(
                              child: Stack(
                                children: [
                                  // Iterate by tileValue instead of list index to enable position animation
                                  ...List.generate(rows * cols, (tileValue) {
                                    if (tileValue == rows * cols - 1 && !isSolved) {
                                      return const SizedBox.shrink();
                                    }

                                    // Find current position of this specific tileValue
                                    int currentIndex = tiles.indexOf(tileValue);
                                    int r = currentIndex ~/ cols;
                                    int c = currentIndex % cols;

                                    return AnimatedPositioned(
                                      key: ValueKey(tileValue),
                                      duration: _tileDuration,
                                      curve: _tileCurve,
                                      left: c * (tileSize + gap),
                                      top: r * (tileSize + gap),
                                      width: tileSize,
                                      height: tileSize,
                                      child: GestureDetector(
                                        onTap: () => _moveTile(currentIndex),
                                        child: TileWidget(
                                          tileValue: tileValue,
                                          rows: rows,
                                          cols: cols,
                                          imagePath: assetPath,
                                        ),
                                      ),
                                    );
                                  }),
                                  if (showHint)
                                    RepaintBoundary(
                                      child: GestureDetector(
                                        onTap: () => setState(() => showHint = false),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.asset(
                                            assetPath,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                            cacheWidth: 800, // Optimize memory
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
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
                          ValueListenableBuilder<int>(
                            valueListenable: _movesNotifier,
                            builder: (context, movesCount, child) {
                              return Text(
                                'Moves: $movesCount',
                                style: const TextStyle(
                                    color: Color(0xFF7B4E2B),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20),
                              );
                            },
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
                          child: CartoonIconButton(
                            onPressed: _isShuffling ? null : () => _setupGame(animated: true),
                            icon: Icons.shuffle,
                            label: 'Shuffle',
                            color: const Color(0xFF8BC34A),
                            shadowColor: const Color(0xFF558B2F),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: CartoonIconButton(
                            onPressed: () {
                              setState(() {
                                showHint = !showHint;
                              });
                            },
                            icon: Icons.lightbulb_outline,
                            label: showHint ? 'HIDE' : 'HINT',
                            color: const Color(0xFF64B5F6),
                            shadowColor: const Color(0xFF1976D2),
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
      },
    );
  }
}

class CartoonIconButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color shadowColor;
  final VoidCallback? onPressed;

  const CartoonIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.shadowColor,
    this.onPressed,
  });

  @override
  State<CartoonIconButton> createState() => _CartoonIconButtonState();
}

class _CartoonIconButtonState extends State<CartoonIconButton> with SingleTickerProviderStateMixin {
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
    bool isEnabled = widget.onPressed != null;

    return GestureDetector(
      onTapDown: (_) => isEnabled ? _controller.forward() : null,
      onTapUp: (_) {
        if (isEnabled) {
          _controller.reverse();
          AudioManager.playClick();
          widget.onPressed!();
        }
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: isEnabled ? widget.shadowColor : Colors.black12,
                offset: const Offset(0, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isEnabled ? widget.color : Colors.grey[400],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white24, width: 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  widget.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HeaderCartoonButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final Color shadowColor;
  final VoidCallback onTap;

  const HeaderCartoonButton({
    super.key,
    required this.icon,
    required this.color,
    required this.shadowColor,
    required this.onTap,
  });

  @override
  State<HeaderCartoonButton> createState() => _HeaderCartoonButtonState();
}

class _HeaderCartoonButtonState extends State<HeaderCartoonButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
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
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        AudioManager.playClick();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: widget.shadowColor,
                offset: const Offset(0, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white24, width: 2),
            ),
            child: Icon(widget.icon, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }
}

class TileWidget extends StatelessWidget {
  final int tileValue;
  final int rows;
  final int cols;
  final String imagePath;

  const TileWidget({
    super.key,
    required this.tileValue,
    required this.rows,
    required this.cols,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate alignment for the image piece
    double alignmentX = (cols > 1) ? (tileValue % cols) / (cols - 1) * 2 - 1 : 0;
    double alignmentY = (rows > 1) ? (tileValue ~/ cols) / (rows - 1) * 2 - 1 : 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10, width: 0.5), // Thinner, subtle border
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            FractionallySizedBox(
              widthFactor: cols.toDouble(),
              heightFactor: rows.toDouble(),
              alignment: Alignment(alignmentX, alignmentY),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                cacheWidth: 800, // Optimize memory for tiles
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
                    fontSize: 10,
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
