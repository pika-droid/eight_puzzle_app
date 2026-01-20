import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Service for persisting game state using shared_preferences.
///
/// Saves and loads the complete game state including:
/// - Board state
/// - Move count
/// - Undo/redo history stacks
class GameStorageService {
  static const String _keyGameState = 'puzzle_game_state_v1';

  // Best score keys
  static const String _keyBestMoves = 'puzzle_best_moves';
  static const String _keyBestTime = 'puzzle_best_time';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _sharedPrefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Checks if a saved game exists.
  Future<bool> hasSavedGame() async {
    final prefs = await _sharedPrefs;
    return prefs.containsKey(_keyGameState);
  }

  /// Saves the current game state.
  Future<void> saveGame({
    required List<int> boardState,
    required int moveCount,
    required int secondsElapsed,
    required List<List<int>> undoStack,
    required List<List<int>> redoStack,
    int? moveLimit,
    String? difficulty,
  }) async {
    final prefs = await _sharedPrefs;

    final Map<String, dynamic> data = {
      'boardState': boardState,
      'moveCount': moveCount,
      'secondsElapsed': secondsElapsed,
      'undoStack': undoStack,
      'redoStack': redoStack,
      'savedAt': DateTime.now().toIso8601String(),
      'moveLimit': moveLimit,
      'difficulty': difficulty,
    };

    await prefs.setString(_keyGameState, jsonEncode(data));
  }

  /// Loads a saved game state.
  ///
  /// Returns null if no saved game exists.
  Future<SavedGameState?> loadGame() async {
    final prefs = await _sharedPrefs;

    if (!prefs.containsKey(_keyGameState)) {
      return null;
    }

    try {
      final String? jsonString = prefs.getString(_keyGameState);
      if (jsonString == null) return null;

      final Map<String, dynamic> data = jsonDecode(jsonString);

      final boardState = List<int>.from(data['boardState']);
      final moveCount = data['moveCount'] as int;
      final secondsElapsed = (data['secondsElapsed'] as int?) ?? 0;

      final undoStack = (data['undoStack'] as List)
          .map((e) => List<int>.from(e))
          .toList();

      final redoStack = (data['redoStack'] as List)
          .map((e) => List<int>.from(e))
          .toList();

      final savedAtString = data['savedAt'] as String?;
      final savedAt = savedAtString != null
          ? DateTime.tryParse(savedAtString)
          : null;

      final moveLimit = data['moveLimit'] as int?;
      final difficulty = data['difficulty'] as String?;

      return SavedGameState(
        boardState: boardState,
        moveCount: moveCount,
        secondsElapsed: secondsElapsed,
        undoStack: undoStack,
        redoStack: redoStack,
        savedAt: savedAt,
        moveLimit: moveLimit,
        difficulty: difficulty,
      );
    } catch (e) {
      // If decoding fails, clear the corrupted data
      await clearSave();
      return null;
    }
  }

  /// Clears the saved game.
  Future<void> clearSave() async {
    final prefs = await _sharedPrefs;
    await prefs.remove(_keyGameState);
  }

  /// Saves the best score if the new score is better.
  ///
  /// Updates if:
  /// - No previous best score exists
  /// - New moves < best moves
  /// - New moves == best moves AND new time < best time
  Future<void> saveBestScore(int moves, int seconds) async {
    final prefs = await _sharedPrefs;
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
      // Best score is separate from game state, so we save these individually
      // or we could bundle them too, but they are global app lifecycle
      // whereas game state is session specific. Keeping them separate is fine.
      await prefs.setInt(_keyBestMoves, moves);
      await prefs.setInt(_keyBestTime, seconds);
    }
  }

  /// Gets the current best score.
  Future<BestScore?> getBestScore() async {
    final prefs = await _sharedPrefs;
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
  final int? moveLimit;
  final String? difficulty;

  const SavedGameState({
    required this.boardState,
    required this.moveCount,
    required this.secondsElapsed,
    required this.undoStack,
    required this.redoStack,
    this.savedAt,
    this.moveLimit,
    this.difficulty,
  });
}

class BestScore {
  final int moves;
  final int seconds;

  const BestScore({required this.moves, required this.seconds});
}
