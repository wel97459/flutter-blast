import 'package:flutter/material.dart';

import '../models/game_state.dart';
import '../widgets/board_widget.dart';
import '../widgets/pieces_panel.dart';
import '../widgets/score_panel.dart';

/// The main game screen.
///
/// Listens to [GameState] and rebuilds whenever the state changes. Shows a
/// game-over overlay when [GameState.isGameOver] is true.
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GameState _gameState = GameState();

  @override
  void dispose() {
    _gameState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _gameState,
          builder: (context, _) {
            return Stack(
              children: [
                _buildGameContent(context),
                if (_gameState.isGameOver) _buildGameOverOverlay(context),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildGameContent(BuildContext context) {
    return Column(
      children: [
        // ── Header ───────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(
            children: [
              const Text(
                'BLOCK BLAST',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white70),
                tooltip: 'New game',
                onPressed: _gameState.restartGame,
              ),
            ],
          ),
        ),

        // ── Score ────────────────────────────────────────────────────────
        const SizedBox(height: 8),
        ScorePanel(gameState: _gameState),

        // ── Board ────────────────────────────────────────────────────────
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: BoardWidget(gameState: _gameState),
              ),
            ),
          ),
        ),

        // ── Piece palette ────────────────────────────────────────────────
        PiecesPanel(gameState: _gameState),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildGameOverOverlay(BuildContext context) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 400),
      child: Container(
        color: Colors.black.withAlpha(180),
        child: Center(
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF0F3460), width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'GAME OVER',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Score: ${_gameState.score}',
                  style: const TextStyle(
                    color: Color(0xFF8888AA),
                    fontSize: 18,
                  ),
                ),
                if (_gameState.score >= _gameState.highScore &&
                    _gameState.highScore > 0) ...[
                  const SizedBox(height: 8),
                  const Text(
                    '🏆 New High Score!',
                    style: TextStyle(
                      color: Color(0xFFFDD835),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _gameState.restartGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E88E5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'PLAY AGAIN',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
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
