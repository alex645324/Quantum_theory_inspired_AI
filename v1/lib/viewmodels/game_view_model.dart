// GameViewModel for QCI Tic-Tac-Toe
// Manages game flow, rule mutations, turn logic

import 'package:flutter/material.dart';
import '../models/game_state.dart';
import 'quantum_mind.dart';
import 'animation_view_model.dart';
import '../services/settings_service.dart';

class GameViewModel extends ChangeNotifier {
  // Quantum-inspired: The current "reality" state of the game
  GameState _gameState;
  
  // Quantum-inspired: The quantum mind managing superposition
  late QuantumMind _quantumMind;
  
  // Quantum-inspired: Turn state management
  bool _isPlayerTurn = true; // true = player turn, false = quantum processing
  
  // Quantum-inspired: Animation controller for synchronized pulsing
  late AnimationViewModel _animationViewModel;
  
  // Getter for the current game state
  GameState get gameState => _gameState;
  
  // Getter for the quantum mind
  QuantumMind get quantumMind => _quantumMind;
  
  // Getter for the animation view model
  AnimationViewModel get animationViewModel => _animationViewModel;
  
  // Getter for the current board
  List<List<String>> get board => _gameState.board;
  
  // Getter for current player
  String get currentPlayer => _gameState.currentPlayer;
  
  // Getter for game status
  String get gameStatus => _gameState.gameStatus;
  
  // Getter for winner
  String? get winner => _gameState.winner;
  
  // Getter for whether game is over
  bool get isGameOver => _gameState.isGameOver;
  
  // Getter for turn state
  bool get isPlayerTurn => _isPlayerTurn;

  // Constructor - initialize with empty game state and quantum mind
  GameViewModel(TickerProvider vsync) : _gameState = GameState() {
    _quantumMind = QuantumMind();
    
    // Load animation settings from file
    final settings = SettingsService.loadSettings();
    _animationViewModel = AnimationViewModel(vsync, settings: settings);
    _updateQuantumSuperposition();
    
    // Set up the deliberation completion callback
    _animationViewModel.onDeliberationComplete = _handleDeliberationComplete;
  }

  // Quantum-inspired: Check if a move is valid in the current reality
  bool isValidMove(int row, int col) {
    return _gameState.isValidMove(row, col);
  }

  // Quantum-inspired: Get available moves in the current reality
  List<Position> getAvailableMoves() {
    return _gameState.getAvailableMoves();
  }

  // Quantum-inspired: Reset the game reality to initial state
  void resetReality() {
    _gameState = GameState();
    _isPlayerTurn = true; // Start with player turn
    _animationViewModel.stopAnimations(); // Stop any ongoing animations
    _updateQuantumSuperposition();
    notifyListeners();
  }

  // Quantum-inspired: Check if the game reality has reached a terminal state
  void checkGameOver() {
    notifyListeners();
  }

  // Quantum-inspired: Collapse a player's move into the current reality
  Future<void> collapsePlayerMove(int row, int col) async {
    // Only allow moves during player turn
    if (!_isPlayerTurn) {
      print('DEBUG: Move rejected - not player turn');
      return; // Not player's turn
    }
    
    // Validate the move
    if (!isValidMove(row, col)) {
      print('DEBUG: Move rejected - invalid position ($row, $col)');
      return; // Invalid move, do nothing
    }
    
    print('DEBUG: Valid move at ($row, $col) - starting quantum sequence');
    
    // Apply the move to the game state
    _gameState = _gameState.makeMove(row, col);
    print('DEBUG: Game state updated with player move');
    
    // Switch to quantum processing phase
    _isPlayerTurn = false;
    print('DEBUG: Switched to quantum processing phase');
    
    // Update the quantum superposition with the new game state
    _updateQuantumSuperposition();
    print('DEBUG: Quantum superposition updated');
    
    // Show ghost boards during quantum processing
    _quantumMind.showGhostBoards();
    print('DEBUG: Ghost boards visibility set to: ${_quantumMind.isVisible}');
    print('DEBUG: Number of ghost boards: ${_quantumMind.ghostBoards.length}');
    
    // Notify listeners immediately to show the player's move
    notifyListeners();
    print('DEBUG: Notified listeners of state change');
    
    // Wait for 1 second before starting the emergence sequence
    print('DEBUG: Starting 1-second pause');
    await Future.delayed(const Duration(seconds: 1));
    print('DEBUG: Pause completed');
    
    // Start the emergence sequence
    print('DEBUG: Starting emergence sequence');
    await _animationViewModel.startEmergenceSequence();
    print('DEBUG: Emergence sequence completed');
  }
  
  // Quantum-inspired: Update the quantum superposition
  void _updateQuantumSuperposition() {
    _quantumMind.updateSuperposition(_gameState);
  }
  
  // Quantum-inspired: Switch back to player turn
  void switchToPlayerTurn() {
    _isPlayerTurn = true;
    _animationViewModel.stopAnimations();
    notifyListeners();
  }
  
  // Quantum-inspired: Switch to quantum processing phase
  void switchToQuantumProcessing() {
    _isPlayerTurn = false;
    notifyListeners();
  }
  
  // Handle deliberation sequence completion and make the winning move
  void _handleDeliberationComplete() {
    print('DEBUG: Deliberation completed - QCI making winning move');
    
    // Get the quantum winning position
    final winningPosition = _quantumMind.getQuantumWinningPosition();
    
    if (winningPosition != null) {
      print('DEBUG: QCI making move at position (${winningPosition.row}, ${winningPosition.col})');
      
      // Apply the QCI move to the game state
      _gameState = _gameState.makeMove(winningPosition.row, winningPosition.col);
      
      // Hide ghost boards
      _quantumMind.hideGhostBoards();
      
      // Switch back to player turn
      _isPlayerTurn = true;
      
      print('DEBUG: QCI move completed - switched back to player turn');
      notifyListeners();
    } else {
      print('DEBUG: ERROR - No winning position found!');
      // Fallback: just switch back to player turn
      _isPlayerTurn = true;
      _quantumMind.hideGhostBoards();
      notifyListeners();
    }
  }
  
  @override
  void dispose() {
    _animationViewModel.dispose();
    super.dispose();
  }

  @override
  String toString() {
    return 'GameViewModel(gameState: $_gameState, quantumMind: $_quantumMind, isPlayerTurn: $_isPlayerTurn)';
  }
} 