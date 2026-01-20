/// Utility class to calculate heuristic values for individual tiles.
class TileHeuristicCalculator {
  static const List<int> goalState = [1, 2, 3, 4, 5, 6, 7, 8, 0];

  /// Gets the target (goal) position for a tile.
  static int getTargetPosition(int tile) {
    return goalState.indexOf(tile);
  }

  /// Gets the row and column for a position.
  static (int row, int col) getRowCol(int position) {
    return (position ~/ 3, position % 3);
  }

  /// Calculates Manhattan distance for a tile at a given position.
  static int getManhattanDistance(int tile, int currentPosition) {
    if (tile == 0) return 0;

    final (currentRow, currentCol) = getRowCol(currentPosition);
    final targetPosition = getTargetPosition(tile);
    final (targetRow, targetCol) = getRowCol(targetPosition);

    final verticalDistance = (currentRow - targetRow).abs();
    final horizontalDistance = (currentCol - targetCol).abs();

    return verticalDistance + horizontalDistance;
  }

  /// Gets the vertical and horizontal distance components separately.
  static (int vertical, int horizontal) getManhattanComponents(
    int tile,
    int currentPosition,
  ) {
    if (tile == 0) return (0, 0);

    final (currentRow, currentCol) = getRowCol(currentPosition);
    final targetPosition = getTargetPosition(tile);
    final (targetRow, targetCol) = getRowCol(targetPosition);

    return ((currentRow - targetRow).abs(), (currentCol - targetCol).abs());
  }

  /// Checks if a tile has a linear conflict in its current position.
  ///
  /// A linear conflict occurs when:
  /// - Two tiles are in their goal row/column
  /// - But they are in reversed order relative to their goal positions
  static bool hasLinearConflict(
    int tile,
    int currentPosition,
    List<int> boardState,
  ) {
    if (tile == 0) return false;

    final (currentRow, currentCol) = getRowCol(currentPosition);
    final targetPosition = getTargetPosition(tile);
    final (targetRow, targetCol) = getRowCol(targetPosition);

    // Check row conflict
    if (currentRow == targetRow) {
      // Tile is in its goal row - check for conflicts with other tiles
      for (int col = 0; col < 3; col++) {
        if (col == currentCol) continue;

        final otherPosition = currentRow * 3 + col;
        final otherTile = boardState[otherPosition];
        if (otherTile == 0) continue;

        final otherTargetPosition = getTargetPosition(otherTile);
        final (otherTargetRow, otherTargetCol) = getRowCol(otherTargetPosition);

        // Check if other tile is also in this row in goal state
        if (otherTargetRow == currentRow) {
          // Both tiles belong to this row in goal state
          // Check if they're in reversed order
          if ((currentCol < col && targetCol > otherTargetCol) ||
              (currentCol > col && targetCol < otherTargetCol)) {
            return true;
          }
        }
      }
    }

    // Check column conflict
    if (currentCol == targetCol) {
      // Tile is in its goal column - check for conflicts with other tiles
      for (int row = 0; row < 3; row++) {
        if (row == currentRow) continue;

        final otherPosition = row * 3 + currentCol;
        final otherTile = boardState[otherPosition];
        if (otherTile == 0) continue;

        final otherTargetPosition = getTargetPosition(otherTile);
        final (otherTargetRow, otherTargetCol) = getRowCol(otherTargetPosition);

        // Check if other tile is also in this column in goal state
        if (otherTargetCol == currentCol) {
          // Both tiles belong to this column in goal state
          // Check if they're in reversed order
          if ((currentRow < row && targetRow > otherTargetRow) ||
              (currentRow > row && targetRow < otherTargetRow)) {
            return true;
          }
        }
      }
    }

    return false;
  }

  /// Gets Hamming score for a tile (1 if misplaced, 0 if correct).
  static int getHammingScore(int tile, int currentPosition) {
    if (tile == 0) return 0;
    return currentPosition == getTargetPosition(tile) ? 0 : 1;
  }

  /// Gets a complete heuristic report for a tile.
  static TileHeuristicReport getReport(
    int tile,
    int currentPosition,
    List<int> boardState,
  ) {
    final targetPosition = getTargetPosition(tile);
    final (currentRow, currentCol) = getRowCol(currentPosition);
    final (targetRow, targetCol) = getRowCol(targetPosition);
    final (verticalDist, horizontalDist) = getManhattanComponents(
      tile,
      currentPosition,
    );

    return TileHeuristicReport(
      tile: tile,
      currentRow: currentRow,
      currentCol: currentCol,
      targetRow: targetRow,
      targetCol: targetCol,
      verticalDistance: verticalDist,
      horizontalDistance: horizontalDist,
      manhattanDistance: verticalDist + horizontalDist,
      hasLinearConflict: hasLinearConflict(tile, currentPosition, boardState),
      hammingScore: getHammingScore(tile, currentPosition),
    );
  }
}

/// Data class holding heuristic report for a tile.
class TileHeuristicReport {
  final int tile;
  final int currentRow;
  final int currentCol;
  final int targetRow;
  final int targetCol;
  final int verticalDistance;
  final int horizontalDistance;
  final int manhattanDistance;
  final bool hasLinearConflict;
  final int hammingScore;

  const TileHeuristicReport({
    required this.tile,
    required this.currentRow,
    required this.currentCol,
    required this.targetRow,
    required this.targetCol,
    required this.verticalDistance,
    required this.horizontalDistance,
    required this.manhattanDistance,
    required this.hasLinearConflict,
    required this.hammingScore,
  });

  int get targetPosition => targetRow * 3 + targetCol;

  bool get isCorrectPosition => manhattanDistance == 0;
}
