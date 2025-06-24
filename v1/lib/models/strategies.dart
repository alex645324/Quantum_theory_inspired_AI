// Quantum Strategy classes for QCI Tic-Tac-Toe
// Each strategy represents a different 'way of thinking' in superposition

import 'dart:math' as math;
import 'game_state.dart';
import 'quantum_move.dart';

// Abstract base class for all quantum strategies
abstract class Strategy {
  // Quantum-inspired: The type/name of this strategy's basis state
  String get basisState;
  
  // Quantum-inspired: Base phase offset for this strategy (0° to 315° in 45° increments)
  double get basePhase;
  
  // Quantum-inspired: Suggest a move based on this strategy's thinking
  QuantumMove suggest(GameState gameState);
  
  // Helper to create complex amplitude with magnitude and strategy-specific phase
  ComplexAmplitude _createAmplitude(double magnitude) {
    // Add some small random variation to the base phase (-π/8 to +π/8)
    final variation = (math.Random().nextDouble() - 0.5) * math.pi / 4;
    final phase = basePhase + variation;
    return ComplexAmplitude(magnitude: magnitude, phase: phase);
  }
  
  // Helper to get valid corners based on board rules
  List<Position> getValidCorners(GameState gameState) {
    final corners = <Position>[];
    final maxCol = gameState.rules.additionalColumn ? 3 : 2;
    
    // Add all corners
    corners.add(const Position(0, 0));
    corners.add(Position(0, maxCol));
    corners.add(Position(2, 0));
    corners.add(Position(2, maxCol));
    
    return corners;
  }
  
  // Helper to get valid edges based on board rules
  List<Position> getValidEdges(GameState gameState) {
    final edges = <Position>[];
    final maxCol = gameState.rules.additionalColumn ? 3 : 2;
    
    // Add all edges
    edges.add(const Position(0, 1));
    edges.add(const Position(1, 0));
    if (gameState.rules.centerAvailable) {
      edges.add(const Position(1, 1));
    }
    edges.add(Position(1, maxCol));
    edges.add(Position(2, 1));
    if (gameState.rules.additionalColumn) {
      edges.add(const Position(0, 2));
      edges.add(const Position(1, 2));
      edges.add(const Position(2, 2));
    }
    
    return edges;
  }
  
  // Helper to check if a position is valid under current rules
  bool isValidPosition(Position pos, GameState gameState) {
    final maxCol = gameState.rules.additionalColumn ? 3 : 2;
    
    return pos.row >= 0 && pos.row <= 2 &&
           pos.col >= 0 && pos.col <= maxCol &&
           (gameState.rules.centerAvailable || pos.row != 1 || pos.col != 1);
  }
}

// CenterStrategy: Always prioritizes center, then corners, then edges
// Personality: Direct and focused, believes in controlling the center
class CenterStrategy extends Strategy {
  @override
  String get basisState => 'Center';
  
  @override
  double get basePhase => 0.0; // 0°
  
  @override
  QuantumMove suggest(GameState gameState) {
    final availableMoves = gameState.getAvailableMoves();
    if (availableMoves.isEmpty) {
      // No moves available, return a default move
      return QuantumMove(
        position: const Position(0, 0),
        amplitude: _createAmplitude(0.0),
        basisState: basisState,
        player: gameState.currentPlayer,
      );
    }
    
    // Priority order: center, corners, edges
    final center = const Position(1, 1);
    final corners = [
      const Position(0, 0), const Position(0, 2),
      const Position(2, 0), const Position(2, 2),
    ];
    final edges = [
      const Position(0, 1), const Position(1, 0),
      const Position(1, 2), const Position(2, 1),
    ];
    
    // Check if center is available
    if (availableMoves.contains(center)) {
      return QuantumMove(
        position: center,
        amplitude: _createAmplitude(1.0), // High confidence for center
        basisState: basisState,
        player: gameState.currentPlayer,
      );
    }
    
    // Check if any corners are available
    for (final corner in corners) {
      if (availableMoves.contains(corner)) {
        return QuantumMove(
          position: corner,
          amplitude: _createAmplitude(0.8), // High confidence for corners
          basisState: basisState,
          player: gameState.currentPlayer,
        );
      }
    }
    
    // Check if any edges are available
    for (final edge in edges) {
      if (availableMoves.contains(edge)) {
        return QuantumMove(
          position: edge,
          amplitude: _createAmplitude(0.6), // Medium confidence for edges
          basisState: basisState,
          player: gameState.currentPlayer,
        );
      }
    }
    
    // Fallback: pick first available move
    return QuantumMove(
      position: availableMoves.first,
      amplitude: _createAmplitude(0.3), // Low confidence for fallback
      basisState: basisState,
      player: gameState.currentPlayer,
    );
  }
}

