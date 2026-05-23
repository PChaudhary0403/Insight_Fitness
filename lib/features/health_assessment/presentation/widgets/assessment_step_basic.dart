import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_theme.dart';

/// Step 1: Basic health inputs (name, age, gender, height, weight).
class AssessmentStepBasic extends StatefulWidget {
  final String fullName;
  final int age;
  final String gender;
  final double heightCm;
  final double weightKg;
  final void Function(String name, int age, String gender, double height, double weight) onChanged;

  const AssessmentStepBasic({
    super.key,
    required this.fullName,
    required this.age,
    required this.gender,
    required this.heightCm,
    required this.weightKg,
    required this.onChanged,
  });

  @override
  State<AssessmentStepBasic> createState() => _AssessmentStepBasicState();
}

class _AssessmentStepBasicState extends State<AssessmentStepBasic> {
  late TextEditingController _nameCtrl;
  late String _gender;
  late double _height;
  late double _weight;
  late int _age;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.fullName);
    _gender = widget.gender;
    _height = widget.heightCm;
    _weight = widget.weightKg;
    _age = widget.age;
  }

  void _emit() {
    widget.onChanged(_nameCtrl.text, _age, _gender, _height, _weight);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
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
          // Name
          _label('Full Name'),
          _textField(_nameCtrl, 'Enter your full name', Icons.person_outline_rounded, () => _emit()),

          const SizedBox(height: AppTheme.spacing20),

          // Age slider
          _label('Age: $_age years'),
          _sliderCard(
            value: _age.toDouble(),
            min: 10, max: 100,
            divisions: 90,
            color: AppColors.accent,
            onChanged: (v) { setState(() => _age = v.round()); _emit(); },
          ),

          const SizedBox(height: AppTheme.spacing20),

          // Gender
          _label('Gender'),
          const SizedBox(height: 8),
          Row(
            children: [
              _genderChip('male', '♂ Male'),
              const SizedBox(width: 10),
              _genderChip('female', '♀ Female'),
              const SizedBox(width: 10),
              _genderChip('other', '⚧ Other'),
            ],
          ),

          const SizedBox(height: AppTheme.spacing20),

          // Height slider
          _label('Height: ${_height.toStringAsFixed(0)} cm'),
          _sliderCard(
            value: _height,
            min: 100, max: 220,
            divisions: 120,
            color: AppColors.secondary,
            onChanged: (v) { setState(() => _height = v); _emit(); },
          ),

          const SizedBox(height: AppTheme.spacing20),

          // Weight slider
          _label('Weight: ${_weight.toStringAsFixed(1)} kg'),
          _sliderCard(
            value: _weight,
            min: 30, max: 200,
            divisions: 340,
            color: AppColors.movement,
            onChanged: (v) { setState(() => _weight = double.parse(v.toStringAsFixed(1))); _emit(); },
          ),

          const SizedBox(height: AppTheme.spacing48),
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: AppTypography.bodyMedium(color: AppColors.darkTextPrimary)),
      );

  Widget _textField(TextEditingController ctrl, String hint, IconData icon, VoidCallback onDone) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceElevated,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppColors.darkDivider),
      ),
      child: TextField(
        controller: ctrl,
        onChanged: (_) => onDone(),
        style: AppTypography.body(color: AppColors.darkTextPrimary),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: AppColors.darkTextTertiary, size: 20),
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _genderChip(String value, String label) {
    final selected = _gender == value;
    return Expanded(
      child: GestureDetector(
        onTap: () { setState(() => _gender = value); _emit(); },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary.withValues(alpha: 0.15) : AppColors.darkSurfaceElevated,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.darkDivider,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTypography.bodyMedium(
                color: selected ? AppColors.primary : AppColors.darkTextSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sliderCard({
    required double value,
    required double min,
    required double max,
    required int divisions,
    required Color color,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceElevated,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppColors.darkDivider),
      ),
      child: SliderTheme(
        data: SliderThemeData(
          activeTrackColor: color,
          inactiveTrackColor: color.withValues(alpha: 0.15),
          thumbColor: color,
          overlayColor: color.withValues(alpha: 0.1),
          trackHeight: 4,
        ),
        child: Slider(
          value: value.clamp(min, max),
          min: min, max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
