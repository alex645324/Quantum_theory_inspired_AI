// AnimationSettings model for QCI Tic-Tac-Toe
// Configurable animation durations and speeds

class AnimationSettings {
  // Phase 1: Emergence animations
  final int mainBoardPulseDuration;      // milliseconds
  final int ghostEmergenceDuration;      // milliseconds
  final int floatingAnimationDuration;   // milliseconds
  
  // Phase 2: Deliberation sequence animations
  final int mainBoardShrinkDuration;     // milliseconds
  final int screenDimmingDuration;       // milliseconds
  final int ghostForwardDuration;        // milliseconds
  final int columnArrangementDuration;   // milliseconds
  final int winnerPulseDuration;         // milliseconds
  final int returnAnimationDuration;     // milliseconds
  final int finalUndimmingDuration;      // milliseconds
  final int finalMergeDuration;          // milliseconds
  
  // Pause durations between sequences
  final int emergenceDelayDuration;      // milliseconds - delay before emergence
  final int deliberationDelayDuration;   // milliseconds - delay before deliberation starts
  final int finalPauseDuration;          // milliseconds - pause before QCI move
  
  const AnimationSettings({
    // Phase 1 defaults (current values)
    this.mainBoardPulseDuration = 500,
    this.ghostEmergenceDuration = 500,
    this.floatingAnimationDuration = 2000,
    
    // Phase 2 defaults (current values)
    this.mainBoardShrinkDuration = 800,
    this.screenDimmingDuration = 600,
    this.ghostForwardDuration = 500,
    this.columnArrangementDuration = 800,
    this.winnerPulseDuration = 600,
    this.returnAnimationDuration = 800,
    this.finalUndimmingDuration = 600,
    this.finalMergeDuration = 800,
    
    // Pause defaults (current values)
    this.emergenceDelayDuration = 100,      // delay between pulse and emergence
    this.deliberationDelayDuration = 2000,  // delay before deliberation starts
    this.finalPauseDuration = 1000,         // pause before QCI move
  });
  
  // Create a copy with modified values (for admin interface)
  AnimationSettings copyWith({
    int? mainBoardPulseDuration,
    int? ghostEmergenceDuration,
    int? floatingAnimationDuration,
    int? mainBoardShrinkDuration,
    int? screenDimmingDuration,
    int? ghostForwardDuration,
    int? columnArrangementDuration,
    int? winnerPulseDuration,
    int? returnAnimationDuration,
    int? finalUndimmingDuration,
    int? finalMergeDuration,
    int? emergenceDelayDuration,
    int? deliberationDelayDuration,
    int? finalPauseDuration,
  }) {
    return AnimationSettings(
      mainBoardPulseDuration: mainBoardPulseDuration ?? this.mainBoardPulseDuration,
      ghostEmergenceDuration: ghostEmergenceDuration ?? this.ghostEmergenceDuration,
      floatingAnimationDuration: floatingAnimationDuration ?? this.floatingAnimationDuration,
      mainBoardShrinkDuration: mainBoardShrinkDuration ?? this.mainBoardShrinkDuration,
      screenDimmingDuration: screenDimmingDuration ?? this.screenDimmingDuration,
      ghostForwardDuration: ghostForwardDuration ?? this.ghostForwardDuration,
      columnArrangementDuration: columnArrangementDuration ?? this.columnArrangementDuration,
      winnerPulseDuration: winnerPulseDuration ?? this.winnerPulseDuration,
      returnAnimationDuration: returnAnimationDuration ?? this.returnAnimationDuration,
      finalUndimmingDuration: finalUndimmingDuration ?? this.finalUndimmingDuration,
      finalMergeDuration: finalMergeDuration ?? this.finalMergeDuration,
      emergenceDelayDuration: emergenceDelayDuration ?? this.emergenceDelayDuration,
      deliberationDelayDuration: deliberationDelayDuration ?? this.deliberationDelayDuration,
      finalPauseDuration: finalPauseDuration ?? this.finalPauseDuration,
    );
  }
} 