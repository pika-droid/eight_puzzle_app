import 'dart:ui';

import 'package:flutter/material.dart';

/// A glassmorphic styled puzzle tile with blur and glow effects.
enum TileSwipeDirection { up, down, left, right }

/// A glassmorphic styled puzzle tile with blur and glow effects.
class GlassTile extends StatelessWidget {
  final int number;
  final double size;
  final bool isHighlighted;
  final double? heatValue; // 0.0 (green) to 1.0 (red)
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final void Function(TileSwipeDirection)? onSwipe;
  final Color? baseColor;
  final Color? accentColor;
  final Color? heatColorStart;
  final Color? heatColorEnd;

  const GlassTile({
    super.key,
    required this.number,
    required this.size,
    this.isHighlighted = false,
    this.heatValue,
    this.onTap,
    this.onLongPress,
    this.onSwipe,
    this.baseColor,
    this.accentColor,
    this.heatColorStart,
    this.heatColorEnd,
  });

  @override
  Widget build(BuildContext context) {
    if (number == 0) {
      // Empty tile - show subtle dotted border
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 2,
          ),
        ),
      );
    }

    // Get heat color if applicable
    Color? heatColor;
    if (heatValue != null) {
      heatColor = Color.lerp(
        heatColorStart ?? const Color(0xFF10B981), // Green
        heatColorEnd ?? const Color(0xFFEF4444), // Red
        heatValue!,
      );
    }

    final effectiveBaseColor =
        heatColor ?? baseColor ?? const Color(0xFF6366F1);
    final effectiveAccentColor = accentColor ?? const Color(0xFFF472B6);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      onHorizontalDragEnd: (details) {
        if (onSwipe == null) return;
        if (details.primaryVelocity! > 0) {
          onSwipe!(TileSwipeDirection.right);
        } else if (details.primaryVelocity! < 0) {
          onSwipe!(TileSwipeDirection.left);
        }
      },
      onVerticalDragEnd: (details) {
        if (onSwipe == null) return;
        if (details.primaryVelocity! > 0) {
          onSwipe!(TileSwipeDirection.down);
        } else if (details.primaryVelocity! < 0) {
          onSwipe!(TileSwipeDirection.up);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    effectiveBaseColor.withValues(alpha: 0.4),
                    effectiveBaseColor.withValues(alpha: 0.2),
                  ],
                ),
                border: Border.all(
                  color: isHighlighted
                      ? effectiveAccentColor
                      : Colors.white.withValues(alpha: 0.2),
                  width: isHighlighted ? 3 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: effectiveBaseColor.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: -5,
                  ),
                  if (isHighlighted)
                    BoxShadow(
                      color: effectiveAccentColor.withValues(alpha: 0.5),
                      blurRadius: 20,
                    ),
                ],
              ),
              child: Center(
                child: Text(
                  number.toString(),
                  style: TextStyle(
                    fontSize: size * 0.4,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
