// GhostBoard model for QCI Tic-Tac-Toe
// Represents a possibility board with strategy and proposed move

import 'quantum_move.dart';

class GhostBoard {
  // Quantum-inspired: The strategy this ghost board represents (e.g., 'Greedy', 'Defensive')
  final String basisState;

  // The move this ghost board proposes (QuantumMove)
  final QuantumMove proposedMove;

  // Visual properties for animation (optional, can be extended)
  final double opacity; // 0.0 (invisible) to 1.0 (fully visible)
  final double angle;   // Position in the ring (radians or degrees)

  const GhostBoard({
    required this.basisState,
    required this.proposedMove,
    this.opacity = 1.0,
    this.angle = 0.0,
  });

  // Copy with modifications (immutability pattern)
  GhostBoard copyWith({
    String? basisState,
    QuantumMove? proposedMove,
    double? opacity,
    double? angle,
  }) {
    return GhostBoard(
      basisState: basisState ?? this.basisState,
      proposedMove: proposedMove ?? this.proposedMove,
      opacity: opacity ?? this.opacity,
      angle: angle ?? this.angle,
    );
  }

  @override
  String toString() {
    return 'GhostBoard(basisState: $basisState, proposedMove: $proposedMove, opacity: $opacity, angle: $angle)';
  }
} 