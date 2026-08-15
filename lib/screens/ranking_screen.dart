import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/database_service.dart';
import '../services/audio_manager.dart';
import '../theme/theme_manager.dart';

class RankingScreen extends StatelessWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: ThemeManager.themeNotifier,
      builder: (context, currentTheme, child) {
        return Scaffold(
          body: Stack(
            children: [
              // Background with deep blur
              Positioned.fill(
                child: Image.asset(
                  ThemeManager.getBackground(),
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(color: Colors.black.withValues(alpha: 0.3)),
                ),
              ),

              SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              AudioManager.playClick();
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    offset: Offset(0, 4),
                                    blurRadius: 0,
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.arrow_back, color: Color(0xFFD38E4A), size: 25),
                            ),
                          ),
                          const Expanded(
                            child: Center(
                              child: Text(
                                "GLOBAL\nRANKING",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  height: 1.1,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                  shadows: [
                                    Shadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 4)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 45), 
                        ],
                      ),
                    ),

                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: DatabaseService.getGlobalRankings(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
                                  const SizedBox(height: 10),
                                  Text(
                                    "Error loading rankings:\n${snapshot.error}",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                ],
                              ),
                            );
                          }
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator(color: Colors.white));
                          }
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return const Center(
                              child: Text("No ranking found yet...", style: TextStyle(color: Colors.white70, fontSize: 18)),
                            );
                          }

                          // Filter out guest users in the UI to avoid complex Firestore indexing/ordering issues
                          final users = snapshot.data!.docs.where((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            return data['isAnonymous'] != true;
                          }).toList();

                          if (users.isEmpty) {
                            return const Center(
                              child: Text("No ranking found yet...", style: TextStyle(color: Colors.white70, fontSize: 18)),
                            );
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            itemCount: users.length,
                            itemBuilder: (context, index) {
                              try {
                                final userData = users[index].data() as Map<String, dynamic>;
                                final username = userData['displayName']?.toString() ?? "Explorer";
                                // Safely convert to int as Firestore might store numbers as doubles
                                final score = (userData['totalScore'] ?? 0).toInt();
                                final photoUrl = userData['photoUrl']?.toString();

                                bool isTopThree = index < 3;
                                
                                return _RankingTile(
                                  rank: index + 1,
                                  username: username,
                                  score: score,
                                  photoUrl: photoUrl,
                                  isTopThree: isTopThree,
                                );
                              } catch (e) {
                                debugPrint("Error rendering ranking item at index $index: $e");
                                return const SizedBox.shrink();
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RankingTile extends StatelessWidget {
  final int rank;
  final String username;
  final int score;
  final String? photoUrl;
  final bool isTopThree;

  const _RankingTile({
    required this.rank,
    required this.username,
    required this.score,
    this.photoUrl,
    required this.isTopThree,
  });

  @override
  Widget build(BuildContext context) {
    Color rankColor = rank == 1 
        ? const Color(0xFFFFD700) 
        : rank == 2 
            ? const Color(0xFFC0C0C0) 
            : rank == 3 
                ? const Color(0xFFCD7F32) 
                : Colors.white70;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isTopThree 
            ? rankColor.withValues(alpha: 0.15) 
            : Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: isTopThree ? rankColor : Colors.white12,
          width: isTopThree ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Rank Badge
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: isTopThree ? rankColor : Colors.white10,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                "$rank",
                style: TextStyle(
                  color: isTopThree ? Colors.black87 : Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          
          // User Avatar
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: rankColor,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFF4E342E),
              backgroundImage: (photoUrl != null && photoUrl!.isNotEmpty) 
                  ? NetworkImage(photoUrl!) 
                  : null,
              onBackgroundImageError: (photoUrl != null && photoUrl!.isNotEmpty)
                  ? (exception, stackTrace) {
                      debugPrint("Avatar image error: $exception");
                    }
                  : null,
              child: (photoUrl == null || photoUrl!.isEmpty) 
                  ? const Icon(Icons.person, color: Colors.white70) 
                  : null,
            ),
          ),
          const SizedBox(width: 15),

          // Name
          Expanded(
            child: Text(
              username,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: isTopThree ? FontWeight.w900 : FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),

          // Score
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "$score",
                style: TextStyle(
                  color: rankColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Text(
                "pts",
                style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }
}