// DefensiveStrategy: Blocks opponent winning moves first
// Personality: Cautious and protective, prioritizes defense over offense
class DefensiveStrategy extends Strategy {
  @override
  String get basisState => 'Defensive';
  
  @override
  double get basePhase => math.pi / 4; // 45°
  
  @override
  QuantumMove suggest(GameState gameState) {
    final availableMoves = gameState.getAvailableMoves();
    if (availableMoves.isEmpty) {
      return QuantumMove(
        position: const Position(0, 0),
        amplitude: _createAmplitude(0.0),
        basisState: basisState,
        player: gameState.currentPlayer,
      );
    }
    
    // First priority: Block opponent's winning moves
    final opponent = gameState.currentPlayer == 'X' ? 'O' : 'X';
    final blockingMove = _findBlockingMove(gameState, opponent);
    if (blockingMove != null) {
      return QuantumMove(
        position: blockingMove,
        amplitude: _createAmplitude(0.9), // Very high confidence for blocking
        basisState: basisState,
        player: gameState.currentPlayer,
      );
    }
    
    // Second priority: Take center if available
    final center = const Position(1, 1);
    if (availableMoves.contains(center)) {
      return QuantumMove(
        position: center,
        amplitude: _createAmplitude(0.7), // High confidence for center
        basisState: basisState,
        player: gameState.currentPlayer,
      );
    }
    
    // Third priority: Take corners
    final corners = [
      const Position(0, 0), const Position(0, 2),
      const Position(2, 0), const Position(2, 2),
    ];
    for (final corner in corners) {
      if (availableMoves.contains(corner)) {
        return QuantumMove(
          position: corner,
          amplitude: _createAmplitude(0.6), // Medium confidence for corners
          basisState: basisState,
          player: gameState.currentPlayer,
        );
      }
    }
    
    // Fallback: pick first available move
    return QuantumMove(
      position: availableMoves.first,
      amplitude: _createAmplitude(0.3), // Low confidence for fallback
      basisState: basisState,
      player: gameState.currentPlayer,
    );
  }
  
  // Helper method to find a move that blocks opponent's win
  Position? _findBlockingMove(GameState gameState, String opponent) {
    final board = gameState.board;
    
    // Check rows
    for (int row = 0; row < 3; row++) {
      if (_countInRow(board, row, opponent) == 2 && _countInRow(board, row, '') == 1) {
        for (int col = 0; col < 3; col++) {
          if (board[row][col].isEmpty) {
            return Position(row, col);
          }
        }
      }
    }
    
    // Check columns
    for (int col = 0; col < 3; col++) {
      if (_countInColumn(board, col, opponent) == 2 && _countInColumn(board, col, '') == 1) {
        for (int row = 0; row < 3; row++) {
          if (board[row][col].isEmpty) {
            return Position(row, col);
          }
        }
      }
    }
    
    // Check diagonals
    if (_countInDiagonal(board, opponent, true) == 2 && _countInDiagonal(board, '', true) == 1) {
      for (int i = 0; i < 3; i++) {
        if (board[i][i].isEmpty) {
          return Position(i, i);
        }
      }
    }
    
    if (_countInDiagonal(board, opponent, false) == 2 && _countInDiagonal(board, '', false) == 1) {
      for (int i = 0; i < 3; i++) {
        if (board[i][2-i].isEmpty) {
          return Position(i, 2-i);
        }
      }
    }
    
    return null;
  }
  
  // Helper methods for counting pieces
  int _countInRow(List<List<String>> board, int row, String piece) {
    return board[row].where((cell) => cell == piece).length;
  }
  
  int _countInColumn(List<List<String>> board, int col, String piece) {
    return board.where((row) => row[col] == piece).length;
  }
  
  int _countInDiagonal(List<List<String>> board, String piece, bool mainDiagonal) {
    int count = 0;
    for (int i = 0; i < 3; i++) {
      if (mainDiagonal) {
        if (board[i][i] == piece) count++;
      } else {
        if (board[i][2-i] == piece) count++;
      }
    }
    return count;
  }
}

// MirrorStrategy: Copies/mirrors opponent patterns
// Personality: Adaptive and reactive, learns from opponent's style
class MirrorStrategy extends Strategy {
  @override
  String get basisState => 'Mirror';
  
  @override
  double get basePhase => math.pi / 2; // 90°
  
