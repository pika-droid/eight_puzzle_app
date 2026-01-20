abstract class HeuristicStrategy {
  /// Calculates the estimated cost from the current [state] to the goal.
  int calculate(List<int> state);
}
