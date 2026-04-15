import 'dart:math';

import 'package:flutter/material.dart';
import 'package:blockblast_flutter/widgets/game_board_grid.dart';
import 'package:blockblast_flutter/models/block.dart';
import 'package:blockblast_flutter/widgets/piece_shelf.dart'; // Import PieceShelf
import 'package:blockblast_flutter/models/piece.dart'; // Import Piece model
import 'package:blockblast_flutter/models/game_logic.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      home: const MyHomePage(title: 'Blockblast'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Random _random = Random();
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
  int _combo = 0;
  int _shelfResetCounter = 1; // Counter to trigger shelf reset

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
    _gameBoardBlocks = _generateSeededBoard();
    _currentPieces = _generateNextPieces();
    _score = 0;
    _combo = 0;
    _shelfResetCounter = 1;
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
    setState(() {
      placePiece(_gameBoardBlocks, piece, row, col);
      final linesCleared = checkAndClearLines(_gameBoardBlocks);
      _score += calculateScore(piece, linesCleared, _combo);
      if (linesCleared > 0 && _combo == 0) {
        _combo++;
        _shelfResetCounter = 2; // Reset shelf counter on multi-line clear
      } else if (linesCleared > 0 && _combo > 0) {
        _combo++;
        _shelfResetCounter = 1; // Reset shelf counter on multi-line clear
      }
      // Remove the piece from the shelf if it was from there
      _currentPieces.remove(piece);
      if (_currentPieces.isEmpty) {
        if (_shelfResetCounter > 0) {
          _shelfResetCounter--;
        } else {
          _combo = 0; // Reset combo if shelf reset counter is exhausted
        }
        _currentPieces = _generateNextPieces();
      }

      // Check for game over
      if (isGameOver(_gameBoardBlocks, _currentPieces)) {
        _showGameOverDialog();
      }
    });
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Game Over!'),
          content: Text('Your final score is: $_score'),
          actions: <Widget>[
            TextButton(
              child: const Text('Try Again'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _gameBoardBlocks = _generateSeededBoard();
                  _currentPieces = _generateNextPieces();
                  _score = 0;
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
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: GameBoardGrid(
                blocks: _gameBoardBlocks,
                didAcceptData: _onPieceAccepted, // Pass the callback
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: PieceShelf(pieces: _currentPieces),
          ),
        ],
      ),
    );
  }
}
