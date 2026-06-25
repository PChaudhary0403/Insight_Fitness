import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_theme.dart';

/// Step 2: Lifestyle & activity inputs.
class AssessmentStepLifestyle extends StatefulWidget {
  final String activityLevel;
  final String occupation;
  final double dailySittingHours;
  final String wakeUpTime;
  final String sleepTime;
  final String exerciseFrequency;
  final void Function(String activity, String occ, double sitting, String wake, String sleep, String exercise) onChanged;

  const AssessmentStepLifestyle({
    super.key,
    required this.activityLevel,
    required this.occupation,
    required this.dailySittingHours,
    required this.wakeUpTime,
    required this.sleepTime,
    required this.exerciseFrequency,
    required this.onChanged,
  });

  @override
  State<AssessmentStepLifestyle> createState() => _AssessmentStepLifestyleState();
}

class _AssessmentStepLifestyleState extends State<AssessmentStepLifestyle> {
  late TextEditingController _occCtrl;
  late String _activityLevel;
  late double _sittingHours;
  late String _wakeUp;
  late String _sleep;
  late String _exerciseFreq;

  final _activityOptions = const {
    'sedentary': ('🪑', 'Sedentary'),
    'light': ('🚶', 'Lightly Active'),
    'moderate': ('🏃', 'Moderate'),
    'active': ('💪', 'Active'),
    'very_active': ('🔥', 'Very Active'),
  };

  final _exerciseOptions = const {
    'never': 'Never',
    '1-2x': '1-2x/week',
    '3-4x': '3-4x/week',
    '5-6x': '5-6x/week',
    'daily': 'Daily',
  };

  @override
  void initState() {
    super.initState();
    _occCtrl = TextEditingController(text: widget.occupation);
    _activityLevel = widget.activityLevel;
    _sittingHours = widget.dailySittingHours;
    _wakeUp = widget.wakeUpTime;
    _sleep = widget.sleepTime;
    _exerciseFreq = widget.exerciseFrequency;
  }

  void _emit() {
    widget.onChanged(_activityLevel, _occCtrl.text, _sittingHours, _wakeUp, _sleep, _exerciseFreq);
  }

  @override
  void dispose() {
    _occCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppTheme.spacing16),

          // Occupation
          _label('Occupation'),
          _textField(_occCtrl, 'e.g. Software Developer', Icons.work_outline_rounded),

          const SizedBox(height: AppTheme.spacing20),

          // Activity Level
          _label('Activity Level'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _activityOptions.entries.map((e) => _activityChip(e.key, e.value.$1, e.value.$2)).toList(),
          ),

          const SizedBox(height: AppTheme.spacing20),

          // Sitting hours
          _label('Daily Sitting: ${_sittingHours.toStringAsFixed(0)} hours'),
          _sliderCard(
            value: _sittingHours, min: 0, max: 16, divisions: 16,
            color: _sittingHours >= 8 ? AppColors.error : AppColors.success,
            onChanged: (v) { setState(() => _sittingHours = v); _emit(); },
          ),

          const SizedBox(height: AppTheme.spacing20),

          // Wake-up & Sleep time
          Row(
            children: [
              Expanded(child: _timePicker('Wake-up', _wakeUp, Icons.wb_sunny_rounded, AppColors.warning, (v) {
                setState(() => _wakeUp = v); _emit();
              })),
              const SizedBox(width: 12),
              Expanded(child: _timePicker('Sleep', _sleep, Icons.nightlight_round, AppColors.sleep, (v) {
                setState(() => _sleep = v); _emit();
              })),
            ],
          ),

          const SizedBox(height: AppTheme.spacing20),

          // Exercise frequency
          _label('Exercise Frequency'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _exerciseOptions.entries.map((e) => _exerciseChip(e.key, e.value)).toList(),
          ),

          const SizedBox(height: AppTheme.spacing48),
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: AppTypography.bodyMedium(color: AppColors.textPrimary)),
      );

  Widget _textField(TextEditingController ctrl, String hint, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppColors.dividerColor),
      ),
      child: TextField(
        controller: ctrl,
        onChanged: (_) => _emit(),
        style: AppTypography.body(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: AppColors.textTertiary, size: 20),
          filled: false, border: InputBorder.none,
          enabledBorder: InputBorder.none, focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _activityChip(String value, String emoji, String label) {
    final selected = _activityLevel == value;
    return GestureDetector(
      onTap: () { setState(() => _activityLevel = value); _emit(); },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.15) : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppColors.primary : AppColors.dividerColor),
        ),
        child: Text('$emoji $label', style: AppTypography.bodySmall(
          color: selected ? AppColors.primary : AppColors.textSecondary,
        )),
      ),
    );
  }

  Widget _exerciseChip(String value, String label) {
    final selected = _exerciseFreq == value;
    return GestureDetector(
      onTap: () { setState(() => _exerciseFreq = value); _emit(); },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.movement.withValues(alpha: 0.15) : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppColors.movement : AppColors.dividerColor),
        ),
        child: Text(label, style: AppTypography.bodySmall(
          color: selected ? AppColors.movement : AppColors.textSecondary,
        )),
      ),
    );
  }

  Widget _sliderCard({
    required double value, required double min, required double max,
    required int divisions, required Color color, required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppColors.dividerColor),
      ),
      child: SliderTheme(
        data: SliderThemeData(
          activeTrackColor: color, inactiveTrackColor: color.withValues(alpha: 0.15),
          thumbColor: color, overlayColor: color.withValues(alpha: 0.1), trackHeight: 4,
        ),
        child: Slider(value: value.clamp(min, max), min: min, max: max, divisions: divisions, onChanged: onChanged),
      ),
    );
  }

  Widget _timePicker(String label, String current, IconData icon, Color color, ValueChanged<String> onChanged) {
    return GestureDetector(
      onTap: () async {
        final parts = current.split(':');
        final picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])),
        );
        if (picked != null) {
          onChanged('${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}');
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(color: AppColors.dividerColor),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(label, style: AppTypography.caption(color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Text(current, style: AppTypography.h4(color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}