  @override
  QuantumMove suggest(GameState gameState) {
    final availableMoves = gameState.getAvailableMoves();
    if (availableMoves.isEmpty) {
      return QuantumMove(
        position: const Position(0, 0),
        amplitude: _createAmplitude(0.0),
        basisState: basisState,
        player: gameState.currentPlayer,
      );
    }
    
    // If this is the first move, take center
    if (gameState.board.every((row) => row.every((cell) => cell.isEmpty))) {
      final center = const Position(1, 1);
      if (availableMoves.contains(center)) {
        return QuantumMove(
          position: center,
          amplitude: _createAmplitude(0.8), // High confidence for center on first move
          basisState: basisState,
          player: gameState.currentPlayer,
        );
      }
    }
    
    // Try to mirror the opponent's last move
    final mirroredMove = _findMirroredMove(gameState);
    if (mirroredMove != null && availableMoves.contains(mirroredMove)) {
      return QuantumMove(
        position: mirroredMove,
        amplitude: _createAmplitude(0.7), // High confidence for mirroring
        basisState: basisState,
        player: gameState.currentPlayer,
      );
    }
    
    // If mirroring isn't possible, try to complete a pattern
    final patternMove = _findPatternMove(gameState);
    if (patternMove != null && availableMoves.contains(patternMove)) {
      return QuantumMove(
        position: patternMove,
        amplitude: _createAmplitude(0.6), // Medium confidence for pattern completion
        basisState: basisState,
        player: gameState.currentPlayer,
      );
    }
    
    // Fallback: take center or first available move
    final center = const Position(1, 1);
    if (availableMoves.contains(center)) {
      return QuantumMove(
        position: center,
        amplitude: _createAmplitude(0.5), // Medium confidence for center
        basisState: basisState,
        player: gameState.currentPlayer,
      );
    }
    
    return QuantumMove(
      position: availableMoves.first,
      amplitude: _createAmplitude(0.3), // Low confidence for fallback
      basisState: basisState,
      player: gameState.currentPlayer,
    );
  }
  
  // Helper method to find a move that mirrors the opponent's last move
  Position? _findMirroredMove(GameState gameState) {
    final board = gameState.board;
    final opponent = gameState.currentPlayer == 'X' ? 'O' : 'X';
    
    // Find opponent's pieces and try to mirror them
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 3; col++) {
        if (board[row][col] == opponent) {
          // Try to mirror across center
          final mirroredRow = 2 - row;
          final mirroredCol = 2 - col;
          if (board[mirroredRow][mirroredCol].isEmpty) {
            return Position(mirroredRow, mirroredCol);
          }
        }
      }
    }
    
    return null;
  }
  
  // Helper method to find a move that completes a pattern
  Position? _findPatternMove(GameState gameState) {
    final board = gameState.board;
    final player = gameState.currentPlayer;
    
    // Look for two of player's pieces in a row/column/diagonal
    // and complete the pattern if possible
    
    // Check rows
    for (int row = 0; row < 3; row++) {
      if (_countInRow(board, row, player) == 2 && _countInRow(board, row, '') == 1) {
        for (int col = 0; col < 3; col++) {
          if (board[row][col].isEmpty) {
            return Position(row, col);
          }
        }
      }
    }
    
    // Check columns
    for (int col = 0; col < 3; col++) {
      if (_countInColumn(board, col, player) == 2 && _countInColumn(board, col, '') == 1) {
        for (int row = 0; row < 3; row++) {
          if (board[row][col].isEmpty) {
            return Position(row, col);
          }
        }
      }
    }
    
    return null;
  }
  
  // Helper methods for counting pieces (reused from DefensiveStrategy)
  int _countInRow(List<List<String>> board, int row, String piece) {
    return board[row].where((cell) => cell == piece).length;
  }
  
  int _countInColumn(List<List<String>> board, int col, String piece) {
    return board.where((row) => row[col] == piece).length;
  }
}

// ForkStrategy: Sets up multiple win conditions simultaneously
// Personality: Strategic and opportunistic, creates complex winning scenarios
class ForkStrategy extends Strategy {
  @override
  String get basisState => 'Fork';
  
  @override
  double get basePhase => 3 * math.pi / 4; // 135°
  
