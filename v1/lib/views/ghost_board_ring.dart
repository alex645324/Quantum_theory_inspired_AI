import 'dart:math' as math;
// GhostBoardRing widget for QCI Tic-Tac-Toe
// Arranges 8 ghost boards in a circle around the main board

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/game_view_model.dart';
import '../models/quantum_move.dart';
import 'ghost_board.dart';

class GhostBoardRing extends StatelessWidget {
  // Size of the ring (outer diameter)
  final double ringSize;
  // Size of each ghost board
  final double ghostBoardSize;

  // Static variables to track changes
  static double? _lastRingSize;
  static double? _lastGhostBoardWidth;
  static bool? _lastAdditionalColumn;

  const GhostBoardRing({
    super.key,
    this.ringSize = 320.0,
    this.ghostBoardSize = 80.0,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<GameViewModel>(
      builder: (context, gameViewModel, child) {
        final quantumMind = gameViewModel.quantumMind;
        final ghostBoards = quantumMind.ghostBoards;
        final animationViewModel = gameViewModel.animationViewModel;
        final rules = gameViewModel.gameState.rules;
        
        // Set opacity based on turn state - hide during player turn
        final opacity = gameViewModel.isPlayerTurn ? 0.0 : 0.6;
        
        // Calculate the actual width needed for each ghost board
        final ghostBoardWidth = ghostBoardSize * (rules.additionalColumn ? 4/3 : 1);
        
        // Calculate minimum ring size needed based on ghost board size
        // Increase minimum spacing when we have additional column to prevent overlap
        final minSpacingBetweenBoards = rules.additionalColumn ? 60.0 : 20.0;
        final effectiveGhostBoardSize = math.max(ghostBoardWidth, ghostBoardSize);
        
        // Increase the minimum ring diameter when we have additional column
        // We multiply by a larger factor to ensure enough space for wider boards
        final minRingDiameter = rules.additionalColumn 
            ? (effectiveGhostBoardSize + minSpacingBetweenBoards) * 3.5  // Increased factor for additional column
            : (effectiveGhostBoardSize + minSpacingBetweenBoards) * 3;
        
        // Use the larger of the minimum required size or the provided ring size
        final effectiveRingSize = math.max(minRingDiameter, ringSize);
        
        // Calculate center point
        final center = effectiveRingSize / 2;
        
        // Increase radius when we have additional column to push boards further out
        final radiusAdjustment = rules.additionalColumn ? 1.2 : 1.0;  // 20% more radius for additional column
        final radius = (effectiveRingSize - effectiveGhostBoardSize) / 2 * radiusAdjustment;

        // Only print debug info when key values change
        if (_lastRingSize != effectiveRingSize || 
            _lastGhostBoardWidth != ghostBoardWidth ||
            _lastAdditionalColumn != rules.additionalColumn) {
          
          print('\nDEBUG: Ghost Board Ring Key Changes:');
          print('  - Ring Size (provided): $ringSize');
          print('  - Effective Ring Size: $effectiveRingSize');
          print('  - Ghost Board Width: $ghostBoardWidth');
          print('  - Min Spacing: $minSpacingBetweenBoards');
          print('  - Effective Ghost Board Size: $effectiveGhostBoardSize');
          print('  - Radius: $radius');
          print('  - Has Additional Column: ${rules.additionalColumn}');
          
          // Print positions for first and adjacent ghost boards to check spacing
          final firstAngle = 0.0;
          final secondAngle = math.pi / 4;
          
          final firstX = center + radius * math.cos(firstAngle) - ghostBoardWidth / 2;
          final firstY = center + radius * math.sin(firstAngle) - ghostBoardSize / 2;
          
          final secondX = center + radius * math.cos(secondAngle) - ghostBoardWidth / 2;
          final secondY = center + radius * math.sin(secondAngle) - ghostBoardSize / 2;
          
          print('\nDEBUG: Adjacent Ghost Board Positions:');
          print('  Board 1: ($firstX, $firstY)');
          print('  Board 2: ($secondX, $secondY)');
          print('  Distance between boards: ${math.sqrt(math.pow(secondX - firstX, 2) + math.pow(secondY - firstY, 2))}');
          
          // Update tracked values
          _lastRingSize = effectiveRingSize;
          _lastGhostBoardWidth = ghostBoardWidth;
          _lastAdditionalColumn = rules.additionalColumn;
        }
        
        return SizedBox(
          width: effectiveRingSize,
          height: effectiveRingSize,
          child: Stack(
            children: List.generate(8, (index) {
              final angle = (index * math.pi / 4); // 45° increments
              final ghostBoard = ghostBoards[index];
              final strategy = quantumMind.getStrategy(index);
              
              // Calculate position on the ring
              final boardCenterX = center + radius * math.cos(angle);
              final boardCenterY = center + radius * math.sin(angle);
              
              // Adjust final position by subtracting half the board size
              final x = boardCenterX - ghostBoardWidth / 2;
              final y = boardCenterY - ghostBoardSize / 2;
              
              return Positioned(
                left: x,
                top: y,
                child: AnimatedBuilder(
                  animation: animationViewModel.pulseAnimation,
                  builder: (context, child) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          strategy?.basisState ?? 'Ghost',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.withOpacity(opacity),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        GhostBoard(
                          board: _createBoardWithSuggestion(
                            gameViewModel.board,
                            ghostBoard.proposedMove,
                          ),
                          size: ghostBoardSize,
                          opacity: opacity,
                          strategyName: ghostBoard.basisState,
                          phase: ghostBoard.proposedMove.amplitude.phase,
                          magnitude: ghostBoard.proposedMove.amplitude.magnitude,
                          rules: rules,
                        ),
                      ],
                    );
                  },
                ),
              );
            }),
          ),
        );
      },
    );
  }

  // Helper to create a board state with the suggested move
  List<List<String>> _createBoardWithSuggestion(
    List<List<String>> currentBoard,
    QuantumMove move,
  ) {
    final columns = currentBoard[0].length;
    final board = List.generate(
      3,
      (row) => List.generate(
        columns,
        (col) => currentBoard[row][col],
      ),
    );
    
    if (move.position != null) {
      board[move.position!.row][move.position!.col] = move.player;
    }
    
    return board;
  }
} 