# 🧩 8-Puzzle Challenge

A stunning, modern implementation of the classic 8-puzzle game built with Flutter. This project combines efficient algorithms with a premium glassmorphic UI to create an immersive puzzle-solving experience.

## ✨ Features

### 🎮 Gameplay & Controls
-   **Smooth Interactions**: Natural swipe and flick gestures to move tiles.
-   **Animations**: Fluid tile sliding animations and dynamic background gradients that shift as you play.
-   **Timer & Moves**: Track your efficiency with a real-time move counter and stopwatch.

### 🧠 Advanced Solver
Stuck? Let the AI take over!
-   **A* (A-Star) Algorithm**: Finds the optimal solution in seconds.
-   **Heuristics**: Uses Manhattan Distance, Linear Conflict, and Hamming Distance for precise state evaluation.
-   **Auto-Play**: Watch the puzzle solve itself with a beautiful animation sequence.

### 🎨 Visuals & Immersion
-   **Glassmorphism Design**: Frosted glass effects on tiles and UI elements for a modern look.
-   **Dynamic Themes**: Choose from a variety of color palettes to match your mood.
-   **Audio Feedback**: Satisfying sound effects for moves, shuffles, and victory (with mute toggle).

### 🔍 Inspector Mode
For the algorithm enthusiasts!
-   **Deep Dive**: Long-press any tile to reveal its heuristic details.
-   **Visual Debugging**: See the calculated costs (G, H, F), Manhattan distance, and target position ghost overlays directly on the board.

## 🛠️ Technical Stack

-   **Framework**: Flutter (Dart)
-   **State Management**: BLoC (Business Logic Component) Pattern
-   **Architecture**: Clean Architecture (Presentation, Domain, Data layers)
-   **Asynchronous Computing**: Solvers run in separate **Isolates** to keep the UI buttery smooth during complex calculations.

## 🚀 Getting Started

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/pika-droid/eight_puzzle_app.git
    ```
2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Run the app**:
    ```bash
    flutter run
    ```

## 📸 Screenshots

*(Add your screenshots here)*

## 🤝 Contributing

Contributions are welcome! Feel free to open issues or submit pull requests to help improve the app.

---
Built with 💙 using Flutter.
