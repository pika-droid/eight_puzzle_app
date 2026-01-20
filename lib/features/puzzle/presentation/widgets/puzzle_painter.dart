import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Custom painter for the 8-puzzle board.
///
/// Draws tile images at correct grid positions with optional heatmap overlay.
class PuzzlePainter extends CustomPainter {
  /// Current board state (0-8, where 0 is the empty tile).
  final List<int> boardState;

  /// Sliced tile images (index 0-8 corresponds to tile numbers 0-8).
  /// Index 0 is the empty tile image (usually not drawn).
  final List<ui.Image>? tileImages;

  /// Optional heatmap values for each position (0.0 to 1.0).
  /// Key is the board position (0-8), value is the heat intensity.
  final Map<int, double>? heatMapValues;

  /// Size of each tile in pixels.
  final double tileSize;

  /// Optional position to highlight with a ghost tile (for Inspector Mode).
  /// This shows where the inspected tile should be in the goal state.
  final int? ghostTilePosition;

  /// The tile number to show as a ghost (for labeling).
  final int? ghostTileNumber;

  /// Whether to show the shadow board (goal state) as an overlay.
  final bool showShadowBoard;

  /// Goal state for shadow board display.
  static const List<int> goalState = [1, 2, 3, 4, 5, 6, 7, 8, 0];

  PuzzlePainter({
    required this.boardState,
    this.tileImages,
    this.heatMapValues,
    required this.tileSize,
    this.ghostTilePosition,
    this.ghostTileNumber,
    this.showShadowBoard = false,
  });

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final double gridSize = tileSize * 3;

    // Draw shadow board (goal state) first if enabled
    if (showShadowBoard) {
      _drawShadowBoard(canvas);
    }

    // Draw tiles
    for (int position = 0; position < 9; position++) {
      final int tile = boardState[position];
      final int row = position ~/ 3;
      final int col = position % 3;
      final double x = col * tileSize;
      final double y = row * tileSize;

      final ui.Rect tileRect = ui.Rect.fromLTWH(x, y, tileSize, tileSize);

      if (tile != 0) {
        // Draw tile image
        if (tileImages != null && tile < tileImages!.length) {
          final ui.Image tileImage = tileImages![tile];
          canvas.drawImageRect(
            tileImage,
            ui.Rect.fromLTWH(
              0,
              0,
              tileImage.width.toDouble(),
              tileImage.height.toDouble(),
            ),
            tileRect,
            Paint(),
          );
        } else {
          // Fallback: Draw numbered tile
          _drawNumberedTile(canvas, tileRect, tile);
        }

        // Draw heatmap overlay if provided
        if (heatMapValues != null && heatMapValues!.containsKey(position)) {
          _drawHeatmapOverlay(canvas, tileRect, heatMapValues![position]!);
        }
      } else {
        // Draw empty tile background
        final paint = Paint()..color = Colors.grey.shade300;
        canvas.drawRect(tileRect, paint);
      }
    }

    // Draw grid lines
    _drawGridLines(canvas, gridSize);

    // Draw border
    _drawBorder(canvas, gridSize);

