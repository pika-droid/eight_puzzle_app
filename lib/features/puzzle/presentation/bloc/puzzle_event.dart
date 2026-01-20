import 'package:equatable/equatable.dart';

abstract class PuzzleEvent extends Equatable {
  const PuzzleEvent();

  @override
  List<Object?> get props => [];
}

/// Load or reset the puzzle with an optional initial state.
class LoadPuzzle extends PuzzleEvent {
  /// If null, generates a random solvable puzzle.
  final List<int>? initialState;
  final String?
  difficulty; // Using String to avoid circular dependency, or better Import Difficulty
  final bool isMoveBudgetEnabled;

  const LoadPuzzle({
    this.initialState,
    this.difficulty,
    this.isMoveBudgetEnabled = false,
  });

  @override
  List<Object?> get props => [initialState, difficulty, isMoveBudgetEnabled];
}

/// Move a tile at the given position (swaps with adjacent empty tile).
class MoveTile extends PuzzleEvent {
  /// The position (0-8) of the tile to move.
  final int tilePosition;

  const MoveTile({required this.tilePosition});

  @override
  List<Object?> get props => [tilePosition];
}

/// Start the A* auto-solver in an isolate.
class StartAutoSolve extends PuzzleEvent {
  const StartAutoSolve();
}

/// Toggle the heuristic heatmap overlay visibility.
class ToggleHeuristicOverlay extends PuzzleEvent {
  const ToggleHeuristicOverlay();
}

/// Advance to the next step in the solution animation.
class AnimateSolutionStep extends PuzzleEvent {
  const AnimateSolutionStep();
}

/// Shuffle the puzzle to a new random solvable state.
class ShufflePuzzle extends PuzzleEvent {
  const ShufflePuzzle();
}

/// Undo the last move.
class UndoMove extends PuzzleEvent {
  const UndoMove();
}

/// Redo the last undone move.
class RedoMove extends PuzzleEvent {
  const RedoMove();
}

/// Resume from a saved game state.
class ResumeSavedGame extends PuzzleEvent {
  final List<int> boardState;
  final int moveCount;
  final List<List<int>> undoStack;
  final List<List<int>> redoStack;
  final int? moveLimit;
  final String? difficulty;

  const ResumeSavedGame({
    required this.boardState,
    required this.moveCount,
    required this.undoStack,
    required this.redoStack,
    this.moveLimit,
    this.difficulty,
  });

  @override
  List<Object?> get props => [
    boardState,
    moveCount,
    undoStack,
    redoStack,
    moveLimit,
    difficulty,
  ];
}

/// Toggle the shadow board (goal state overlay) visibility.
class ToggleShadowBoard extends PuzzleEvent {
  const ToggleShadowBoard();
}

/// Internal event: Timer ticked (increment seconds).
class TimerTicked extends PuzzleEvent {
  final int secondsElapsed;
  const TimerTicked(this.secondsElapsed);

  @override
  List<Object?> get props => [secondsElapsed];
}
