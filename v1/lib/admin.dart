// Standalone Admin Interface for QCI Tic-Tac-Toe Animation Settings
// Run with: flutter run lib/admin.dart

import 'package:flutter/material.dart';
import 'models/animation_settings.dart';
import 'services/settings_service.dart';

void main() {
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QCI Animation Admin',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      ),
      home: const AdminScreen(),
    );
  }
}

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  late AnimationSettings _settings;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    _settings = SettingsService.loadSettings();
  }



  void _saveSettings() {
    try {
      SettingsService.saveSettings(_settings);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving settings: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _resetToDefaults() {
    setState(() {
      _settings = const AnimationSettings();
    });
  }

  void _updateSetting(AnimationSettings newSettings) {
    setState(() {
      _settings = newSettings;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QCI Animation Settings'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Phase 1: Emergence Animations'),
            _buildSlider(
              'Main Board Pulse',
              _settings.mainBoardPulseDuration,
              100,
              2000,
              (value) => _updateSetting(_settings.copyWith(mainBoardPulseDuration: value)),
            ),
            _buildSlider(
              'Ghost Emergence',
              _settings.ghostEmergenceDuration,
              100,
              2000,
              (value) => _updateSetting(_settings.copyWith(ghostEmergenceDuration: value)),
            ),
            _buildSlider(
              'Floating Animation',
              _settings.floatingAnimationDuration,
              500,
              5000,
              (value) => _updateSetting(_settings.copyWith(floatingAnimationDuration: value)),
            ),
            
            const SizedBox(height: 24),
            _buildSectionHeader('Phase 2: Deliberation Animations'),
            _buildSlider(
              'Main Board Shrink',
              _settings.mainBoardShrinkDuration,
              200,
              2000,
              (value) => _updateSetting(_settings.copyWith(mainBoardShrinkDuration: value)),
            ),
            _buildSlider(
              'Screen Dimming',
              _settings.screenDimmingDuration,
              200,
              2000,
              (value) => _updateSetting(_settings.copyWith(screenDimmingDuration: value)),
            ),
            _buildSlider(
              'Ghost Forward Movement',
              _settings.ghostForwardDuration,
              200,
              2000,
              (value) => _updateSetting(_settings.copyWith(ghostForwardDuration: value)),
            ),
            _buildSlider(
              'Column Arrangement',
              _settings.columnArrangementDuration,
              300,
              3000,
              (value) => _updateSetting(_settings.copyWith(columnArrangementDuration: value)),
            ),
            _buildSlider(
              'Winner Pulse',
              _settings.winnerPulseDuration,
              200,
              2000,
              (value) => _updateSetting(_settings.copyWith(winnerPulseDuration: value)),
            ),
            _buildSlider(
              'Return Animation',
              _settings.returnAnimationDuration,
              300,
              3000,
              (value) => _updateSetting(_settings.copyWith(returnAnimationDuration: value)),
            ),
            _buildSlider(
              'Final Undimming',
              _settings.finalUndimmingDuration,
              200,
              2000,
              (value) => _updateSetting(_settings.copyWith(finalUndimmingDuration: value)),
            ),
            _buildSlider(
              'Final Merge',
              _settings.finalMergeDuration,
              300,
              3000,
              (value) => _updateSetting(_settings.copyWith(finalMergeDuration: value)),
            ),
            
            const SizedBox(height: 24),
            _buildSectionHeader('Timing & Delays'),
            _buildSlider(
              'Emergence Delay',
              _settings.emergenceDelayDuration,
              0,
              1000,
              (value) => _updateSetting(_settings.copyWith(emergenceDelayDuration: value)),
            ),
            _buildSlider(
              'Deliberation Start Delay',
              _settings.deliberationDelayDuration,
              500,
              5000,
              (value) => _updateSetting(_settings.copyWith(deliberationDelayDuration: value)),
            ),
            _buildSlider(
              'Final Pause Before Move',
              _settings.finalPauseDuration,
              0,
              3000,
              (value) => _updateSetting(_settings.copyWith(finalPauseDuration: value)),
            ),
            
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveSettings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Save Settings'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _resetToDefaults,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Reset to Defaults'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Settings will be saved to: animation_settings.json\nRestart the main game to apply changes.',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSlider(
    String label,
    int currentValue,
    int min,
    int max,
    void Function(int) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${currentValue}ms',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Slider(
            value: currentValue.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: ((max - min) / 50).round(),
            onChanged: (value) => onChanged(value.round()),
          ),
        ],
      ),
    );
  }
} 