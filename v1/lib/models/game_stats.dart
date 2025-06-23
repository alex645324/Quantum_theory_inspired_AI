// GameStats model for QCI Tic-Tac-Toe
// Simple session tracking (wins/losses)

class GameStats {
  // Total number of games played
  final int totalGames;

  // Number of games won by the player
  final int playerWins;

  // Number of games won by QCI
  final int qciWins;

  const GameStats({
    this.totalGames = 0,
    this.playerWins = 0,
    this.qciWins = 0,
  });

  // Copy with modifications (immutability pattern)
  GameStats copyWith({
    int? totalGames,
    int? playerWins,
    int? qciWins,
  }) {
    return GameStats(
      totalGames: totalGames ?? this.totalGames,
      playerWins: playerWins ?? this.playerWins,
      qciWins: qciWins ?? this.qciWins,
    );
  }

  // Record a win for the specified player
  GameStats recordWin(bool playerWon) {
    return copyWith(
      totalGames: totalGames + 1,
      playerWins: playerWins + (playerWon ? 1 : 0),
      qciWins: qciWins + (playerWon ? 0 : 1),
    );
  }

  // Get the win rate for the player (0.0 to 1.0)
  double get playerWinRate => totalGames > 0 ? playerWins / totalGames : 0.0;

  // Get the win rate for QCI (0.0 to 1.0)
  double get qciWinRate => totalGames > 0 ? qciWins / totalGames : 0.0;

  // Get the number of draws
  int get draws => totalGames - playerWins - qciWins;

  // Get the draw rate (0.0 to 1.0)
  double get drawRate => totalGames > 0 ? draws / totalGames : 0.0;

  @override
  String toString() {
    return 'GameStats(totalGames: $totalGames, playerWins: $playerWins, qciWins: $qciWins, playerWinRate: $playerWinRate)';
  }
} 