import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:blockblast_flutter/widgets/game_board_grid.dart';
import 'package:blockblast_flutter/models/block.dart';
import 'package:blockblast_flutter/widgets/piece_shelf.dart'; // Import PieceShelf
import 'package:blockblast_flutter/models/piece.dart'; // Import Piece model
import 'package:blockblast_flutter/models/game_logic.dart';
import 'package:blockblast_flutter/services/feedback_service.dart';
import 'package:blockblast_flutter/services/high_score_storage.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  JustAudioMediaKit.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, HighScoreStorage? highScoreStorage})
    : _highScoreStorage = highScoreStorage ?? const HighScoreStorage();

  final HighScoreStorage _highScoreStorage;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blockblast Flutter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 170, 215, 255),
        ),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(
        title: 'Blockblast',
        highScoreStorage: _highScoreStorage,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
    HighScoreStorage? highScoreStorage,
  }) : highScoreStorage = highScoreStorage ?? const HighScoreStorage();

  final String title;
  final HighScoreStorage highScoreStorage;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Random _random = Random();
  late final GameFeedbackService _feedbackService;
  static const List<int> _seedBlockColors = [
    0xFF42A5F5, // blue
    0xFF66BB6A, // green
    0xFFEF5350, // red
    0xFFFFA726, // orange
    0xFF26A69A, // teal
  ];

  // Game board blocks (initially empty)
  late List<List<Block>> _gameBoardBlocks;
  // Copy of the game board for piece generation
  late List<List<Block>> _gameBoardBlocksCopy;
  late List<Piece> _currentPieces;
  int _score = 0;
  int _highScore = 0;
  bool _hasNewHighScoreThisGame = false;
  int _combo = 0;
  int _shelfResetCounter = 1; // Counter to trigger shelf reset
  bool _isDraggingPiece = false;

  List<List<Block>> _generateSeededBoard() {
    // Keep seeded density low so the game remains solvable.
    const seededCellChance = 0.16;

    return List.generate(8, (_) {
      return List.generate(8, (_) {
        final shouldFill = _random.nextDouble() < seededCellChance;
        if (!shouldFill) {
          return Block.empty();
        }

        final color =
            _seedBlockColors[_random.nextInt(_seedBlockColors.length)];
        return Block(color: color);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _feedbackService = GameFeedbackService();
    _gameBoardBlocks = _generateSeededBoard();
    _currentPieces = _generateNextPieces();
    _score = 0;
    _hasNewHighScoreThisGame = false;
    _loadHighScore();
    _combo = 0;
    _shelfResetCounter = 1;
  }

  @override
  void dispose() {
    _feedbackService.dispose();
    super.dispose();
  }

  Future<void> _loadHighScore() async {
    final highScore = await widget.highScoreStorage.loadHighScore();
    if (!mounted) {
      return;
    }

    setState(() {
      _highScore = highScore;
    });
  }

  List<Piece> _generateNextPieces() {
    _gameBoardBlocksCopy = _gameBoardBlocks
        .map((row) => row.map((block) => block).toList())
        .toList(); // Deep copy of the game board
    return List.generate(3, (_) => _generatePlayablePiece());
  }

  Piece _generatePlayablePiece() {
    var candidate = Piece.generateRandomPiece();

    for (int attempt = 0; attempt < 5; attempt++) {
      final bestPosition = findBestPiece(_gameBoardBlocksCopy, candidate);
      if (bestPosition.isNotEmpty) {
        placePiece(
          _gameBoardBlocksCopy,
          candidate,
          bestPosition['row']!,
          bestPosition['col']!,
        ); // Place the piece at the best position
        checkAndClearLines(_gameBoardBlocksCopy);
        return candidate;
      }
      candidate = Piece.generateRandomPiece();
    }

    return candidate;
  }

  void _onPieceAccepted(Piece piece, int row, int col) {
    bool shouldPersistHighScore = false;
    int linesCleared = 0;

    setState(() {
      _isDraggingPiece = false;
      placePiece(_gameBoardBlocks, piece, row, col);
      linesCleared = checkAndClearLines(_gameBoardBlocks);
      _score += calculateScore(piece, linesCleared, _combo);
      if (_score > _highScore) {
        _highScore = _score;
        _hasNewHighScoreThisGame = true;
        shouldPersistHighScore = true;
      }
      if (linesCleared > 0) {
        _combo++;
        _shelfResetCounter = 1;
      } else if (_shelfResetCounter == -1 && linesCleared > 0 && _combo > 0) {
        _combo++;
        _shelfResetCounter = 1;
      } else if (_shelfResetCounter == -1) {
        _combo = 0;
        _shelfResetCounter = 0;
      }
      // Remove the piece from the shelf if it was from there
      _currentPieces.remove(piece);
      if (_currentPieces.isEmpty) {
        if (_shelfResetCounter > 0 && linesCleared == 0) {
          _shelfResetCounter = -1;
        }
        _currentPieces = _generateNextPieces();
      }

      // Check for game over
      if (isGameOver(_gameBoardBlocks, _currentPieces)) {
        _showGameOverDialog();
      }
    });

    unawaited(
      _feedbackService.onPiecePlaced(
        linesCleared: linesCleared,
        isNewHighScore: shouldPersistHighScore,
      ),
    );

    if (shouldPersistHighScore) {
      unawaited(widget.highScoreStorage.saveHighScore(_highScore));
    }
  }

  void _showGameOverDialog() {
    unawaited(_feedbackService.onGameOver());
    final isNewHighScore = _hasNewHighScoreThisGame;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Game Over!'),
          content: Text(
            isNewHighScore
                ? 'New high score: $_highScore\nFinal score: $_score'
                : 'Your final score is: $_score\nBest: $_highScore',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Try Again'),
              onPressed: () {
                unawaited(_feedbackService.onPiecePicked());
                Navigator.of(context).pop();
                setState(() {
                  _gameBoardBlocks = _generateSeededBoard();
                  _currentPieces = _generateNextPieces();
                  _score = 0;
                  _hasNewHighScoreThisGame = false;
                  _combo = 0;
                  _shelfResetCounter = 1;
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text(
                'Score: $_score',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _combo > 0 ? Colors.red : Colors.black,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                'Best: $_highScore',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: GameBoardGrid(
                blocks: _gameBoardBlocks,
                didAcceptData: _onPieceAccepted,
                isDraggingPiece: _isDraggingPiece,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: PieceShelf(
              pieces: _currentPieces,
              onPickUp: () {
                setState(() {
                  _isDraggingPiece = true;
                });
                unawaited(_feedbackService.onPiecePicked());
              },
              onDragFinished: () {
                if (!_isDraggingPiece) {
                  return;
                }
                setState(() {
                  _isDraggingPiece = false;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
