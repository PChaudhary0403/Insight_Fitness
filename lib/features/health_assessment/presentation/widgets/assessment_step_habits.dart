import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_theme.dart';

/// Step 3: Diet & wellness habits.
class AssessmentStepHabits extends StatefulWidget {
  final String dietaryPreference;
  final double waterIntakeLiters;
  final String stressLevel;
  final void Function(String diet, double water, String stress) onChanged;

  const AssessmentStepHabits({
    super.key,
    required this.dietaryPreference,
    required this.waterIntakeLiters,
    required this.stressLevel,
    required this.onChanged,
  });

  @override
  State<AssessmentStepHabits> createState() => _AssessmentStepHabitsState();
}

class _AssessmentStepHabitsState extends State<AssessmentStepHabits> {
  late String _diet;
  late double _water;
  late String _stress;

  final _dietOptions = const {
    'omnivore': ('🍖', 'Omnivore'),
    'vegetarian': ('🥬', 'Vegetarian'),
    'vegan': ('🌱', 'Vegan'),
    'keto': ('🥑', 'Keto'),
    'paleo': ('🍗', 'Paleo'),
  };

  final _stressOptions = const {
    'low': ('😌', 'Low', AppColors.success),
    'moderate': ('😐', 'Moderate', AppColors.warning),
    'high': ('😰', 'High', AppColors.error),
    'very_high': ('🤯', 'Very High', AppColors.error),
  };

  @override
  void initState() {
    super.initState();
    _diet = widget.dietaryPreference;
    _water = widget.waterIntakeLiters;
    _stress = widget.stressLevel;
  }

  void _emit() => widget.onChanged(_diet, _water, _stress);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppTheme.spacing16),

          // Dietary Preference
          _label('Dietary Preference'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _dietOptions.entries.map((e) {
              final selected = _diet == e.key;
              return GestureDetector(
                onTap: () { setState(() => _diet = e.key); _emit(); },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.nutrition.withValues(alpha: 0.15) : AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: selected ? AppColors.nutrition : AppColors.dividerColor),
                  ),
                  child: Text('${e.value.$1} ${e.value.$2}', style: AppTypography.bodySmall(
                    color: selected ? AppColors.nutrition : AppColors.textSecondary,
                  )),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: AppTheme.spacing24),

          // Water Intake
          _label('Daily Water Intake: ${_water.toStringAsFixed(1)}L'),
          const SizedBox(height: 8),
          _buildWaterVisual(),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(color: AppColors.dividerColor),
            ),
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: AppColors.hydration,
                inactiveTrackColor: AppColors.hydration.withValues(alpha: 0.15),
                thumbColor: AppColors.hydration,
                overlayColor: AppColors.hydration.withValues(alpha: 0.1),
                trackHeight: 4,
              ),
              child: Slider(
                value: _water.clamp(0.5, 6.0),
                min: 0.5, max: 6.0, divisions: 22,
                onChanged: (v) { setState(() => _water = double.parse(v.toStringAsFixed(1))); _emit(); },
              ),
            ),
          ),

          const SizedBox(height: AppTheme.spacing24),

          // Stress Level
          _label('Stress Level'),
          const SizedBox(height: 8),
          Row(
            children: _stressOptions.entries.map((e) {
              final selected = _stress == e.key;
              final color = e.value.$3;
              return Expanded(
                child: GestureDetector(
                  onTap: () { setState(() => _stress = e.key); _emit(); },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(right: e.key != 'very_high' ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: selected ? color.withValues(alpha: 0.15) : AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: selected ? color : AppColors.dividerColor),
                    ),
                    child: Column(
                      children: [
                        Text(e.value.$1, style: const TextStyle(fontSize: 24)),
                        const SizedBox(height: 4),
                        Text(e.value.$2, style: AppTypography.caption(
                          color: selected ? color : AppColors.textSecondary,
                        ), textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: AppTheme.spacing48),
        ],
      ),
    );
  }

  Widget _buildWaterVisual() {
    final glasses = (_water / 0.25).round().clamp(0, 20);
    return Wrap(
      spacing: 6, runSpacing: 6,
      children: List.generate(12, (i) {
        final filled = i < glasses;
        return Container(
          width: 28, height: 36,
          decoration: BoxDecoration(
            color: filled ? AppColors.hydration.withValues(alpha: 0.3) : AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: filled ? AppColors.hydration : AppColors.dividerColor),
          ),
          child: Center(
            child: Text(
              filled ? '💧' : '',
              style: const TextStyle(fontSize: 14),
            ),
          ),
        );
      }),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: AppTypography.bodyMedium(color: AppColors.textPrimary),
      );
}
