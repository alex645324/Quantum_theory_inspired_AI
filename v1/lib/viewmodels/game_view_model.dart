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
  
  // Debug: Track game cycles and moves
  int _gameMove = 0;
  int _gameCycle = 0;
  
  // QCI Process state tracking
  bool _isQciProcessRunning = false;
  
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
  
  // Getter for QCI process state
  bool get isQciProcessRunning => _isQciProcessRunning;

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
    _gameMove = 0;
    _gameCycle = 0;
    _isQciProcessRunning = false; // Reset QCI process flag
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
    print('DEBUG: QCI RESTART - collapsePlayerMove called (Cycle: $_gameCycle, Move: $_gameMove)');
    
    // Don't allow moves if animations are still running
    if (_animationViewModel.isAnimating) {
      print('DEBUG: Move rejected - animations still in progress');
      return;
    }
    
    // Simple state check - only allow moves during player turn
    if (!_isPlayerTurn) {
      print('DEBUG: Move rejected - not player turn');
      return;
    }
    
    // Validate the move
    if (!isValidMove(row, col)) {
      print('DEBUG: Move rejected - invalid position');
      return;
    }
    
    // Apply player's move
    _gameState = _gameState.makeMove(row, col);
    _gameMove++;
    
    // Check for game over after player move
    if (_gameState.isGameOver) {
      print('DEBUG: Game over after player move');
      notifyListeners();
      return;
    }
    
    // Start QCI sequence
    _isPlayerTurn = false;
    _isQciProcessRunning = true;
    print('DEBUG: Starting QCI sequence');
    
    // Update quantum state
    _updateQuantumSuperposition();
    _quantumMind.showGhostBoards();
    notifyListeners();
    
    try {
      // Start animations
      await Future.delayed(const Duration(seconds: 1));
      await _animationViewModel.startEmergenceSequence();
      
      // Start deliberation if still in QCI phase
      if (!_gameState.isGameOver) {
        await Future.delayed(Duration(milliseconds: _animationViewModel.settings.deliberationDelayDuration));
        await _animationViewModel.startDeliberationSequence();
      }
    } catch (e) {
      print('DEBUG: Animation error: $e');
      // Cleanup on error
      _animationViewModel.stopAnimations();
      _isQciProcessRunning = false;
      _isPlayerTurn = true;
      notifyListeners();
    }
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
  
  // Handle deliberation sequence completion
  void _handleDeliberationComplete() {
    if (_gameState.isGameOver) return;
    
    print('DEBUG: QCI deliberation complete');
    
    // Ensure all animations are stopped
    _animationViewModel.stopAnimations();
    
    // Get and apply QCI move
    final qciMove = _quantumMind.getQuantumWinningPosition();
    if (qciMove != null) {
      _gameState = _gameState.makeMove(qciMove.row, qciMove.col);
      _gameMove++;
    }
    
    // Hide ghost boards
    _quantumMind.hideGhostBoards();
    
    // Complete cycle and prepare for next player
    _gameCycle++;
    _isQciProcessRunning = false;
    _isPlayerTurn = !_gameState.isGameOver; // Only allow next player turn if game not over
    
    print('DEBUG: QCI cycle complete - Cycle: $_gameCycle, Game Over: ${_gameState.isGameOver}');
    notifyListeners();
  }
  
  @override
  void dispose() {
    _animationViewModel.dispose();
    super.dispose();
  }

  @override
  String toString() {
    return 'GameViewModel(cycle: $_gameCycle, move: $_gameMove, gameState: $_gameState, quantumMind: $_quantumMind, isPlayerTurn: $_isPlayerTurn)';
  }
} 