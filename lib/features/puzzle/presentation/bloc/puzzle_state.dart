import 'package:equatable/equatable.dart';

abstract class PuzzleState extends Equatable {
  const PuzzleState();

  @override
  List<Object?> get props => [];
}

/// Initial state before puzzle is loaded.
class PuzzleInitial extends PuzzleState {
  const PuzzleInitial();
}

/// Puzzle is loaded and ready for interaction.
class PuzzleLoaded extends PuzzleState {
  /// Current board state (0-8).
  final List<int> boardState;

  /// Number of moves made so far.
  final int moveCount;

  /// Whether the heuristic overlay is visible.
  final bool showHeuristicOverlay;

  /// Heatmap values for each position (0.0 to 1.0).
  /// Only populated when [showHeuristicOverlay] is true.
  final Map<int, double>? heatMapValues;

  /// Whether the puzzle is solved (goal state reached).
  final bool isSolved;

  /// Whether there are moves that can be undone.
  final bool canUndo;

  /// Whether there are moves that can be redone.
  final bool canRedo;

  /// Whether the shadow board (goal state overlay) is visible.
  final bool showShadowBoard;

  /// Optimal number of moves to solve the puzzle (computed on shuffle).
  /// Used for efficiency rating.
  final int? optimalMoveCount;

  /// Time elapsed in seconds.
  final int secondsElapsed;

  const PuzzleLoaded({
    required this.boardState,
    this.moveCount = 0,
    this.showHeuristicOverlay = false,
    this.heatMapValues,
    this.isSolved = false,
    this.canUndo = false,
    this.canRedo = false,
    this.showShadowBoard = false,
    this.optimalMoveCount,
    this.secondsElapsed = 0,
  });

  @override
  List<Object?> get props => [
    boardState,
    moveCount,
    showHeuristicOverlay,
    heatMapValues,
    isSolved,
    canUndo,
    canRedo,
    showShadowBoard,
    optimalMoveCount,
    secondsElapsed,
  ];

  PuzzleLoaded copyWith({
    List<int>? boardState,
    int? moveCount,
    bool? showHeuristicOverlay,
    Map<int, double>? heatMapValues,
    bool? isSolved,
    bool? canUndo,
    bool? canRedo,
    bool? showShadowBoard,
    int? optimalMoveCount,
    int? secondsElapsed,
  }) {
    return PuzzleLoaded(
      boardState: boardState ?? this.boardState,
      moveCount: moveCount ?? this.moveCount,
      showHeuristicOverlay: showHeuristicOverlay ?? this.showHeuristicOverlay,
      heatMapValues: heatMapValues ?? this.heatMapValues,
      isSolved: isSolved ?? this.isSolved,
      canUndo: canUndo ?? this.canUndo,
      canRedo: canRedo ?? this.canRedo,
      showShadowBoard: showShadowBoard ?? this.showShadowBoard,
      optimalMoveCount: optimalMoveCount ?? this.optimalMoveCount,
      secondsElapsed: secondsElapsed ?? this.secondsElapsed,
    );
  }
}

/// Solver is running in the background.
class PuzzleSolving extends PuzzleState {
  /// Current board state while solving.
  final List<int> boardState;

  const PuzzleSolving({required this.boardState});

  @override
  List<Object?> get props => [boardState];
}

/// Solver has completed with a solution.
class PuzzleSolved extends PuzzleState {
  /// The solution path (list of board states from start to goal).
  final List<List<int>> solutionPath;

  /// Time taken to solve.
  final int secondsElapsed;

  /// Current step in the animation (0 = start).
  final int currentStep;

  const PuzzleSolved({
    required this.solutionPath,
    this.currentStep = 0,
    required this.secondsElapsed,
  });

  @override
  List<Object?> get props => [solutionPath, currentStep, secondsElapsed];

  PuzzleSolved copyWith({
    List<List<int>>? solutionPath,
    int? currentStep,
    int? secondsElapsed,
  }) {
    return PuzzleSolved(
      solutionPath: solutionPath ?? this.solutionPath,
      currentStep: currentStep ?? this.currentStep,
      secondsElapsed: secondsElapsed ?? this.secondsElapsed,
    );
  }
}

/// Error state when something goes wrong.
class PuzzleError extends PuzzleState {
  final String message;

  const PuzzleError({required this.message});

  @override
  List<Object?> get props => [message];
}