  @override
  QuantumMove suggest(GameState gameState) {
    final availableMoves = gameState.getAvailableMoves();
    if (availableMoves.isEmpty) {
      return QuantumMove(
        position: const Position(0, 0),
        amplitude: _createAmplitude(0.0),
        basisState: basisState,
        player: gameState.currentPlayer,
      );
    }
    
    // First priority: Create a fork (multiple winning opportunities)
    final forkMove = _findForkMove(gameState);
    if (forkMove != null && availableMoves.contains(forkMove)) {
      return QuantumMove(
        position: forkMove,
        amplitude: _createAmplitude(0.9), // Very high confidence for fork creation
        basisState: basisState,
        player: gameState.currentPlayer,
      );
    }
    
    // Second priority: Block opponent's fork
    final opponent = gameState.currentPlayer == 'X' ? 'O' : 'X';
    final blockingForkMove = _findForkMove(gameState, opponent);
    if (blockingForkMove != null && availableMoves.contains(blockingForkMove)) {
      return QuantumMove(
        position: blockingForkMove,
        amplitude: _createAmplitude(0.8), // High confidence for blocking fork
        basisState: basisState,
        player: gameState.currentPlayer,
      );
    }
    
    // Third priority: Take center
    final center = const Position(1, 1);
    if (availableMoves.contains(center)) {
      return QuantumMove(
        position: center,
        amplitude: _createAmplitude(0.7), // High confidence for center
        basisState: basisState,
        player: gameState.currentPlayer,
      );
    }
    
    // Fourth priority: Take corners (good for creating forks)
    final corners = [
      const Position(0, 0), const Position(0, 2),
      const Position(2, 0), const Position(2, 2),
    ];
    for (final corner in corners) {
      if (availableMoves.contains(corner)) {
        return QuantumMove(
          position: corner,
          amplitude: _createAmplitude(0.6), // Medium confidence for corners
          basisState: basisState,
          player: gameState.currentPlayer,
        );
      }
    }
    
    // Fallback: pick first available move
    return QuantumMove(
      position: availableMoves.first,
      amplitude: _createAmplitude(0.3), // Low confidence for fallback
      basisState: basisState,
      player: gameState.currentPlayer,
    );
  }
  
  // Helper method to find a move that creates a fork
  Position? _findForkMove(GameState gameState, [String? player]) {
    final targetPlayer = player ?? gameState.currentPlayer;
    final availableMoves = gameState.getAvailableMoves();
    
    // Check each available move to see if it creates multiple winning opportunities
    for (final move in availableMoves) {
      if (_createsFork(gameState, move, targetPlayer)) {
        return move;
      }
    }
    
    return null;
  }
  
  // Helper method to check if a move creates a fork
  bool _createsFork(GameState gameState, Position move, String player) {
    // Create a temporary board with this move
    final tempBoard = gameState.board.map((row) => List<String>.from(row)).toList();
    tempBoard[move.row][move.col] = player;
    
    // Count how many winning opportunities this creates
    int winningOpportunities = 0;
    
    // Check rows
    for (int row = 0; row < 3; row++) {
      if (_countInRow(tempBoard, row, player) == 2 && _countInRow(tempBoard, row, '') == 1) {
        winningOpportunities++;
      }
    }
    
    // Check columns
    for (int col = 0; col < 3; col++) {
      if (_countInColumn(tempBoard, col, player) == 2 && _countInColumn(tempBoard, col, '') == 1) {
        winningOpportunities++;
      }
    }
    
    // Check diagonals
    if (_countInDiagonal(tempBoard, player, true) == 2 && _countInDiagonal(tempBoard, '', true) == 1) {
      winningOpportunities++;
    }
    if (_countInDiagonal(tempBoard, player, false) == 2 && _countInDiagonal(tempBoard, '', false) == 1) {
      winningOpportunities++;
    }
    
    // A fork creates at least 2 winning opportunities
    return winningOpportunities >= 2;
  }
  
  // Helper methods for counting pieces (reused from previous strategies)
  int _countInRow(List<List<String>> board, int row, String piece) {
    return board[row].where((cell) => cell == piece).length;
  }
  
  int _countInColumn(List<List<String>> board, int col, String piece) {
    return board.where((row) => row[col] == piece).length;
  }
  
  int _countInDiagonal(List<List<String>> board, String piece, bool mainDiagonal) {
    int count = 0;
    for (int i = 0; i < 3; i++) {
      if (mainDiagonal) {
        if (board[i][i] == piece) count++;
      } else {
        if (board[i][2-i] == piece) count++;
      }
    }
    return count;
  }
}

// AggressiveStrategy: Always goes for immediate wins
// Personality: Bold and direct, prioritizes winning over everything else
class AggressiveStrategy extends Strategy {
  @override
  String get basisState => 'Aggressive';
  
  @override
  double get basePhase => math.pi; // 180°
  