    // Draw ghost tile overlay for Inspector Mode
    _drawGhostTile(canvas);
  }

  /// Draws the goal state as a semi-transparent overlay.
  void _drawShadowBoard(ui.Canvas canvas) {
    for (int position = 0; position < 9; position++) {
      final int goalTile = goalState[position];
      if (goalTile == 0) continue; // Don't draw the empty tile

      final int row = position ~/ 3;
      final int col = position % 3;
      final double x = col * tileSize;
      final double y = row * tileSize;

      // Draw shadow number at 20% opacity
      final textPainter = TextPainter(
        text: TextSpan(
          text: goalTile.toString(),
          style: TextStyle(
            color: Colors.indigo.withValues(alpha: 0.15),
            fontSize: tileSize * 0.5,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          x + (tileSize - textPainter.width) / 2,
          y + (tileSize - textPainter.height) / 2,
        ),
      );
    }
  }

  void _drawNumberedTile(ui.Canvas canvas, ui.Rect rect, int number) {
    // Background
    final bgPaint = Paint()..color = Colors.blueGrey.shade100;
    canvas.drawRect(rect, bgPaint);

    // Number text
    final textPainter = TextPainter(
      text: TextSpan(
        text: number.toString(),
        style: TextStyle(
          color: Colors.black87,
          fontSize: tileSize * 0.4,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        rect.left + (rect.width - textPainter.width) / 2,
        rect.top + (rect.height - textPainter.height) / 2,
      ),
    );
  }

  void _drawHeatmapOverlay(ui.Canvas canvas, ui.Rect rect, double intensity) {
    // Clamp intensity to [0.0, 1.0]
    final double clampedIntensity = intensity.clamp(0.0, 1.0);

    // Red (high cost) to Green (low cost) gradient
    // intensity 0.0 = Green (good), 1.0 = Red (bad)
    final Color overlayColor = Color.lerp(
      Colors.green,
      Colors.red,
      clampedIntensity,
    )!;

    final paint = Paint()
      ..color = overlayColor.withValues(alpha: 0.3)
      ..blendMode = BlendMode.srcOver;

    canvas.drawRect(rect, paint);
  }

  void _drawGridLines(ui.Canvas canvas, double gridSize) {
    final paint = Paint()
      ..color = Colors.black54
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Vertical lines
    for (int i = 1; i < 3; i++) {
      final double x = i * tileSize;
      canvas.drawLine(Offset(x, 0), Offset(x, gridSize), paint);
    }

    // Horizontal lines
    for (int i = 1; i < 3; i++) {
      final double y = i * tileSize;
      canvas.drawLine(Offset(0, y), Offset(gridSize, y), paint);
    }
  }

  void _drawBorder(ui.Canvas canvas, double gridSize) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    canvas.drawRect(ui.Rect.fromLTWH(0, 0, gridSize, gridSize), paint);
  }

  void _drawGhostTile(ui.Canvas canvas) {
    if (ghostTilePosition == null) return;

    final int row = ghostTilePosition! ~/ 3;
    final int col = ghostTilePosition! % 3;
    final double x = col * tileSize;
    final double y = row * tileSize;

    final ui.Rect tileRect = ui.Rect.fromLTWH(x, y, tileSize, tileSize);

    // Draw semi-transparent cyan overlay
    final paint = Paint()
      ..color = Colors.cyan.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;
    canvas.drawRect(tileRect, paint);

    // Draw dashed border
    final borderPaint = Paint()
      ..color = Colors.cyanAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawRect(tileRect, borderPaint);

    // Draw ghost tile number if provided
    if (ghostTileNumber != null && ghostTileNumber != 0) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: ghostTileNumber.toString(),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: tileSize * 0.3,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          x + (tileSize - textPainter.width) / 2,
          y + (tileSize - textPainter.height) / 2,
        ),
      );
    }

    // Draw "TARGET" label
    final labelPainter = TextPainter(
      text: TextSpan(
        text: 'TARGET',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.8),
          fontSize: tileSize * 0.12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    labelPainter.layout();
    labelPainter.paint(
      canvas,
      Offset(
        x + (tileSize - labelPainter.width) / 2,
        y + tileSize - labelPainter.height - 8,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant PuzzlePainter oldDelegate) {
    return oldDelegate.boardState != boardState ||
        oldDelegate.tileImages != tileImages ||
        oldDelegate.heatMapValues != heatMapValues ||
        oldDelegate.tileSize != tileSize ||
        oldDelegate.ghostTilePosition != ghostTilePosition ||
        oldDelegate.ghostTileNumber != ghostTileNumber ||
        oldDelegate.showShadowBoard != showShadowBoard;
  }
}
