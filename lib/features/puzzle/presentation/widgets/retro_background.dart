import 'package:flutter/material.dart';

class RetroBackground extends StatefulWidget {
  final Widget child;
  final Color gridColor;

  const RetroBackground({
    super.key,
    required this.child,
    this.gridColor = const Color(0xFF00F0FF), // Neon Cyan default
  });

  @override
  State<RetroBackground> createState() => _RetroBackgroundState();
}

class _RetroBackgroundState extends State<RetroBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _gridAnimationController;

  @override
  void initState() {
    super.initState();
    _gridAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _gridAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Deep Midnight Blue background
    const midnightBlue = Color(0xFF000A1F);

    return Scaffold(
      backgroundColor: midnightBlue,
      body: Stack(
        children: [
          // Animated Grid
          Positioned.fill(
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _gridAnimationController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: GridPainter(
                      color: widget.gridColor.withValues(alpha: 0.2),
                      scrollOffset: _gridAnimationController.value,
                    ),
                  );
                },
              ),
            ),
          ),
          // Content
          widget.child,
        ],
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  final Color color;
  final double scrollOffset;

  GridPainter({required this.color, required this.scrollOffset});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final double gridSize = 40.0;

    // Perspective Grid Effect - scrolling down
    final double offset = scrollOffset * gridSize;

    // Vertical lines
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Horizontal lines (moving)
    for (double y = offset % gridSize; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Gradient overlay to fade out edges/add depth
    final gradientPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Colors.transparent, Color(0xFF000A1F)],
        stops: [0.4, 1.0],
        radius: 1.2,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      gradientPaint,
    );
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) =>
      oldDelegate.scrollOffset != scrollOffset || oldDelegate.color != color;
}
