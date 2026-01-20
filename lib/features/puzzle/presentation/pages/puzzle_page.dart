import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/audio_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_bloc.dart';
import '../../data/game_storage_service.dart';
import '../../domain/logic/game_generator.dart'; // For Difficulty
import '../../domain/logic/tile_heuristic_calculator.dart';
import '../bloc/puzzle_bloc.dart';
import '../bloc/puzzle_event.dart';
import '../bloc/puzzle_state.dart';
import '../widgets/retro_background.dart';
import '../widgets/retro_button.dart';
import '../widgets/retro_container.dart';
import '../widgets/animated_puzzle_grid.dart';
import '../widgets/glass_dialog.dart';
import '../widgets/heuristic_report_dialog.dart';
import '../widgets/victory_dialog.dart';

class PuzzlePage extends StatefulWidget {
  final Difficulty difficulty;
  final bool isMoveBudgetEnabled;

  const PuzzlePage({
    super.key,
    this.difficulty = Difficulty.medium,
    this.isMoveBudgetEnabled = false,
  });

  @override
  State<PuzzlePage> createState() => _PuzzlePageState();
}

class _PuzzlePageState extends State<PuzzlePage> {
  Timer? _animationTimer;

  // Inspector Mode state
  TileHeuristicReport? _inspectedTileReport;

  // Storage service for checking saved games
  final GameStorageService _storageService = GameStorageService();
  final AudioService _audioService = AudioService();

  @override
  void dispose() {
    _animationTimer?.cancel();
    super.dispose();
  }

  // ... existing code ...

  void _startAnimationTimer(BuildContext context) {
    _animationTimer?.cancel();
    _animationTimer = Timer.periodic(const Duration(milliseconds: 300), (_) {
      context.read<PuzzleBloc>().add(const AnimateSolutionStep());
    });
  }

  void _stopAnimationTimer() {
    _animationTimer?.cancel();
    _animationTimer = null;
  }

