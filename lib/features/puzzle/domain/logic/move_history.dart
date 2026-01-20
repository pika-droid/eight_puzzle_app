/// Stack-based history system for undo/redo functionality.
///
/// Maintains two stacks:
/// - [_undoStack]: Previous board states that can be undone to
/// - [_redoStack]: States that were undone and can be redone
class MoveHistory {
  final List<List<int>> _undoStack = [];
  final List<List<int>> _redoStack = [];

  /// Maximum history size to prevent memory issues.
  static const int maxHistorySize = 1000;

  /// Whether there are moves that can be undone.
  bool get canUndo => _undoStack.isNotEmpty;

  /// Whether there are moves that can be redone.
  bool get canRedo => _redoStack.isNotEmpty;

  /// Number of states in undo history.
  int get undoCount => _undoStack.length;

  /// Number of states in redo history.
  int get redoCount => _redoStack.length;

  /// Records a state before a move is made.
  ///
  /// This should be called BEFORE the move is executed.
  /// Clears the redo stack (standard undo/redo behavior).
  void recordMove(List<int> previousState) {
    _undoStack.add(List<int>.from(previousState));
    _redoStack.clear();

    // Prevent memory issues with very long games
    if (_undoStack.length > maxHistorySize) {
      _undoStack.removeAt(0);
    }
  }

  /// Undoes the last move and returns the previous state.
  ///
  /// [currentState] is the current board state before undo.
  /// Returns the state to restore, or null if nothing to undo.
  List<int>? undo(List<int> currentState) {
    if (!canUndo) return null;

    // Save current state to redo stack
    _redoStack.add(List<int>.from(currentState));

    // Pop and return the previous state
    return _undoStack.removeLast();
  }

  /// Redoes the last undone move.
  ///
  /// [currentState] is the current board state before redo.
  /// Returns the state to restore, or null if nothing to redo.
  List<int>? redo(List<int> currentState) {
    if (!canRedo) return null;

    // Save current state to undo stack
    _undoStack.add(List<int>.from(currentState));

    // Pop and return the redo state
    return _redoStack.removeLast();
  }

  /// Clears all history.
  void clear() {
    _undoStack.clear();
    _redoStack.clear();
  }

  /// Gets the undo stack as an unmodifiable list (for persistence).
  List<List<int>> get undoStackSnapshot =>
      _undoStack.map((s) => List<int>.from(s)).toList();

  /// Gets the redo stack as an unmodifiable list (for persistence).
  List<List<int>> get redoStackSnapshot =>
      _redoStack.map((s) => List<int>.from(s)).toList();

  /// Restores history from saved data (for persistence).
  void restoreFromSnapshot({
    required List<List<int>> undoStack,
    required List<List<int>> redoStack,
  }) {
    _undoStack.clear();
    _redoStack.clear();
    _undoStack.addAll(undoStack.map((s) => List<int>.from(s)));
    _redoStack.addAll(redoStack.map((s) => List<int>.from(s)));
  }
}
