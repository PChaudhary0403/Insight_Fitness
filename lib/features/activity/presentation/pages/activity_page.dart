import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/services/user_data_service.dart';

/// Activity page — manual exercise logging with sets & reps.
/// No input for the day = 0 exercise, which affects dashboard scores.
class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});
  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  final data = UserDataService.instance;

  void _addSteps() {
    showDialog(
      context: context,
      builder: (ctx) {
        int steps = 1000;
        return StatefulBuilder(
          builder: (ctx, setDialogState) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text('Add Steps', style: AppTypography.h3(color: AppColors.textPrimary)),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('$steps steps', style: AppTypography.metric(color: AppColors.movement)),
              Slider(
                value: steps.toDouble(), min: 100, max: 15000, divisions: 149,
                activeColor: AppColors.movement, inactiveColor: AppColors.surfaceElevated,
                onChanged: (v) => setDialogState(() => steps = v.round()),
              ),
              Wrap(spacing: 8, children: [500, 1000, 2000, 5000].map((s) => ActionChip(
                label: Text('+$s', style: AppTypography.caption(color: AppColors.movement)),
                backgroundColor: AppColors.movement.withValues(alpha: 0.12), side: BorderSide.none,
                onPressed: () => setDialogState(() => steps = s),
              )).toList()),
            ]),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx),
                child: Text('Cancel', style: AppTypography.bodyMedium(color: AppColors.textSecondary))),
              ElevatedButton(
                onPressed: () { data.addSteps(steps); Navigator.pop(ctx); setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('🚶 Added $steps steps!'),
                    backgroundColor: AppColors.movement, behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.movement,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: Text('Add', style: AppTypography.button(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openLogExercise() {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => _LogExerciseSheet(onLogged: (name, sets, reps, minutes, calories) {
        data.logExerciseEntry(name: name, icon: 'fitness', sets: sets, reps: reps,
          estimatedMinutes: minutes, caloriesBurned: calories);
        Navigator.pop(context);
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('💪 $name: $sets sets × $reps reps • $calories kcal'),
          backgroundColor: AppColors.exercise, behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }),
    );
  }

  void _removeExercise(int index) async {
    await data.removeExerciseEntry(index);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final steps = data.dailySteps;
    final stepPercent = (steps / 10000).clamp(0.0, 1.0);
    final km = (steps * 0.0008).toStringAsFixed(1);
    final log = data.exerciseLog;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: Text('Activity', style: AppTypography.h3(color: AppColors.textPrimary)),
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(icon: const Icon(Icons.add_rounded, color: AppColors.primary),
            onPressed: _openLogExercise, tooltip: 'Log exercise'),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacing24),
        child: Column(children: [
          // Steps card
          GestureDetector(
            onTap: _addSteps,
            child: Container(
              width: double.infinity, padding: const EdgeInsets.all(AppTheme.spacing24),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.movement.withValues(alpha: 0.15), AppColors.movement.withValues(alpha: 0.05)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                border: Border.all(color: AppColors.movement.withValues(alpha: 0.2)),
              ),
              child: Column(children: [
                const Icon(Icons.directions_walk_rounded, color: AppColors.movement, size: 40),
                const SizedBox(height: AppTheme.spacing12),
                Text(_fmtSteps(steps), style: AppTypography.score(color: AppColors.textPrimary)),
                Text('/ 10,000 steps', style: AppTypography.body(color: AppColors.textSecondary)),
                const SizedBox(height: AppTheme.spacing16),
                ClipRRect(borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(value: stepPercent, minHeight: 10,
                    backgroundColor: AppColors.movement.withValues(alpha: 0.15),
                    valueColor: const AlwaysStoppedAnimation(AppColors.movement))),
                const SizedBox(height: AppTheme.spacing8),
                Text(steps == 0 ? 'Tap to add steps' : '$km km walked',
                  style: AppTypography.bodySmall(color: AppColors.textSecondary)),
              ]),
            ),
          ).animate().fadeIn(duration: 500.ms),

          const SizedBox(height: AppTheme.spacing20),

          // Metrics grid
          Row(children: [
            Expanded(child: _Metric(Icons.fitness_center_rounded, 'Exercises', '${log.length}', AppColors.exercise)),
            const SizedBox(width: AppTheme.spacing12),
            Expanded(child: _Metric(Icons.repeat_rounded, 'Total Sets', '${data.dailyTotalSets}', AppColors.movement)),
          ]).animate(delay: 200.ms).fadeIn(duration: 400.ms),
          const SizedBox(height: AppTheme.spacing12),
          Row(children: [
            Expanded(child: _Metric(Icons.tag_rounded, 'Total Reps', '${data.dailyTotalReps}', AppColors.primary)),
            const SizedBox(width: AppTheme.spacing12),
            Expanded(child: _Metric(Icons.local_fire_department_rounded, 'Calories', '${data.dailyCaloriesBurned}', const Color(0xFFFF6B35))),
          ]).animate(delay: 300.ms).fadeIn(duration: 400.ms),
          const SizedBox(height: AppTheme.spacing12),
          Row(children: [
            Expanded(child: _Metric(Icons.timer_outlined, 'Duration', '${data.dailyExerciseMin} min', AppColors.info)),
            const SizedBox(width: AppTheme.spacing12),
            Expanded(child: _Metric(Icons.whatshot_rounded, 'Streak', '${data.currentStreak} days',
              data.currentStreak > 0 ? AppColors.warning : AppColors.textTertiary)),
          ]).animate(delay: 350.ms).fadeIn(duration: 400.ms),

          const SizedBox(height: AppTheme.spacing24),

          // Exercise log
          Container(
            width: double.infinity, padding: const EdgeInsets.all(AppTheme.spacing20),
            decoration: BoxDecoration(color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(color: AppColors.cardBorder)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text("Today's Exercises", style: AppTypography.h4(color: AppColors.textPrimary)),
                const Spacer(),
                GestureDetector(onTap: _openLogExercise,
                  child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.exercise.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                    child: Text('+ Add', style: AppTypography.caption(color: AppColors.exercise)))),
              ]),
              const SizedBox(height: AppTheme.spacing16),
              if (log.isEmpty)
                Padding(padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: Column(children: [
                    Icon(Icons.fitness_center_rounded, color: AppColors.textTertiary, size: 36),
                    const SizedBox(height: 8),
                    Text('No exercises logged today', style: AppTypography.body(color: AppColors.textTertiary)),
                    const SizedBox(height: 4),
                    Text('Tap + to log your workout with sets & reps',
                      style: AppTypography.caption(color: AppColors.textTertiary)),
                    const SizedBox(height: 8),
                    Text('⚠️ Zero exercise today affects your health score',
                      style: AppTypography.caption(color: AppColors.warning)),
                  ])))
              else
                ...log.asMap().entries.map((entry) {
                  final i = entry.key;
                  final e = entry.value;
                  return Dismissible(
                    key: ValueKey('exercise_$i'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.delete_rounded, color: AppColors.error)),
                    onDismissed: (_) => _removeExercise(i),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.surfaceElevated, borderRadius: BorderRadius.circular(12)),
                      child: Row(children: [
                        Container(width: 40, height: 40,
                          decoration: BoxDecoration(color: AppColors.exercise.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.fitness_center_rounded, color: AppColors.exercise, size: 20)),
                        const SizedBox(width: AppTheme.spacing12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(e['name'] ?? '', style: AppTypography.bodyMedium(color: AppColors.textPrimary)),
                          Text('${e['sets']} sets × ${e['reps']} reps • ${e['minutes']} min',
                            style: AppTypography.caption(color: AppColors.textSecondary)),
                        ])),
                        Text('${e['calories']} kcal', style: AppTypography.bodySmall(color: AppColors.exercise)),
                      ]),
                    ),
                  );
                }),
            ]),
          ).animate(delay: 400.ms).fadeIn(duration: 400.ms),
        ]),
      ),
    );
  }

  String _fmtSteps(int s) => s >= 1000 ? '${(s / 1000).toStringAsFixed(0)},${(s % 1000).toString().padLeft(3, '0')}' : '$s';
}

