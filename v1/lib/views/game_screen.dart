// GameScreen widget for QCI Tic-Tac-Toe
// Main game interface with AppBar and body layout

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/game_view_model.dart';
import '../viewmodels/animation_view_model.dart';
import 'main_board.dart';
import 'ghost_board.dart';
import 'animation_overlay.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late final GameViewModel _gameViewModel;
  late final AnimationViewModel _animationViewModel;

  @override
  void initState() {
    super.initState();
    _animationViewModel = AnimationViewModel(this);
    _gameViewModel = GameViewModel(this, _animationViewModel);
  }

  @override
  void dispose() {
    _gameViewModel.dispose();
    _animationViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _gameViewModel),
        ChangeNotifierProvider.value(value: _animationViewModel),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('QCI Tic-Tac-Toe'),
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          elevation: 2,
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            // Calculate sizes based on screen constraints
            final screenSize = (constraints.maxWidth < constraints.maxHeight
                    ? constraints.maxWidth
                    : constraints.maxHeight) * 0.85;
            
            // Make all boards the same size
            final boardSize = screenSize * 0.15; // All boards same size
            
            return Center(
              child: Consumer<GameViewModel>(
                builder: (context, gameViewModel, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Animation overlay (handles connecting lines and effects)
                      AnimationOverlay(
                        mainBoardSize: boardSize,
                        mainBoardCenter: Offset(
                          constraints.maxWidth / 2,
                          constraints.maxHeight / 2,
                        ),
                        ghostPositions: _calculateGhostPositions(
                          gameViewModel,
                          boardSize,
                          constraints,
                        ),
                      ),
                      
                      // Ghost boards positioned around main board during QCI's turn
                      if (!gameViewModel.isPlayerTurn)
                        _buildGhostBoardOutline(
                          mainBoardSize: boardSize,
                          ghostBoardSize: boardSize,
                          gameViewModel: gameViewModel,
                          constraints: constraints,
                        ),
                      
                      // Main board (always visible)
                      MainBoard(
                        size: boardSize,
                      ),
                      
                      // Placeholder for mutation button (bottom center)
                      Positioned(
                        bottom: 24,
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                          ),
                          child: const Center(
                            child: Icon(Icons.auto_fix_high, size: 32, color: Colors.grey),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
  
  // Calculate ghost board positions based on animation phase
  List<Offset> _calculateGhostPositions(
    GameViewModel gameViewModel,
    double mainBoardSize,
    BoxConstraints constraints,
  ) {
    final animationViewModel = gameViewModel.animationViewModel;
    final center = Offset(
      constraints.maxWidth / 2,
      constraints.maxHeight / 2,
    );
    
    // Calculate final positions (same as before)
    final double offset = 48.0;
    final double totalSize = mainBoardSize + mainBoardSize * 2 + offset * 4;
    final double mainStart = mainBoardSize + offset * 2;
    final double mainEnd = mainStart + mainBoardSize;
    final double centerOffset = mainBoardSize / 2 - mainBoardSize / 2;

    final List<Offset> finalPositions = [
      Offset(offset, offset), // Top-left
      Offset(mainStart + centerOffset, offset), // Top-middle
      Offset(mainEnd + offset, offset), // Top-right
      Offset(mainEnd + offset, mainStart + centerOffset), // Right-middle
      Offset(mainEnd + offset, mainEnd + offset), // Bottom-right
      Offset(mainStart + centerOffset, mainEnd + offset), // Bottom-middle
      Offset(offset, mainEnd + offset), // Bottom-left
      Offset(offset, mainStart + centerOffset), // Left-middle
    ];
    
    // Let the AnimationViewModel handle position interpolation
    return animationViewModel.calculateGhostPositions(
      center: center,
      radius: totalSize / 2,
      finalPositions: finalPositions,
    );
  }
  
  // Build ghost boards positioned around the main board
  Widget _buildGhostBoardOutline({
    required double mainBoardSize,
    required double ghostBoardSize,
    required GameViewModel gameViewModel,
    required BoxConstraints constraints,
  }) {
    final quantumMind = gameViewModel.quantumMind;
    final ghostBoards = quantumMind.ghostBoards;
    final positions = _calculateGhostPositions(
      gameViewModel,
      mainBoardSize,
      constraints,
    );

    return SizedBox.expand(
      child: Stack(
        clipBehavior: Clip.none,
        children: List.generate(8, (i) {
          final ghostBoard = ghostBoards[i];
          final strategy = quantumMind.getStrategy(i);
          final pos = positions[i];
          
          return Positioned(
            left: pos.dx,
            top: pos.dy,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  strategy?.basisState ?? 'Ghost',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.withOpacity(0.7),
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
                  opacity: 0.6,
                  strategyName: ghostBoard.basisState,
                  phase: ghostBoard.proposedMove.amplitude.phase,
                  magnitude: ghostBoard.proposedMove.amplitude.magnitude,
                  pulseFactor: gameViewModel.animationViewModel.pulseValue,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
  
  // Helper method to create a board showing the suggested move
  List<List<String>> _createBoardWithSuggestion(
    List<List<String>> currentBoard,
    dynamic proposedMove,
  ) {
    final board = List.generate(
      3,
      (row) => List.generate(
        3,
        (col) => currentBoard[row][col],
      ),
    );
    
    if (proposedMove != null && proposedMove.position != null) {
      final pos = proposedMove.position;
      if (pos.row >= 0 && pos.row < 3 && pos.col >= 0 && pos.col < 3) {
        board[pos.row][pos.col] = proposedMove.player;
      }
    }
    
    return board;
  }
} 