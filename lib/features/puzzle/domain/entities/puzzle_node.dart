import 'package:equatable/equatable.dart';

class PuzzleNode extends Equatable implements Comparable<PuzzleNode> {
  final List<int> state;
  final int gCost;
  final int hCost;
  final PuzzleNode? parent;

  const PuzzleNode({
    required this.state,
    required this.gCost,
    required this.hCost,
    this.parent,
  });

  int get fCost => gCost + hCost;

  /// Unique string representation of the state for hashing/Set uniqueness.
  /// Example: "1,2,3,4,5,6,7,8,0"
  String get id => state.join(',');

  @override
  List<Object?> get props => [state, gCost, hCost, parent];

  @override
  int compareTo(PuzzleNode other) {
    final int fCompare = fCost.compareTo(other.fCost);
    if (fCompare != 0) {
      return fCompare;
    }
    // Tie-breaker: prefer higher gCost (closer to goal in some implementations,
    // or just consistent tie-breaking) or lower hCost.
    // Usually prefer lower hCost.
    return hCost.compareTo(other.hCost);
  }

  @override
  String toString() {
    return 'PuzzleNode(f: $fCost, g: $gCost, h: $hCost, state: $state)';
  }
}
