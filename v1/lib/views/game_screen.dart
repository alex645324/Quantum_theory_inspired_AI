// GameScreen widget for QCI Tic-Tac-Toe
// Main game interface with AppBar and body layout

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../viewmodels/game_view_model.dart';
import '../models/game_state.dart';
import 'main_board.dart';
import 'ghost_board.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {

  @override
  void dispose() {
    super.dispose();
  }

  // Calculate main board scale based on current animation state
  double _getMainBoardScale(animationViewModel) {
    double baseScale = 1.0 + (animationViewModel.mainBoardPulseAnimation.value * 0.05);
    
    if (animationViewModel.isFinalMerging) {
      // During final merge, use the scale-up animation
      return baseScale * animationViewModel.mainBoardScaleUpAnimation.value;
    } else if (animationViewModel.isShrinking) {
      // During shrinking phase
      return baseScale * animationViewModel.mainBoardShrinkAnimation.value;
    } else {
      // Normal state - just pulse
      return baseScale;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameViewModel(this),
      child: Consumer<GameViewModel>(
        builder: (context, gameViewModel, child) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8F9FA), // Cool, soft white background
            body: LayoutBuilder(
              builder: (context, constraints) {
                // Calculate sizes based on screen constraints
                final screenSize = (constraints.maxWidth < constraints.maxHeight
                        ? constraints.maxWidth
                        : constraints.maxHeight) * 0.85;
                
                // Make all boards the same size
                final boardSize = screenSize * 0.15; // All boards same size
                final mainBoardSize = boardSize * 2; // Main board is larger
                
                return Consumer<GameViewModel>(
                  builder: (context, gameViewModel, child) {
                    return AnimatedBuilder(
                      animation: gameViewModel.animationViewModel,
                      builder: (context, child) {
                        final animationViewModel = gameViewModel.animationViewModel;
                        final isEmerging = animationViewModel.isEmerging;
                        final isFloating = animationViewModel.isFloating;
                        final emergenceScale = animationViewModel.emergenceScaleAnimation.value;
                        
                        return Stack(
                          children: [
                            // Background dimming overlay
                            if (animationViewModel.isDimming)
                              Positioned.fill(
                                child: Container(
                                  color: Colors.black.withOpacity(
                                    animationViewModel.isFinalUndimming 
                                      ? animationViewModel.dimmingAnimation.value * animationViewModel.finalUndimAnimation.value
                                      : animationViewModel.dimmingAnimation.value
                                  ),
                                ),
                              ),
                            
                            // Main game area - boards (main board will be dimmed by overlay above)
                            Center(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Main board with pulse, shrink, and scale-up animations (invisible during dimming, visible during return)
                                  Opacity(
                                    opacity: (animationViewModel.isDimming && !animationViewModel.isReturning) ? 0.0 : 
                                            animationViewModel.isReturning ? animationViewModel.returnAnimation.value : 1.0,
                                    child: Transform.scale(
                                      scale: _getMainBoardScale(animationViewModel),
                                      child: MainBoard(
                                        size: mainBoardSize,
                                      ),
                                    ),
                                  ),
                                  
                                  // Ghost boards (stay undimmed - rendered after dimming overlay)
                                  if (!gameViewModel.isPlayerTurn) ...[
                                    Transform.scale(
                                      scale: animationViewModel.ghostForwardAnimation.value,
                                      child: _buildGhostBoardOutline(
                                        mainBoardSize: mainBoardSize,
                                        ghostBoardSize: boardSize,
                                        gameViewModel: gameViewModel,
                                        emergenceScale: emergenceScale,
                                        emergenceOpacity: animationViewModel.emergenceOpacityAnimation.value,
                                        floatingOffset: isFloating ? animationViewModel.getFloatingOffset() : 0.0,
                                        columnArrangementProgress: animationViewModel.columnArrangementAnimation.value,
                                        isArranging: animationViewModel.isArranging,
                                        winnerPulseIntensity: animationViewModel.winnerPulseAnimation.value,
                                        isPulsing: animationViewModel.isPulsing,
                                        returnProgress: animationViewModel.returnAnimation.value,
                                        isReturning: animationViewModel.isReturning,
                                        finalMergeProgress: animationViewModel.finalMergeAnimation.value,
                                        isFinalMerging: animationViewModel.isFinalMerging,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            
                            // Change Rules button - always at bottom, separate from game elements
                            Positioned(
                              bottom: 24,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: TextButton(
                                  onPressed: () {
                                    // TODO: Implement rule changes
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Theme.of(context).colorScheme.primary,
                                    backgroundColor: Colors.white.withOpacity(0.9),
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    elevation: 4,
                                  ),
                                  child: const Text(
                                    'Change Rules',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
  
  // Build ghost boards positioned around the main board
  Widget _buildGhostBoardOutline({
    required double mainBoardSize,
    required double ghostBoardSize,
    required GameViewModel gameViewModel,
    required double emergenceScale,
    required double emergenceOpacity,
    required double floatingOffset,
    double columnArrangementProgress = 0.0,
    bool isArranging = false,
    double winnerPulseIntensity = 0.0,
    bool isPulsing = false,
    double returnProgress = 0.0,
    bool isReturning = false,
    double finalMergeProgress = 0.0,
    bool isFinalMerging = false,
  }) {
    final quantumMind = gameViewModel.quantumMind;
    final ghostBoards = quantumMind.ghostBoards;
    
    final double offset = 48.0; // Increased gap between boards for better spacing
    final double totalSize = mainBoardSize + ghostBoardSize * 2 + offset * 4; // Added extra offset for outer padding
    final double mainStart = ghostBoardSize + offset * 2; // Double offset for outer padding
    final double mainEnd = mainStart + mainBoardSize;
    final double centerOffset = mainBoardSize / 2 - ghostBoardSize / 2;
    
    // Group ghost boards by their moves for column arrangement
    Map<String, List<int>> moveGroups = {};
    Position? quantumWinningPosition;
    if (isArranging) {
      for (int i = 0; i < ghostBoards.length; i++) {
        final move = ghostBoards[i].proposedMove;
        final moveKey = '${move.position?.row ?? -1}_${move.position?.col ?? -1}';
        moveGroups[moveKey] = (moveGroups[moveKey] ?? [])..add(i);
      }
      
      // Determine quantum winning position if pulsing
      if (isPulsing) {
        quantumWinningPosition = quantumMind.getQuantumWinningPosition();
      }
    }

    // 8 positions: TL, TM, TR, RM, BR, BM, BL, LM (clockwise from top-left)
    final List<Offset> positions = [
      // Top-left corner
      Offset(offset, offset),
      // Top-middle
      Offset(mainStart + centerOffset, offset),
      // Top-right corner
      Offset(mainEnd + offset, offset),
      // Right-middle
      Offset(mainEnd + offset, mainStart + centerOffset),
      // Bottom-right corner
      Offset(mainEnd + offset, mainEnd + offset),
      // Bottom-middle
      Offset(mainStart + centerOffset, mainEnd + offset),
      // Bottom-left corner
      Offset(offset, mainEnd + offset),
      // Left-middle
      Offset(offset, mainStart + centerOffset),
    ];

    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: totalSize,
        height: totalSize,
        child: Stack(
          clipBehavior: Clip.none,
          children: List.generate(8, (i) {
            final pos = positions[i];
            final ghostBoard = ghostBoards[i];
            final strategy = quantumMind.getStrategy(i);
            
            // Calculate emergence position (start from center)
            final centerX = totalSize / 2 - ghostBoardSize / 2;
            final centerY = totalSize / 2 - ghostBoardSize / 2;
            final targetX = pos.dx;
            final targetY = pos.dy;
            
            double currentX = centerX + (targetX - centerX) * emergenceScale;
            double currentY = centerY + (targetY - centerY) * emergenceScale;
            
            // Row arrangement positioning
            if (isArranging && columnArrangementProgress > 0) {
              final move = ghostBoard.proposedMove;
              final moveKey = '${move.position?.row ?? -1}_${move.position?.col ?? -1}';
              final groupMembers = moveGroups[moveKey] ?? [];
              final indexInGroup = groupMembers.indexOf(i);
              final groupIndex = moveGroups.keys.toList().indexOf(moveKey);
              
              // Calculate row position
              final rowsCount = moveGroups.length;
              final rowHeight = totalSize / (rowsCount + 1);
              final rowY = (groupIndex + 1) * rowHeight - ghostBoardSize / 2;
              final rowX = centerX + (indexInGroup - (groupMembers.length - 1) / 2) * (ghostBoardSize + 20);
              
              // Store final row positions
              final finalRowX = rowX;
              final finalRowY = rowY;
              
              // If returning, interpolate from row back to original position
              if (isReturning && returnProgress > 0) {
                currentX = finalRowX + (currentX - finalRowX) * returnProgress;
                currentY = finalRowY + (currentY - finalRowY) * returnProgress;
              } else {
                // Normal arrangement: interpolate to row position
                currentX = currentX + (rowX - currentX) * columnArrangementProgress;
                currentY = currentY + (rowY - currentY) * columnArrangementProgress;
              }
            }
            
            // Final merge: ghost boards move toward the main board position (merge back into main board)
            if (isFinalMerging) {
              // Calculate the main board's current position (always centered)
              final mainBoardX = centerX;
              final mainBoardY = centerY;
              
              // finalMergeProgress goes from 1.0 (original positions) to 0.0 (merged to center)
              // So as finalMergeProgress decreases, ghost boards should move closer to center
              // Use (1.0 - finalMergeProgress) to get merge progress from 0.0 to 1.0
              final actualMergeProgress = 1.0 - finalMergeProgress;
              
              // Interpolate from current position toward main board center
              currentX = currentX + (mainBoardX - currentX) * actualMergeProgress;
              currentY = currentY + (mainBoardY - currentY) * actualMergeProgress;
            }
            
            // Enhanced scale effect for "emerging from behind"
            final enhancedScale = emergenceScale * 0.8 + 0.2; // Start smaller, scale up more dramatically
            
            // Check if this board is in the winning row (quantum determination)
            final isInWinningRow = isPulsing && 
                quantumWinningPosition != null && 
                ghostBoard.proposedMove.position?.row == quantumWinningPosition!.row && 
                ghostBoard.proposedMove.position?.col == quantumWinningPosition!.col;
            
            // Calculate opacity for final merge (fade out during merge)
            double finalOpacity = emergenceOpacity;
            if (isFinalMerging) {
              // finalMergeProgress goes from 1.0 to 0.0 during the animation
              // We want ghost boards to fade out as they merge, so use finalMergeProgress directly
              // When finalMergeProgress = 1.0 (start) → full opacity
              // When finalMergeProgress = 0.0 (end) → zero opacity (fully faded)
              finalOpacity = emergenceOpacity * finalMergeProgress;
            }
            
            Widget ghostBoardWidget = GhostBoard(
              board: _createBoardWithSuggestion(gameViewModel.board, ghostBoard.proposedMove),
              size: ghostBoardSize,
              opacity: finalOpacity,
              strategyName: strategy?.basisState ?? 'Ghost',
              phase: ghostBoard.proposedMove.amplitude.phase,
              magnitude: ghostBoard.proposedMove.amplitude.magnitude,
              scale: 1.0, // Remove the scale from GhostBoard since we're handling it here
              floatingOffset: floatingOffset,
              showLabel: emergenceScale > 0.9, // Only show label near final position
            );
            
            // Add green outline pulse effect for winning row
            if (isInWinningRow && winnerPulseIntensity > 0) {
              ghostBoardWidget = Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.green.withOpacity(winnerPulseIntensity),
                    width: 1.0 + (winnerPulseIntensity * 1.0), // Thinner outline
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ghostBoardWidget,
              );
            }
            
            return Positioned(
              left: currentX,
              top: currentY,
              child: Transform.scale(
                scale: enhancedScale,
                child: ghostBoardWidget,
              ),
            );
          }),
        ),
      ),
    );
  }
  
  // Helper method to create a board showing the suggested move
  List<List<String>> _createBoardWithSuggestion(List<List<String>> currentBoard, dynamic proposedMove) {
    // Create a copy of the current board
    final board = List.generate(
      3,
      (row) => List.generate(
        3,
        (col) => currentBoard[row][col],
      ),
    );
    
    // If there's a valid proposed move, highlight it with a special marker
    if (proposedMove != null && proposedMove.position != null) {
      final pos = proposedMove.position;
      if (pos.row >= 0 && pos.row < 3 && pos.col >= 0 && pos.col < 3) {
        board[pos.row][pos.col] = proposedMove.player;
      }
    }
    
    return board;
  }
} 