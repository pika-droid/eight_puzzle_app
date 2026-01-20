import 'package:flutter/material.dart';

import '../../domain/logic/efficiency_calculator.dart';

/// Dialog displayed when the puzzle is solved.
///
/// Shows: Player moves, optimal moves, grade, and efficiency.
class VictoryDialog extends StatelessWidget {
  final int playerMoves;
  final int? optimalMoves;
  final int secondsElapsed;
  final VoidCallback onPlayAgain;

  const VictoryDialog({
    super.key,
    required this.playerMoves,
    this.optimalMoves,
    required this.secondsElapsed,
    required this.onPlayAgain,
  });

  @override
  Widget build(BuildContext context) {
    final String grade = optimalMoves != null
        ? EfficiencyCalculator.getGrade(playerMoves, optimalMoves!)
        : 'S';
    final String description = EfficiencyCalculator.getGradeDescription(grade);
    final double efficiency = optimalMoves != null
        ? EfficiencyCalculator.getEfficiencyPercent(playerMoves, optimalMoves!)
        : 100.0;
    final Color gradeColor = Color(
      EfficiencyCalculator.getGradeColorValue(grade),
    );

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.celebration, color: Colors.amber, size: 28),
          SizedBox(width: 8),
          Flexible(child: Text('🎉 Puzzle Solved!')),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Grade badge
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: gradeColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: gradeColor, width: 4),
            ),
            child: Center(
              child: Text(
                grade,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: gradeColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Grade description
          Text(
            description,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Stats
          _buildStatRow(
            context,
            icon: Icons.touch_app,
            label: 'Your Moves',
            value: playerMoves.toString(),
          ),
          const SizedBox(height: 8),
          _buildStatRow(
            context,
            icon: Icons.timer,
            label: 'Time',
            value: _formatTime(secondsElapsed),
          ),
          const SizedBox(height: 8),
          if (optimalMoves != null) ...[
            _buildStatRow(
              context,
              icon: Icons.star,
              label: 'Optimal Moves',
              value: optimalMoves.toString(),
            ),
            const SizedBox(height: 8),
            _buildStatRow(
              context,
              icon: Icons.speed,
              label: 'Efficiency',
              value: '${efficiency.toStringAsFixed(0)}%',
            ),
          ],
        ],
      ),
      actions: [
        FilledButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
            onPlayAgain();
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Play Again'),
        ),
      ],
    );
  }

  String _formatTime(int seconds) {
    final int m = seconds ~/ 60;
    final int s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Widget _buildStatRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ],
    );
  }
}