  @override
  QuantumMove suggest(GameState gameState) {
    final availableMoves = gameState.getAvailableMoves();
    if (availableMoves.isEmpty) {
      return QuantumMove(
        position: const Position(0, 0),
        amplitude: _createAmplitude(0.0),
        basisState: basisState,
        player: gameState.currentPlayer,
      );
    }
    
    // First priority: Win immediately if possible
    final winningMove = _findWinningMove(gameState);
    if (winningMove != null && availableMoves.contains(winningMove)) {
      return QuantumMove(
        position: winningMove,
        amplitude: _createAmplitude(1.0), // Maximum confidence for immediate win
        basisState: basisState,
        player: gameState.currentPlayer,
      );
    }
    
    // Second priority: Block opponent's immediate win
    final opponent = gameState.currentPlayer == 'X' ? 'O' : 'X';
    final blockingMove = _findWinningMove(gameState, opponent);
    if (blockingMove != null && availableMoves.contains(blockingMove)) {
      return QuantumMove(
        position: blockingMove,
        amplitude: _createAmplitude(0.9), // Very high confidence for blocking win
        basisState: basisState,
        player: gameState.currentPlayer,
      );
    }
    
    // Third priority: Create a winning opportunity
    final opportunityMove = _findOpportunityMove(gameState);
    if (opportunityMove != null && availableMoves.contains(opportunityMove)) {
      return QuantumMove(
        position: opportunityMove,
        amplitude: _createAmplitude(0.8), // High confidence for creating opportunity
        basisState: basisState,
        player: gameState.currentPlayer,
      );
    }
    
    // Fourth priority: Take center
    final center = const Position(1, 1);
    if (availableMoves.contains(center)) {
      return QuantumMove(
        position: center,
        amplitude: _createAmplitude(0.7), // High confidence for center
        basisState: basisState,
        player: gameState.currentPlayer,
      );
    }
    
    // Fifth priority: Take corners
    final corners = [
      const Position(0, 0), const Position(0, 2),
      const Position(2, 0), const Position(2, 2),
    ];
    for (final corner in corners) {
      if (availableMoves.contains(corner)) {
        return QuantumMove(
          position: corner,
          amplitude: _createAmplitude(0.6), // Medium confidence for corners
          basisState: basisState,
          player: gameState.currentPlayer,
        );
      }
    }
    
    // Fallback: pick first available move
    return QuantumMove(
      position: availableMoves.first,
      amplitude: _createAmplitude(0.4), // Medium-low confidence for fallback
      basisState: basisState,
      player: gameState.currentPlayer,
    );
  }
  
  // Helper method to find a move that wins immediately
  Position? _findWinningMove(GameState gameState, [String? player]) {
    final targetPlayer = player ?? gameState.currentPlayer;
    final availableMoves = gameState.getAvailableMoves();
    
    for (final move in availableMoves) {
      if (_createsWin(gameState, move, targetPlayer)) {
        return move;
      }
    }
    
    return null;
  }
  
  // Helper method to find a move that creates a winning opportunity
  Position? _findOpportunityMove(GameState gameState) {
    final availableMoves = gameState.getAvailableMoves();
    
    for (final move in availableMoves) {
      if (_createsOpportunity(gameState, move)) {
        return move;
      }
    }
    
    return null;
  }
  
  // Helper method to check if a move creates an immediate win
  bool _createsWin(GameState gameState, Position move, String player) {
    final tempBoard = gameState.board.map((row) => List<String>.from(row)).toList();
    tempBoard[move.row][move.col] = player;
    
    // Check if this creates a win
    return _hasWinningLine(tempBoard, player);
  }
  
  // Helper method to check if a move creates a winning opportunity
  bool _createsOpportunity(GameState gameState, Position move) {
    final tempBoard = gameState.board.map((row) => List<String>.from(row)).toList();
    tempBoard[move.row][move.col] = gameState.currentPlayer;
    
    // Check if this creates a line with 2 of player's pieces and 1 empty
    return _hasWinningOpportunity(tempBoard, gameState.currentPlayer);
  }
  
  // Helper method to check if board has a winning line
  bool _hasWinningLine(List<List<String>> board, String player) {
    // Check rows
    for (int row = 0; row < 3; row++) {
      if (board[row].every((cell) => cell == player)) {
        return true;
      }
    }
    
    // Check columns
    for (int col = 0; col < 3; col++) {
      if (board.every((row) => row[col] == player)) {
        return true;
      }
    }
    
    // Check diagonals
    if (board[0][0] == player && board[1][1] == player && board[2][2] == player) {
      return true;
    }
    if (board[0][2] == player && board[1][1] == player && board[2][0] == player) {
      return true;
    }
    
    return false;
  }
  
  // Helper method to check if board has a winning opportunity
  bool _hasWinningOpportunity(List<List<String>> board, String player) {
    // Check rows
    for (int row = 0; row < 3; row++) {
      if (_countInRow(board, row, player) == 2 && _countInRow(board, row, '') == 1) {
        return true;
      }
    }
    
    // Check columns
    for (int col = 0; col < 3; col++) {
      if (_countInColumn(board, col, player) == 2 && _countInColumn(board, col, '') == 1) {
        return true;
      }
    }
    
    // Check diagonals
    if (_countInDiagonal(board, player, true) == 2 && _countInDiagonal(board, '', true) == 1) {
      return true;
    }
    if (_countInDiagonal(board, player, false) == 2 && _countInDiagonal(board, '', false) == 1) {
      return true;
    }
    
    return false;
  }
  
  // Helper methods for counting pieces (reused from previous strategies)
  int _countInRow(List<List<String>> board, int row, String piece) {
    return board[row].where((cell) => cell == piece).length;
  }
  
