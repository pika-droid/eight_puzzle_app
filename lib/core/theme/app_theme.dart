import 'package:flutter/material.dart';

class AppTheme {
  final String name;
  final List<Color> backgroundGradientColors;
  final Color tileColor;
  final Color tileHeatColorStart;
  final Color tileHeatColorEnd;
  final Color accentColor;
  final Color textColor;

  const AppTheme({
    required this.name,
    required this.backgroundGradientColors,
    required this.tileColor,
    required this.tileHeatColorStart,
    required this.tileHeatColorEnd,
    required this.accentColor,
    required this.textColor,
  });

  static const cosmic = AppTheme(
    name: 'Cosmic',
    backgroundGradientColors: [
      Color(0xFF0F0F1A), // Dark navy
      Color(0xFF1A1A2E), // Dark purple
      Color(0xFF16213E), // Deep blue
      Color(0xFF0F0F1A), // Dark navy
    ],
    tileColor: Color(0xFF6366F1), // Indigo
    tileHeatColorStart: Color(0xFF10B981), // Green
    tileHeatColorEnd: Color(0xFFEF4444), // Red
    accentColor: Color(0xFFF472B6), // Pink (highlight)
    textColor: Colors.white,
  );

  static const nature = AppTheme(
    name: 'Nature',
    backgroundGradientColors: [
      Color(0xFF1B4332), // Dark green
      Color(0xFF2D6A4F), // Forest green
      Color(0xFF40916C), // Medium green
      Color(0xFF1B4332), // Dark green
    ],
    tileColor: Color(0xFF52B788), // Light green
    tileHeatColorStart: Color(0xFFD8F3DC), // Pale green
    tileHeatColorEnd: Color(0xFFAA4465), // Berry red
    accentColor: Color(0xFF95D5B2), // Mint
    textColor: Colors.white,
  );

  static const minimal = AppTheme(
    name: 'Minimal',
    backgroundGradientColors: [
      Color(0xFFF8F9FA), // Off white
      Color(0xFFE9ECEF), // Light grey
      Color(0xFFDEE2E6), // Grey
      Color(0xFFF8F9FA), // Off white
    ],
    tileColor: Color(0xFFCED4DA), // Grey tile
    tileHeatColorStart: Color(0xFFADB5BD), // Darker grey
    tileHeatColorEnd: Color(0xFF495057), // Dark grey
    accentColor: Color(0xFF212529), // Black
    textColor: Color(0xFF212529), // Black text
  );

  static const sunset = AppTheme(
    name: 'Sunset',
    backgroundGradientColors: [
      Color(0xFF35012C), // Deep purple
      Color(0xFFAB0DA4),
      Color(0xFFE80F88),
      Color(0xFFFF9E00), // Orange
    ],
    tileColor: Color(0xFFE80F88),
    tileHeatColorStart: Color(0xFFFF9E00),
    tileHeatColorEnd: Color(0xFF35012C),
    accentColor: Color(0xFFFF9E00),
    textColor: Colors.white,
  );

  static const List<AppTheme> values = [cosmic, nature, minimal, sunset];

  static TextStyle retroTextStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    List<Shadow>? shadows,
  }) {
    return TextStyle(
      fontFamily: 'Press Start 2P',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      shadows: shadows,
    );
  }
}
