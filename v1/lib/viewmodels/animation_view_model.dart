// AnimationViewModel for QCI Tic-Tac-Toe
// Controls visual timing and state transitions

import 'package:flutter/material.dart';
import 'dart:math' as math;

// Enum to track current animation phase
enum AnimationPhase {
  idle,
  emerging,
  considering,
  clustering,
  selecting,
  collapsing,
  returning
}

class AnimationViewModel extends ChangeNotifier {
  // Animation phase tracking
  AnimationPhase _currentPhase = AnimationPhase.idle;
  
  // Phase 1: Quantum Emergence (500ms)
  late AnimationController _emergenceController;
  late Animation<double> _emergenceAnimation;
  
  // Original pulse animation (will be used in Phase 2)
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  // Quantum-inspired: Whether the quantum rhythm is active
  bool _isPulsing = false;
  
  // Getters
  AnimationPhase get currentPhase => _currentPhase;
  Animation<double> get emergenceAnimation => _emergenceAnimation;
  Animation<double> get pulseAnimation => _pulseAnimation;
  bool get isPulsing => _isPulsing;
  double get pulseValue => _pulseAnimation.value;
  
  // Constructor - requires a TickerProvider
  AnimationViewModel(TickerProvider vsync) {
    _initializeAnimations(vsync);
  }
  
  // Initialize all animation controllers
  void _initializeAnimations(TickerProvider vsync) {
    // Initialize emergence animation (Phase 1)
    _emergenceController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: vsync,
    );
    
    _emergenceAnimation = CurvedAnimation(
      parent: _emergenceController,
      curve: Curves.easeOutExpo, // Dramatic emergence effect
    );
    
    // Add emergence completion listener
    _emergenceController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // When emergence completes, move to consideration phase
        _startConsiderationPhase();
      }
    });
    
    // Initialize pulse animation (Phase 2)
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: vsync,
    );
    
    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0).chain(
          CurveTween(curve: const _NaturalBreathingCurve()),
        ),
        weight: 100.0,
      ),
    ]).animate(_pulseController);
    
    // Add listener to notify when animation updates
    _pulseAnimation.addListener(() {
      notifyListeners();
    });
  }
  
  // Start the quantum animation sequence
  void startQuantumSequence() {
    if (_currentPhase == AnimationPhase.idle) {
      _currentPhase = AnimationPhase.emerging;
      _emergenceController.forward();
      notifyListeners();
    }
  }
  
  // Start consideration phase (Phase 2)
  void _startConsiderationPhase() {
    _currentPhase = AnimationPhase.considering;
    startQuantumRhythm();
    notifyListeners();
  }
  
  // Calculate ghost board positions based on emergence progress
  List<Offset> calculateGhostPositions({
    required Offset center,
    required double radius,
    required List<Offset> finalPositions,
  }) {
    final progress = _emergenceAnimation.value;
    
    return List.generate(8, (index) {
      final finalPos = finalPositions[index];
      // Lerp from center to final position
      return Offset.lerp(center, finalPos, progress) ?? center;
    });
  }
  
  // Original methods for pulse animation
  void startQuantumRhythm() {
    if (!_isPulsing) {
      _isPulsing = true;
      _pulseController.repeat();
      notifyListeners();
    }
  }
  
  void stopQuantumRhythm() {
    if (_isPulsing) {
      _isPulsing = false;
      _pulseController.stop();
      notifyListeners();
    }
  }
  
  // Reset all animations to initial state
  void reset() {
    _currentPhase = AnimationPhase.idle;
    stopQuantumRhythm();
    _emergenceController.reset();
    notifyListeners();
  }
  
  @override
  void dispose() {
    _emergenceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
}

// Custom curve for natural, smooth breathing
class _NaturalBreathingCurve extends Curve {
  const _NaturalBreathingCurve();

  @override
  double transform(double t) {
    // Combine sine wave with cubic easing for softer transitions
    final sineValue = 0.5 - 0.5 * math.cos(t * math.pi);
    
    // Apply additional easing at the extremes
    if (t < 0.2) {
      // Ease in
      final easeIn = Curves.easeInOutCubic.transform(t * 5);
      return sineValue * easeIn;
    } else if (t > 0.8) {
      // Ease out
      final easeOut = Curves.easeInOutCubic.transform((1 - t) * 5);
      return sineValue * (1 - easeOut) + easeOut;
    }
    
    return sineValue;
  }
} 