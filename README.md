# 8-Puzzle Challenge

A modern implementation of the classic 8-puzzle game built with Flutter. This project combines efficient algorithms with a premium glassmorphic UI to create an immersive puzzle-solving experience.

## Features

### Gameplay & Controls
- **Smooth Interactions**: Natural swipe and flick gestures to move tiles.
- **Animations**: Fluid tile sliding animations and dynamic background gradients that shift during gameplay.
- **Timer & Moves**: Track efficiency with a real-time move counter and stopwatch.

### Advanced Solver
- **A* Algorithm**: Finds the optimal solution efficiently using the A* search algorithm.
- **Heuristics**: Implements Manhattan Distance, Linear Conflict, and Hamming Distance for precise state evaluation.
- **Auto-Play**: Automatically animates the solution sequence on the board.

### Visuals & Immersion
- **Glassmorphism Design**: Frosted glass effects on tiles and UI elements.
- **Dynamic Themes**: Multiple color palettes to customize the application appearance.
- **Audio Feedback**: Sound effects for moves, shuffles, and victory events (includes mute toggle).

### Inspector Mode
- **Deep Dive**: Long-press any tile to reveal heuristic details.
- **Visual Debugging**: Displays calculated costs (G, H, F), Manhattan distance, and target position overlays directly on the board.

## Technical Stack

- **Framework**: Flutter (Dart)
- **State Management**: BLoC (Business Logic Component) Pattern
- **Architecture**: Clean Architecture (Presentation, Domain, Data layers)
- **Concurrency**: Solvers run in separate Isolates to ensure the UI remains responsive during complex calculations.

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
