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
        
        // Set opacity based on turn state - hide during player turn
        final opacity = gameViewModel.isPlayerTurn ? 0.0 : 0.6;
        
        final center = ringSize / 2;
        final radius = (ringSize - ghostBoardSize) / 2;
        
        return SizedBox(
          width: ringSize,
          height: ringSize,
          child: Stack(
            children: List.generate(8, (index) {
              final angle = (index * math.pi / 4); // 45° increments
              final ghostBoard = ghostBoards[index];
              final strategy = quantumMind.getStrategy(index);
              
              // Calculate position on the ring
              final x = center + radius * math.cos(angle) - ghostBoardSize / 2;
              final y = center + radius * math.sin(angle) - ghostBoardSize / 2;
              
              // Get phase and magnitude from the quantum move
              final phase = ghostBoard.proposedMove.amplitude.phase;
              final magnitude = ghostBoard.proposedMove.amplitude.magnitude;
              
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
                          phase: phase,
                          magnitude: magnitude,
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
    final board = List.generate(
      3,
      (row) => List.generate(
        3,
        (col) => currentBoard[row][col],
      ),
    );
    
    board[move.position.row][move.position.col] = move.player;
    return board;
  }
} 