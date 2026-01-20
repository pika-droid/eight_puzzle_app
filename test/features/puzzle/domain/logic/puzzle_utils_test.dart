import 'package:eight_puzzle_app/core/error/exceptions.dart';
import 'package:eight_puzzle_app/features/puzzle/domain/logic/puzzle_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PuzzleUtils', () {
    test('should return normally for a solvable state (0 inversions)', () {
      final state = [1, 2, 3, 4, 5, 6, 7, 8, 0];
      expect(() => PuzzleUtils.isSolvable(state), returnsNormally);
    });

    test('should return normally for a solvable state (even inversions)', () {
      // 1, 8, 2 -> 8>2 (1 inv)
      // 0, 4, 3 -> 4>3 (1 inv)
      // 7, 6, 5 -> 7>6, 7>5, 6>5 (3 inv)
      // Total = 5 + others... let's use a known solvable one:
      // [1, 2, 3, 4, 5, 6, 8, 7, 0] -> 8,7 is 1 inversion -> Odd -> Unsolvable
      // [1, 2, 3, 4, 5, 0, 7, 8, 6] -> 7>6, 8>6 -> 2 inversions -> Even -> Solvable
      final state = [1, 2, 3, 4, 5, 0, 7, 8, 6];
      expect(() => PuzzleUtils.isSolvable(state), returnsNormally);
    });

    test(
      'should throw UnsolvablePuzzleException for unsolvable state (odd inversions)',
      () {
        // [1, 2, 3, 4, 5, 6, 8, 7, 0] -> 8>7 (1 inversion) -> Odd
        final state = [1, 2, 3, 4, 5, 6, 8, 7, 0];
        expect(
          () => PuzzleUtils.isSolvable(state),
          throwsA(isA<UnsolvablePuzzleException>()),
        );
      },
    );

    test('should throw UnsolvablePuzzleException for invalid length', () {
      final state = [1, 2, 3];
      expect(
        () => PuzzleUtils.isSolvable(state),
        throwsA(isA<UnsolvablePuzzleException>()),
      );
    });
  });
}