  int _countInColumn(List<List<String>> board, int col, String piece) {
    return board.where((row) => row[col] == piece).length;
  }
  
  int _countInDiagonal(List<List<String>> board, String piece, bool mainDiagonal) {
    int count = 0;
    for (int i = 0; i < 3; i++) {
      if (mainDiagonal) {
        if (board[i][i] == piece) count++;
      } else {
        if (board[i][2-i] == piece) count++;
      }
    }
    return count;
  }
}

// RandomStrategy: Makes unpredictable/chaotic moves
// Personality: Unpredictable and chaotic, adds entropy to the system
class RandomStrategy extends Strategy {
  @override
  String get basisState => 'Random';
  
  @override
  double get basePhase => 5 * math.pi / 4; // 225°
  
  @override
  QuantumMove suggest(GameState gameState) {
    final availableMoves = gameState.getAvailableMoves();
    if (availableMoves.isEmpty) {
      return QuantumMove(
        position: const Position(0, 0),
        amplitude: _createAmplitude(0.0),
        basisState: basisState,
        player: gameState.currentPlayer,
      );
    }
    
    // Random strategy: pick a random move from available moves
    // Use a simple hash-based randomization for consistency
    final randomIndex = _getRandomIndex(availableMoves.length, gameState);
    final selectedMove = availableMoves[randomIndex];
    
    // Vary amplitude based on move type for some unpredictability
    ComplexAmplitude amplitude;
    if (_isCenter(selectedMove)) {
      amplitude = _createAmplitude(0.6); // Medium confidence for center
    } else if (_isCorner(selectedMove)) {
      amplitude = _createAmplitude(0.5); // Medium-low confidence for corners
    } else {
      amplitude = _createAmplitude(0.4); // Low confidence for edges
    }
    
    // Add some randomness to the amplitude itself
    amplitude = _getRandomOffset(gameState) * amplitude;
    amplitude = amplitude.clamp(ComplexAmplitude(magnitude: 0.1, phase: 0.0), ComplexAmplitude(magnitude: 0.9, phase: 0.0)); // Keep within reasonable bounds
    
    return QuantumMove(
      position: selectedMove,
      amplitude: amplitude,
      basisState: basisState,
      player: gameState.currentPlayer,
    );
  }
  
  // Helper method to get a pseudo-random index
  int _getRandomIndex(int max, GameState gameState) {
    // Use board state to generate a pseudo-random but consistent number
    int hash = 0;
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 3; col++) {
        final cell = gameState.board[row][col];
        hash += (row * 3 + col) * (cell.isEmpty ? 0 : cell.codeUnitAt(0));
      }
    }
    return hash % max;
  }
  
  // Helper method to get a random offset for amplitude
  ComplexAmplitude _getRandomOffset(GameState gameState) {
    // Use a different hash for amplitude variation
    int hash = 0;
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 3; col++) {
        final cell = gameState.board[row][col];
        hash += (row * 7 + col * 11) * (cell.isEmpty ? 1 : cell.codeUnitAt(0) + 1);
      }
    }
    final phase = (hash % 100) / 100.0 * 2 * math.pi;
    return ComplexAmplitude(magnitude: 0.2, phase: phase);
  }
  
  // Helper method to check if position is center
  bool _isCenter(Position position) {
    return position.row == 1 && position.col == 1;
  }
  
  // Helper method to check if position is corner
  bool _isCorner(Position position) {
    return (position.row == 0 || position.row == 2) && 
           (position.col == 0 || position.col == 2);
  }
}

// ConservativeStrategy: Plays safest moves, avoids risks
// Personality: Cautious and methodical, prioritizes safety over winning
class ConservativeStrategy extends Strategy {
  @override
  String get basisState => 'Conservative';
  
  @override
  double get basePhase => 3 * math.pi / 2; // 270°
  
