import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'puzzle_painter.dart';

/// Widget that displays the puzzle board with tap and long-press interaction.
///
/// Wrapped in a RepaintBoundary for optimization.
class PuzzleBoardWidget extends StatelessWidget {
  final List<int> boardState;
  final List<ui.Image>? tileImages;
  final Map<int, double>? heatMapValues;
  final double size;
  final void Function(int position)? onTileTap;
  final void Function(int position)? onTileLongPress;

  /// Position to highlight with a ghost tile (for Inspector Mode).
  final int? ghostTilePosition;

  /// Tile number to show on the ghost tile.
  final int? ghostTileNumber;

  /// Whether to show the shadow board (goal state overlay).
  final bool showShadowBoard;

  const PuzzleBoardWidget({
    super.key,
    required this.boardState,
    this.tileImages,
    this.heatMapValues,
    required this.size,
    this.onTileTap,
    this.onTileLongPress,
    this.ghostTilePosition,
    this.ghostTileNumber,
    this.showShadowBoard = false,
  });

  @override
  Widget build(BuildContext context) {
    final double tileSize = size / 3;

    return RepaintBoundary(
      child: GestureDetector(
        onTapUp: (details) {
          if (onTileTap == null) return;

          final int position = _getPositionFromOffset(
            details.localPosition,
            tileSize,
          );
          onTileTap!(position);
        },
        onLongPressStart: (details) {
          if (onTileLongPress == null) return;

          final int position = _getPositionFromOffset(
            details.localPosition,
            tileSize,
          );
          // Don't inspect the empty tile
          if (boardState[position] == 0) return;
          onTileLongPress!(position);
        },
        child: CustomPaint(
          size: Size(size, size),
          painter: PuzzlePainter(
            boardState: boardState,
            tileImages: tileImages,
            heatMapValues: heatMapValues,
            tileSize: tileSize,
            ghostTilePosition: ghostTilePosition,
            ghostTileNumber: ghostTileNumber,
            showShadowBoard: showShadowBoard,
          ),
        ),
      ),
    );
  }

  int _getPositionFromOffset(Offset localPosition, double tileSize) {
    final int col = (localPosition.dx / tileSize).floor().clamp(0, 2);
    final int row = (localPosition.dy / tileSize).floor().clamp(0, 2);
    return row * 3 + col;
  }
}
