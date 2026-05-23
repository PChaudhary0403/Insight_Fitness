import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/services/user_data_service.dart';

/// Activity & movement tracking page — connected to UserDataService.
class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  final data = UserDataService.instance;

  // Logged exercises for today (starts empty)
  final List<_LoggedExercise> _exercises = [];

  int get _totalExerciseMin => _exercises.fold(0, (s, e) => s + e.durationMin);
  int get _totalCaloriesBurned => _exercises.fold(0, (s, e) => s + e.caloriesBurned);

  void _logExercise() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LogExerciseSheet(
        onLogged: (exercise) {
          setState(() => _exercises.add(exercise));
          data.logExercise(exercise.durationMin);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('💪 ${exercise.name}: ${exercise.durationMin} min • ${exercise.caloriesBurned} kcal burned'),
            backgroundColor: AppColors.exercise,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ));
        },
      ),
    );
  }

  void _addSteps() {
    showDialog(
      context: context,
      builder: (ctx) {
        int steps = 1000;
        return StatefulBuilder(
          builder: (ctx, setDialogState) => AlertDialog(
            backgroundColor: AppColors.darkSurface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text('Add Steps', style: AppTypography.h3(color: AppColors.darkTextPrimary)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$steps steps', style: AppTypography.metric(color: AppColors.movement)),
                Slider(
                  value: steps.toDouble(), min: 100, max: 15000,
                  divisions: 149,
                  activeColor: AppColors.movement,
                  inactiveColor: AppColors.darkSurfaceElevated,
                  onChanged: (v) => setDialogState(() => steps = v.round()),
                ),
                Wrap(
                  spacing: 8,
                  children: [500, 1000, 2000, 5000].map((s) => ActionChip(
                    label: Text('+$s', style: AppTypography.caption(color: AppColors.movement)),
                    backgroundColor: AppColors.movement.withValues(alpha: 0.12),
                    side: BorderSide.none,
                    onPressed: () => setDialogState(() => steps = s),
                  )).toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Cancel', style: AppTypography.bodyMedium(color: AppColors.darkTextSecondary)),
              ),
              ElevatedButton(
                onPressed: () {
                  data.addSteps(steps);
                  Navigator.pop(ctx);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('🚶 Added $steps steps!'),
                    backgroundColor: AppColors.movement,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ));
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.movement, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: Text('Add', style: AppTypography.button(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final steps = data.dailySteps;
    final exerciseMin = data.dailyExerciseMin;
    final stepPercent = (steps / 10000).clamp(0.0, 1.0);
    final km = (steps * 0.0008).toStringAsFixed(1); // rough estimate

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        title: Text('Activity', style: AppTypography.h3(color: AppColors.darkTextPrimary)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.darkTextPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.primary),
            onPressed: _logExercise,
            tooltip: 'Log exercise',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacing24),
        child: Column(
          children: [
            // ─── Steps Card ─────────────────────────────
            GestureDetector(
              onTap: _addSteps,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppTheme.spacing24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.movement.withValues(alpha: 0.15),
                      AppColors.movement.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  border: Border.all(color: AppColors.movement.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.directions_walk_rounded, color: AppColors.movement, size: 40),
                    const SizedBox(height: AppTheme.spacing12),
                    Text(
                      _formatSteps(steps),
                      style: AppTypography.score(color: AppColors.darkTextPrimary),
                    ),
                    Text('/ 10,000 steps', style: AppTypography.body(color: AppColors.darkTextSecondary)),
                    const SizedBox(height: AppTheme.spacing16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: stepPercent,
                        minHeight: 10,
                        backgroundColor: AppColors.movement.withValues(alpha: 0.15),
                        valueColor: const AlwaysStoppedAnimation(AppColors.movement),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing8),
                    Text(
                      steps == 0 ? 'Tap to add steps' : '$km km walked',
                      style: AppTypography.bodySmall(color: AppColors.darkTextSecondary),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 500.ms),

            const SizedBox(height: AppTheme.spacing20),

            // ─── Activity Metrics Grid ──────────────────
            Row(
              children: [
                Expanded(child: _MetricCard(icon: Icons.timer_outlined, label: 'Exercise', value: '$exerciseMin min', color: AppColors.movement)),
                const SizedBox(width: AppTheme.spacing12),
                Expanded(child: _MetricCard(icon: Icons.local_fire_department_rounded, label: 'Burned', value: '$_totalCaloriesBurned kcal', color: AppColors.exercise)),
              ],
            ).animate(delay: 200.ms).fadeIn(duration: 400.ms),

            const SizedBox(height: AppTheme.spacing12),

            Row(
              children: [
                Expanded(child: _MetricCard(
                  icon: Icons.airline_seat_recline_normal_rounded,
                  label: 'Sitting',
                  value: data.profile != null ? '${data.profile!.dailySittingHours.toStringAsFixed(0)}h baseline' : '—',
                  color: AppColors.error,
                  isWarning: true,
                )),
                const SizedBox(width: AppTheme.spacing12),
                Expanded(child: _MetricCard(
                  icon: Icons.fitness_center_rounded,
                  label: 'Sessions',
                  value: '${_exercises.length}',
                  color: AppColors.exercise,
                )),
              ],
            ).animate(delay: 300.ms).fadeIn(duration: 400.ms),

            const SizedBox(height: AppTheme.spacing24),

            // ─── Logged Exercises ───────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spacing20),
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                border: Border.all(color: AppColors.darkCardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Today\'s Exercises', style: AppTypography.h4(color: AppColors.darkTextPrimary)),
                      const Spacer(),
                      GestureDetector(
                        onTap: _logExercise,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.exercise.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('+ Add', style: AppTypography.caption(color: AppColors.exercise)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  if (_exercises.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.fitness_center_rounded, color: AppColors.darkTextTertiary, size: 32),
                            const SizedBox(height: 8),
                            Text('No exercises logged yet', style: AppTypography.body(color: AppColors.darkTextTertiary)),
                            const SizedBox(height: 4),
                            Text('Tap + to log your workout', style: AppTypography.caption(color: AppColors.darkTextTertiary)),
                          ],
                        ),
                      ),
                    )
                  else
                    ..._exercises.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.exercise.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(e.icon, color: AppColors.exercise, size: 20),
                          ),
                          const SizedBox(width: AppTheme.spacing12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(e.name, style: AppTypography.bodyMedium(color: AppColors.darkTextPrimary)),
                                Text('${e.durationMin} min', style: AppTypography.caption(color: AppColors.darkTextSecondary)),
                              ],
                            ),
                          ),
                          Text('${e.caloriesBurned} kcal', style: AppTypography.bodySmall(color: AppColors.darkTextSecondary)),
                        ],
                      ),
                    )),
                ],
              ),
            ).animate(delay: 400.ms).fadeIn(duration: 400.ms),

            const SizedBox(height: AppTheme.spacing20),

            // ─── Streak ─────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spacing20),
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                border: Border.all(color: AppColors.darkCardBorder),
              ),
              child: Row(
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: AppTheme.spacing12),
                  Text('Movement Streak: ', style: AppTypography.body(color: AppColors.darkTextSecondary)),
                  Text(
                    data.currentStreak == 0 ? 'Start today!' : '${data.currentStreak} days',
                    style: AppTypography.h4(color: AppColors.darkTextPrimary),
                  ),
                ],
              ),
            ).animate(delay: 500.ms).fadeIn(duration: 400.ms),
          ],
        ),
      ),
    );
  }

  String _formatSteps(int steps) {
    if (steps >= 1000) {
      return '${(steps / 1000).toStringAsFixed(0)},${(steps % 1000).toString().padLeft(3, '0')}';
    }
    return '$steps';
  }
}

