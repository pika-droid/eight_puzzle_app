import 'heuristic_strategy.dart';

/// Manhattan Distance heuristic for the 8-puzzle.
/// Calculates the sum of Manhattan distances of each tile from its goal position.
class ManhattanDistanceStrategy implements HeuristicStrategy {
  /// Goal state: [1, 2, 3, 4, 5, 6, 7, 8, 0]
  static const List<int> goalState = [1, 2, 3, 4, 5, 6, 7, 8, 0];

  @override
  int calculate(List<int> state) {
    int distance = 0;
    for (int i = 0; i < state.length; i++) {
      final int tile = state[i];
      if (tile == 0) continue; // Skip empty tile

      // Current position (row, col)
      final int currentRow = i ~/ 3;
      final int currentCol = i % 3;

      // Goal position for this tile
      final int goalIndex = goalState.indexOf(tile);
      final int goalRow = goalIndex ~/ 3;
      final int goalCol = goalIndex % 3;

      distance += (currentRow - goalRow).abs() + (currentCol - goalCol).abs();
    }
    return distance;
  }
}
