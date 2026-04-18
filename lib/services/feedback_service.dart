import 'dart:async';

import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

class GameFeedbackService {
  static const String _tapSoundPath = 'assets/sounds/tap.ogg';
  static const String _clearSoundPath = 'assets/sounds/clear.ogg';

  Future<void> onPiecePicked() async {
    unawaited(_playTap());
    await HapticFeedback.selectionClick();
  }

  Future<void> onPiecePlaced({
    required int linesCleared,
    bool isNewHighScore = false,
  }) async {
    unawaited(linesCleared > 0 ? _playClear() : _playTap());

    if (linesCleared > 0) {
      await HapticFeedback.mediumImpact();
    } else {
      await HapticFeedback.lightImpact();
    }

    if (isNewHighScore) {
      await HapticFeedback.heavyImpact();
    }
  }

  Future<void> onGameOver() async {
    unawaited(_playClear());
    await HapticFeedback.heavyImpact();
    await HapticFeedback.vibrate();
  }

  Future<void> _playTap() async {
    await _playAsset(
      _tapSoundPath,
      volume: 0.85,
      fallback: SystemSoundType.click,
    );
  }

  Future<void> _playClear() async {
    await _playAsset(
      _clearSoundPath,
      volume: 1.0,
      fallback: SystemSoundType.alert,
    );
  }

  Future<void> _playAsset(
    String assetPath, {
    required double volume,
    required SystemSoundType fallback,
  }) async {
    final player = AudioPlayer();

    try {
      await player.setVolume(volume);
      await player.setAsset(assetPath);
      await player.seek(Duration.zero);
      await player.play();

      unawaited(
        player.playerStateStream
            .firstWhere((state) {
              return state.processingState == ProcessingState.completed;
            })
            .then((_) => player.dispose()),
      );
    } catch (_) {
      unawaited(player.dispose());
      unawaited(SystemSound.play(fallback));
    }
  }

  void dispose() {}
}
