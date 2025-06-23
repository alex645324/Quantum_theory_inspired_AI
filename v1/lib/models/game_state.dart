// GameState model for QCI Tic-Tac-Toe
// Represents the current state of the game board and rules

class GameState {
  // Quantum-inspired: The "reality" board state (3x3 grid)
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
  })  : board = board ?? _createEmptyBoard(),
        rules = rules ?? const GameRules();
  
  // Create empty 3x3 board
  static List<List<String>> _createEmptyBoard() {
    return List.generate(3, (_) => List.filled(3, ''));
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
    // Check rows, columns, and diagonals for win
    for (int i = 0; i < 3; i++) {
      // Check rows
      if (board[i][0].isNotEmpty && 
          board[i][0] == board[i][1] && 
          board[i][1] == board[i][2]) {
        return 'won';
      }
      
      // Check columns
      if (board[0][i].isNotEmpty && 
          board[0][i] == board[1][i] && 
          board[1][i] == board[2][i]) {
        return 'won';
      }
    }
    
    // Check diagonals
    if (board[0][0].isNotEmpty && 
        board[0][0] == board[1][1] && 
        board[1][1] == board[2][2]) {
      return 'won';
    }
    
    if (board[0][2].isNotEmpty && 
        board[0][2] == board[1][1] && 
        board[1][1] == board[2][0]) {
      return 'won';
    }
    
    // Check for draw (all cells filled)
    bool isDraw = board.every((row) => row.every((cell) => cell.isNotEmpty));
    return isDraw ? 'draw' : 'playing';
  }
  
  // Get available moves (empty positions)
  List<Position> getAvailableMoves() {
    List<Position> moves = [];
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 3; col++) {
        if (board[row][col].isEmpty) {
          moves.add(Position(row, col));
        }
      }
    }
    return moves;
  }
  
  // Check if position is valid and empty
  bool isValidMove(int row, int col) {
    return row >= 0 && row < 3 && 
           col >= 0 && col < 3 && 
           board[row][col].isEmpty;
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
  
  const GameRules({
    this.winCondition = 3,
    this.centerAvailable = true,
    this.wrapEdges = false,
    this.allowMoveReuse = false,
  });
  
  GameRules copyWith({
    int? winCondition,
    bool? centerAvailable,
    bool? wrapEdges,
    bool? allowMoveReuse,
  }) {
    return GameRules(
      winCondition: winCondition ?? this.winCondition,
      centerAvailable: centerAvailable ?? this.centerAvailable,
      wrapEdges: wrapEdges ?? this.wrapEdges,
      allowMoveReuse: allowMoveReuse ?? this.allowMoveReuse,
    );
  }
  
  @override
  String toString() {
    return 'GameRules(winCondition: $winCondition, centerAvailable: $centerAvailable, wrapEdges: $wrapEdges, allowMoveReuse: $allowMoveReuse)';
  }
} 