// GhostBoard widget for QCI Tic-Tac-Toe
// Represents a quantum possibility state

import 'package:flutter/material.dart';
import '../models/game_state.dart';

class GhostBoard extends StatelessWidget {
  final List<List<String>> board;
  final double size;
  final double opacity;
  final String strategyName;
  final double phase;
  final double magnitude;
  final double scale;
  final double floatingOffset;
  final bool showLabel;
  final GameRules rules;

  const GhostBoard({
    super.key,
    required this.board,
    required this.size,
    this.opacity = 0.6,
    required this.strategyName,
    required this.phase,
    required this.magnitude,
    this.scale = 1.0,
    this.floatingOffset = 0.0,
    this.showLabel = true,
    required this.rules,
  });

  @override
  Widget build(BuildContext context) {
    final columns = rules.additionalColumn ? 4 : 3;
    
    return Transform.translate(
      offset: Offset(0, floatingOffset),
      child: Transform.scale(
        scale: scale,
        child: Opacity(
          opacity: opacity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showLabel) ...[
                Text(
                  strategyName,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.withOpacity(0.7),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
              ],
              Container(
                width: size * (columns / 3), // Adjust width for additional column
                height: size,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white70,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                  color: Colors.black12,
                ),
                child: Column(
                  children: List.generate(3, (row) {
                    return Expanded(
                      child: Row(
                        children: List.generate(columns, (col) {
                          final cellValue = board[row][col];
                          final isCenterPiece = row == 1 && col == 1;
                          final isCenterDisabled = !rules.centerAvailable && isCenterPiece;
                          
                          return Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.white24,
                                  width: 0.5,
                                ),
                                color: isCenterDisabled ? Colors.black26 : null,
                              ),
                              child: Center(
                                child: Text(
                                  cellValue,
                                  style: TextStyle(
                                    fontSize: size * 0.2,
                                    fontWeight: FontWeight.bold,
                                    color: _getCellColor(cellValue, isCenterDisabled),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCellColor(String cell, bool isCenterDisabled) {
    if (isCenterDisabled) {
      return Colors.white12;
    }
    switch (cell) {
      case 'X':
        return Colors.blue.withOpacity(0.7);
      case 'O':
        return Colors.red.withOpacity(0.7);
      default:
        return Colors.transparent;
    }
  }
} 