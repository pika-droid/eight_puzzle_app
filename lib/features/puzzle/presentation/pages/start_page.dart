import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../bloc/puzzle_bloc.dart';
// import '../bloc/puzzle_event.dart';
import 'puzzle_page.dart'; // Ensure this import is correct relative to file structure
import '../../domain/logic/game_generator.dart'; // For Difficulty enum

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage>
    with SingleTickerProviderStateMixin {
  Difficulty _selectedDifficulty = Difficulty.medium;
  bool _isMoveBudgetEnabled = false;
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

  void _startGame() {
    // Navigate to PuzzlePage with selected parameters
    // We need to inject the LoadPuzzle event with these params.
    // Assuming PuzzlePage handles the BlocProvider or we pass it.
    // Usually we push the page, and the page's initState or a passed argument triggers the load.
    // Or we can add the event here if the Bloc is provided above.
    // For now, let's assume we push PuzzlePage and pass arguments or use a route.
    // Since existing PuzzlePage likely uses a standard BlocProvider, we might need
    // to pass these params to it.
    // Actually, looking at PuzzleBloc, it waits for LoadPuzzle.
    // We should probably reset the bloc with these new params.

    // Using a simple Navigator push.
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PuzzlePage(
          difficulty: _selectedDifficulty,
          isMoveBudgetEnabled: _isMoveBudgetEnabled,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Colors
    const midnightBlue = Color(0xFF000A1F); // #000A1F - Deep Midnight
    const neonCyan = Color(0xFF00F0FF); // #00F0FF - Neon Cyan
    final glassWhite = Colors.white.withValues(alpha: 0.1);
    final textStyle = GoogleFonts.pressStart2p(color: Colors.white);

    return Scaffold(
      backgroundColor: midnightBlue,
      body: Stack(
        children: [
          // 1. Abstract 3D Grid Background (Animated)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _gridAnimationController,
              builder: (context, child) {
                return CustomPaint(
                  painter: GridPainter(
                    color: neonCyan.withValues(alpha: 0.2),
                    scrollOffset: _gridAnimationController.value,
                  ),
                );
              },
            ),
          ),

          // 2. Main Content
          Center(
            child: SingleChildScrollView(
              // For safety on small screens
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo / Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      border: Border.all(color: neonCyan, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: neonCyan.withValues(alpha: 0.5),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: GridView.count(
                        crossAxisCount: 3,
                        padding: const EdgeInsets.all(4),
                        mainAxisSpacing: 4,
                        crossAxisSpacing: 4,
                        shrinkWrap: true,
                        children: List.generate(9, (index) {
                          if (index == 8) return const SizedBox();
                          return Container(
                            color: neonCyan.withValues(alpha: 0.8),
                          );
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    '8-PUZZLE',
                    style: GoogleFonts.pressStart2p(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [const Shadow(color: neonCyan, blurRadius: 10)],
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Glassmorphism Card
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        width: 350,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: glassWhite,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // PUZZLE DEPTH
                            Text(
                              'PUZZLE DEPTH',
                              style: textStyle.copyWith(
                                fontSize: 14,
                                color: neonCyan,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            _buildDifficultyButton(
                              Difficulty.easy,
                              'EASY',
                              '5-10 Moves',
                              neonCyan,
                              textStyle,
                            ),
                            const SizedBox(height: 8),
                            _buildDifficultyButton(
                              Difficulty.medium,
                              'MEDIUM',
                              '15-20 Moves',
                              neonCyan,
                              textStyle,
                            ),
                            const SizedBox(height: 8),
                            _buildDifficultyButton(
                              Difficulty.hard,
                              'HARD',
                              '25-31 Moves',
                              neonCyan,
                              textStyle,
                            ),

                            const SizedBox(height: 32),

                            // CHALLENGE MODES
                            Text(
                              'CHALLENGE MODES',
                              style: textStyle.copyWith(
                                fontSize: 14,
                                color: neonCyan,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),

                            // Move Budget Toggle
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isMoveBudgetEnabled = !_isMoveBudgetEnabled;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: _isMoveBudgetEnabled
                                      ? neonCyan.withValues(alpha: 0.2)
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: _isMoveBudgetEnabled
                                        ? neonCyan
                                        : Colors.white.withValues(alpha: 0.3),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.battery_charging_full,
                                      color: _isMoveBudgetEnabled
                                          ? neonCyan
                                          : Colors.white.withValues(alpha: 0.5),
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'MOVE BUDGET',
                                        style: textStyle.copyWith(
                                          fontSize: 12,
                                          color: _isMoveBudgetEnabled
                                              ? Colors.white
                                              : Colors.white.withValues(
                                                  alpha: 0.5,
                                                ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _isMoveBudgetEnabled
                                            ? neonCyan
                                            : Colors.transparent,
                                        border: Border.all(color: neonCyan),
                                      ),
                                      child: _isMoveBudgetEnabled
                                          ? const Icon(
                                              Icons.check,
                                              size: 14,
                                              color: Colors.black,
                                            )
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Start Button
                  FilledButton(
                    onPressed: _startGame,
                    style: FilledButton.styleFrom(
                      backgroundColor: neonCyan,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 10,
                      shadowColor: neonCyan.withValues(alpha: 0.5),
                    ),
                    child: Text(
                      'START GAME',
                      style: GoogleFonts.pressStart2p(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyButton(
    Difficulty difficulty,
    String label,
    String subLabel,
    Color accentColor,
    TextStyle baseStyle,
  ) {
    final bool isSelected = _selectedDifficulty == difficulty;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDifficulty = difficulty;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withValues(alpha: 0.2)
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? accentColor
                : Colors.white.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.3),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: baseStyle.copyWith(
                fontSize: 12,
                color: isSelected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.6),
              ),
            ),
            Text(
              subLabel,
              style: baseStyle.copyWith(
                fontSize: 10,
                color: isSelected
                    ? accentColor
                    : Colors.white.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
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

    // Perspective Grid Effect
    // Simple implementation: standard grid moving down/up

    final double offset = scrollOffset * gridSize;

    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = offset % gridSize; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Gradient overlay to fade out edges
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
      oldDelegate.scrollOffset != scrollOffset;
}
