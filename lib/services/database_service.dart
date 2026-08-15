import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Checks if a username already exists in the database.
  static Future<bool> isUsernameUnique(String username) async {
    try {
      debugPrint("Checking uniqueness for: $username");
      final query = await _db
          .collection('users')
          .where('username', isEqualTo: username.toLowerCase())
          .get()
          .timeout(const Duration(seconds: 10));
      return query.docs.isEmpty;
    } catch (e) {
      debugPrint("Error checking username: $e");
      rethrow;
    }
  }

  /// Saves the user's initial profile with a unique username.
  static Future<void> createUserProfile(User user, String username) async {
    debugPrint("Creating/Merging profile for: $username");
    await _db.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'username': username.toLowerCase(),
      'displayName': username,
      'email': user.email,
      'photoUrl': user.photoURL,
      'isAnonymous': user.isAnonymous,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true)).timeout(const Duration(seconds: 10));
    
    // Initialize stats only if they don't exist yet
    final doc = await getUserData(user.uid);
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null || data['totalScore'] == null) {
      await _db.collection('users').doc(user.uid).set({
        'totalScore': 0,
        'totalPuzzlesSolved': 0,
        'progress': {},
      }, SetOptions(merge: true));
    }
  }

  /// Fetches user data.
  static Future<DocumentSnapshot> getUserData(String uid) async {
    return await _db.collection('users').doc(uid).get().timeout(const Duration(seconds: 10));
  }

  /// Syncs Firestore progress to local SharedPreferences.
  static Future<void> syncProgressToLocal(String uid) async {
    try {
      final doc = await getUserData(uid);
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final progress = data['progress'] as Map<String, dynamic>? ?? {};
        final prefs = await SharedPreferences.getInstance();

        // Sync completed levels per difficulty
        // Since the app uses 'completedLevels_Easy', etc.
        List<String> difficulties = ['Easy', 'Medium', 'Hard'];
        for (var difficulty in difficulties) {
          int maxLevel = 0;
          progress.forEach((key, value) {
            // Key format: "Easy_1", "Medium_5", etc.
            if (key.startsWith("${difficulty}_")) {
              int level = int.tryParse(key.split('_')[1]) ?? 0;
              if (level > maxLevel) maxLevel = level;
              
              // Sync individual level stats
              final stats = value as Map<String, dynamic>;
              prefs.setString('level_${difficulty}_${level}_moves', stats['moves'].toString());
              prefs.setString('level_${difficulty}_${level}_time', stats['time'].toString());
              prefs.setString('level_${difficulty}_${level}_score', stats['score'].toString());
            }
          });
          prefs.setInt('completedLevels_$difficulty', maxLevel);
        }
      }
    } catch (e) {
      debugPrint("Error syncing progress: $e");
    }
  }

  /// Adds points and saves level progress to Firestore.
  static Future<void> saveLevelProgress({
    required String uid,
    required String difficulty,
    required int level,
    required int score,
    required int moves,
    required String time,
  }) async {
    try {
      final docRef = _db.collection('users').doc(uid);
      
      // Update total score and increment puzzles solved
      // and update the specific level in the progress map
      await docRef.update({
        'totalScore': FieldValue.increment(score),
        'totalPuzzlesSolved': FieldValue.increment(1),
        'lastPlayed': FieldValue.serverTimestamp(),
        'progress.${difficulty}_$level': {
          'score': score,
          'moves': moves,
          'time': time,
          'solvedAt': FieldValue.serverTimestamp(),
        }
      }).timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint("Error saving level progress: $e");
    }
  }

  /// Gets the top 50 players globally based on totalScore.
  static Stream<QuerySnapshot> getGlobalRankings() {
    return _db
        .collection('users')
        .orderBy('totalScore', descending: true)
        .limit(50)
        .snapshots();
  }

  /// Syncs local progress from SharedPreferences to Firestore.
  static Future<void> syncLocalProgressToFirestore(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final docRef = _db.collection('users').doc(user.uid);
      
      // Fetch existing data to avoid overwriting chosen identity
      final doc = await docRef.get();
      final existingData = doc.data();

      Map<String, dynamic> profileUpdate = {
        'uid': user.uid,
        'email': user.email,
        'photoUrl': user.photoURL,
        'isAnonymous': false,
        'lastSyncedAt': FieldValue.serverTimestamp(),
      };

      // Only use Google name if the user doesn't already have a chosen identity in the cloud
      if (existingData == null || existingData['username'] == null) {
        final localName = prefs.getString('local_chosen_username');
        profileUpdate['displayName'] = localName ?? user.displayName;
        if (localName != null) {
          profileUpdate['username'] = localName.toLowerCase();
        }
      }

      // Use set with merge: true to ensure the document exists and fields are merged
      await docRef.set(profileUpdate, SetOptions(merge: true));

      Map<String, dynamic> progressUpdate = {};
      int totalScore = existingData?['totalScore'] ?? 0;
      int totalSolved = existingData?['totalPuzzlesSolved'] ?? 0;

      List<String> difficulties = ['Easy', 'Medium', 'Hard'];
      for (var difficulty in difficulties) {
        int maxLevel = prefs.getInt('completedLevels_$difficulty') ?? 0;
        if (maxLevel > 0) {
          for (int i = 1; i <= maxLevel; i++) {
            final scoreStr = prefs.getString('level_${difficulty}_${i}_score') ?? "0";
            final movesStr = prefs.getString('level_${difficulty}_${i}_moves') ?? "0";
            final timeStr = prefs.getString('level_${difficulty}_${i}_time') ?? "00:00";
            
            final score = int.tryParse(scoreStr) ?? 0;
            final moves = int.tryParse(movesStr) ?? 0;
            
            totalScore += score;
            totalSolved++;
            
            progressUpdate['progress.${difficulty}_$i'] = {
              'score': score,
              'moves': moves,
              'time': timeStr,
              'solvedAt': FieldValue.serverTimestamp(),
            };
          }
        }
      }

      if (progressUpdate.isNotEmpty) {
        progressUpdate['totalScore'] = FieldValue.increment(totalScore);
        progressUpdate['totalPuzzlesSolved'] = FieldValue.increment(totalSolved);
        progressUpdate['lastPlayed'] = FieldValue.serverTimestamp();
        
        await docRef.update(progressUpdate).timeout(const Duration(seconds: 15));
        debugPrint("Synced local progress to Firestore for user: ${user.uid}");
      }
    } catch (e) {
      debugPrint("Error syncing local progress to Firestore: $e");
    }
  }

  /// Clears all local progress data from SharedPreferences.
  static Future<void> clearLocalProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allKeys = prefs.getKeys();
      
      for (String key in allKeys) {
        if (key.startsWith('completedLevels_') || 
            key.startsWith('level_') || 
            key == 'isLocalGuest' ||
            key == 'local_chosen_username') {
          await prefs.remove(key);
        }
      }
      debugPrint("Local progress cleared.");
    } catch (e) {
      debugPrint("Error clearing local progress: $e");
    }
  }
}
