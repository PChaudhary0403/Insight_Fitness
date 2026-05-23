import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/discipline_models.dart';

/// Bottom sheet for creating a new discipline commitment.
class CreateDisciplineSheet extends StatefulWidget {
  final void Function(DisciplineRule rule) onCreated;
  const CreateDisciplineSheet({super.key, required this.onCreated});

  @override
  State<CreateDisciplineSheet> createState() => _CreateDisciplineSheetState();
}

class _CreateDisciplineSheetState extends State<CreateDisciplineSheet> {
  final _titleCtrl = TextEditingController();
  String _category = 'custom';
  String _recurrence = 'daily';
  String _strictness = 'moderate';
  String _verification = 'manual_checkin';
  String _startTime = '06:00';
  String _endTime = '07:00';

  final _categories = const {
    'wake_up': ('🌅', 'Wake Up', Icons.wb_sunny_rounded, AppColors.warning),
    'sleep': ('🌙', 'Sleep', Icons.nightlight_round, AppColors.sleep),
    'exercise': ('💪', 'Exercise', Icons.fitness_center_rounded, AppColors.exercise),
    'meditation': ('🧘', 'Meditation', Icons.self_improvement_rounded, AppColors.mindfulness),
    'diet': ('🥗', 'Diet', Icons.restaurant_rounded, AppColors.nutrition),
    'study': ('📚', 'Study', Icons.menu_book_rounded, AppColors.accent),
    'screen': ('📵', 'Screen Limit', Icons.phone_android_rounded, AppColors.secondary),
    'custom': ('🎯', 'Custom', Icons.tune_rounded, AppColors.primary),
  };

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  void _create() {
    if (_titleCtrl.text.trim().isEmpty) return;
    final cat = _categories[_category]!;
    widget.onCreated(DisciplineRule(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleCtrl.text.trim(),
      category: _category,
      icon: cat.$3,
      color: cat.$4,
      targetTimeStart: _startTime,
      targetTimeEnd: _endTime,
      recurrence: _recurrence,
      strictness: _strictness,
      verificationMethod: _verification,
      createdAt: DateTime.now(),
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      decoration: const BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40, height: 4,
            decoration: BoxDecoration(color: AppColors.darkDivider, borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text('Create Discipline', style: AppTypography.h3(color: AppColors.darkTextPrimary)),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  _label('Discipline Title'),
                  _field(_titleCtrl, 'e.g. Wake up at 6 AM'),
                  const SizedBox(height: 20),

                  // Category
                  _label('Category'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: _categories.entries.map((e) {
                      final sel = _category == e.key;
                      return GestureDetector(
                        onTap: () => setState(() => _category = e.key),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: sel ? e.value.$4.withValues(alpha: 0.15) : AppColors.darkSurfaceElevated,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: sel ? e.value.$4 : AppColors.darkDivider),
                          ),
                          child: Text('${e.value.$1} ${e.value.$2}', style: AppTypography.bodySmall(
                            color: sel ? e.value.$4 : AppColors.darkTextSecondary,
                          )),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Time Window
                  _label('Time Window'),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: _timePick('Start', _startTime, (v) => setState(() => _startTime = v))),
                    const SizedBox(width: 12),
                    Expanded(child: _timePick('End', _endTime, (v) => setState(() => _endTime = v))),
                  ]),
                  const SizedBox(height: 20),

                  // Recurrence
                  _label('Recurrence'),
                  const SizedBox(height: 8),
                  _chipRow({'daily': 'Daily', 'weekdays': 'Weekdays', 'weekends': 'Weekends'}, _recurrence, (v) => setState(() => _recurrence = v)),
                  const SizedBox(height: 20),

                  // Strictness
                  _label('Strictness Level'),
                  const SizedBox(height: 8),
                  _chipRow({'strict': '🔒 Strict', 'moderate': '⚖️ Moderate', 'relaxed': '😌 Relaxed'}, _strictness, (v) => setState(() => _strictness = v)),
                  const SizedBox(height: 20),

                  // Verification
                  _label('Verification Method'),
                  const SizedBox(height: 8),
                  _chipRow({
                    'manual_checkin': '✋ Manual',
                    'button_confirm': '🔘 Button',
                    'timestamp_log': '⏱️ Timestamp',
                  }, _verification, (v) => setState(() => _verification = v)),

                  // Trust info
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
                    ),
                    child: Row(children: [
                      Icon(Icons.shield_rounded, color: AppColors.warning, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(
                        'Timestamp logging has higher trust than manual check-ins. Consider wearable integration for maximum trust scoring.',
                        style: AppTypography.caption(color: AppColors.warning),
                      )),
                    ]),
                  ),

                  const SizedBox(height: 24),

                  // Create button
                  SizedBox(
                    width: double.infinity, height: 52,
                    child: ElevatedButton(
                      onPressed: _create,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusFull)),
                      ),
                      child: Text('Create Discipline', style: AppTypography.button(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String t) => Text(t, style: AppTypography.bodyMedium(color: AppColors.darkTextPrimary));

  Widget _field(TextEditingController c, String hint) => Container(
    margin: const EdgeInsets.only(top: 8),
    decoration: BoxDecoration(
      color: AppColors.darkSurfaceElevated,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.darkDivider),
    ),
    child: TextField(
      controller: c,
      style: AppTypography.body(color: AppColors.darkTextPrimary),
      decoration: InputDecoration(
        hintText: hint, filled: false, border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    ),
  );

  Widget _chipRow(Map<String, String> opts, String current, ValueChanged<String> onTap) {
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: opts.entries.map((e) {
        final sel = current == e.key;
        return GestureDetector(
          onTap: () => onTap(e.key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: sel ? AppColors.primary.withValues(alpha: 0.15) : AppColors.darkSurfaceElevated,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: sel ? AppColors.primary : AppColors.darkDivider),
            ),
            child: Text(e.value, style: AppTypography.bodySmall(color: sel ? AppColors.primary : AppColors.darkTextSecondary)),
          ),
        );
      }).toList(),
    );
  }

  Widget _timePick(String label, String value, ValueChanged<String> onChanged) {
    return GestureDetector(
      onTap: () async {
        final parts = value.split(':');
        final picked = await showTimePicker(context: context, initialTime: TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])));
        if (picked != null) onChanged('${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}');
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.darkSurfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.darkDivider),
        ),
        child: Column(children: [
          Text(label, style: AppTypography.caption(color: AppColors.darkTextSecondary)),
          const SizedBox(height: 4),
          Text(value, style: AppTypography.h4(color: AppColors.darkTextPrimary)),
        ]),
      ),
    );
  }
}
