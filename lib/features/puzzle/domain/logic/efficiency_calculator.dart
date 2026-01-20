/// Utility class for calculating efficiency ratings.
///
/// Compares player's move count to optimal solution and assigns a grade.
class EfficiencyCalculator {
  /// Grading thresholds:
  /// - S: Moves <= Optimal
  /// - A: Moves <= Optimal × 1.5
  /// - B: Moves <= Optimal × 2.0
  /// - C: Moves > Optimal × 2.0
  static String getGrade(int playerMoves, int optimalMoves) {
    if (optimalMoves <= 0) return 'S'; // Already solved or edge case

    final double ratio = playerMoves / optimalMoves;

    if (ratio <= 1.0) return 'S';
    if (ratio <= 1.5) return 'A';
    if (ratio <= 2.0) return 'B';
    return 'C';
  }

  /// Gets the efficiency percentage (100% = optimal, higher = worse).
  static double getEfficiencyPercent(int playerMoves, int optimalMoves) {
    if (optimalMoves <= 0) return 100.0;
    if (playerMoves <= optimalMoves) return 100.0;

    // Calculate as inverse ratio (how close to optimal)
    return (optimalMoves / playerMoves) * 100;
  }

  /// Gets a description for the grade.
  static String getGradeDescription(String grade) {
    switch (grade) {
      case 'S':
        return 'Perfect! Optimal solution!';
      case 'A':
        return 'Excellent! Very efficient!';
      case 'B':
        return 'Good job! Room for improvement.';
      case 'C':
        return 'Keep practicing!';
      default:
        return '';
    }
  }

  /// Gets the color for a grade.
  static int getGradeColorValue(String grade) {
    switch (grade) {
      case 'S':
        return 0xFFFFD700; // Gold
      case 'A':
        return 0xFF4CAF50; // Green
      case 'B':
        return 0xFF2196F3; // Blue
      case 'C':
        return 0xFFFF9800; // Orange
      default:
        return 0xFF9E9E9E; // Grey
    }
  }
}
