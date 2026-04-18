import 'package:shared_preferences/shared_preferences.dart';

class HighScoreStorage {
  const HighScoreStorage();

  static const String highScoreKey = 'high_score';

  Future<int> loadHighScore() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getInt(highScoreKey) ?? 0;
  }

  Future<void> saveHighScore(int highScore) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(highScoreKey, highScore);
  }
}
