import 'package:shared_preferences/shared_preferences.dart';

class StreakManager {
  static const String _streakKey = 'current_streak';
  static const String _lastDateKey = 'last_played_date';

  /// Gets the current streak. Resets to 0 if a day was missed.
  static Future<int> getStreak() async {
    final prefs = await SharedPreferences.getInstance();
    
    int streak = prefs.getInt(_streakKey) ?? 0;
    int lastTimestamp = prefs.getInt(_lastDateKey) ?? 0;

    // If never played, streak is always 0
    if (lastTimestamp == 0) {
      if (streak != 0) await prefs.setInt(_streakKey, 0);
      return 0;
    }

    DateTime lastDate = DateTime.fromMillisecondsSinceEpoch(lastTimestamp);
    DateTime today = _stripTime(DateTime.now());
    DateTime lastPlayedDay = _stripTime(lastDate);

    int diff = today.difference(lastPlayedDay).inDays;

    if (diff > 1) {
      // Missed more than a day -> Reset streak
      await prefs.setInt(_streakKey, 0);
      return 0;
    }

    return streak;
  }

  /// Updates the streak when a puzzle is solved.
  static Future<void> updateStreak() async {
    final prefs = await SharedPreferences.getInstance();
    int streak = prefs.getInt(_streakKey) ?? 0;
    int lastTimestamp = prefs.getInt(_lastDateKey) ?? 0;

    DateTime now = DateTime.now();
    DateTime today = _stripTime(now);

    if (lastTimestamp == 0) {
      // First time solving
      await prefs.setInt(_streakKey, 1);
      await prefs.setInt(_lastDateKey, today.millisecondsSinceEpoch);
      return;
    }

    DateTime lastDate = DateTime.fromMillisecondsSinceEpoch(lastTimestamp);
    DateTime lastPlayedDay = _stripTime(lastDate);

    int diff = today.difference(lastPlayedDay).inDays;

    if (diff == 0) {
      // Already solved today, no change
      return;
    } else if (diff == 1) {
      // Solved yesterday, increment streak
      await prefs.setInt(_streakKey, streak + 1);
      await prefs.setInt(_lastDateKey, today.millisecondsSinceEpoch);
    } else {
      // Missed a day, reset and start fresh with 1
      await prefs.setInt(_streakKey, 1);
      await prefs.setInt(_lastDateKey, today.millisecondsSinceEpoch);
    }
  }

  static DateTime _stripTime(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
