import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/theme_manager.dart';
import '../services/audio_manager.dart';
import 'game_play.dart';

class LevelSelectionScreen extends StatefulWidget {
  final String difficultyTitle;
  final int rows;
  final int cols;
  final String assetFolder;
  final int? totalLevels;

  const LevelSelectionScreen({
    super.key,
    required this.difficultyTitle,
    required this.rows,
    required this.cols,
    required this.assetFolder,
    this.totalLevels,
  });

  @override
  State<LevelSelectionScreen> createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen> {
  int completedLevels = 0;
  Map<int, Map<String, String>> levelStats = {};
  int actualTotalLevels = 10;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    
    // Determine total levels
    if (widget.totalLevels != null) {
      actualTotalLevels = widget.totalLevels!;
    } else {
      actualTotalLevels = await _countLevelsDynamically(widget.assetFolder);
    }

    setState(() {
      completedLevels = prefs.getInt('completedLevels_${widget.difficultyTitle}') ?? 0;
      levelStats = {};
      for (int i = 1; i <= actualTotalLevels; i++) {
        String? moves = prefs.getString('level_${widget.difficultyTitle}_${i}_moves');
        String? time = prefs.getString('level_${widget.difficultyTitle}_${i}_time');
        if (moves != null && time != null) {
          levelStats[i] = {'moves': moves, 'time': time};
        }
      }
      _isLoading = false;
    });
  }

  Future<int> _countLevelsDynamically(String folder) async {
    try {
      // Use the modern AssetManifest API for more reliable counting
      final AssetManifest manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final List<String> allAssets = manifest.listAssets();
      
      final normalizedFolder = folder.toLowerCase();
      final Set<int> levelNumbers = {};

      for (String path in allAssets) {
        final lowerPath = path.toLowerCase();
        
        // Match files that are within the target folder
        // Using contains instead of startsWith to handle potential path prefixes (like packages/)
        if (lowerPath.contains('/$normalizedFolder/')) {
          final fileNameWithExt = path.split('/').last;
          final fileName = fileNameWithExt.split('.').first;
          final levelNum = int.tryParse(fileName);
          
          if (levelNum != null) {
            levelNumbers.add(levelNum);
          }
        }
      }

      debugPrint("Dynamic Count for $folder: found ${levelNumbers.length} levels");
      return levelNumbers.isEmpty ? 10 : levelNumbers.length;
    } catch (e) {
      debugPrint("Error counting levels dynamically: $e");
      return 10; // Fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: ThemeManager.themeNotifier,
      builder: (context, currentTheme, child) {
        return Scaffold(
          body: Stack(
            children: [
              // Background
              Positioned.fill(
                child: Image.asset(
                  ThemeManager.getBackground(),
                  fit: BoxFit.cover,
                  cacheWidth: 1080, // Optimize memory
                ),
              ),

              // Overlay
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.6),
                ),
              ),

              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          AudioManager.playClick();
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                offset: Offset(0, 4),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.chevron_left, color: Color(0xFFE46A16), size: 22),
                        ),
                      ),
                      const SizedBox(height: 10), // Reduced from 20
                      Center(
                        child: Column(
                          children: [
                            Text(
                              widget.difficultyTitle,
                              style: const TextStyle(
                                fontSize: 32, // Slightly smaller text
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '${widget.cols} × ${widget.rows} · Challenge Puzzles',
                              style: const TextStyle(
                                fontSize: 16, // Slightly smaller text
                                color: Colors.greenAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20), // Reduced from 30
                      Row(
                        children: [
                          Text(
                            '$completedLevels / $actualTotalLevels',
                            style: const TextStyle(
                              fontSize: 18, // Slightly smaller text
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: actualTotalLevels > 0 ? completedLevels / actualTotalLevels : 0,
                                backgroundColor: Colors.white24,
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.orangeAccent),
                                minHeight: 10, // Slightly thinner
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20), // Reduced from 30
                      Expanded(
                        child: _isLoading 
                          ? const Center(child: CircularProgressIndicator(color: Colors.white))
                          : GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: actualTotalLevels,
                          itemBuilder: (context, index) {
                            int level = index + 1;
                            bool isCompleted = level <= completedLevels;
                            bool isCurrent = level == (completedLevels + 1);
                            bool isLocked = level > (completedLevels + 1);

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
                                      AudioManager.playClick();
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              GamePlayScreen(
                                                level: level,
                                                rows: widget.rows,
                                                cols: widget.cols,
                                                assetFolder: widget.assetFolder,
                                                difficultyTitle: widget.difficultyTitle,
                                                totalLevels: actualTotalLevels,
                                              ),
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
      },
    );
  }
}

class LevelButton extends StatefulWidget {
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
  State<LevelButton> createState() => _LevelButtonState();
}

class _LevelButtonState extends State<LevelButton> with SingleTickerProviderStateMixin {
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
    Color bgColor;
    Color shadowColor;
    
    if (widget.isCompleted) {
      bgColor = const Color(0xFFFFA726); // Matte Orange
      shadowColor = const Color(0xFFE65100);
    } else if (widget.isCurrent) {
      bgColor = const Color(0xFFFFEB3B); // Matte Yellow
      shadowColor = const Color(0xFFFBC02D);
    } else {
      bgColor = Colors.white.withValues(alpha: 0.2);
      shadowColor = Colors.black26;
    }

    if (widget.isLocked) {
      bgColor = const Color(0xFF9E9E9E).withValues(alpha: 0.5); // Matte Grey
      shadowColor = Color(0xFF616161).withValues(alpha: 0.5);
    }

    return GestureDetector(
      onTapDown: (_) => widget.isLocked ? null : _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        if (widget.onTap != null) widget.onTap!();
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
                color: shadowColor,
                offset: const Offset(0, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white24, width: 2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.isLocked)
                  const Icon(Icons.lock_outline, color: Colors.white70, size: 28)
                else ...[
                  Text(
                    '${widget.level}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      shadows: [Shadow(color: Colors.black26, offset: Offset(0, 1), blurRadius: 2)],
                    ),
                  ),
                  if (widget.isCompleted && widget.moves != null && widget.time != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Column(
                        children: [
                          Text(
                            '${widget.moves} moves',
                            style: const TextStyle(
                                fontSize: 9,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            widget.time!,
                            style: const TextStyle(
                                fontSize: 9,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  if (widget.isCurrent)
                    const Icon(
                      Icons.play_arrow,
                      color: Color(0xFF5D4037),
                      size: 18,
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