// ─── Log Exercise Sheet ─────────────────────────────────────

class _LogExerciseSheet extends StatefulWidget {
  final Function(_LoggedExercise) onLogged;
  const _LogExerciseSheet({required this.onLogged});

  @override
  State<_LogExerciseSheet> createState() => _LogExerciseSheetState();
}

class _LogExerciseSheetState extends State<_LogExerciseSheet> {
  String _selected = '';
  int _duration = 30;

  static const _exercises = [
    ('Running', Icons.directions_run_rounded, 10),     // kcal per min
    ('Walking', Icons.directions_walk_rounded, 5),
    ('Cycling', Icons.pedal_bike_rounded, 8),
    ('Yoga', Icons.self_improvement_rounded, 4),
    ('Weight Training', Icons.fitness_center_rounded, 7),
    ('Swimming', Icons.pool_rounded, 9),
    ('HIIT', Icons.flash_on_rounded, 12),
    ('Stretching', Icons.accessibility_new_rounded, 3),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.darkDivider, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text('Log Exercise', style: AppTypography.h3(color: AppColors.darkTextPrimary)),
            const SizedBox(height: 20),

            // Exercise type selection
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _exercises.map((e) {
                final isSelected = _selected == e.$1;
                return GestureDetector(
                  onTap: () => setState(() => _selected = e.$1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.exercise.withValues(alpha: 0.2) : AppColors.darkSurfaceElevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSelected ? AppColors.exercise.withValues(alpha: 0.5) : Colors.transparent),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(e.$2, color: isSelected ? AppColors.exercise : AppColors.darkTextSecondary, size: 18),
                        const SizedBox(width: 6),
                        Text(e.$1, style: AppTypography.bodySmall(color: isSelected ? AppColors.exercise : AppColors.darkTextPrimary)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),
            // Duration slider
            Text('Duration: $_duration min', style: AppTypography.h4(color: AppColors.darkTextPrimary)),
            Slider(
              value: _duration.toDouble(), min: 5, max: 120, divisions: 23,
              activeColor: AppColors.exercise,
              inactiveColor: AppColors.darkSurfaceElevated,
              onChanged: (v) => setState(() => _duration = v.round()),
            ),
            Wrap(
              spacing: 8,
              children: [10, 20, 30, 45, 60].map((d) => ActionChip(
                label: Text('$d min', style: AppTypography.caption(color: AppColors.exercise)),
                backgroundColor: AppColors.exercise.withValues(alpha: 0.12),
                side: BorderSide.none,
                onPressed: () => setState(() => _duration = d),
              )).toList(),
            ),

            if (_selected.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Est. ${_getCalories()} kcal burned',
                style: AppTypography.bodyMedium(color: AppColors.darkTextSecondary),
              ),
            ],

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selected.isEmpty ? null : () {
                  final ex = _exercises.firstWhere((e) => e.$1 == _selected);
                  widget.onLogged(_LoggedExercise(
                    name: _selected,
                    icon: ex.$2,
                    durationMin: _duration,
                    caloriesBurned: _getCalories(),
                  ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.exercise,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  disabledBackgroundColor: AppColors.darkSurfaceElevated,
                ),
                child: Text('Log Exercise', style: AppTypography.button(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  int _getCalories() {
    final ex = _exercises.where((e) => e.$1 == _selected);
    if (ex.isEmpty) return 0;
    return ex.first.$3 * _duration;
  }
}

// ─── Models ──────────────────────────────────────────────────

class _LoggedExercise {
  final String name;
  final IconData icon;
  final int durationMin;
  final int caloriesBurned;
  const _LoggedExercise({required this.name, required this.icon, required this.durationMin, required this.caloriesBurned});
}

// ─── Reusable Widgets ───────────────────────────────────────

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isWarning;

  const _MetricCard({
    required this.icon, required this.label, required this.value,
    required this.color, this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: isWarning ? color.withValues(alpha: 0.08) : AppColors.darkSurface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: isWarning ? color.withValues(alpha: 0.3) : AppColors.darkCardBorder),
      ),
      child: Column(children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(label, style: AppTypography.caption(color: AppColors.darkTextSecondary)),
        const SizedBox(height: 4),
        Text(value, style: AppTypography.h4(color: color)),
      ]),
    );
  }
}
