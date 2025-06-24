// GameState model for QCI Tic-Tac-Toe
// Represents the current state of the game board and rules

class GameState {
  // Quantum-inspired: The "reality" board state (3x3 or 3x4 grid)
  final List<List<String>> board;
  
  // Current player making the move ('X' or 'O')
  final String currentPlayer;
  
  // Game status: 'playing', 'won', 'draw'
  final String gameStatus;
  
  // Quantum-inspired: Current rule set (can mutate during game)
  final GameRules rules;
  
  // Constructor with default values for new game
  GameState({
    List<List<String>>? board,
    this.currentPlayer = 'X',
    this.gameStatus = 'playing',
    GameRules? rules,
  })  : board = board ?? _createEmptyBoard(rules?.additionalColumn ?? false),
        rules = rules ?? const GameRules();
  
  // Create empty board based on rules
  static List<List<String>> _createEmptyBoard(bool additionalColumn) {
    final columns = additionalColumn ? 4 : 3;
    return List.generate(3, (_) => List.filled(columns, ''));
  }
  
  // Copy with modifications (immutable pattern)
  GameState copyWith({
    List<List<String>>? board,
    String? currentPlayer,
    String? gameStatus,
    GameRules? rules,
  }) {
    return GameState(
      board: board ?? this.board,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      gameStatus: gameStatus ?? this.gameStatus,
      rules: rules ?? this.rules,
    );
  }
  
  // Make a move on the board
  GameState makeMove(int row, int col) {
    if (gameStatus != 'playing' || board[row][col].isNotEmpty) {
      return this; // Invalid move, return unchanged state
    }
    
    // Create new board with the move
    List<List<String>> newBoard = board.map((row) => List<String>.from(row)).toList();
    newBoard[row][col] = currentPlayer;
    
    // Check for win or draw
    String newStatus = _checkGameStatus(newBoard);
    
    // Switch players if game continues
    String nextPlayer = newStatus == 'playing' ? (currentPlayer == 'X' ? 'O' : 'X') : currentPlayer;
    
    return copyWith(
      board: newBoard,
      currentPlayer: nextPlayer,
      gameStatus: newStatus,
    );
  }
  
  // Check if game is won, drawn, or still playing
  String _checkGameStatus(List<List<String>> board) {
    final columns = rules.additionalColumn ? 4 : 3;
    
    // Check rows for win
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col <= columns - rules.winCondition; col++) {
        bool isWin = true;
        for (int i = 0; i < rules.winCondition - 1; i++) {
          if (board[row][col + i].isEmpty || board[row][col + i] != board[row][col + i + 1]) {
            isWin = false;
            break;
          }
        }
        if (isWin) return 'won';
      }
    }
    
    // Check columns for win
    for (int col = 0; col < columns; col++) {
      if (board[0][col].isNotEmpty && 
          board[0][col] == board[1][col] && 
          board[1][col] == board[2][col]) {
        return 'won';
      }
    }
    
    // Check diagonals for win (only if they can fit the win condition)
    if (!rules.additionalColumn || rules.winCondition == 3) {
      // Main diagonal
      if (board[0][0].isNotEmpty && 
          board[0][0] == board[1][1] && 
          board[1][1] == board[2][2]) {
        return 'won';
      }
      
      // Secondary diagonal
      if (board[0][2].isNotEmpty && 
          board[0][2] == board[1][1] && 
          board[1][1] == board[2][0]) {
        return 'won';
      }
    }
    
    // Additional diagonals for 4th column if present
    if (rules.additionalColumn) {
      // Additional main diagonal
      if (board[0][1].isNotEmpty && 
          board[0][1] == board[1][2] && 
          board[1][2] == board[2][3]) {
        return 'won';
      }
      
      // Additional secondary diagonal
      if (board[0][3].isNotEmpty && 
          board[0][3] == board[1][2] && 
          board[1][2] == board[2][1]) {
        return 'won';
      }
    }
    
    // Check for draw (all cells filled)
    bool isDraw = true;
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < columns; col++) {
        if (board[row][col].isEmpty && (rules.centerAvailable || row != 1 || col != 1)) {
          isDraw = false;
          break;
        }
      }
      if (!isDraw) break;
    }
    return isDraw ? 'draw' : 'playing';
  }
  
  // Get available moves (empty positions)
  List<Position> getAvailableMoves() {
    List<Position> moves = [];
    final columns = rules.additionalColumn ? 4 : 3;
    
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < columns; col++) {
        // Skip middle piece if it's not available
        if (!rules.centerAvailable && row == 1 && col == 1) continue;
        if (board[row][col].isEmpty) {
          moves.add(Position(row, col));
        }
      }
    }
    return moves;
  }
  
  // Check if position is valid and empty
  bool isValidMove(int row, int col) {
    final columns = rules.additionalColumn ? 4 : 3;
    return row >= 0 && row < 3 && 
           col >= 0 && col < columns && 
           board[row][col].isEmpty &&
           (rules.centerAvailable || row != 1 || col != 1);
  }
  
  // Get winner (if game is won)
  String? get winner {
    return gameStatus == 'won' ? (currentPlayer == 'X' ? 'O' : 'X') : null;
  }
  
  // Check if game is over
  bool get isGameOver => gameStatus != 'playing';
  
  @override
  String toString() {
    return 'GameState(board: $board, currentPlayer: $currentPlayer, gameStatus: $gameStatus)';
  }
}

// Position class for board coordinates
class Position {
  final int row;
  final int col;
  
  const Position(this.row, this.col);
  
  @override
  bool operator ==(Object other) {
    return other is Position && other.row == row && other.col == col;
  }
  
  @override
  int get hashCode => Object.hash(row, col);
  
  @override
  String toString() => 'Position($row, $col)';
}

// Game rules that can mutate during gameplay
class GameRules {
  // Quantum-inspired: Number of cells required to win (can mutate)
  final int winCondition;
  
  // Whether center tile is available (can be removed)
  final bool centerAvailable;
  
  // Whether board wraps around edges
  final bool wrapEdges;
  
  // Whether players can reuse previous moves
  final bool allowMoveReuse;
  
  // Whether the board has an additional column
  final bool additionalColumn;
  
  const GameRules({
    this.winCondition = 3,
    this.centerAvailable = true,
    this.wrapEdges = false,
    this.allowMoveReuse = false,
    this.additionalColumn = false,
  });
  
  GameRules copyWith({
    int? winCondition,
    bool? centerAvailable,
    bool? wrapEdges,
    bool? allowMoveReuse,
    bool? additionalColumn,
  }) {
    return GameRules(
      winCondition: winCondition ?? this.winCondition,
      centerAvailable: centerAvailable ?? this.centerAvailable,
      wrapEdges: wrapEdges ?? this.wrapEdges,
      allowMoveReuse: allowMoveReuse ?? this.allowMoveReuse,
      additionalColumn: additionalColumn ?? this.additionalColumn,
    );
  }
  
  @override
  String toString() {
    return 'GameRules(winCondition: $winCondition, centerAvailable: $centerAvailable, wrapEdges: $wrapEdges, allowMoveReuse: $allowMoveReuse, additionalColumn: $additionalColumn)';
  }
} 