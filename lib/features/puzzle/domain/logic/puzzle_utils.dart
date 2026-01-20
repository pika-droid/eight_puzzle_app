import 'package:eight_puzzle_app/core/error/exceptions.dart';

class PuzzleUtils {
  /// Checks if a given 8-puzzle state is solvable.
  ///
  /// Throws [UnsolvablePuzzleException] if not solvable or invalid.
  static void isSolvable(List<int> state) {
    if (state.length != 9) {
      throw UnsolvablePuzzleException('Invalid board size. Must be 9.');
    }

    int inversions = 0;
    // Don't count the empty tile (0) in inversions
    final tiles = state.where((tile) => tile != 0).toList();

    for (int i = 0; i < tiles.length; i++) {
      for (int j = i + 1; j < tiles.length; j++) {
        if (tiles[i] > tiles[j]) {
          inversions++;
        }
      }
    }

    // For 8-puzzle (3x3 grid), it's solvable if inversions are even.
    if (inversions % 2 != 0) {
      throw UnsolvablePuzzleException(
        'Odd inversion count: $inversions. Puzzle is unsolvable.',
      );
    }
  }
}
