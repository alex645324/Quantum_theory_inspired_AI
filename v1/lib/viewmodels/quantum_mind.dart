// QuantumMind ViewModel for QCI Tic-Tac-Toe
// Handles superposition, interference, and collapse

import 'package:flutter/foundation.dart';
import '../models/game_state.dart';
import '../models/ghost_board.dart';
import '../models/quantum_move.dart';
import '../models/strategies.dart';

class QuantumMind extends ChangeNotifier {
  // Quantum-inspired: The 8 ghost boards in superposition
  List<GhostBoard> _ghostBoards = [];
  
  // Quantum-inspired: The strategies for each ghost board
  List<Strategy> _strategies = [];
  
  // Quantum-inspired: The current game state that all ghosts observe
  GameState? _currentGameState;
  
  // Quantum-inspired: Whether ghost boards should be visible
  bool _isVisible = true;
  
  // Getter for all ghost boards
  List<GhostBoard> get ghostBoards => _ghostBoards;
  
  // Getter for all strategies
  List<Strategy> get strategies => _strategies;
  
  // Getter for current game state
  GameState? get currentGameState => _currentGameState;
  
  // Getter for visibility state
  bool get isVisible => _isVisible;
  
  // Getter for individual ghost board
  GhostBoard? getGhostBoard(int index) {
    if (index >= 0 && index < _ghostBoards.length) {
      return _ghostBoards[index];
    }
    return null;
  }
  
  // Getter for individual strategy
  Strategy? getStrategy(int index) {
    if (index >= 0 && index < _strategies.length) {
      return _strategies[index];
    }
    return null;
  }
  
  // Constructor - initialize with empty state
  QuantumMind() {
    _initializeSuperposition();
  }
  
  // Quantum-inspired: Initialize the superposition of 8 ghost boards
  void _initializeSuperposition() {
    // Create the 8 different strategies
    _strategies = [
      CenterStrategy(),
      DefensiveStrategy(),
      MirrorStrategy(),
      ForkStrategy(),
      AggressiveStrategy(),
      RandomStrategy(),
      ConservativeStrategy(),
      LongTermStrategy(),
    ];
    
    // Create empty ghost boards (will be populated when game state is set)
    _ghostBoards = List.generate(8, (index) {
      return GhostBoard(
        basisState: _strategies[index].basisState,
        proposedMove: QuantumMove(
          position: const Position(0, 0),
          amplitude: ComplexAmplitude(magnitude: 0.0, phase: 0.0),
          basisState: _strategies[index].basisState,
          player: 'X',
        ),
        opacity: 0.6,
        angle: (index / 8) * 2 * 3.141592653589793, // Distribute in a circle
      );
    });
  }
  
  // Quantum-inspired: Update the superposition with new game state
  void updateSuperposition(GameState gameState) {
    _currentGameState = gameState;
    
    // Update each ghost board with its strategy's suggestion
    for (int i = 0; i < _ghostBoards.length; i++) {
      final strategy = _strategies[i];
      final quantumMove = strategy.suggest(gameState);
      
      // Create a new ghost board with the updated move
      _ghostBoards[i] = _ghostBoards[i].copyWith(
        proposedMove: quantumMove,
      );
    }
    
    // Notify listeners that the superposition has been updated
    notifyListeners();
  }
  
  // Quantum-inspired: Hide ghost boards (during player turn)
  void hideGhostBoards() {
    _isVisible = false;
    notifyListeners();
  }
  
  // Quantum-inspired: Show ghost boards (during quantum processing)
  void showGhostBoards() {
    _isVisible = true;
    notifyListeners();
  }
  
  // Quantum-inspired: Get all quantum moves from all ghost boards
  List<QuantumMove> getAllQuantumMoves() {
    return _ghostBoards.map((ghostBoard) => ghostBoard.proposedMove).toList();
  }
  
  // Quantum-inspired: Get quantum moves grouped by position
  Map<Position, List<QuantumMove>> getQuantumMovesByPosition() {
    final movesByPosition = <Position, List<QuantumMove>>{};
    
    for (final ghostBoard in _ghostBoards) {
      final position = ghostBoard.proposedMove.position;
      movesByPosition.putIfAbsent(position, () => []).add(ghostBoard.proposedMove);
    }
    
    return movesByPosition;
  }
  
  // Quantum-inspired: Get the total amplitude for each position
  Map<Position, ComplexAmplitude> getPositionAmplitudes() {
    final movesByPosition = getQuantumMovesByPosition();
    final amplitudes = <Position, ComplexAmplitude>{};
    
    movesByPosition.forEach((position, moves) {
      // Sum up all complex amplitudes for this position
      final totalAmplitude = moves.fold(
        ComplexAmplitude(magnitude: 0.0, phase: 0.0),
        (sum, move) => sum + move.amplitude
      );
      amplitudes[position] = totalAmplitude;
    });
    
    return amplitudes;
  }
  
  // Helper method to get the magnitude of interference at each position
  Map<Position, double> getPositionMagnitudes() {
    final amplitudes = getPositionAmplitudes();
    return amplitudes.map((position, complexAmp) => 
      MapEntry(position, complexAmp.magnitude)
    );
  }
  
  // Helper method to get the phase of interference at each position
  Map<Position, double> getPositionPhases() {
    final amplitudes = getPositionAmplitudes();
    return amplitudes.map((position, complexAmp) => 
      MapEntry(position, complexAmp.phase)
    );
  }
  
  @override
  String toString() {
    return 'QuantumMind(ghostBoards: ${_ghostBoards.length}, strategies: ${_strategies.length}, isVisible: $_isVisible)';
  }
} 