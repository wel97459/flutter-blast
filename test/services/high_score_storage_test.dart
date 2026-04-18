import 'package:blockblast_flutter/services/high_score_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HighScoreStorage', () {
    late HighScoreStorage storage;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      storage = const HighScoreStorage();
    });

    test('loads zero when no high score is stored', () async {
      expect(await storage.loadHighScore(), 0);
    });

    test('saves and reloads the high score', () async {
      await storage.saveHighScore(128);

      expect(await storage.loadHighScore(), 128);
    });
  });
}
