// Settings Service for QCI Tic-Tac-Toe
// Handles loading and saving animation settings from JSON file

import 'dart:convert';
import 'dart:io';
import '../models/animation_settings.dart';

class SettingsService {
  static const String _settingsFile = 'animation_settings.json';
  
  // Load settings from JSON file, fallback to defaults if file doesn't exist
  static AnimationSettings loadSettings() {
    try {
      final file = File(_settingsFile);
      if (file.existsSync()) {
        final jsonString = file.readAsStringSync();
        final jsonMap = json.decode(jsonString);
        return _parseSettingsFromJson(jsonMap);
      } else {
        print('Settings file not found, using defaults');
        return const AnimationSettings();
      }
    } catch (e) {
      print('Error loading settings: $e, using defaults');
      return const AnimationSettings();
    }
  }
  
  // Parse AnimationSettings from JSON map
  static AnimationSettings _parseSettingsFromJson(Map<String, dynamic> json) {
    return AnimationSettings(
      mainBoardPulseDuration: json['mainBoardPulseDuration'] ?? 500,
      ghostEmergenceDuration: json['ghostEmergenceDuration'] ?? 500,
      floatingAnimationDuration: json['floatingAnimationDuration'] ?? 2000,
      mainBoardShrinkDuration: json['mainBoardShrinkDuration'] ?? 800,
      screenDimmingDuration: json['screenDimmingDuration'] ?? 600,
      ghostForwardDuration: json['ghostForwardDuration'] ?? 500,
      columnArrangementDuration: json['columnArrangementDuration'] ?? 800,
      winnerPulseDuration: json['winnerPulseDuration'] ?? 600,
      returnAnimationDuration: json['returnAnimationDuration'] ?? 800,
      finalUndimmingDuration: json['finalUndimmingDuration'] ?? 600,
      finalMergeDuration: json['finalMergeDuration'] ?? 800,
      emergenceDelayDuration: json['emergenceDelayDuration'] ?? 100,
      deliberationDelayDuration: json['deliberationDelayDuration'] ?? 2000,
      finalPauseDuration: json['finalPauseDuration'] ?? 1000,
    );
  }
  
  // Save settings to JSON file
  static void saveSettings(AnimationSettings settings) {
    try {
      final file = File(_settingsFile);
      final jsonString = json.encode(_settingsToJson(settings));
      file.writeAsStringSync(jsonString);
      print('Settings saved successfully');
    } catch (e) {
      print('Error saving settings: $e');
    }
  }
  
  // Convert AnimationSettings to JSON map
  static Map<String, dynamic> _settingsToJson(AnimationSettings settings) {
    return {
      'mainBoardPulseDuration': settings.mainBoardPulseDuration,
      'ghostEmergenceDuration': settings.ghostEmergenceDuration,
      'floatingAnimationDuration': settings.floatingAnimationDuration,
      'mainBoardShrinkDuration': settings.mainBoardShrinkDuration,
      'screenDimmingDuration': settings.screenDimmingDuration,
      'ghostForwardDuration': settings.ghostForwardDuration,
      'columnArrangementDuration': settings.columnArrangementDuration,
      'winnerPulseDuration': settings.winnerPulseDuration,
      'returnAnimationDuration': settings.returnAnimationDuration,
      'finalUndimmingDuration': settings.finalUndimmingDuration,
      'finalMergeDuration': settings.finalMergeDuration,
      'emergenceDelayDuration': settings.emergenceDelayDuration,
      'deliberationDelayDuration': settings.deliberationDelayDuration,
      'finalPauseDuration': settings.finalPauseDuration,
    };
  }
} 