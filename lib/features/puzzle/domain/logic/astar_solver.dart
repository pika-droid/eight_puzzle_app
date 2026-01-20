import 'dart:collection';

import 'package:collection/collection.dart';

import '../entities/puzzle_node.dart';
import 'heuristic_strategy.dart';
import 'puzzle_utils.dart';

/// A* search algorithm implementation for the 8-puzzle.
class AStarSolver {
  final HeuristicStrategy heuristic;

  static const List<int> goalState = [1, 2, 3, 4, 5, 6, 7, 8, 0];

  AStarSolver({required this.heuristic});

  /// Solves the puzzle starting from [initialState].
  ///
  /// Returns a list of states from start to goal (inclusive).
  /// Throws [UnsolvablePuzzleException] if the puzzle is unsolvable.
  List<List<int>> solve(List<int> initialState) {
    // Validate solvability first.
    PuzzleUtils.isSolvable(initialState);

    // Check if already at goal
    if (_isGoal(initialState)) {
      return [initialState];
    }

    // Priority Queue (min-heap by fCost)
    final PriorityQueue<PuzzleNode> openSet = PriorityQueue<PuzzleNode>(
      (a, b) => a.compareTo(b),
    );

    // Closed set for O(1) lookup
    final HashSet<String> closedSet = HashSet<String>();

    // Map to track best gCost for each state (for re-opening nodes if needed)
    final Map<String, int> gCostMap = {};

    final startNode = PuzzleNode(
      state: initialState,
      gCost: 0,
      hCost: heuristic.calculate(initialState),
    );

    openSet.add(startNode);
    gCostMap[startNode.id] = 0;

    while (openSet.isNotEmpty) {
      final PuzzleNode current = openSet.removeFirst();

      // Skip if already processed with better cost
      if (closedSet.contains(current.id)) {
        continue;
      }

      closedSet.add(current.id);

      // Check goal
      if (_isGoal(current.state)) {
        return _reconstructPath(current);
      }

      // Expand neighbors
      final List<List<int>> neighbors = _getNeighbors(current.state);

      for (final neighborState in neighbors) {
        final String neighborId = neighborState.join(',');

        // Skip if already in closed set
        if (closedSet.contains(neighborId)) {
          continue;
        }

        final int tentativeG = current.gCost + 1;

        // Check if we've seen this state with a better gCost
        if (gCostMap.containsKey(neighborId) &&
            tentativeG >= gCostMap[neighborId]!) {
          continue;
        }

        gCostMap[neighborId] = tentativeG;

        final neighborNode = PuzzleNode(
          state: neighborState,
          gCost: tentativeG,
          hCost: heuristic.calculate(neighborState),
          parent: current,
        );

        openSet.add(neighborNode);
      }
    }

    // Should not reach here if isSolvable passed, but just in case.
    throw Exception('No solution found.');
  }

  bool _isGoal(List<int> state) {
    for (int i = 0; i < state.length; i++) {
      if (state[i] != goalState[i]) return false;
    }
    return true;
  }

  /// Generates all valid neighbor states by moving the empty tile.
  List<List<int>> _getNeighbors(List<int> state) {
    final int emptyIndex = state.indexOf(0);
    final int row = emptyIndex ~/ 3;
    final int col = emptyIndex % 3;

    final List<List<int>> neighbors = [];

    // Up
    if (row > 0) {
      neighbors.add(_swap(state, emptyIndex, emptyIndex - 3));
    }
    // Down
    if (row < 2) {
      neighbors.add(_swap(state, emptyIndex, emptyIndex + 3));
    }
    // Left
    if (col > 0) {
      neighbors.add(_swap(state, emptyIndex, emptyIndex - 1));
    }
    // Right
    if (col < 2) {
      neighbors.add(_swap(state, emptyIndex, emptyIndex + 1));
    }

    return neighbors;
  }

  List<int> _swap(List<int> state, int i, int j) {
    final newState = List<int>.from(state);
    newState[i] = state[j];
    newState[j] = state[i];
    return newState;
  }

  /// Reconstructs the path from start to goal by following parent references.
  List<List<int>> _reconstructPath(PuzzleNode goalNode) {
    final List<List<int>> path = [];
    PuzzleNode? current = goalNode;

    while (current != null) {
      path.add(current.state);
      current = current.parent;
    }

    return path.reversed.toList();
  }
}
