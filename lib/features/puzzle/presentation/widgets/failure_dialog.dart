import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'glass_dialog.dart';
import 'retro_button.dart';

/// Dialog displayed when the puzzle fails (move budget exceeded).
class FailureDialog extends StatelessWidget {
  final int moveCount;
  final int secondsElapsed;
  final VoidCallback onTryAgain;
  final VoidCallback onBackToMenu;

  const FailureDialog({
    super.key,
    required this.moveCount,
    required this.secondsElapsed,
    required this.onTryAgain,
    required this.onBackToMenu,
  });

  @override
  Widget build(BuildContext context) {
    return GlassDialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.redAccent,
                size: 28,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'OUT OF MOVES!',
                  style: AppTheme.retroTextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Failure icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.redAccent, width: 4),
            ),
            child: const Center(
              child: Icon(Icons.close, size: 50, color: Colors.redAccent),
            ),
          ),
          const SizedBox(height: 16),

          // Failure message
          Text(
            'You ran out of moves!',
            style: AppTheme.retroTextStyle(fontSize: 12, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Stats
          _buildStatRow(
            context,
            icon: Icons.touch_app,
            label: 'Moves Used',
            value: moveCount.toString(),
          ),
          const SizedBox(height: 8),
          _buildStatRow(
            context,
            icon: Icons.timer,
            label: 'Time',
            value: _formatTime(secondsElapsed),
          ),

          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: RetroButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onBackToMenu();
                  },
                  icon: const Icon(Icons.home),
                  label: 'MENU',
                  baseColor: Colors.grey,
                  isSmall: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: RetroButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onTryAgain();
                  },
                  icon: const Icon(Icons.refresh),
                  label: 'TRY AGAIN',
                  baseColor: Theme.of(context).colorScheme.primary,
                  isSmall: true,
                ),
              ),
            ],
          ),
        ],
      ),
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
            Text(
              label,
              style: AppTheme.retroTextStyle(
                fontSize: 10,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: AppTheme.retroTextStyle(fontSize: 14, color: Colors.white),
        ),
      ],
    );
  }
}