  @override
  QuantumMove suggest(GameState gameState) {
    final availableMoves = gameState.getAvailableMoves();
    if (availableMoves.isEmpty) {
      return QuantumMove(
        position: const Position(0, 0),
        amplitude: _createAmplitude(0.0),
        basisState: basisState,
        player: gameState.currentPlayer,
      );
    }
    
    // First priority: Block opponent's immediate win (safety first)
    final opponent = gameState.currentPlayer == 'X' ? 'O' : 'X';
    final blockingMove = _findWinningMove(gameState, opponent);
    if (blockingMove != null && availableMoves.contains(blockingMove)) {
      return QuantumMove(
        position: blockingMove,
        amplitude: _createAmplitude(0.9), // Very high confidence for safety
        basisState: basisState,
        player: gameState.currentPlayer,
      );
    }
    
    // Second priority: Take center (safe and strong position)
    final center = const Position(1, 1);
    if (availableMoves.contains(center)) {
      return QuantumMove(
        position: center,
        amplitude: _createAmplitude(0.8), // High confidence for center
        basisState: basisState,
        player: gameState.currentPlayer,
      );
    }
    
    // Third priority: Take edges (safe, less risky than corners)
    final edges = [
      const Position(0, 1), const Position(1, 0),
      const Position(1, 2), const Position(2, 1),
    ];
    for (final edge in edges) {
      if (availableMoves.contains(edge)) {
        return QuantumMove(
          position: edge,
          amplitude: _createAmplitude(0.7), // High confidence for edges
          basisState: basisState,
          player: gameState.currentPlayer,
        );
      }
    }
    
    // Fourth priority: Take corners (only if no safer options)
    final corners = [
      const Position(0, 0), const Position(0, 2),
      const Position(2, 0), const Position(2, 2),
    ];
    for (final corner in corners) {
      if (availableMoves.contains(corner)) {
        return QuantumMove(
          position: corner,
          amplitude: _createAmplitude(0.5), // Medium confidence for corners
          basisState: basisState,
          player: gameState.currentPlayer,
        );
      }
    }
    
    // Fallback: pick first available move
    return QuantumMove(
      position: availableMoves.first,
      amplitude: _createAmplitude(0.3), // Low confidence for fallback
      basisState: basisState,
      player: gameState.currentPlayer,
    );
  }
  
  // Helper method to find a move that wins immediately (for blocking)
  Position? _findWinningMove(GameState gameState, String player) {
    final availableMoves = gameState.getAvailableMoves();
    
    for (final move in availableMoves) {
      if (_createsWin(gameState, move, player)) {
        return move;
      }
    }
    
    return null;
  }
  
  // Helper method to check if a move creates an immediate win
  bool _createsWin(GameState gameState, Position move, String player) {
    final tempBoard = gameState.board.map((row) => List<String>.from(row)).toList();
    tempBoard[move.row][move.col] = player;
    
    // Check if this creates a win
    return _hasWinningLine(tempBoard, player);
  }
  
  // Helper method to check if board has a winning line
  bool _hasWinningLine(List<List<String>> board, String player) {
    // Check rows
    for (int row = 0; row < 3; row++) {
      if (board[row].every((cell) => cell == player)) {
        return true;
      }
    }
    
    // Check columns
    for (int col = 0; col < 3; col++) {
      if (board.every((row) => row[col] == player)) {
        return true;
      }
    }
    
    // Check diagonals
    if (board[0][0] == player && board[1][1] == player && board[2][2] == player) {
      return true;
    }
    if (board[0][2] == player && board[1][1] == player && board[2][0] == player) {
      return true;
    }
    
    return false;
  }
}

// LongTermStrategy: Plans several moves ahead
// Personality: Strategic and patient, thinks long-term rather than immediate gains
class LongTermStrategy extends Strategy {
  @override
  String get basisState => 'LongTerm';
  
  @override
  double get basePhase => 7 * math.pi / 4; // 315°
  
  @override
  QuantumMove suggest(GameState gameState) {
    final availableMoves = gameState.getAvailableMoves();
    if (availableMoves.isEmpty) {
      return QuantumMove(
        position: const Position(0, 0),
        amplitude: _createAmplitude(0.0),
        basisState: basisState,
        player: gameState.currentPlayer,
      );
    }
    
    // First priority: Win immediately if possible
    final winningMove = _findWinningMove(gameState);
    if (winningMove != null && availableMoves.contains(winningMove)) {
      return QuantumMove(
        position: winningMove,
        amplitude: _createAmplitude(1.0), // Maximum confidence for immediate win
        basisState: basisState,
        player: gameState.currentPlayer,
      );
    }
    
    // Second priority: Block opponent's immediate win
    final opponent = gameState.currentPlayer == 'X' ? 'O' : 'X';
    final blockingMove = _findWinningMove(gameState, opponent);
    if (blockingMove != null && availableMoves.contains(blockingMove)) {
      return QuantumMove(
        position: blockingMove,
        amplitude: _createAmplitude(0.9), // Very high confidence for blocking
        basisState: basisState,
        player: gameState.currentPlayer,
      );
    }
    
    // Third priority: Create a fork opportunity
    final forkMove = _findForkMove(gameState);
    if (forkMove != null && availableMoves.contains(forkMove)) {
      return QuantumMove(
        position: forkMove,
        amplitude: _createAmplitude(0.8), // High confidence for fork creation
        basisState: basisState,
        player: gameState.currentPlayer,
      );
    }
    
    // Fourth priority: Block opponent's fork
    final blockingForkMove = _findForkMove(gameState, opponent);
    if (blockingForkMove != null && availableMoves.contains(blockingForkMove)) {
      return QuantumMove(
        position: blockingForkMove,
        amplitude: _createAmplitude(0.7), // High confidence for blocking fork
        basisState: basisState,
        player: gameState.currentPlayer,
      );
    }
    
    // Fifth priority: Take center (strong long-term position)
    final center = const Position(1, 1);
    if (availableMoves.contains(center)) {
      return QuantumMove(
        position: center,
        amplitude: _createAmplitude(0.6), // Medium-high confidence for center
        basisState: basisState,
        player: gameState.currentPlayer,
      );
    }
    
    // Sixth priority: Take corners (good for long-term strategy)
    final corners = [
      const Position(0, 0), const Position(0, 2),
      const Position(2, 0), const Position(2, 2),
    ];
    for (final corner in corners) {
      if (availableMoves.contains(corner)) {
        return QuantumMove(
          position: corner,
          amplitude: _createAmplitude(0.5), // Medium confidence for corners
          basisState: basisState,
          player: gameState.currentPlayer,
        );
      }
    }
    
    // Fallback: pick first available move
    return QuantumMove(
      position: availableMoves.first,
      amplitude: _createAmplitude(0.3), // Low confidence for fallback
      basisState: basisState,
      player: gameState.currentPlayer,
    );
  }
  
