// MainBoard widget for QCI Tic-Tac-Toe
// The central "reality" board (large, prominent)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/game_view_model.dart';

class MainBoard extends StatelessWidget {
  // Size of the board
  final double size;

  const MainBoard({
    super.key,
    this.size = 80.0, // Default size matches ghost boards
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<GameViewModel>(
      builder: (context, gameViewModel, child) {
        final board = gameViewModel.board;
        final isGameOver = gameViewModel.isGameOver;
        final rules = gameViewModel.gameState.rules;
        final columns = rules.additionalColumn ? 4 : 3;
        
        return Container(
          width: size * (columns / 3), // Adjust width for additional column while maintaining cell size
          height: size,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white70,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(8.0),
            color: Colors.black12,
            boxShadow: [
              BoxShadow(
                color: Colors.white24,
                blurRadius: 8.0,
                spreadRadius: 2.0,
              ),
            ],
          ),
          child: Column(
            children: List.generate(3, (row) {
              return Expanded(
                child: Row(
                  children: List.generate(columns, (col) {
                    final cellValue = board[row][col];
                    final isValidMove = gameViewModel.isValidMove(row, col);
                    final isCenterPiece = row == 1 && col == 1;
                    final isCenterDisabled = !rules.centerAvailable && isCenterPiece;
                    
                    return Expanded(
                      child: GestureDetector(
                        onTap: isValidMove && !isGameOver && !isCenterDisabled
                            ? () {
                                gameViewModel.collapsePlayerMove(row, col);
                              }
                            : null,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white24,
                              width: 0.5,
                            ),
                            color: isCenterDisabled
                                ? Colors.black26 // Darker background for disabled center
                                : isValidMove && !isGameOver 
                                    ? Colors.white10
                                    : Colors.transparent,
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
                      ),
                    );
                  }),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  // Get color for cell content
  Color _getCellColor(String cell, bool isCenterDisabled) {
    if (isCenterDisabled) {
      return Colors.white12; // Very transparent for disabled center
    }
    switch (cell) {
      case 'X':
        return Colors.blue;
      case 'O':
        return Colors.red;
      default:
        return Colors.transparent;
    }
  }
} 