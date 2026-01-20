import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_bloc.dart';

/// An animated gradient background with floating orbs for a modern liquid glass effect.
class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;

  const AnimatedGradientBackground({super.key, required this.child});

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        final theme = state.theme;
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: theme.backgroundGradientColors,
                  stops: [
                    0.0,
                    0.3 + 0.1 * math.sin(_controller.value * 2 * math.pi),
                    0.7 + 0.1 * math.cos(_controller.value * 2 * math.pi),
                    1.0,
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Floating orbs
                  ...List.generate(
                    3,
                    (index) => _buildFloatingOrb(index, theme),
                  ),
                  // Main content
                  widget.child,
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFloatingOrb(int index, AppTheme theme) {
    final double baseSize = 200 + index * 100;
    final double animationOffset = index * 0.33;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double progress = (_controller.value + animationOffset) % 1.0;
        final double x = math.sin(progress * 2 * math.pi) * 50;
        final double y = math.cos(progress * 2 * math.pi) * 30;

        return Positioned(
          left:
              (index == 0
                  ? -50
                  : index == 1
                  ? 150
                  : 50) +
              x,
          top:
              (index == 0
                  ? -100
                  : index == 1
                  ? 300
                  : 500) +
              y,
          child: Container(
            width: baseSize,
            height: baseSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _getOrbColor(index, theme).withValues(alpha: 0.3),
                  _getOrbColor(index, theme).withValues(alpha: 0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getOrbColor(int index, AppTheme theme) {
    switch (index) {
      case 0:
        return theme.tileColor;
      case 1:
        return theme.accentColor;
      case 2:
        return theme.backgroundGradientColors.first;
      default:
        return theme.tileColor;
    }
  }
}
