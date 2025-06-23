// GameViewModel for QCI Tic-Tac-Toe
// Manages game flow, rule mutations, turn logic

import 'package:flutter/material.dart';
import '../models/game_state.dart';
import 'quantum_mind.dart';
import 'animation_view_model.dart';

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
  GameViewModel(TickerProvider vsync, AnimationViewModel animationViewModel) : _gameState = GameState() {
    _quantumMind = QuantumMind();
    _animationViewModel = animationViewModel;
    _updateQuantumSuperposition();
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
    _animationViewModel.stopQuantumRhythm(); // Stop any ongoing animations
    _updateQuantumSuperposition();
    notifyListeners();
  }

  // Quantum-inspired: Check if the game reality has reached a terminal state
  void checkGameOver() {
    // The GameState already handles this internally
    // This method is here for future quantum logic extensions
    notifyListeners();
  }

  // Quantum-inspired: Collapse a player's move into the current reality
  void collapsePlayerMove(int row, int col) {
    // Only allow moves during player turn
    if (!_isPlayerTurn) {
      return; // Not player's turn
    }
    
    // Validate the move
    if (!isValidMove(row, col)) {
      return; // Invalid move, do nothing
    }
    
    // Apply the move to the game state
    _gameState = _gameState.makeMove(row, col);
    
    // Switch to quantum processing phase
    _isPlayerTurn = false;
    
    // Show ghost boards during quantum processing
    _quantumMind.showGhostBoards();
    
    // Start the quantum animation sequence
    _animationViewModel.startQuantumSequence();
    
    // Update the quantum superposition with the new game state
    _updateQuantumSuperposition();
    
    // Notify listeners that the state has changed
    notifyListeners();
  }
  
  // Quantum-inspired: Update the quantum superposition
  void _updateQuantumSuperposition() {
    _quantumMind.updateSuperposition(_gameState);
  }
  
  // Quantum-inspired: Switch back to player turn (for future QCI response phase)
  void switchToPlayerTurn() {
    _isPlayerTurn = true;
    // Hide ghost boards during player turn
    _quantumMind.hideGhostBoards();
    // Stop pulsing animation
    _animationViewModel.stopQuantumRhythm();
    notifyListeners();
  }
  
  // Quantum-inspired: Switch to quantum processing phase
  void switchToQuantumProcessing() {
    _isPlayerTurn = false;
    // Show ghost boards during quantum processing
    _quantumMind.showGhostBoards();
    // Start synchronized pulsing animation
    _animationViewModel.startQuantumRhythm();
    notifyListeners();
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