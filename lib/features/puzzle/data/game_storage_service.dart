import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Service for persisting game state using shared_preferences.
///
/// Saves and loads the complete game state including:
/// - Board state
/// - Move count
/// - Undo/redo history stacks
class GameStorageService {
  static const String _keyBoardState = 'puzzle_board_state';
  static const String _keyMoveCount = 'puzzle_move_count';
  static const String _keySecondsElapsed = 'puzzle_seconds_elapsed';
  static const String _keyUndoStack = 'puzzle_undo_stack';
  static const String _keyRedoStack = 'puzzle_redo_stack';
  static const String _keySavedAt = 'puzzle_saved_at';

  // Best score keys
  static const String _keyBestMoves = 'puzzle_best_moves';
  static const String _keyBestTime = 'puzzle_best_time';

  /// Checks if a saved game exists.
  Future<bool> hasSavedGame() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_keyBoardState);
  }

  /// Saves the current game state.
  Future<void> saveGame({
    required List<int> boardState,
    required int moveCount,
    required int secondsElapsed,
    required List<List<int>> undoStack,
    required List<List<int>> redoStack,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_keyBoardState, jsonEncode(boardState));
    await prefs.setInt(_keyMoveCount, moveCount);
    await prefs.setInt(_keySecondsElapsed, secondsElapsed);
    await prefs.setString(_keyUndoStack, _encodeStackList(undoStack));
    await prefs.setString(_keyRedoStack, _encodeStackList(redoStack));
    await prefs.setString(_keySavedAt, DateTime.now().toIso8601String());
  }

  /// Loads a saved game state.
  ///
  /// Returns null if no saved game exists.
  Future<SavedGameState?> loadGame() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey(_keyBoardState)) {
      return null;
    }

    try {
      final boardStateJson = prefs.getString(_keyBoardState);
      final moveCount = prefs.getInt(_keyMoveCount) ?? 0;
      final secondsElapsed = prefs.getInt(_keySecondsElapsed) ?? 0;
      final undoStackJson = prefs.getString(_keyUndoStack);
      final redoStackJson = prefs.getString(_keyRedoStack);
      final savedAtString = prefs.getString(_keySavedAt);

      if (boardStateJson == null) return null;

      final boardState = List<int>.from(jsonDecode(boardStateJson));
      final undoStack = _decodeStackList(undoStackJson);
      final redoStack = _decodeStackList(redoStackJson);
      final savedAt = savedAtString != null
          ? DateTime.tryParse(savedAtString)
          : null;

      return SavedGameState(
        boardState: boardState,
        moveCount: moveCount,
        secondsElapsed: secondsElapsed,
        undoStack: undoStack,
        redoStack: redoStack,
        savedAt: savedAt,
      );
    } catch (e) {
      // If decoding fails, clear the corrupted data
      await clearSave();
      return null;
    }
  }

  /// Clears the saved game.
  Future<void> clearSave() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyBoardState);
    await prefs.remove(_keyMoveCount);
    await prefs.remove(_keySecondsElapsed);
    await prefs.remove(_keyUndoStack);
    await prefs.remove(_keyRedoStack);
    await prefs.remove(_keySavedAt);
  }

  /// Encodes a list of board states to JSON string.
  String _encodeStackList(List<List<int>> stack) {
    return jsonEncode(stack);
  }

  /// Decodes a JSON string to a list of board states.
  List<List<int>> _decodeStackList(String? json) {
    if (json == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(json);
      return decoded.map((e) => List<int>.from(e)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Saves the best score if the new score is better.
  ///
  /// Updates if:
  /// - No previous best score exists
  /// - New moves < best moves
  /// - New moves == best moves AND new time < best time
  Future<void> saveBestScore(int moves, int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    final currentBestMoves = prefs.getInt(_keyBestMoves);
    final currentBestTime = prefs.getInt(_keyBestTime);

    bool shouldUpdate = false;

    if (currentBestMoves == null) {
      shouldUpdate = true;
    } else if (moves < currentBestMoves) {
      shouldUpdate = true;
    } else if (moves == currentBestMoves &&
        seconds < (currentBestTime ?? double.infinity)) {
      shouldUpdate = true;
    }

    if (shouldUpdate) {
      await prefs.setInt(_keyBestMoves, moves);
      await prefs.setInt(_keyBestTime, seconds);
    }
  }

  /// Gets the current best score.
  Future<BestScore?> getBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    final moves = prefs.getInt(_keyBestMoves);
    final time = prefs.getInt(_keyBestTime);

    if (moves == null || time == null) return null;

    return BestScore(moves: moves, seconds: time);
  }
}

/// Data class holding a saved game state.
class SavedGameState {
  final List<int> boardState;
  final int moveCount;
  final int secondsElapsed;
  final List<List<int>> undoStack;
  final List<List<int>> redoStack;
  final DateTime? savedAt;

  const SavedGameState({
    required this.boardState,
    required this.moveCount,
    required this.secondsElapsed,
    required this.undoStack,
    required this.redoStack,
    this.savedAt,
  });
}

class BestScore {
  final int moves;
  final int seconds;

  const BestScore({required this.moves, required this.seconds});
}
