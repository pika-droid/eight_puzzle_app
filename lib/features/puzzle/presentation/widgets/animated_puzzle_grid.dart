import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_bloc.dart';
import 'glass_tile.dart';

/// An animated puzzle grid with smooth tile transitions.
class AnimatedPuzzleGrid extends StatelessWidget {
  final List<int> boardState;
  final double size;
  final Map<int, double>? heatMapValues;
  final bool showShadowBoard;
  final int? highlightedPosition;
  final void Function(int position)? onTileTap;
  final void Function(int position)? onTileLongPress;

  static const List<int> goalState = [1, 2, 3, 4, 5, 6, 7, 8, 0];

  const AnimatedPuzzleGrid({
    super.key,
    required this.boardState,
    required this.size,
    this.heatMapValues,
    this.showShadowBoard = false,
    this.highlightedPosition,
    this.onTileTap,
    this.onTileLongPress,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate tile size accounting for padding and gaps between tiles
    const double padding = 8.0;
    const double gap = 6.0;
    final double tileSize = (size - (padding * 2) - (gap * 2)) / 3;

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        final theme = state.theme;
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.accentColor.withValues(alpha: 0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.tileColor.withValues(alpha: 0.2),
                blurRadius: 30,
                spreadRadius: -10,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(padding),
              child: Stack(
                children: [
                  // Shadow board (goal state overlay)
                  if (showShadowBoard) _buildShadowBoard(tileSize, gap),

                  // Animated tiles
                  ..._buildAnimatedTiles(tileSize, gap, theme),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShadowBoard(double tileSize, double gap) {
    return Positioned.fill(
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: gap,
          mainAxisSpacing: gap,
        ),
        itemCount: 9,
        itemBuilder: (context, index) {
          final goalTile = goalState[index];
          if (goalTile == 0) return const SizedBox();

          return Center(
            child: Text(
              goalTile.toString(),
              style: GoogleFonts.pressStart2p(
                fontSize: tileSize * 0.4,
                fontWeight: FontWeight.bold,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildAnimatedTiles(
    double tileSize,
    double gap,
    AppTheme theme,
  ) {
    final List<Widget> tiles = [];

    for (int i = 0; i < 9; i++) {
      final tile = boardState[i];
      final row = i ~/ 3;
      final col = i % 3;

      if (tile == 0) continue;

      // Calculate position using consistent spacing
      final double left = col * (tileSize + gap);
      final double top = row * (tileSize + gap);

      tiles.add(
        AnimatedPositioned(
          key: ValueKey('tile_$tile'),
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          left: left,
          top: top,
          child: GlassTile(
            number: tile,
            size: tileSize,
            isHighlighted: highlightedPosition == i,
            heatValue: heatMapValues?[i],
            onTap: tile != 0 && onTileTap != null ? () => onTileTap!(i) : null,
            onLongPress: tile != 0 && onTileLongPress != null
                ? () => onTileLongPress!(i)
                : null,
            onSwipe: tile != 0 && onTileTap != null
                ? (direction) => _handleSwipe(i, direction)
                : null,
            baseColor: theme.tileColor,
            accentColor: theme.accentColor,
            heatColorStart: theme.tileHeatColorStart,
            heatColorEnd: theme.tileHeatColorEnd,
          ),
        ),
      );
    }

    return tiles;
  }

  void _handleSwipe(int index, TileSwipeDirection direction) {
    if (onTileTap == null) return;

    final int targetIndex;
    switch (direction) {
      case TileSwipeDirection.up:
        targetIndex = index - 3;
        break;
      case TileSwipeDirection.down:
        targetIndex = index + 3;
        break;
      case TileSwipeDirection.left:
        if (index % 3 == 0) return; // Left edge
        targetIndex = index - 1;
        break;
      case TileSwipeDirection.right:
        if (index % 3 == 2) return; // Right edge
        targetIndex = index + 1;
        break;
    }

    if (targetIndex >= 0 && targetIndex < 9) {
      if (boardState[targetIndex] == 0) {
        onTileTap!(index);
      }
    }
  }
}
