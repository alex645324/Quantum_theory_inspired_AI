// AnimationViewModel for QCI Tic-Tac-Toe
// Controls visual timing and state transitions

import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/animation_settings.dart';

class AnimationViewModel extends ChangeNotifier {
  // Callback for when deliberation sequence completes
  VoidCallback? _onDeliberationComplete;
  
  // Animation settings (configurable durations)
  AnimationSettings _settings;
  // Main board pulse animation
  late AnimationController _mainBoardPulseController;
  late Animation<double> _mainBoardPulseAnimation;
  
  // Ghost board emergence animation
  late AnimationController _emergenceController;
  late Animation<double> _emergenceScaleAnimation;
  late Animation<double> _emergenceOpacityAnimation;
  
  // Ghost board floating animation
  late AnimationController _floatingController;
  late Animation<double> _floatingAnimation;
  
  // Phase 2: Main board shrink animation
  late AnimationController _mainBoardShrinkController;
  late Animation<double> _mainBoardShrinkAnimation;
  
  // Phase 2: Screen dimming animation
  late AnimationController _dimmingController;
  late Animation<double> _dimmingAnimation;
  
  // Phase 2: Ghost boards forward movement animation
  late AnimationController _ghostForwardController;
  late Animation<double> _ghostForwardAnimation;
  
  // Phase 2: Column arrangement animation
  late AnimationController _columnArrangementController;
  late Animation<double> _columnArrangementAnimation;
  
  // Phase 2: Winner pulse animation
  late AnimationController _winnerPulseController;
  late Animation<double> _winnerPulseAnimation;
  
  // Phase 2: Main board un-dim and ghost boards return animation
  late AnimationController _returnController;
  late Animation<double> _returnAnimation;
  
  // Phase 2: Final un-dimming animation
  late AnimationController _finalUndimController;
  late Animation<double> _finalUndimAnimation;
  
  // Phase 2: Final merge-back and scale-up animation
  late AnimationController _finalMergeController;
  late Animation<double> _finalMergeAnimation;
  late Animation<double> _mainBoardScaleUpAnimation;
  
  // Quantum-inspired: Whether animations are active
  bool _isEmerging = false;
  bool _isFloating = false;
  bool _isShrinking = false;
  bool _isDimming = false;
  bool _isMovingForward = false;
  bool _isArranging = false;
  bool _isPulsing = false;
  bool _isReturning = false;
  bool _isFinalUndimming = false;
  bool _isFinalMerging = false;
  
  // Getters for animations
  Animation<double> get mainBoardPulseAnimation => _mainBoardPulseAnimation;
  Animation<double> get emergenceScaleAnimation => _emergenceScaleAnimation;
  Animation<double> get emergenceOpacityAnimation => _emergenceOpacityAnimation;
  Animation<double> get floatingAnimation => _floatingAnimation;
  Animation<double> get mainBoardShrinkAnimation => _mainBoardShrinkAnimation;
  Animation<double> get dimmingAnimation => _dimmingAnimation;
  Animation<double> get ghostForwardAnimation => _ghostForwardAnimation;
  Animation<double> get columnArrangementAnimation => _columnArrangementAnimation;
  Animation<double> get winnerPulseAnimation => _winnerPulseAnimation;
  Animation<double> get returnAnimation => _returnAnimation;
  Animation<double> get finalUndimAnimation => _finalUndimAnimation;
  Animation<double> get finalMergeAnimation => _finalMergeAnimation;
  Animation<double> get mainBoardScaleUpAnimation => _mainBoardScaleUpAnimation;
  
  // State getters
  bool get isEmerging => _isEmerging;
  bool get isFloating => _isFloating;
  bool get isShrinking => _isShrinking;
  bool get isDimming => _isDimming;
  bool get isMovingForward => _isMovingForward;
  bool get isArranging => _isArranging;
  bool get isPulsing => _isPulsing;
  bool get isReturning => _isReturning;
  bool get isFinalUndimming => _isFinalUndimming;
  bool get isFinalMerging => _isFinalMerging;
  
  // Setter for deliberation completion callback
  set onDeliberationComplete(VoidCallback? callback) {
    _onDeliberationComplete = callback;
  }
  
  // Getter for current settings
  AnimationSettings get settings => _settings;
  
