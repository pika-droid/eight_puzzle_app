import 'heuristic_strategy.dart';
import 'manhattan_distance_strategy.dart';

/// Linear Conflict heuristic for the 8-puzzle.
/// Extends Manhattan Distance by adding +2 for each pair of conflicting tiles
/// in both rows and columns.
///
/// A conflict occurs when two tiles are in their goal row/column, but in
/// reversed order relative to each other.
class LinearConflictStrategy implements HeuristicStrategy {
  final ManhattanDistanceStrategy _manhattan = ManhattanDistanceStrategy();

  static const List<int> goalState = [1, 2, 3, 4, 5, 6, 7, 8, 0];

  @override
  int calculate(List<int> state) {
    int conflicts = 0;

    // Check row conflicts
    for (int row = 0; row < 3; row++) {
      conflicts += _countRowConflicts(state, row);
    }

    // Check column conflicts
    for (int col = 0; col < 3; col++) {
      conflicts += _countColumnConflicts(state, col);
    }

    // Linear Conflict = Manhattan + 2 * number_of_conflicts
    return _manhattan.calculate(state) + (2 * conflicts);
  }

  /// Counts linear conflicts in a specific row.
  int _countRowConflicts(List<int> state, int row) {
    int conflicts = 0;
    final int startIndex = row * 3;

    for (int i = 0; i < 3; i++) {
      final int tileA = state[startIndex + i];
      if (tileA == 0) continue;

      // Check if tileA's goal is in this row
      final int goalIndexA = goalState.indexOf(tileA);
      final int goalRowA = goalIndexA ~/ 3;
      if (goalRowA != row) continue;

      for (int j = i + 1; j < 3; j++) {
        final int tileB = state[startIndex + j];
        if (tileB == 0) continue;

        // Check if tileB's goal is in this row
        final int goalIndexB = goalState.indexOf(tileB);
        final int goalRowB = goalIndexB ~/ 3;
        if (goalRowB != row) continue;

        // Both tiles belong to this row in goal state.
        // Conflict if tileA's goal col > tileB's goal col (reversed order).
        final int goalColA = goalIndexA % 3;
        final int goalColB = goalIndexB % 3;
        if (goalColA > goalColB) {
          conflicts++;
        }
      }
    }
    return conflicts;
  }

  /// Counts linear conflicts in a specific column.
  int _countColumnConflicts(List<int> state, int col) {
    int conflicts = 0;

    for (int i = 0; i < 3; i++) {
      final int indexA = i * 3 + col;
      final int tileA = state[indexA];
      if (tileA == 0) continue;

      // Check if tileA's goal is in this column
      final int goalIndexA = goalState.indexOf(tileA);
      final int goalColA = goalIndexA % 3;
      if (goalColA != col) continue;

      for (int j = i + 1; j < 3; j++) {
        final int indexB = j * 3 + col;
        final int tileB = state[indexB];
        if (tileB == 0) continue;

        // Check if tileB's goal is in this column
        final int goalIndexB = goalState.indexOf(tileB);
        final int goalColB = goalIndexB % 3;
        if (goalColB != col) continue;

        // Both tiles belong to this column in goal state.
        // Conflict if tileA's goal row > tileB's goal row (reversed order).
        final int goalRowA = goalIndexA ~/ 3;
        final int goalRowB = goalIndexB ~/ 3;
        if (goalRowA > goalRowB) {
          conflicts++;
        }
      }
    }
    return conflicts;
  }
}