// ─── Log Exercise Bottom Sheet ──────────────────────────────

class _LogExerciseSheet extends StatefulWidget {
  final Function(String name, int sets, int reps, int minutes, int calories) onLogged;
  const _LogExerciseSheet({required this.onLogged});
  @override
  State<_LogExerciseSheet> createState() => _LogExerciseSheetState();
}

class _LogExerciseSheetState extends State<_LogExerciseSheet> {
  String _selected = '';
  int _sets = 3;
  int _reps = 12;
  final _customController = TextEditingController();
  bool _isCustom = false;

  // Exercise library with cal-per-rep estimates
  static const _exercises = [
    ('Push-ups', Icons.fitness_center_rounded, 0.5, 'Chest, Arms'),
    ('Pull-ups', Icons.fitness_center_rounded, 1.0, 'Back, Arms'),
    ('Squats', Icons.directions_walk_rounded, 0.4, 'Legs, Glutes'),
    ('Lunges', Icons.directions_walk_rounded, 0.5, 'Legs, Glutes'),
    ('Planks', Icons.rectangle_rounded, 0.3, 'Core'),
    ('Crunches', Icons.accessibility_new_rounded, 0.3, 'Core'),
    ('Burpees', Icons.sports_gymnastics_rounded, 1.2, 'Full Body'),
    ('Jumping Jacks', Icons.sports_gymnastics_rounded, 0.3, 'Cardio'),
    ('Mountain Climbers', Icons.terrain_rounded, 0.5, 'Core, Cardio'),
    ('Tricep Dips', Icons.fitness_center_rounded, 0.5, 'Arms'),
    ('Calf Raises', Icons.directions_walk_rounded, 0.2, 'Legs'),
    ('Glute Bridges', Icons.accessibility_new_rounded, 0.3, 'Glutes'),
    ('Deadlifts', Icons.fitness_center_rounded, 0.8, 'Back, Legs'),
    ('Bench Press', Icons.fitness_center_rounded, 0.7, 'Chest'),
    ('Shoulder Press', Icons.fitness_center_rounded, 0.6, 'Shoulders'),
    ('Bicep Curls', Icons.fitness_center_rounded, 0.4, 'Arms'),
    ('Lat Pulldowns', Icons.fitness_center_rounded, 0.5, 'Back'),
    ('Leg Press', Icons.fitness_center_rounded, 0.6, 'Legs'),
    ('Running (10 min)', Icons.directions_run_rounded, 10.0, 'Cardio'),
    ('Cycling (10 min)', Icons.pedal_bike_rounded, 8.0, 'Cardio, Legs'),
    ('Yoga (15 min)', Icons.self_improvement_rounded, 4.0, 'Flexibility'),
    ('Swimming (10 min)', Icons.pool_rounded, 9.0, 'Full Body'),
  ];

