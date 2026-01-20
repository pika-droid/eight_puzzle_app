import 'package:eight_puzzle_app/core/error/exceptions.dart';
import 'package:eight_puzzle_app/features/puzzle/domain/logic/astar_solver.dart';
import 'package:eight_puzzle_app/features/puzzle/domain/logic/linear_conflict_strategy.dart';
import 'package:eight_puzzle_app/features/puzzle/domain/logic/manhattan_distance_strategy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AStarSolver', () {
    late AStarSolver solver;
    late ManhattanDistanceStrategy manhattan;
    late LinearConflictStrategy linearConflict;

    setUp(() {
      manhattan = ManhattanDistanceStrategy();
      linearConflict = LinearConflictStrategy();
      solver = AStarSolver(heuristic: linearConflict);
    });

    test('should solve a known solvable board in 3 steps', () {
      // Goal: [1, 2, 3, 4, 5, 6, 7, 8, 0]
      // Start: [1, 2, 3, 4, 5, 0, 7, 8, 6]
      // Move 6 up to swap with 0 -> [1, 2, 3, 4, 5, 6, 7, 8, 0]
      // Actually that's 1 step. Let's use a 3-step scenario:
      // Start: [1, 2, 3, 4, 0, 5, 7, 8, 6]
      // Step 1: Move 5 left -> [1, 2, 3, 4, 5, 0, 7, 8, 6]
      // Step 2: Move 6 up -> [1, 2, 3, 4, 5, 6, 7, 8, 0]
      // That's 2 steps. Let's try:
      // Start: [1, 2, 3, 0, 4, 5, 7, 8, 6]
      // Step 1: 4 left -> [1, 2, 3, 4, 0, 5, 7, 8, 6]
      // Step 2: 5 left -> [1, 2, 3, 4, 5, 0, 7, 8, 6]
      // Step 3: 6 up -> [1, 2, 3, 4, 5, 6, 7, 8, 0]
      // 3 steps!

      final initialState = [1, 2, 3, 0, 4, 5, 7, 8, 6];
      final path = solver.solve(initialState);

      // Path includes start and goal, so 3 steps = 4 states
      expect(path.length, equals(4));
      expect(path.first, equals(initialState));
      expect(path.last, equals([1, 2, 3, 4, 5, 6, 7, 8, 0]));
    });

    test('should throw UnsolvablePuzzleException for unsolvable board', () {
      // [1, 2, 3, 4, 5, 6, 8, 7, 0] -> 1 inversion (8 > 7) -> Odd -> Unsolvable
      final unsolvableState = [1, 2, 3, 4, 5, 6, 8, 7, 0];

      expect(
        () => solver.solve(unsolvableState),
        throwsA(isA<UnsolvablePuzzleException>()),
      );
    });

    test('LinearConflict cost >= Manhattan cost for conflict scenario', () {
      // State with linear conflict:
      // [2, 1, 3, 4, 5, 6, 7, 8, 0]
      // Tiles 2 and 1 are in row 0, both belong to row 0 in goal,
      // but 2 is before 1 (reversed order) -> 1 row conflict.
      // Manhattan for tile 1: goal[0] -> current[1] = 1
      // Manhattan for tile 2: goal[1] -> current[0] = 1
      // Total Manhattan = 2, Linear Conflict = 2 + 2 = 4

      final conflictState = [2, 1, 3, 4, 5, 6, 7, 8, 0];

      final manhattanCost = manhattan.calculate(conflictState);
      final linearConflictCost = linearConflict.calculate(conflictState);

      expect(linearConflictCost, greaterThanOrEqualTo(manhattanCost));
      expect(linearConflictCost, equals(manhattanCost + 2)); // 1 conflict
    });

    test('should solve the goal state immediately (0 steps)', () {
      final goalState = [1, 2, 3, 4, 5, 6, 7, 8, 0];
      final path = solver.solve(goalState);

      expect(path.length, equals(1));
      expect(path.first, equals(goalState));
    });
  });
}
