import 'package:blockblast_flutter/models/block.dart';
import 'package:blockblast_flutter/models/piece.dart';

bool isValidPlacement(List<List<Block>> grid, Piece piece, int row, int col) {
  for (var pos in piece.shape) {
    final r = row + pos.$1;
    final c = col + pos.$2;
    if (r < 0 || r >= grid.length || c < 0 || c >= grid[0].length) {
      return false;
    }
    if (grid[r][c].isFilled) {
      return false;
    }
  }
  return true;
}

void placePiece(List<List<Block>> grid, Piece piece, int row, int col) {
  for (var pos in piece.shape) {
    final r = row + pos.$1;
    final c = col + pos.$2;
    if (r >= 0 && r < grid.length && c >= 0 && c < grid[0].length) {
      grid[r][c] = Block(color: piece.color);
    }
  }
}

int checkAndClearLines(List<List<Block>> grid) {
  List<int> fullRows = [];
  List<int> fullCols = [];

  // Check rows
  for (int r = 0; r < grid.length; r++) {
    bool isFull = true;
    for (int c = 0; c < grid[r].length; c++) {
      if (!grid[r][c].isFilled) {
        isFull = false;
        break;
      }
    }
    if (isFull) fullRows.add(r);
  }

  // Check columns
  for (int c = 0; c < grid[0].length; c++) {
    bool isFull = true;
    for (int r = 0; r < grid.length; r++) {
      if (!grid[r][c].isFilled) {
        isFull = false;
        break;
      }
    }
    if (isFull) fullCols.add(c);
  }

  // Clear rows
  for (int r in fullRows) {
    for (int c = 0; c < grid[r].length; c++) {
      grid[r][c] = Block.empty();
    }
  }

  // Clear columns
  for (int c in fullCols) {
    for (int r = 0; r < grid.length; r++) {
      grid[r][c] = Block.empty();
    }
  }

  return fullRows.length + fullCols.length;
}

int calculateScore(Piece piece, int linesCleared, int combo) {
  return piece.shape.length + (linesCleared * 22) + (combo * 24);
}

bool isGameOver(List<List<Block>> grid, List<Piece> pieces) {
  if (pieces.isEmpty) return false;

  for (var piece in pieces) {
    for (int r = 0; r < grid.length; r++) {
      for (int c = 0; c < grid[0].length; c++) {
        if (isValidPlacement(grid, piece, r, c)) {
          return false;
        }
      }
    }
  }
  return true;
}

Map<String, int> findBestPiece(List<List<Block>> grid, Piece piece) {
  for (int r = 0; r < grid.length; r++) {
    for (int c = 0; c < grid[0].length; c++) {
      if (isValidPlacement(grid, piece, r, c)) {
        return {'row': r, 'col': c};
      }
    }
  }
  return {};
}