  // Helper method to find a move that wins immediately
  Position? _findWinningMove(GameState gameState, [String? player]) {
    final targetPlayer = player ?? gameState.currentPlayer;
    final availableMoves = gameState.getAvailableMoves();
    
    for (final move in availableMoves) {
      if (_createsWin(gameState, move, targetPlayer)) {
        return move;
      }
    }
    
    return null;
  }
  
  // Helper method to find a move that creates a fork
  Position? _findForkMove(GameState gameState, [String? player]) {
    final targetPlayer = player ?? gameState.currentPlayer;
    final availableMoves = gameState.getAvailableMoves();
    
    for (final move in availableMoves) {
      if (_createsFork(gameState, move, targetPlayer)) {
        return move;
      }
    }
    
    return null;
  }
  
  // Helper method to check if a move creates an immediate win
  bool _createsWin(GameState gameState, Position move, String player) {
    final tempBoard = gameState.board.map((row) => List<String>.from(row)).toList();
    tempBoard[move.row][move.col] = player;
    
    return _hasWinningLine(tempBoard, player);
  }
  
  // Helper method to check if a move creates a fork
  bool _createsFork(GameState gameState, Position move, String player) {
    final tempBoard = gameState.board.map((row) => List<String>.from(row)).toList();
    tempBoard[move.row][move.col] = player;
    
    int winningOpportunities = 0;
    
    // Check rows
    for (int row = 0; row < 3; row++) {
      if (_countInRow(tempBoard, row, player) == 2 && _countInRow(tempBoard, row, '') == 1) {
        winningOpportunities++;
      }
    }
    
    // Check columns
    for (int col = 0; col < 3; col++) {
      if (_countInColumn(tempBoard, col, player) == 2 && _countInColumn(tempBoard, col, '') == 1) {
        winningOpportunities++;
      }
    }
    
    // Check diagonals
    if (_countInDiagonal(tempBoard, player, true) == 2 && _countInDiagonal(tempBoard, '', true) == 1) {
      winningOpportunities++;
    }
    if (_countInDiagonal(tempBoard, player, false) == 2 && _countInDiagonal(tempBoard, '', false) == 1) {
      winningOpportunities++;
    }
    
    return winningOpportunities >= 2;
  }
  
  // Helper method to check if board has a winning line
  bool _hasWinningLine(List<List<String>> board, String player) {
    // Check rows
    for (int row = 0; row < 3; row++) {
      if (board[row].every((cell) => cell == player)) {
        return true;
      }
    }
    
    // Check columns
    for (int col = 0; col < 3; col++) {
      if (board.every((row) => row[col] == player)) {
        return true;
      }
    }
    
    // Check diagonals
    if (board[0][0] == player && board[1][1] == player && board[2][2] == player) {
      return true;
    }
    if (board[0][2] == player && board[1][1] == player && board[2][0] == player) {
      return true;
    }
    
    return false;
  }
  
  // Helper methods for counting pieces (reused from previous strategies)
  int _countInRow(List<List<String>> board, int row, String piece) {
    return board[row].where((cell) => cell == piece).length;
  }
  
  int _countInColumn(List<List<String>> board, int col, String piece) {
    return board.where((row) => row[col] == piece).length;
  }
  
  int _countInDiagonal(List<List<String>> board, String piece, bool mainDiagonal) {
    int count = 0;
    for (int i = 0; i < 3; i++) {
      if (mainDiagonal) {
        if (board[i][i] == piece) count++;
      } else {
        if (board[i][2-i] == piece) count++;
      }
    }
    return count;
  }
} 