  Future<void> _checkForSavedGame(BuildContext context) async {
    final savedGame = await _storageService.loadGame();
    if (savedGame == null || !context.mounted) return;

    final shouldResume = await showGlassDialog<bool>(
      context: context,
      barrierDismissible: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'RESUME GAME?',
            style: AppTheme.retroTextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'You have a saved game with ${savedGame.moveCount} moves.\n'
            'Would you like to continue?',
            style: AppTheme.retroTextStyle(
              fontSize: 12,
              color: Colors.white70,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              RetroButton(
                onPressed: () => Navigator.of(context).pop(false),
                label: 'NEW GAME',
                baseColor: Colors.redAccent,
                isSmall: true,
              ),
              const SizedBox(width: 8),
              RetroButton(
                onPressed: () => Navigator.of(context).pop(true),
                label: 'RESUME',
                baseColor: Colors.greenAccent,
                isSmall: true,
              ),
            ],
          ),
        ],
      ),
    );

    if (!context.mounted) return;

    if (shouldResume == true) {
      context.read<PuzzleBloc>().add(
        ResumeSavedGame(
          boardState: savedGame.boardState,
          moveCount: savedGame.moveCount,
          undoStack: savedGame.undoStack,
          redoStack: savedGame.redoStack,
          moveLimit: savedGame.moveLimit,
          difficulty: savedGame.difficulty,
        ),
      );
    } else {
      // User chose new game, clear the save
      await _storageService.clearSave();
    }
  }

  void _showTileInspector(
    BuildContext context,
    int position,
    List<int> boardState,
  ) {
    final int tile = boardState[position];
    if (tile == 0) return; // Don't inspect empty tile

    final report = TileHeuristicCalculator.getReport(
      tile,
      position,
      boardState,
    );

    setState(() {
      _inspectedTileReport = report;
    });

    showGlassDialog(
      context: context,
      child: HeuristicReportContent(report: report),
    ).then((_) {
      // Clear ghost tile when dialog closes
      setState(() {
        _inspectedTileReport = null;
      });
    });
  }

  // Flag to prevent multiple saved game checks
  bool _hasCheckedSavedGame = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PuzzleBloc()
        ..add(
          LoadPuzzle(
            difficulty: widget.difficulty.toString(),
            isMoveBudgetEnabled: widget.isMoveBudgetEnabled,
          ),
        ),
      child: Builder(
        builder: (context) {
          // Check for saved game only once after first frame
          if (!_hasCheckedSavedGame) {
            _hasCheckedSavedGame = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _checkForSavedGame(context);
            });
          }

          return MultiBlocListener(
            listeners: [
              // 1. Move Sound Listener
              BlocListener<PuzzleBloc, PuzzleState>(
                listenWhen: (previous, current) {
                  return previous is PuzzleLoaded &&
                      current is PuzzleLoaded &&
                      current.moveCount > previous.moveCount;
                },
                listener: (context, state) {
                  _audioService.playMoveSound();
                },
              ),
              // 2. Animation Timer Listener
              BlocListener<PuzzleBloc, PuzzleState>(
                listenWhen: (previous, current) {
                  // Only react to changes involving PuzzleSolved or exiting it
                  return (previous is! PuzzleSolved &&
                          current is PuzzleSolved) ||
                      (previous is PuzzleSolved && current is! PuzzleSolved);
                },
                listener: (context, state) {
                  if (state is PuzzleSolved) {
                    _startAnimationTimer(context);
                  } else {
                    _stopAnimationTimer();
                  }
                },
              ),
              // 3. Victory & Error Listener
              BlocListener<PuzzleBloc, PuzzleState>(
                listener: (context, state) {
                  // Victory Sound & Dialog
                  if (state is PuzzleLoaded && state.isSolved) {
                    // We only want to play sound/show dialog if we weren't already settled in solved state.
                    // However, PuzzleBloc emits new states (e.g. invalid moves) that might keep isSolved=true.
                    // But we only show victory dialog once usually.
                    // Let's rely on the transition check in listenWhen or simpler logic:
                    // Just play sound. The user won't likely trigger other events while dialog is up.

                    // Actually, we need to be careful not to spam.
                    // The standard way is checking if we *just* became solved.
                    // Since we can't access 'previous' here easily without listenWhen,
                    // let's use listenWhen below.
                  }

                  if (state is PuzzleError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${state.message}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),
              // 3b. Separate Victory Transition Listener for explicit 'previous' access
              BlocListener<PuzzleBloc, PuzzleState>(
                listenWhen: (previous, current) {
                  if (current is PuzzleLoaded && current.isSolved) {
                    // Trigger if we weren't solved before (Manual solve)
                    if (previous is PuzzleLoaded && !previous.isSolved) {
                      return true;
                    }
                    // Trigger if we just finished animating (Auto solve)
                    if (previous is PuzzleSolved) {
                      return true;
                    }
                  }
                  return false;
                },
                listener: (context, state) {
                  if (state is PuzzleLoaded) {
                    _audioService.playSolveSound();

                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => VictoryDialog(
                        playerMoves: state.moveCount,
                        optimalMoves: state.optimalMoveCount,
                        secondsElapsed: state.secondsElapsed,
                        onPlayAgain: () {
                          context.read<PuzzleBloc>().add(const ShufflePuzzle());
                        },
                      ),
                    );
                  }
                },
              ),
            ],
            child: BlocBuilder<PuzzleBloc, PuzzleState>(
              builder: (context, state) {
                return Scaffold(
                  extendBodyBehindAppBar: true,
                  appBar: AppBar(
                    title: Text(
                      '8 PUZZLE',
                      style: AppTheme.retroTextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Theme.of(context).colorScheme.primary,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    centerTitle: true,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    actions: [
                      // Undo button
                      BlocBuilder<PuzzleBloc, PuzzleState>(
                        buildWhen: (prev, curr) =>
                            (prev is PuzzleLoaded && curr is PuzzleLoaded) &&
                            (prev.canUndo != curr.canUndo),
                        builder: (context, state) {
                          final canUndo =
                              state is PuzzleLoaded && state.canUndo;
                          return IconButton(
                            icon: const Icon(Icons.undo),
                            tooltip: 'Undo',
                            onPressed: canUndo
                                ? () => context.read<PuzzleBloc>().add(
                                    const UndoMove(),
                                  )
                                : null,
                          );
                        },
                      ),
                      // Redo button
                      BlocBuilder<PuzzleBloc, PuzzleState>(
                        buildWhen: (prev, curr) =>
                            (prev is PuzzleLoaded && curr is PuzzleLoaded) &&
                            (prev.canRedo != curr.canRedo),
                        builder: (context, state) {
                          final canRedo =
                              state is PuzzleLoaded && state.canRedo;
                          return IconButton(
                            icon: const Icon(Icons.redo),
                            tooltip: 'Redo',
                            onPressed: canRedo
                                ? () => context.read<PuzzleBloc>().add(
                                    const RedoMove(),
                                  )
                                : null,
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.shuffle),
                        tooltip: 'Shuffle',
                        onPressed: () {
                          context.read<PuzzleBloc>().add(const ShufflePuzzle());
                        },
                      ),
                      PopupMenuButton<AppTheme>(
                        icon: const Icon(Icons.palette),
                        tooltip: 'Change Theme',
                        onSelected: (theme) {
                          context.read<ThemeBloc>().add(ChangeTheme(theme));
                        },
                        itemBuilder: (context) {
                          return AppTheme.values.map((theme) {
                            return PopupMenuItem<AppTheme>(
                              value: theme,
                              child: Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: theme.tileColor,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(theme.name),
                                ],
                              ),
                            );
                          }).toList();
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          _audioService.isMuted
                              ? Icons.volume_off
                              : Icons.volume_up,
                        ),
                        tooltip: 'Toggle Sound',
                        onPressed: () {
                          setState(() {
                            _audioService.toggleMute();
                          });
                        },
                      ),
                    ],
                  ),
                  body: _buildBody(context, state),
                  floatingActionButton: _buildFAB(context, state),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, PuzzleState state) {
    final screenWidth = MediaQuery.of(context).size.width;
    final boardSize = (screenWidth * 0.85).clamp(200.0, 400.0);

    List<int> boardState = [1, 2, 3, 4, 5, 6, 7, 8, 0];
    Map<int, double>? heatMapValues;
    bool showHeuristicOverlay = false;
    int moveCount = 0;
    int secondsElapsed = 0;
    bool isSolving = false;

    if (state is PuzzleLoaded) {
      boardState = state.boardState;
      heatMapValues = state.heatMapValues;
      showHeuristicOverlay = state.showHeuristicOverlay;
      moveCount = state.moveCount;
      secondsElapsed = state.secondsElapsed;
    } else if (state is PuzzleSolving) {
      boardState = state.boardState;
      isSolving = true;
    } else if (state is PuzzleSolved) {
      boardState = state.solutionPath[state.currentStep];
      secondsElapsed = state.secondsElapsed;
    }

    // Get shadow board state
    final bool showShadowBoard = state is PuzzleLoaded
        ? state.showShadowBoard
        : false;

    return RetroBackground(
      gridColor: Theme.of(context).colorScheme.primary,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Move counter and Timer
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildInfoCard(
                        context,
                        label: 'Moves',
                        value:
                            (state is PuzzleLoaded && state.moveLimit != null)
                            ? '$moveCount / ${state.moveLimit}'
                            : '$moveCount',
                        icon: Icons.swap_calls,
                      ),
                      const SizedBox(width: 16),
                      _buildInfoCard(
                        context,
                        label: 'Time',
                        value: _formatTime(secondsElapsed),
                        icon: Icons.timer,
                      ),
                    ],
                  ),
                ),

                // Inspector mode hint
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Long-press any tile to inspect',
                    style: AppTheme.retroTextStyle(
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Puzzle board
                Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedPuzzleGrid(
                      boardState: boardState,
                      heatMapValues: heatMapValues,
                      size: boardSize,
                      showShadowBoard: showShadowBoard,
                      highlightedPosition: _inspectedTileReport?.targetPosition,
                      onTileTap: state is PuzzleLoaded && !state.isSolved
                          ? (position) {
                              context.read<PuzzleBloc>().add(
                                MoveTile(tilePosition: position),
                              );
                            }
                          : null,
                      onTileLongPress: state is PuzzleLoaded
                          ? (position) {
                              _showTileInspector(context, position, boardState);
                            }
                          : null,
                    ),
                    if (isSolving)
                      Container(
                        width: boardSize,
                        height: boardSize,
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 24),

                // Heuristic overlay toggle
                if (state is PuzzleLoaded)
                  SwitchListTile(
                    title: Text(
                      'HEURISTIC HEATMAP',
                      style: AppTheme.retroTextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      'Show tile distance from goal',
                      style: AppTheme.retroTextStyle(
                        fontSize: 8,
                        color: Colors.white70,
                      ),
                    ),
                    value: showHeuristicOverlay,
                    onChanged: (_) {
                      context.read<PuzzleBloc>().add(
                        const ToggleHeuristicOverlay(),
                      );
                    },
                  ),

                // Shadow board toggle
                if (state is PuzzleLoaded)
                  SwitchListTile(
                    title: Text(
                      'SHADOW BOARD',
                      style: AppTheme.retroTextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      'Show goal state as overlay',
                      style: AppTheme.retroTextStyle(
                        fontSize: 8,
                        color: Colors.white70,
                      ),
                    ),
                    value: showShadowBoard,
                    onChanged: (_) {
                      context.read<PuzzleBloc>().add(const ToggleShadowBoard());
                    },
                  ),

                // Animation progress
                if (state is PuzzleSolved)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'ANIMATING: ${state.currentStep + 1} / ${state.solutionPath.length}',
                          style: AppTheme.retroTextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value:
                              (state.currentStep + 1) /
                              state.solutionPath.length,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    return RetroContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      borderColor: Theme.of(context).colorScheme.primary,
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                label.toUpperCase(),
                style: AppTheme.retroTextStyle(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTheme.retroTextStyle(fontSize: 16, color: Colors.white),
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

  Widget? _buildFAB(BuildContext context, PuzzleState state) {
    if (state is PuzzleLoaded && !state.isSolved) {
      return RetroButton(
        onPressed: () {
          context.read<PuzzleBloc>().add(const StartAutoSolve());
        },
        icon: const Icon(Icons.auto_fix_high),
        label: 'AI SOLVE',
        baseColor: Theme.of(context).colorScheme.primary,
      );
    }
    return null;
  }
}
