import 'dart:math';

// import 'puzzle_utils.dart'; // Ensure this import exists or pointing to correct utils

enum Difficulty { easy, medium, hard }

class GameGenerator {
  static const List<int> goalState = [1, 2, 3, 4, 5, 6, 7, 8, 0];

  /// Generates a board by walking backward from the goal state.
  ///
  /// [difficulty] determines the number of random moves from the goal state.
  /// - Easy: 5-10 moves
  /// - Medium: 15-20 moves
  /// - Hard: ~31 moves (or max difficulty logic)
  static List<int> generateBoard(Difficulty difficulty) {
    // Start with the goal state
    final List<int> currentBoard = List.from(goalState);
    int steps;

    switch (difficulty) {
      case Difficulty.easy:
        steps = Random().nextInt(6) + 5; // 5 to 10
        break;
      case Difficulty.medium:
        steps = Random().nextInt(6) + 15; // 15 to 20
        break;
      case Difficulty.hard:
        steps =
            45; // Logic says 31, but let's do a bit more to ensure "Hard" is hard enough, or stick to 31 as requested.
        // User requested: "HARD (25-31 Moves)".
        steps = Random().nextInt(7) + 25; // 25 to 31
        break;
    }

    int prevZeroPos = -1;

    // Perform random walk
    for (int i = 0; i < steps; i++) {
      final validMoves = _getValidMoves(currentBoard);

      // Filter out the reverse move to avoid undoing the last step immediately
      // The reverse move is moving the tile that is currently in the position
      // where the zero was previously.
      // Actually, easier logic: don't move the 0 back to where it was.
      if (prevZeroPos != -1) {
        // Find which move would put 0 back to prevZeroPos
        // validMoves contains the indices of tiles that *can* move into the empty space.
        // If we move a tile at index X to empty space Y, the empty space becomes X.
        // We want to avoid empty space becoming prevZeroPos.
        validMoves.removeWhere((tileIndex) => tileIndex == prevZeroPos);
      }

      if (validMoves.isEmpty) {
        // Should not happen in standard 8-puzzle from corner, but good safety
        break;
      }

      final int currentZeroPos = currentBoard.indexOf(0);
      final int moveTileIndex = validMoves[Random().nextInt(validMoves.length)];

      // Swap 0 and the chosen tile
      currentBoard[currentZeroPos] = currentBoard[moveTileIndex];
      currentBoard[moveTileIndex] = 0;

      prevZeroPos = currentZeroPos; // The zero was at currentZeroPos
    }

    return currentBoard;
  }

  /// Returns a list of indices of tiles that can move into the empty space (0).
  static List<int> _getValidMoves(List<int> board) {
    final int zeroIndex = board.indexOf(0);
    final List<int> moves = [];

    final int row = zeroIndex ~/ 3;
    final int col = zeroIndex % 3;

    // Check Up
    if (row > 0) moves.add(zeroIndex - 3);
    // Check Down
    if (row < 2) moves.add(zeroIndex + 3);
    // Check Left
    if (col > 0) moves.add(zeroIndex - 1);
    // Check Right
    if (col < 2) moves.add(zeroIndex + 1);

    return moves;
  }
}
