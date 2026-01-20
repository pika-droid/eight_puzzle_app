import 'package:flutter/material.dart';

import '../../domain/logic/tile_heuristic_calculator.dart';

/// Dialog content that displays the heuristic report for a tile.
class HeuristicReportContent extends StatelessWidget {
  final TileHeuristicReport report;

  const HeuristicReportContent({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 300),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getTileColor(report),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white54, width: 2),
                ),
                child: Center(
                  child: Text(
                    report.tile.toString(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tile Inspector',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      report.isCorrectPosition
                          ? '✓ In correct position'
                          : '✗ Misplaced',
                      style: TextStyle(
                        color: report.isCorrectPosition
                            ? Colors.greenAccent
                            : Colors.orangeAccent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          const Divider(color: Colors.white24),
          const SizedBox(height: 16),

          // Position info
          _buildInfoRow(
            context,
            icon: Icons.location_on,
            label: 'Current Position',
            value: '(${report.currentRow}, ${report.currentCol})',
            textColor: textColor,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            context,
            icon: Icons.flag,
            label: 'Target Position',
            value: '(${report.targetRow}, ${report.targetCol})',
            textColor: textColor,
            valueColor: Colors.cyanAccent,
          ),

          const SizedBox(height: 24),
          const Divider(color: Colors.white24),
          const SizedBox(height: 16),

          // Heuristic values
          Text(
            'Heuristic Analysis',
            style: theme.textTheme.titleMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          _buildHeuristicRow(
            context,
            label: 'Manhattan Distance',
            value: '${report.manhattanDistance}',
            detail:
                '(↕${report.verticalDistance} + ↔${report.horizontalDistance})',
            textColor: textColor,
          ),
          const SizedBox(height: 8),
          _buildHeuristicRow(
            context,
            label: 'Linear Conflict',
            value: report.hasLinearConflict ? 'Yes (+2 moves)' : 'No',
            valueColor: report.hasLinearConflict
                ? Colors.redAccent
                : Colors.greenAccent,
            textColor: textColor,
          ),
          const SizedBox(height: 8),
          _buildHeuristicRow(
            context,
            label: 'Hamming Score',
            value: report.hammingScore.toString(),
            detail: report.hammingScore == 1 ? '(Misplaced)' : '(Correct)',
            textColor: textColor,
          ),

          const SizedBox(height: 24),

          // Close button
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: Text('Close', style: TextStyle(color: textColor)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color textColor,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.white70),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: textColor.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? textColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildHeuristicRow(
    BuildContext context, {
    required String label,
    required String value,
    String? detail,
    required Color textColor,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: textColor.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? textColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        if (detail != null) ...[
          const SizedBox(width: 8),
          Text(
            detail,
            style: TextStyle(
              color: textColor.withValues(alpha: 0.5),
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  Color _getTileColor(TileHeuristicReport report) {
    if (report.isCorrectPosition) {
      return Colors.green.withValues(alpha: 0.3);
    } else if (report.hasLinearConflict) {
      return Colors.red.withValues(alpha: 0.3);
    } else {
      return Colors.orange.withValues(alpha: 0.3);
    }
  }
}
