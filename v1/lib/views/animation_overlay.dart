// AnimationOverlay view for QCI Tic-Tac-Toe
// Handles quantum animation effects and connecting lines

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/animation_view_model.dart';
import '../viewmodels/game_view_model.dart';

class AnimationOverlay extends StatelessWidget {
  final double mainBoardSize;
  final Offset mainBoardCenter;
  final List<Offset> ghostPositions;

  const AnimationOverlay({
    super.key,
    required this.mainBoardSize,
    required this.mainBoardCenter,
    required this.ghostPositions,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AnimationViewModel>(
      builder: (context, animationViewModel, child) {
        // Only show overlay during non-idle phases
        if (animationViewModel.currentPhase == AnimationPhase.idle) {
          return const SizedBox.shrink();
        }

        return Stack(
          children: [
            // Background dimming effect
            if (animationViewModel.currentPhase == AnimationPhase.clustering)
              AnimatedContainer(
                duration: const Duration(milliseconds: 1000),
                color: Colors.black.withOpacity(0.3),
              ),
            
            // Quantum connecting lines
            CustomPaint(
              painter: _QuantumLinesPainter(
                mainBoardCenter: mainBoardCenter,
                ghostPositions: ghostPositions,
                emergenceProgress: animationViewModel.emergenceAnimation.value,
                pulseValue: animationViewModel.pulseValue,
                phase: animationViewModel.currentPhase,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _QuantumLinesPainter extends CustomPainter {
  final Offset mainBoardCenter;
  final List<Offset> ghostPositions;
  final double emergenceProgress;
  final double pulseValue;
  final AnimationPhase phase;

  _QuantumLinesPainter({
    required this.mainBoardCenter,
    required this.ghostPositions,
    required this.emergenceProgress,
    required this.pulseValue,
    required this.phase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Base line paint
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Glow paint for wave effect
    final glowPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);

    // Draw connecting lines based on current phase
    for (final ghostPos in ghostPositions) {
      switch (phase) {
        case AnimationPhase.emerging:
          // During emergence, lines fade in with ghost boards
          final opacity = emergenceProgress * 0.3;
          linePaint.color = Colors.white.withOpacity(opacity);
          canvas.drawLine(mainBoardCenter, ghostPos, linePaint);
          break;
          
        case AnimationPhase.considering:
          // During consideration, lines pulse with wave effect
          canvas.drawLine(mainBoardCenter, ghostPos, linePaint);
          
          // Calculate wave position along the line
          final waveProgress = pulseValue;
          final wavePos = Offset.lerp(
            mainBoardCenter,
            ghostPos,
            waveProgress,
          );
          
          if (wavePos != null) {
            // Draw glowing wave segment
            canvas.drawLine(
              Offset.lerp(wavePos, ghostPos, -0.1) ?? wavePos,
              Offset.lerp(wavePos, ghostPos, 0.1) ?? wavePos,
              glowPaint,
            );
          }
          break;
          
        case AnimationPhase.clustering:
          // During clustering, lines fade out
          final opacity = (1 - emergenceProgress) * 0.3;
          linePaint.color = Colors.white.withOpacity(opacity);
          canvas.drawLine(mainBoardCenter, ghostPos, linePaint);
          break;
          
        default:
          // No lines in other phases
          break;
      }
    }
  }

  @override
  bool shouldRepaint(_QuantumLinesPainter oldDelegate) {
    return oldDelegate.emergenceProgress != emergenceProgress ||
           oldDelegate.pulseValue != pulseValue ||
           oldDelegate.phase != phase ||
           oldDelegate.mainBoardCenter != mainBoardCenter ||
           oldDelegate.ghostPositions != ghostPositions;
  }
} 