  // Update animation settings and reinitialize controllers
  void updateSettings(AnimationSettings newSettings, TickerProvider vsync) {
    _settings = newSettings;
    
    // Stop all current animations
    stopAnimations();
    
    // Dispose old controllers
    _disposeControllers();
    
    // Reinitialize with new settings
    _initializeAnimations(vsync);
    
    notifyListeners();
  }
  
  // Helper method to dispose all controllers
  void _disposeControllers() {
    _mainBoardPulseController.dispose();
    _emergenceController.dispose();
    _floatingController.dispose();
    _mainBoardShrinkController.dispose();
    _dimmingController.dispose();
    _ghostForwardController.dispose();
    _columnArrangementController.dispose();
    _winnerPulseController.dispose();
    _returnController.dispose();
    _finalUndimController.dispose();
    _finalMergeController.dispose();
  }
  
  // Constructor - requires a TickerProvider and optional settings
  AnimationViewModel(TickerProvider vsync, {AnimationSettings? settings}) 
      : _settings = settings ?? const AnimationSettings() {
    _initializeAnimations(vsync);
  }
  
  // Initialize all animations
  void _initializeAnimations(TickerProvider vsync) {
    print('DEBUG: Initializing animations');
    
    // Main board pulse
    _mainBoardPulseController = AnimationController(
      duration: Duration(milliseconds: _settings.mainBoardPulseDuration),
      vsync: vsync,
    );
    _mainBoardPulseAnimation = CurvedAnimation(
      parent: _mainBoardPulseController,
      curve: Curves.easeInOut,
    );
    
    // Ghost board emergence
    _emergenceController = AnimationController(
      duration: Duration(milliseconds: _settings.ghostEmergenceDuration),
      vsync: vsync,
    );
    _emergenceScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _emergenceController,
      curve: Curves.easeOutBack,
    ));
    _emergenceOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 0.6, // Match the ghost board's final opacity
    ).animate(CurvedAnimation(
      parent: _emergenceController,
      curve: Curves.easeIn,
    ));
    
    // Floating animation
    _floatingController = AnimationController(
      duration: Duration(milliseconds: _settings.floatingAnimationDuration),
      vsync: vsync,
    );
    _floatingAnimation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));
    
    // Main board shrink animation
    _mainBoardShrinkController = AnimationController(
      duration: Duration(milliseconds: _settings.mainBoardShrinkDuration),
      vsync: vsync,
    );
    _mainBoardShrinkAnimation = Tween<double>(
      begin: 1.0, // Full size
      end: 0.5,   // Half size (ghost board size)
    ).animate(CurvedAnimation(
      parent: _mainBoardShrinkController,
      curve: Curves.easeInOut,
    ));
    
    // Screen dimming animation
    _dimmingController = AnimationController(
      duration: Duration(milliseconds: _settings.screenDimmingDuration),
      vsync: vsync,
    );
    _dimmingAnimation = Tween<double>(
      begin: 0.0, // No dimming
      end: 0.6,   // 60% dimming
    ).animate(CurvedAnimation(
      parent: _dimmingController,
      curve: Curves.easeInOut,
    ));
    
    // Ghost boards forward movement animation
    _ghostForwardController = AnimationController(
      duration: Duration(milliseconds: _settings.ghostForwardDuration),
      vsync: vsync,
    );
    _ghostForwardAnimation = Tween<double>(
      begin: 1.0, // Normal size
      end: 1.15,  // Slightly larger (forward effect)
    ).animate(CurvedAnimation(
      parent: _ghostForwardController,
      curve: Curves.easeOut,
    ));
    
    // Column arrangement animation
    _columnArrangementController = AnimationController(
      duration: Duration(milliseconds: _settings.columnArrangementDuration),
      vsync: vsync,
    );
    _columnArrangementAnimation = Tween<double>(
      begin: 0.0, // Start at original positions
      end: 1.0,   // End at column positions
    ).animate(CurvedAnimation(
      parent: _columnArrangementController,
      curve: Curves.easeInOut,
    ));
    
    // Winner pulse animation
    _winnerPulseController = AnimationController(
      duration: Duration(milliseconds: _settings.winnerPulseDuration),
      vsync: vsync,
    );
    _winnerPulseAnimation = Tween<double>(
      begin: 0.0, // No pulse
      end: 1.0,   // Full pulse intensity
    ).animate(CurvedAnimation(
      parent: _winnerPulseController,
      curve: Curves.easeInOut,
    ));
    
    // Return animation (main board un-dim + ghost boards return to original positions)
    _returnController = AnimationController(
      duration: Duration(milliseconds: _settings.returnAnimationDuration),
      vsync: vsync,
    );
    _returnAnimation = Tween<double>(
      begin: 0.0, // Stay in rows
      end: 1.0,   // Return to original positions
    ).animate(CurvedAnimation(
      parent: _returnController,
      curve: Curves.easeInOut,
    ));
    
    // Final un-dimming animation
    _finalUndimController = AnimationController(
      duration: Duration(milliseconds: _settings.finalUndimmingDuration),
      vsync: vsync,
    );
    _finalUndimAnimation = Tween<double>(
      begin: 1.0, // Full dimming
      end: 0.0,   // No dimming
    ).animate(CurvedAnimation(
      parent: _finalUndimController,
      curve: Curves.easeOut,
    ));
    
    // Final merge-back and scale-up animation
    _finalMergeController = AnimationController(
      duration: Duration(milliseconds: _settings.finalMergeDuration),
      vsync: vsync,
    );
    _finalMergeAnimation = Tween<double>(
      begin: 1.0, // Ghost boards at original positions
      end: 0.0,   // Ghost boards merged back to center
    ).animate(CurvedAnimation(
      parent: _finalMergeController,
      curve: Curves.easeInOut,
    ));
    _mainBoardScaleUpAnimation = Tween<double>(
      begin: 0.5, // Small size (ghost board size)
      end: 1.0,   // Full size
    ).animate(CurvedAnimation(
      parent: _finalMergeController,
      curve: Curves.easeOut,
    ));
    
    // Add listeners (simplified - no debug spam)
    _mainBoardPulseAnimation.addListener(notifyListeners);
    _emergenceScaleAnimation.addListener(notifyListeners);
    _floatingAnimation.addListener(notifyListeners);
    _mainBoardShrinkAnimation.addListener(notifyListeners);
    _dimmingAnimation.addListener(notifyListeners);
    _ghostForwardAnimation.addListener(notifyListeners);
    _columnArrangementAnimation.addListener(notifyListeners);
    _winnerPulseAnimation.addListener(notifyListeners);
    _returnAnimation.addListener(notifyListeners);
    _finalUndimAnimation.addListener(notifyListeners);
    _finalMergeAnimation.addListener(notifyListeners);
    _mainBoardScaleUpAnimation.addListener(notifyListeners);
    
    // Add status listeners to handle animation completion
    _emergenceController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        print('DEBUG: Emergence animation completed');
        _isEmerging = false;
      notifyListeners();
      }
    });
    
    print('DEBUG: All animations initialized');
  }
  
  // Start the emergence sequence
  Future<void> startEmergenceSequence() async {
    if (_isEmerging) {
      print('DEBUG: Emergence sequence already in progress');
      return;
    }
    
    print('DEBUG: Starting emergence sequence');
    _isEmerging = true;
    
    // Reset all animations
    _mainBoardPulseController.reset();
    _emergenceController.reset();
    _floatingController.reset();
    
    // Start main board pulse
    print('DEBUG: Starting main board pulse');
    await _mainBoardPulseController.forward();
    print('DEBUG: Main board pulse completed');
    
    await Future.delayed(Duration(milliseconds: _settings.emergenceDelayDuration));
    
    // Start ghost board emergence
    print('DEBUG: Starting ghost board emergence');
    await _emergenceController.forward();
    print('DEBUG: Ghost board emergence completed');
    
    // Start floating animation
    print('DEBUG: Starting floating animation');
    _isFloating = true;
    _floatingController.repeat(reverse: true);
    
    notifyListeners();
  }
  
  // Start Phase 2: Deliberation sequence
  Future<void> startDeliberationSequence() async {
    if (_isShrinking) {
      print('DEBUG: Deliberation sequence already in progress');
      return;
    }
    
    print('DEBUG: Starting deliberation sequence - main board shrink');
    _isShrinking = true;
    
    // Reset animations
    _mainBoardShrinkController.reset();
    _dimmingController.reset();
    _ghostForwardController.reset();
    _columnArrangementController.reset();
    _winnerPulseController.reset();
    _returnController.reset();
    _finalUndimController.reset();
    _finalMergeController.reset();
    
    // Start main board shrink
    await _mainBoardShrinkController.forward();
    print('DEBUG: Main board shrink completed');
    
    // Start screen dimming
    print('DEBUG: Starting screen dimming');
    _isDimming = true;
    await _dimmingController.forward();
    print('DEBUG: Screen dimming completed');
    
    // Start ghost boards forward movement
    print('DEBUG: Starting ghost boards forward movement');
    _isMovingForward = true;
    await _ghostForwardController.forward();
    print('DEBUG: Ghost boards forward movement completed');
    
    // Start column arrangement
    print('DEBUG: Starting column arrangement');
    _isArranging = true;
    await _columnArrangementController.forward();
    print('DEBUG: Column arrangement completed');
    
    // Start winner pulse (quantum decision)
    print('DEBUG: Starting quantum winner determination and pulse');
    _isPulsing = true;
    await _winnerPulseController.forward();
    await _winnerPulseController.reverse();
    print('DEBUG: Winner pulse completed');
    
    // Start return animation (main board un-dim + ghost boards return)
    print('DEBUG: Starting return animation - main board un-dim and ghost boards return');
    _isReturning = true;
    await _returnController.forward();
    print('DEBUG: Return animation completed');
    
    // Start final un-dimming
    print('DEBUG: Starting final un-dimming - removing all screen dimming');
    _isFinalUndimming = true;
    await _finalUndimController.forward();
    print('DEBUG: Final un-dimming completed - screen fully bright');
    
    // Start final merge-back and scale-up
    print('DEBUG: Starting final merge-back and main board scale-up');
    _isFinalMerging = true;
    await _finalMergeController.forward();
    print('DEBUG: Final merge-back and scale-up completed');
    
    // Configurable pause before QCI makes move
    print('DEBUG: ${_settings.finalPauseDuration}ms pause before QCI makes move');
    await Future.delayed(Duration(milliseconds: _settings.finalPauseDuration));
    print('DEBUG: Pause completed - ready for QCI move');
    
      notifyListeners();
    
    // Notify completion - will be handled by GameViewModel
    _onDeliberationComplete?.call();
  }
  
  // Stop all animations
  void stopAnimations() {
    print('DEBUG: Stopping all animations');
    _isEmerging = false;
    _isFloating = false;
    _isShrinking = false;
    _isDimming = false;
    _isMovingForward = false;
    _isArranging = false;
    _isPulsing = false;
    _isReturning = false;
    _isFinalUndimming = false;
    _isFinalMerging = false;
    
    _mainBoardPulseController.stop();
    _emergenceController.stop();
    _floatingController.stop();
    _mainBoardShrinkController.stop();
    _dimmingController.stop();
    _ghostForwardController.stop();
    _columnArrangementController.stop();
    _winnerPulseController.stop();
    _returnController.stop();
    _finalUndimController.stop();
    _finalMergeController.stop();
    
    // Reset all animations to their starting values
    _mainBoardPulseController.reset();
    _emergenceController.reset();
    _floatingController.reset();
    _mainBoardShrinkController.reset();
    _dimmingController.reset();
    _ghostForwardController.reset();
    _columnArrangementController.reset();
    _winnerPulseController.reset();
    _returnController.reset();
    _finalUndimController.reset();
    _finalMergeController.reset();
    
      notifyListeners();
  }
  
  // Get current floating offset
  double getFloatingOffset() {
    return _isFloating ? _floatingAnimation.value * 2.0 : 0.0;
  }
  
  @override
  void dispose() {
    _mainBoardPulseController.dispose();
    _emergenceController.dispose();
    _floatingController.dispose();
    _mainBoardShrinkController.dispose();
    _dimmingController.dispose();
    _ghostForwardController.dispose();
    _columnArrangementController.dispose();
    _winnerPulseController.dispose();
    _returnController.dispose();
    _finalUndimController.dispose();
    _finalMergeController.dispose();
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