  int get _totalReps => _sets * _reps;
  int get _estCalories {
    if (_selected.isEmpty && !_isCustom) return 0;
    if (_isCustom) return (_totalReps * 0.4).round(); // generic estimate
    final ex = _exercises.where((e) => e.$1 == _selected);
    if (ex.isEmpty) return 0;
    // For cardio entries (Running, Cycling, etc.) calPerRep is actually cal/min
    if (_selected.contains('min)')) return (ex.first.$3 * _sets).round();
    return (_totalReps * ex.first.$3).round();
  }
  int get _estMinutes => (_totalReps * 0.08).round().clamp(1, 999); // ~5sec per rep average

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.dividerColor, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 16),
        Text('Log Exercise', style: AppTypography.h3(color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        Text('Select exercise, enter sets & reps', style: AppTypography.caption(color: AppColors.textSecondary)),
        const SizedBox(height: 20),

        // Exercise selection
        Wrap(spacing: 8, runSpacing: 8, children: [
          ..._exercises.map((e) {
            final sel = _selected == e.$1 && !_isCustom;
            return GestureDetector(
              onTap: () => setState(() { _selected = e.$1; _isCustom = false; }),
              child: AnimatedContainer(duration: 200.ms,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: sel ? AppColors.exercise.withValues(alpha: 0.2) : AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: sel ? AppColors.exercise.withValues(alpha: 0.5) : Colors.transparent)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(e.$2, color: sel ? AppColors.exercise : AppColors.textSecondary, size: 16),
                  const SizedBox(width: 6),
                  Text(e.$1, style: AppTypography.caption(color: sel ? AppColors.exercise : AppColors.textPrimary)),
                ])),
            );
          }),
          // Custom exercise chip
          GestureDetector(
            onTap: () => setState(() { _isCustom = true; _selected = ''; }),
            child: AnimatedContainer(duration: 200.ms,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _isCustom ? AppColors.primary.withValues(alpha: 0.2) : AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _isCustom ? AppColors.primary.withValues(alpha: 0.5) : Colors.transparent)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.edit_rounded, color: _isCustom ? AppColors.primary : AppColors.textSecondary, size: 16),
                const SizedBox(width: 6),
                Text('Custom', style: AppTypography.caption(color: _isCustom ? AppColors.primary : AppColors.textPrimary)),
              ])),
          ),
        ]),

        if (_isCustom) ...[
          const SizedBox(height: 16),
          TextField(
            controller: _customController,
            style: AppTypography.body(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Exercise name (e.g. Dumbbell Rows)',
              hintStyle: AppTypography.body(color: AppColors.textTertiary),
              filled: true, fillColor: AppColors.surfaceElevated,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ],

        const SizedBox(height: 24),
        // Sets & Reps input
        Row(children: [
          Expanded(child: _CounterInput(label: 'Sets', value: _sets, min: 1, max: 20,
            onChanged: (v) => setState(() => _sets = v))),
          const SizedBox(width: 16),
          Expanded(child: _CounterInput(label: 'Reps', value: _reps, min: 1, max: 100,
            onChanged: (v) => setState(() => _reps = v))),
        ]),

        const SizedBox(height: 16),
        // Quick preset buttons
        Text('Quick Presets', style: AppTypography.caption(color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, children: [
          _PresetChip('3×10', () => setState(() { _sets = 3; _reps = 10; })),
          _PresetChip('3×12', () => setState(() { _sets = 3; _reps = 12; })),
          _PresetChip('4×8', () => setState(() { _sets = 4; _reps = 8; })),
          _PresetChip('5×5', () => setState(() { _sets = 5; _reps = 5; })),
          _PresetChip('3×15', () => setState(() { _sets = 3; _reps = 15; })),
          _PresetChip('3×20', () => setState(() { _sets = 3; _reps = 20; })),
        ]),

        if (_selected.isNotEmpty || (_isCustom && _customController.text.isNotEmpty)) ...[
          const SizedBox(height: 16),
          Container(padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.exercise.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _SummaryItem('Total Reps', '$_totalReps'),
              _SummaryItem('Est. Time', '~$_estMinutes min'),
              _SummaryItem('Est. Cal', '~$_estCalories kcal'),
            ])),
        ],

        const SizedBox(height: 20),
        SizedBox(width: double.infinity, child: ElevatedButton(
          onPressed: (_selected.isEmpty && (!_isCustom || _customController.text.isEmpty)) ? null : () {
            final name = _isCustom ? _customController.text.trim() : _selected;
            widget.onLogged(name, _sets, _reps, _estMinutes, _estCalories);
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.exercise,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            disabledBackgroundColor: AppColors.surfaceElevated),
          child: Text('Log $_sets × $_reps', style: AppTypography.button(color: Colors.white)),
        )),
        const SizedBox(height: 8),
      ])),
    );
  }
}

