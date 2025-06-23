// QuantumMove model for QCI Tic-Tac-Toe
// Represents a move with quantum-inspired variables

import 'dart:math' as math;
import 'game_state.dart';

// Complex amplitude for quantum-inspired moves
class ComplexAmplitude {
  // Magnitude (strength/confidence) of the move (0.0 to 1.0)
  final double magnitude;
  
  // Phase angle in radians (0 to 2π)
  final double phase;
  
  const ComplexAmplitude({
    required this.magnitude,
    required this.phase,
  });
  
  // Create from real and imaginary parts
  factory ComplexAmplitude.fromRealImag(double real, double imag) {
    final magnitude = math.sqrt(real * real + imag * imag);
    final phase = math.atan2(imag, real);
    return ComplexAmplitude(magnitude: magnitude, phase: phase);
  }
  
  // Get real part
  double get real => magnitude * math.cos(phase);
  
  // Get imaginary part
  double get imaginary => magnitude * math.sin(phase);
  
  // Add two complex amplitudes
  ComplexAmplitude operator +(ComplexAmplitude other) {
    final r = real + other.real;
    final i = imaginary + other.imaginary;
    return ComplexAmplitude.fromRealImag(r, i);
  }
  
  // Multiply two complex amplitudes
  ComplexAmplitude operator *(ComplexAmplitude other) {
    final m = magnitude * other.magnitude;
    final p = phase + other.phase;
    return ComplexAmplitude(magnitude: m, phase: p);
  }
  
  // Copy with modifications
  ComplexAmplitude copyWith({
    double? magnitude,
    double? phase,
  }) {
    return ComplexAmplitude(
      magnitude: magnitude ?? this.magnitude,
      phase: phase ?? this.phase,
    );
  }
  
  // Clamp the magnitude between min and max while preserving phase
  ComplexAmplitude clamp(ComplexAmplitude min, ComplexAmplitude max) {
    final clampedMagnitude = magnitude.clamp(min.magnitude, max.magnitude);
    return ComplexAmplitude(magnitude: clampedMagnitude, phase: phase);
  }
  
  @override
  String toString() {
    return 'ComplexAmplitude(magnitude: $magnitude, phase: ${phase.toStringAsFixed(2)} rad)';
  }
}

class QuantumMove {
  // The position on the board (row, col)
  final Position position;

  // Quantum-inspired: complex amplitude representing strength and phase of this move
  final ComplexAmplitude amplitude;

  // Quantum-inspired: basisState = strategy type (e.g., 'Greedy', 'Defensive')
  final String basisState;

  // The player proposing this move ('X' or 'O')
  final String player;

  const QuantumMove({
    required this.position,
    required this.amplitude,
    required this.basisState,
    required this.player,
  });

  // Copy with modifications (immutability pattern)
  QuantumMove copyWith({
    Position? position,
    ComplexAmplitude? amplitude,
    String? basisState,
    String? player,
  }) {
    return QuantumMove(
      position: position ?? this.position,
      amplitude: amplitude ?? this.amplitude,
      basisState: basisState ?? this.basisState,
      player: player ?? this.player,
    );
  }

  @override
  String toString() {
    return 'QuantumMove(position: $position, amplitude: $amplitude, basisState: $basisState, player: $player)';
  }
} 