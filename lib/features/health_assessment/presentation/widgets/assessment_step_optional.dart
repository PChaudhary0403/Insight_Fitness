import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_theme.dart';

/// Step 4: Optional details (body type, smoking, alcohol, health conditions).
class AssessmentStepOptional extends StatefulWidget {
  final String? bodyType;
  final String? smokingHabit;
  final String? alcoholHabit;
  final List<String> healthConditions;
  final void Function(String? body, String? smoking, String? alcohol, List<String> conditions) onChanged;

  const AssessmentStepOptional({
    super.key,
    required this.bodyType,
    required this.smokingHabit,
    required this.alcoholHabit,
    required this.healthConditions,
    required this.onChanged,
  });

  @override
  State<AssessmentStepOptional> createState() => _AssessmentStepOptionalState();
}

class _AssessmentStepOptionalState extends State<AssessmentStepOptional> {
  late String? _bodyType;
  late String? _smoking;
  late String? _alcohol;
  late List<String> _conditions;

  final _bodyTypes = const {'ectomorph': ('🏃', 'Ectomorph', 'Lean/Slim'), 'mesomorph': ('💪', 'Mesomorph', 'Athletic'), 'endomorph': ('🐻', 'Endomorph', 'Stocky')};
  final _smokingOpts = const {'never': '🚭 Never', 'occasionally': '🚬 Occasionally', 'regularly': '🚬 Regularly', 'heavy': '⚠️ Heavy'};
  final _alcoholOpts = const {'never': '🚫 Never', 'occasionally': '🍷 Occasionally', 'moderate': '🍺 Moderate', 'heavy': '⚠️ Heavy'};
  final _conditionsList = const ['Diabetes', 'Hypertension', 'Heart Disease', 'Asthma', 'Thyroid', 'PCOS', 'Back Pain', 'Joint Issues', 'Anxiety', 'Depression', 'Insomnia', 'Allergies'];

  @override
  void initState() {
    super.initState();
    _bodyType = widget.bodyType;
    _smoking = widget.smokingHabit;
    _alcohol = widget.alcoholHabit;
    _conditions = List.from(widget.healthConditions);
  }

  void _emit() => widget.onChanged(_bodyType, _smoking, _alcohol, _conditions);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppTheme.spacing8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, color: AppColors.info, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text('These fields are optional but help create a more accurate plan.',
                    style: AppTypography.caption(color: AppColors.info))),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.spacing20),

          // Body Type
          _label('Body Type'),
          const SizedBox(height: 8),
          Row(
            children: _bodyTypes.entries.map((e) {
              final selected = _bodyType == e.key;
              return Expanded(
                child: GestureDetector(
                  onTap: () { setState(() => _bodyType = _bodyType == e.key ? null : e.key); _emit(); },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(right: e.key != 'endomorph' ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.secondary.withValues(alpha: 0.15) : AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: selected ? AppColors.secondary : AppColors.dividerColor),
                    ),
                    child: Column(
                      children: [
                        Text(e.value.$1, style: const TextStyle(fontSize: 28)),
                        const SizedBox(height: 4),
                        Text(e.value.$2, style: AppTypography.bodySmall(color: selected ? AppColors.secondary : AppColors.textPrimary)),
                        Text(e.value.$3, style: AppTypography.caption(color: AppColors.textTertiary)),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: AppTheme.spacing20),

          // Smoking
          _label('Smoking Habits'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _smokingOpts.entries.map((e) => _chip(e.key, e.value, _smoking, (v) { setState(() => _smoking = v); _emit(); })).toList(),
          ),

          const SizedBox(height: AppTheme.spacing20),

          // Alcohol
          _label('Alcohol Consumption'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _alcoholOpts.entries.map((e) => _chip(e.key, e.value, _alcohol, (v) { setState(() => _alcohol = v); _emit(); })).toList(),
          ),

          const SizedBox(height: AppTheme.spacing20),

          // Health Conditions
          _label('Health Conditions (if any)'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _conditionsList.map((c) {
              final selected = _conditions.contains(c);
              return GestureDetector(
                onTap: () {
                  setState(() { selected ? _conditions.remove(c) : _conditions.add(c); });
                  _emit();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.error.withValues(alpha: 0.15) : AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: selected ? AppColors.error : AppColors.dividerColor),
                  ),
                  child: Text(c, style: AppTypography.bodySmall(
                    color: selected ? AppColors.error : AppColors.textSecondary,
                  )),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: AppTheme.spacing64),
        ],
      ),
    );
  }

  Widget _label(String t) => Text(t, style: AppTypography.bodyMedium(color: AppColors.textPrimary));

  Widget _chip(String value, String label, String? current, ValueChanged<String?> onTap) {
    final selected = current == value;
    return GestureDetector(
      onTap: () => onTap(selected ? null : value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.warning.withValues(alpha: 0.15) : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.warning : AppColors.dividerColor),
        ),
        child: Text(label, style: AppTypography.bodySmall(
          color: selected ? AppColors.warning : AppColors.textSecondary,
        )),
      ),
    );
  }
}