// ─── Counter Input Widget ──────────────────────────────────

class _CounterInput extends StatelessWidget {
  final String label;
  final int value, min, max;
  final ValueChanged<int> onChanged;
  const _CounterInput({required this.label, required this.value, required this.min, required this.max, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.surfaceElevated, borderRadius: BorderRadius.circular(14)),
      child: Column(children: [
        Text(label, style: AppTypography.caption(color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _circleBtn(Icons.remove_rounded, value > min ? () => onChanged(value - 1) : null),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('$value', style: AppTypography.h2(color: AppColors.textPrimary))),
          _circleBtn(Icons.add_rounded, value < max ? () => onChanged(value + 1) : null),
        ]),
      ]),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback? onTap) => GestureDetector(
    onTap: onTap,
    child: Container(width: 36, height: 36,
      decoration: BoxDecoration(shape: BoxShape.circle,
        color: onTap != null ? AppColors.exercise.withValues(alpha: 0.15) : AppColors.surface),
      child: Icon(icon, color: onTap != null ? AppColors.exercise : AppColors.textTertiary, size: 20)),
  );
}

// ─── Small Widgets ──────────────────────────────────────────

class _Metric extends StatelessWidget {
  final IconData icon; final String label, value; final Color color;
  const _Metric(this.icon, this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppTheme.spacing16),
    decoration: BoxDecoration(color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      border: Border.all(color: AppColors.cardBorder)),
    child: Column(children: [
      Icon(icon, color: color, size: 24), const SizedBox(height: 8),
      Text(label, style: AppTypography.caption(color: AppColors.textSecondary)),
      const SizedBox(height: 4),
      Text(value, style: AppTypography.h4(color: color)),
    ]),
  );
}

class _PresetChip extends StatelessWidget {
  final String label; final VoidCallback onTap;
  const _PresetChip(this.label, this.onTap);
  @override
  Widget build(BuildContext context) => ActionChip(
    label: Text(label, style: AppTypography.caption(color: AppColors.exercise)),
    backgroundColor: AppColors.exercise.withValues(alpha: 0.12), side: BorderSide.none,
    onPressed: onTap);
}

class _SummaryItem extends StatelessWidget {
  final String label, value;
  const _SummaryItem(this.label, this.value);
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(label, style: AppTypography.label(color: AppColors.textSecondary)),
    const SizedBox(height: 2),
    Text(value, style: AppTypography.bodyMedium(color: AppColors.exercise)),
  ]);
}