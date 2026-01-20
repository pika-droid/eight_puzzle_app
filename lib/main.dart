import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/theme_bloc.dart';
import 'features/puzzle/presentation/pages/start_page.dart';

void main() {
  runApp(const EightPuzzleApp());
}

class EightPuzzleApp extends StatelessWidget {
  const EightPuzzleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ThemeBloc(),
      child: MaterialApp(
        title: '8 Puzzle Solver',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6366F1), // Indigo
            brightness: Brightness.light,
            primary: const Color(0xFF6366F1),
            secondary: const Color(0xFFEC4899), // Pink
            surface: Colors.white,
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF818CF8), // Light Indigo
            brightness: Brightness.dark,
            primary: const Color(0xFF818CF8),
            secondary: const Color(0xFFF472B6), // Light Pink
            surface: const Color(0xFF1E1E2E),
            surfaceContainerHighest: const Color(0xFF2A2A3E),
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
          scaffoldBackgroundColor: const Color(0xFF0F0F1A),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
        themeMode: ThemeMode.dark, // Default to dark for modern look
        home: const StartPage(),
      ),
    );
  }
}
