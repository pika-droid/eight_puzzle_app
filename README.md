# 8-Puzzle Solver

A high-performance implementation of the classic 8-puzzle game built with Flutter. This project combines efficient A* algorithms with a striking **Retro Pixel Aesthetic** to create a unique and immersive puzzle-solving experience.

## Features

### Gameplay & Controls
- **Smooth Interactions**: Natural swipe and flick gestures to move tiles.
- **Animations**: Fluid tile sliding animations and a retro-futuristic neon grid background that scrolls with a 3D perspective effect.
- **Timer & Moves**: Track efficiency with a pixel-art style real-time move counter and stopwatch.

### Advanced Solver
- **A* Algorithm**: Finds the optimal solution efficiently using the A* search algorithm.
- **Heuristics**: Implements Manhattan Distance, Linear Conflict, and Hamming Distance for precise state evaluation.
- **Auto-Play**: Automatically animates the solution sequence on the board with a visual progress bar.

### Visuals & Immersion
- **Retro Pixel Aesthetic**: Cyberpunk-inspired design with neon colors (`#00F0FF`, `#FF0099`), scanlines, and the iconic "Press Start 2P" font.
- **Dynamic Themes**: Multiple retro color palettes to customize the application appearance.
- **Audio Feedback**: Satisfying 8-bit sound effects for moves, shuffles, and victory events (includes mute toggle).

### Inspector Mode
- **Deep Dive**: Long-press any tile to open the Inspector.
- **Visual Debugging**: 
  - **Ghost Tile**: Visually highlights exactly where the inspected tile *should* be in the solved state.
  - **Heuristic Report**: Displays calculated costs (G, H, F), Manhattan distance logic, and Linear Conflicts in a glass-overlay dialog.
- **Heatmap Overlay**: Toggle a visual heatmap to see which tiles are furthest from their target positions.

## Technical Stack

- **Framework**: Flutter (Dart)
- **State Management**: BLoC (Business Logic Component) Pattern
- **Architecture**: Clean Architecture (Presentation, Domain, Data layers)
- **Concurrency**: Solvers run in separate Isolates to ensure the UI remains 60fps responsive during complex calculations.


## Getting Started

1. Clone the repository:
   ```bash
   git clone https://github.com/pika-droid/eight_puzzle_app.git
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Contributing

Contributions are welcome. Feel free to open issues or submit pull requests to help improve the app.
