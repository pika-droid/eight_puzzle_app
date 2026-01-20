import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/game_storage_service.dart';
import '../../domain/logic/game_generator.dart';
import '../../domain/logic/move_history.dart';
import '../../domain/logic/puzzle_utils.dart';
import '../../domain/logic/solver_isolate.dart';
import 'puzzle_event.dart';
import 'puzzle_state.dart';

class PuzzleBloc extends Bloc<PuzzleEvent, PuzzleState> {
  static const List<int> goalState = [1, 2, 3, 4, 5, 6, 7, 8, 0];

  /// Move history for undo/redo functionality.
  final MoveHistory _moveHistory = MoveHistory();

  /// Storage service for game persistence.
  final GameStorageService _storageService = GameStorageService();

  /// Getter for move history (for persistence).
  MoveHistory get moveHistory => _moveHistory;

  /// Getter for storage service.
  GameStorageService get storageService => _storageService;

  Timer? _timer;
  int _secondsElapsed = 0;

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  PuzzleBloc() : super(const PuzzleInitial()) {
    on<LoadPuzzle>(_onLoadPuzzle);
    on<MoveTile>(_onMoveTile);
    on<StartAutoSolve>(_onStartAutoSolve);
    on<ToggleHeuristicOverlay>(_onToggleHeuristicOverlay);
    on<ToggleShadowBoard>(_onToggleShadowBoard);
    on<AnimateSolutionStep>(_onAnimateSolutionStep);
    on<ShufflePuzzle>(_onShufflePuzzle);
    on<UndoMove>(_onUndoMove);
    on<RedoMove>(_onRedoMove);
    on<ResumeSavedGame>(_onResumeSavedGame);
    on<TimerTicked>(_onTimerTicked);
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      add(TimerTicked(_secondsElapsed + 1));
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _onTimerTicked(TimerTicked event, Emitter<PuzzleState> emit) {
    _secondsElapsed = event.secondsElapsed;
    final currentState = state;
    if (currentState is PuzzleLoaded && !currentState.isSolved) {
      emit(currentState.copyWith(secondsElapsed: _secondsElapsed));
    }
  }

  void _onLoadPuzzle(LoadPuzzle event, Emitter<PuzzleState> emit) {
    List<int> initialState;
    int? moveLimit;
    Difficulty? difficultyEnum;

    if (event.initialState != null) {
      initialState = event.initialState!;
    } else if (event.difficulty != null) {
      // Parse difficulty from string
      try {
        difficultyEnum = Difficulty.values.firstWhere(
          (e) => e.toString() == event.difficulty,
        );
        initialState = GameGenerator.generateBoard(difficultyEnum);

        if (event.isMoveBudgetEnabled) {
          switch (difficultyEnum) {
            case Difficulty.easy:
              moveLimit = 10;
              break;
            case Difficulty.medium:
              moveLimit = 20;
              break;
            case Difficulty.hard:
              moveLimit = 31;
              break;
          }
        }
      } catch (_) {
        initialState = _generateShuffledPuzzle();
      }
    } else {
      initialState = _generateShuffledPuzzle();
    }

    // Clear history when loading a new puzzle
    _moveHistory.clear();

    // Reset timer
    _secondsElapsed = 0;
    _startTimer();

    emit(
      PuzzleLoaded(
        boardState: initialState,
        moveCount: 0,
        isSolved: _isGoal(initialState),
        canUndo: false,
        canRedo: false,
        secondsElapsed: 0,
        moveLimit: moveLimit,
        difficulty: event.difficulty,
      ),
    );
  }

  void _onMoveTile(MoveTile event, Emitter<PuzzleState> emit) {
    final currentState = state;
    if (currentState is! PuzzleLoaded) return;
    if (currentState.isSolved) return;

    final int tilePosition = event.tilePosition;
    final int emptyPosition = currentState.boardState.indexOf(0);

    // Check if the tile is adjacent to the empty space
    if (!_isAdjacent(tilePosition, emptyPosition)) return;

    // Record current state before move (for undo)
    _moveHistory.recordMove(currentState.boardState);

    // Swap tiles
    final newBoard = List<int>.from(currentState.boardState);
    newBoard[emptyPosition] = newBoard[tilePosition];
    newBoard[tilePosition] = 0;

    final bool solved = _isGoal(newBoard);

    emit(
      currentState.copyWith(
        boardState: newBoard,
        moveCount: currentState.moveCount + 1,
        isSolved: solved,
        heatMapValues: currentState.showHeuristicOverlay
            ? _calculateHeatmap(newBoard)
            : null,
        canUndo: _moveHistory.canUndo,
        canRedo: _moveHistory.canRedo,
      ),
    );

    // Auto-save after move (non-blocking)
    if (!solved) {
      _autoSave(newBoard, currentState.moveCount + 1);
    } else {
      _stopTimer();
      // Save best score if applicable
      _storageService.saveBestScore(
        currentState.moveCount + 1,
        _secondsElapsed,
      );
      // Clear save when puzzle is solved
      _storageService.clearSave();
    }
  }

  void _onUndoMove(UndoMove event, Emitter<PuzzleState> emit) {
    final currentState = state;
    if (currentState is! PuzzleLoaded) return;
    if (!_moveHistory.canUndo) return;

    final previousState = _moveHistory.undo(currentState.boardState);
    if (previousState == null) return;

    emit(
      currentState.copyWith(
        boardState: previousState,
        moveCount: (currentState.moveCount - 1).clamp(
          0,
          currentState.moveCount,
        ),
        isSolved: _isGoal(previousState),
        heatMapValues: currentState.showHeuristicOverlay
            ? _calculateHeatmap(previousState)
            : null,
        canUndo: _moveHistory.canUndo,
        canRedo: _moveHistory.canRedo,
      ),
    );

    // Auto-save after undo
    _autoSave(
      previousState,
      (currentState.moveCount - 1).clamp(0, currentState.moveCount),
    );
  }

  void _onRedoMove(RedoMove event, Emitter<PuzzleState> emit) {
    final currentState = state;
    if (currentState is! PuzzleLoaded) return;
    if (!_moveHistory.canRedo) return;

    final nextState = _moveHistory.redo(currentState.boardState);
    if (nextState == null) return;

    emit(
      currentState.copyWith(
        boardState: nextState,
        moveCount: currentState.moveCount + 1,
        isSolved: _isGoal(nextState),
        heatMapValues: currentState.showHeuristicOverlay
            ? _calculateHeatmap(nextState)
            : null,
        canUndo: _moveHistory.canUndo,
        canRedo: _moveHistory.canRedo,
      ),
    );

    // Auto-save after redo
    _autoSave(nextState, currentState.moveCount + 1);
  }

  Future<void> _onStartAutoSolve(
    StartAutoSolve event,
    Emitter<PuzzleState> emit,
  ) async {
    final currentState = state;
    if (currentState is! PuzzleLoaded) return;
    if (currentState.isSolved) return;

    _stopTimer();
    emit(PuzzleSolving(boardState: currentState.boardState));

    try {
      final solutionPath = await runSolverInIsolate(currentState.boardState);

      emit(
        PuzzleSolved(
          solutionPath: solutionPath,
          currentStep: 0,
          secondsElapsed: _secondsElapsed,
        ),
      );
    } catch (e) {
      emit(PuzzleError(message: e.toString()));
    }
  }

  void _onToggleHeuristicOverlay(
    ToggleHeuristicOverlay event,
    Emitter<PuzzleState> emit,
  ) {
    final currentState = state;
    if (currentState is! PuzzleLoaded) return;

    final bool newOverlayState = !currentState.showHeuristicOverlay;

    emit(
      currentState.copyWith(
        showHeuristicOverlay: newOverlayState,
        heatMapValues: newOverlayState
            ? _calculateHeatmap(currentState.boardState)
            : null,
      ),
    );
  }

  void _onToggleShadowBoard(
    ToggleShadowBoard event,
    Emitter<PuzzleState> emit,
  ) {
    final currentState = state;
    if (currentState is! PuzzleLoaded) return;

    emit(currentState.copyWith(showShadowBoard: !currentState.showShadowBoard));
  }

  void _onAnimateSolutionStep(
    AnimateSolutionStep event,
    Emitter<PuzzleState> emit,
  ) {
    final currentState = state;
    if (currentState is! PuzzleSolved) return;

    final int nextStep = currentState.currentStep + 1;

    if (nextStep >= currentState.solutionPath.length) {
      // Animation complete - transition to PuzzleLoaded with solved state
      // Clear history since this was an auto-solve
      _moveHistory.clear();
      emit(
        PuzzleLoaded(
          boardState: currentState.solutionPath.last,
          moveCount: currentState.solutionPath.length - 1,
          isSolved: true,
          canUndo: false,
          canRedo: false,
          secondsElapsed: currentState.secondsElapsed,
        ),
      );
    } else {
      emit(currentState.copyWith(currentStep: nextStep));
    }
  }

  Future<void> _onShufflePuzzle(
    ShufflePuzzle event,
    Emitter<PuzzleState> emit,
  ) async {
    // Clear history when shuffling
    _moveHistory.clear();
    // Clear saved game when shuffling
    await _storageService.clearSave();

    final newPuzzle = _generateShuffledPuzzle();

    // Reset and start timer
    _secondsElapsed = 0;
    _startTimer();

    // Emit state immediately without optimal count
    emit(
      PuzzleLoaded(
        boardState: newPuzzle,
        moveCount: 0,
        isSolved: false,
        canUndo: false,
        canRedo: false,
        secondsElapsed: 0,
        moveLimit: state is PuzzleLoaded
            ? (state as PuzzleLoaded).moveLimit
            : null,
        difficulty: state is PuzzleLoaded
            ? (state as PuzzleLoaded).difficulty
            : null,
      ),
    );

    // Compute optimal move count in background
    try {
      final solutionPath = await runSolverInIsolate(newPuzzle);
      final optimalMoves =
          solutionPath.length - 1; // -1 because path includes start

      // Update state with optimal move count if still on same puzzle
      final currentState = state;
      if (currentState is PuzzleLoaded &&
          currentState.boardState.join(',') == newPuzzle.join(',')) {
        emit(currentState.copyWith(optimalMoveCount: optimalMoves));
      }
    } catch (_) {
      // Ignore errors - optimal count is optional
    }
  }

  void _onResumeSavedGame(ResumeSavedGame event, Emitter<PuzzleState> emit) {
    // Restore the move history from saved data
    _moveHistory.restoreFromSnapshot(
      undoStack: event.undoStack,
      redoStack: event.redoStack,
    );

    // Resume timer if not solved
    if (!_isGoal(event.boardState)) {
      _startTimer();
    }

    emit(
      PuzzleLoaded(
        boardState: event.boardState,
        moveCount: event.moveCount,
        isSolved: _isGoal(event.boardState),
        canUndo: _moveHistory.canUndo,
        canRedo: _moveHistory.canRedo,
        secondsElapsed: _secondsElapsed,
        moveLimit: event.moveLimit,
        difficulty: event.difficulty,
      ),
    );
  }

  /// Saves the current game state (non-blocking).
  void _autoSave(List<int> boardState, int moveCount) {
    _storageService.saveGame(
      boardState: boardState,
      moveCount: moveCount,
      undoStack: _moveHistory.undoStackSnapshot,
      redoStack: _moveHistory.redoStackSnapshot,
      secondsElapsed: _secondsElapsed,
      moveLimit: state is PuzzleLoaded
          ? (state as PuzzleLoaded).moveLimit
          : null,
      difficulty: state is PuzzleLoaded
          ? (state as PuzzleLoaded).difficulty
          : null,
    );
  }

  /// Checks if two positions are adjacent (horizontally or vertically).
  bool _isAdjacent(int pos1, int pos2) {
    final int row1 = pos1 ~/ 3;
    final int col1 = pos1 % 3;
    final int row2 = pos2 ~/ 3;
    final int col2 = pos2 % 3;

    return (row1 == row2 && (col1 - col2).abs() == 1) ||
        (col1 == col2 && (row1 - row2).abs() == 1);
  }

  bool _isGoal(List<int> state) {
    for (int i = 0; i < state.length; i++) {
      if (state[i] != goalState[i]) return false;
    }
    return true;
  }

  /// Calculates heatmap values for each tile position.
  /// Higher values (closer to 1.0) indicate tiles farther from goal.
  Map<int, double> _calculateHeatmap(List<int> boardState) {
    final Map<int, double> heatmap = {};

    // Maximum possible Manhattan distance for a single tile is 4 (corner to corner)
    const double maxDistance = 4.0;

    for (int position = 0; position < 9; position++) {
      final int tile = boardState[position];
      if (tile == 0) continue;

      // Calculate Manhattan distance for this tile
      final int currentRow = position ~/ 3;
      final int currentCol = position % 3;
      final int goalIndex = goalState.indexOf(tile);
      final int goalRow = goalIndex ~/ 3;
      final int goalCol = goalIndex % 3;

      final int distance =
          (currentRow - goalRow).abs() + (currentCol - goalCol).abs();

      // Normalize to 0.0 - 1.0 range
      heatmap[position] = distance / maxDistance;
    }

    return heatmap;
  }

  /// Generates a random solvable puzzle by shuffling and validating.
  List<int> _generateShuffledPuzzle() {
    final random = Random();
    List<int> puzzle;

    do {
      puzzle = List<int>.from(goalState);
      puzzle.shuffle(random);
    } while (!_isSolvable(puzzle) || _isGoal(puzzle));

    return puzzle;
  }

  bool _isSolvable(List<int> state) {
    try {
      PuzzleUtils.isSolvable(state);
      return true;
    } catch (_) {
      return false;
    }
  }
}
