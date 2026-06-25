import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/services/user_data_service.dart';
import '../../data/exercise_library.dart';
import '../../data/workout_generator.dart';

/// Full-screen workout session with timer, exercise display, and tracking.
class WorkoutSessionPage extends StatefulWidget {
  final GeneratedWorkout workout;
  const WorkoutSessionPage({super.key, required this.workout});

  @override
  State<WorkoutSessionPage> createState() => _WorkoutSessionPageState();
}

class _WorkoutSessionPageState extends State<WorkoutSessionPage> {
  int _currentStepIdx = 0;
  bool _isPaused = false;
  bool _isResting = false;
  bool _isFinished = false;
  int _countdown = 0;
  int _repsCompleted = 0;
  int _totalCalories = 0;
  Timer? _timer;
  final _startTime = DateTime.now();

  WorkoutStep get _currentStep => widget.workout.steps[_currentStepIdx];
  Exercise get _currentExercise => _currentStep.exercise;
  double get _overallProgress => (_currentStepIdx + 1) / widget.workout.steps.length;

  @override
  void initState() {
    super.initState();
    _startCurrentExercise();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCurrentExercise() {
    _isResting = false;
    _repsCompleted = 0;
    if (_currentExercise.type == ExerciseType.timed) {
      _countdown = _currentStep.durationSec;
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_isPaused) return;
      setState(() {
        _countdown--;
        if (_countdown <= 0) {
          t.cancel();
          if (_isResting) {
            _moveToNextExercise();
          } else {
            _totalCalories += _currentStep.estimatedCalories.round();
            _startRest();
          }
        }
      });
    });
  }

  void _startRest() {
    _isResting = true;
    _countdown = _currentStep.restSec;
    _startTimer();
  }

  void _completeReps() {
    _totalCalories += _currentStep.estimatedCalories.round();
    _startRest();
  }

  void _moveToNextExercise() {
    if (_currentStepIdx >= widget.workout.steps.length - 1) {
      _finishWorkout();
    } else {
      setState(() {
        _currentStepIdx++;
        _startCurrentExercise();
      });
    }
  }

  void _skipExercise() {
    _timer?.cancel();
    _moveToNextExercise();
  }

  void _togglePause() {
    setState(() => _isPaused = !_isPaused);
  }

  void _finishWorkout() {
    _timer?.cancel();
    final elapsed = DateTime.now().difference(_startTime).inMinutes;
    final data = UserDataService.instance;
    data.logExercise(elapsed > 0 ? elapsed : 1);
    data.logQuickWorkout(_totalCalories);
    setState(() => _isFinished = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_isFinished) return _buildFinishScreen();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Top bar ──────────────────────────────────
            _buildTopBar(),

            // ─── Progress ─────────────────────────────────
            _buildProgressBar(),

            const Spacer(flex: 1),

            // ─── Exercise Display ─────────────────────────
            _buildExerciseDisplay(),

            const Spacer(flex: 1),

            // ─── Timer / Reps ─────────────────────────────
            _isResting ? _buildRestDisplay() : _buildInputDisplay(),

            const Spacer(flex: 1),

            // ─── Controls ─────────────────────────────────
            _buildControls(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.close_rounded, color: AppColors.textSecondary),
            onPressed: () => _showQuitDialog(),
          ),
          Expanded(
            child: Column(
              children: [
                Text(widget.workout.title, style: AppTypography.bodyMedium(color: AppColors.textPrimary)),
                Text(
                  'Exercise ${_currentStepIdx + 1} of ${widget.workout.steps.length}',
                  style: AppTypography.caption(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(_isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded, color: AppColors.primary),
            onPressed: _togglePause,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: widget.workout.steps.asMap().entries.map((e) {
          final isDone = e.key < _currentStepIdx;
          final isCurrent = e.key == _currentStepIdx;
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: e.key < widget.workout.steps.length - 1 ? 3 : 0),
              decoration: BoxDecoration(
                color: isDone
                    ? AppColors.success
                    : isCurrent
                        ? AppColors.primary
                        : AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildExerciseDisplay() {
    return Column(
      children: [
        Container(
          width: 100, height: 100,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(_currentExercise.icon, color: AppColors.primary, size: 48),
        ).animate().fadeIn().scale(begin: const Offset(0.8, 0.8)),
        const SizedBox(height: 20),
        Text(
          _currentExercise.name,
          style: AppTypography.h2(color: AppColors.textPrimary),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 100.ms),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            _currentExercise.instructions,
            style: AppTypography.body(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 12),
        // Muscle groups
        Wrap(
          spacing: 6,
          children: _currentExercise.muscleGroups.map((m) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.exercise.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(m.name, style: AppTypography.label(color: AppColors.exercise)),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildInputDisplay() {
    if (_currentExercise.type == ExerciseType.timed) {
      return _buildTimerDisplay();
    } else {
      return _buildRepCounter();
    }
  }

  Widget _buildTimerDisplay() {
    final mins = _countdown ~/ 60;
    final secs = _countdown % 60;
    return Column(
      children: [
        Text(
          '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}',
          style: TextStyle(color: AppColors.textPrimary,
            fontSize: 64,
            fontWeight: FontWeight.w700,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isPaused ? 'PAUSED' : 'HOLD',
          style: AppTypography.bodyMedium(color: _isPaused ? AppColors.warning : AppColors.primary),
        ),
      ],
    );
  }

  Widget _buildRepCounter() {
    return Column(
      children: [
        Text(
          '${_currentStep.reps}',
          style: TextStyle(color: AppColors.textPrimary,
            fontSize: 64,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text('REPS', style: AppTypography.bodyMedium(color: AppColors.textSecondary)),
        const SizedBox(height: 20),
        SizedBox(
          width: 180, height: 56,
          child: ElevatedButton(
            onPressed: _completeReps,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Text('Done', style: AppTypography.button(color: Colors.white)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRestDisplay() {
    return Column(
      children: [
        Text('REST', style: AppTypography.h4(color: AppColors.info)),
        const SizedBox(height: 8),
        Text(
          '$_countdown',
          style: const TextStyle(
            color: AppColors.info,
            fontSize: 56,
            fontWeight: FontWeight.w700,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 8),
        if (_currentStepIdx < widget.workout.steps.length - 1)
          Text(
            'Next: ${widget.workout.steps[_currentStepIdx + 1].exercise.name}',
            style: AppTypography.body(color: AppColors.textSecondary),
          ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () {
            _timer?.cancel();
            _moveToNextExercise();
          },
          child: Text('Skip Rest →', style: AppTypography.bodyMedium(color: AppColors.primary)),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Skip
          _ControlBtn(
            icon: Icons.skip_next_rounded,
            label: 'Skip',
            color: AppColors.textSecondary,
            onTap: _skipExercise,
          ),
          // Pause/Resume
          _ControlBtn(
            icon: _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
            label: _isPaused ? 'Resume' : 'Pause',
            color: AppColors.primary,
            onTap: _togglePause,
            isLarge: true,
          ),
          // Finish early
          _ControlBtn(
            icon: Icons.stop_rounded,
            label: 'Finish',
            color: AppColors.warning,
            onTap: _finishWorkout,
          ),
        ],
      ),
    );
  }

  // ─── Finish Screen ──────────────────────────────────────

  Widget _buildFinishScreen() {
    final elapsed = DateTime.now().difference(_startTime);
    final mins = elapsed.inMinutes;
    final secs = elapsed.inSeconds % 60;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_rounded, color: AppColors.success, size: 48).animate().scale(begin: const Offset(0.5, 0.5)).fadeIn(),
                const SizedBox(height: 20),
                Text('Session Complete', style: AppTypography.h2(color: AppColors.textPrimary)).animate(delay: 200.ms).fadeIn(),
                const SizedBox(height: 8),
                Text(widget.workout.title, style: AppTypography.body(color: AppColors.textSecondary)).animate(delay: 300.ms).fadeIn(),
                const SizedBox(height: 32),

                // Stats
                Row(
                  children: [
                    _FinishStat(Icons.timer_rounded, '$mins:${secs.toString().padLeft(2, '0')}', 'Duration'),
                    _FinishStat(Icons.local_fire_department_rounded, '$_totalCalories', 'Calories'),
                    _FinishStat(Icons.fitness_center_rounded, '${_currentStepIdx + 1}', 'Exercises'),
                  ],
                ).animate(delay: 400.ms).fadeIn(),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text('Done', style: AppTypography.button(color: Colors.white)),
                  ),
                ).animate(delay: 500.ms).fadeIn(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showQuitDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Quit Workout?', style: AppTypography.h3(color: AppColors.textPrimary)),
        content: Text('Your progress will be lost.', style: AppTypography.body(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Continue', style: AppTypography.bodyMedium(color: AppColors.primary))),
          TextButton(onPressed: () { Navigator.pop(ctx); Navigator.pop(context); }, child: Text('Quit', style: AppTypography.bodyMedium(color: AppColors.error))),
        ],
      ),
    );
  }
}

class _ControlBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isLarge;
  const _ControlBtn({required this.icon, required this.label, required this.color, required this.onTap, this.isLarge = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isLarge ? 64 : 48, height: isLarge ? 64 : 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: isLarge ? 0.2 : 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: isLarge ? 32 : 24),
          ),
          const SizedBox(height: 4),
          Text(label, style: AppTypography.caption(color: color)),
        ],
      ),
    );
  }
}

class _FinishStat extends StatelessWidget {
  final IconData icon;
  final String value, label;
  const _FinishStat(this.icon, this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: AppColors.primary),
            const SizedBox(height: 6),
            Text(value, style: AppTypography.h3(color: AppColors.textPrimary)),
            Text(label, style: AppTypography.caption(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}