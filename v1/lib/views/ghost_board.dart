// GhostBoard widget for QCI Tic-Tac-Toe
// Individual small tic-tac-toe board (faded/transparent)

import 'package:flutter/material.dart';
import 'dart:math' as math;

class GhostBoard extends StatelessWidget {
  // The board state (3x3 grid of strings: '', 'X', 'O')
  final List<List<String>> board;
  
  // Opacity for the ghost effect (0.0 to 1.0)
  final double opacity;
  
  // Size of the board
  final double size;
  
  // Strategy name for this ghost board
  final String strategyName;

  // Phase-based color properties
  final double phase; // -π to +π
  final double magnitude; // 0.0 to 1.0
  final double pulseFactor; // Current animation pulse value (0.0 to 1.0)

  const GhostBoard({
    super.key,
    required this.board,
    this.opacity = 0.6,
    this.size = 80.0,
    this.strategyName = 'Ghost',
    this.phase = 0.0,
    this.magnitude = 1.0,
    this.pulseFactor = 0.0,
  });

  // Get base color based on phase
  Color _getPhaseColor() {
    // Use a simpler color scheme based on phase
    final normalizedPhase = (phase + math.pi) / (2 * math.pi); // 0 to 1
    
    if (normalizedPhase < 0.25) {
      return Colors.blue;
    } else if (normalizedPhase < 0.5) {
      return Colors.purple;
    } else if (normalizedPhase < 0.75) {
      return Colors.red;
    } else {
      return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = _getPhaseColor();
    final effectiveOpacity = opacity * (0.3 + 0.7 * pulseFactor * magnitude);
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: Border.all(
          color: baseColor.withOpacity(effectiveOpacity),
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.black12,
        boxShadow: [
          BoxShadow(
            color: baseColor.withOpacity(effectiveOpacity * 0.3),
            blurRadius: 8.0,
            spreadRadius: 2.0,
          ),
        ],
      ),
      child: Column(
        children: List.generate(3, (row) {
          return Expanded(
            child: Row(
              children: List.generate(3, (col) {
                return Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: baseColor.withOpacity(effectiveOpacity * 0.3),
                        width: 0.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        board[row][col],
                        style: TextStyle(
                          fontSize: size * 0.2,
                          fontWeight: FontWeight.bold,
                          color: _getCellColor(board[row][col]),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ),
    );
  }

  // Get color for cell content
  Color _getCellColor(String cell) {
    switch (cell) {
      case 'X':
        return Colors.blue.withOpacity(opacity);
      case 'O':
        return Colors.red.withOpacity(opacity);
      default:
        return Colors.transparent;
    }
  }
} 