import 'package:flutter/foundation.dart';

import 'astar_solver.dart';
import 'linear_conflict_strategy.dart';

/// Runs the A* solver in a separate isolate to prevent UI freezing.
///
/// Uses Flutter's `compute` function for simple isolate management.
Future<List<List<int>>> runSolverInIsolate(List<int> initialState) async {
  return compute(_solvePuzzle, initialState);
}

/// Top-level function for isolate execution.
/// Must be a top-level or static function for `compute`.
List<List<int>> _solvePuzzle(List<int> initialState) {
  final solver = AStarSolver(heuristic: LinearConflictStrategy());
  return solver.solve(initialState);
}
