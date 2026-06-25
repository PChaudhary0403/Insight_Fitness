import 'dart:math';
import 'exercise_library.dart';
import '../../health_assessment/data/models/health_profile.dart';

/// A single exercise step in a generated workout.
class WorkoutStep {
  final Exercise exercise;
  final int reps;         // only for rep-based
  final int durationSec;  // only for timed
  final int restSec;

  const WorkoutStep({required this.exercise, this.reps = 0, this.durationSec = 0, this.restSec = 10});

  double get estimatedCalories {
    final secs = exercise.type == ExerciseType.timed ? durationSec : (reps * 2.5).round();
    return exercise.caloriesPerMin * (secs / 60);
  }

  int get totalTimeSec {
    return (exercise.type == ExerciseType.timed ? durationSec : (reps * 2.5).round()) + restSec;
  }
}

/// A generated workout with metadata.
class GeneratedWorkout {
  final String title;
  final WorkoutMode mode;
  final int targetDurationMin;
  final List<WorkoutStep> steps;
  final DateTime createdAt;

  const GeneratedWorkout({
    required this.title,
    required this.mode,
    required this.targetDurationMin,
    required this.steps,
    required this.createdAt,
  });

  int get totalCalories => steps.fold(0, (s, e) => s + e.estimatedCalories.round());
  int get totalTimeSec => steps.fold(0, (s, e) => s + e.totalTimeSec);
  int get exerciseCount => steps.length;
}

/// Generates personalized quick workouts based on user profile and preferences.
class WorkoutGenerator {
  WorkoutGenerator._();

  static final _rng = Random();

  /// Get the appropriate difficulty for a user's profile.
  static Difficulty _userDifficulty(HealthProfile? profile) {
    if (profile == null) return Difficulty.beginner;
    final bmi = profile.bmi ?? 22;
    final age = profile.age;
    final activity = profile.activityLevel;

    if (age > 55 || bmi > 35 || activity == 'sedentary') return Difficulty.beginner;
    if (activity == 'active' || activity == 'very_active') return Difficulty.advanced;
    return Difficulty.intermediate;
  }

  /// Generate a workout for the given mode and duration.
  static GeneratedWorkout generate({
    required WorkoutMode mode,
    required int durationMin,
    HealthProfile? profile,
  }) {
    final difficulty = _userDifficulty(profile);

    // Get eligible exercises for the mode + difficulty
    var pool = ExerciseLibrary.byMode(mode)
        .where((e) => e.difficulty.index <= difficulty.index)
        .toList();

    // Fallback: if pool too small, add beginner exercises
    if (pool.length < 3) {
      pool = ExerciseLibrary.forDifficulty(difficulty);
    }

    // Shuffle for variety
    pool.shuffle(_rng);

    // Fill the workout time
    final steps = <WorkoutStep>[];
    int totalSec = 0;
    final targetSec = durationMin * 60;
    int idx = 0;

    while (totalSec < targetSec && idx < pool.length * 2) {
      final ex = pool[idx % pool.length];
      idx++;

      // Scale based on difficulty and user
      final scaleFactor = switch (difficulty) {
        Difficulty.beginner => 0.7,
        Difficulty.intermediate => 1.0,
        Difficulty.advanced => 1.3,
      };

      WorkoutStep step;
      if (ex.type == ExerciseType.reps) {
        final reps = (ex.defaultReps * scaleFactor).round();
        step = WorkoutStep(exercise: ex, reps: reps, restSec: durationMin <= 3 ? 5 : 10);
      } else {
        final secs = (ex.defaultSeconds * scaleFactor).round();
        step = WorkoutStep(exercise: ex, durationSec: secs, restSec: durationMin <= 3 ? 5 : 10);
      }

      totalSec += step.totalTimeSec;
      steps.add(step);
    }

    final title = _modeTitle(mode, durationMin);

    return GeneratedWorkout(
      title: title,
      mode: mode,
      targetDurationMin: durationMin,
      steps: steps,
      createdAt: DateTime.now(),
    );
  }

  /// Generate a smart suggestion based on user context.
  static String getSmartSuggestion(HealthProfile? profile) {
    if (profile == null) return 'Complete your assessment for personalized suggestions.';

    final flags = profile.flags;
    final sedentaryRisk = profile.sedentaryRiskScore ?? 0;
    final bmi = profile.bmi ?? 22;
    final activity = profile.activityLevel;

    if (sedentaryRisk > 7) return '🪑 High sedentary risk! Time for a 3-min desk refresh.';
    if (flags.contains('sedentary')) return '💡 Sedentary lifestyle detected. Try a 5-min mobility session.';
    if (bmi > 30) return '🏃 Quick 5-min fat burn can boost your day.';
    if (bmi < 18.5) return '💪 Light strength session to build lean muscle.';
    if (activity == 'active' || activity == 'very_active') return '🔥 Great activity level! Push with a 10-min HIIT.';
    if (flags.contains('irregular_lifestyle')) return '⏰ Irregular schedule? 3-min posture reset can help.';
    return '🎯 Quick 5-min workout keeps you consistent!';
  }

  static String _modeTitle(WorkoutMode mode, int min) {
    final modeStr = switch (mode) {
      WorkoutMode.strength => 'Strength',
      WorkoutMode.cardio => 'Cardio',
      WorkoutMode.stretching => 'Stretch',
      WorkoutMode.posture => 'Posture Fix',
      WorkoutMode.mobility => 'Mobility',
      WorkoutMode.deskRefresh => 'Desk Refresh',
      WorkoutMode.fatBurn => 'Fat Burn',
      WorkoutMode.beginner => 'Easy Start',
    };
    return '$min-Min $modeStr';
  }

  /// Mode metadata for UI display.
  static const modeInfo = {
    WorkoutMode.strength: ('💪', 'Strength', 'Build muscle with bodyweight exercises'),
    WorkoutMode.cardio: ('🏃', 'Cardio', 'Elevate heart rate and burn calories'),
    WorkoutMode.stretching: ('🧘', 'Stretch', 'Flexibility and muscle recovery'),
    WorkoutMode.posture: ('🏛️', 'Posture', 'Correct alignment and reduce pain'),
    WorkoutMode.mobility: ('🔄', 'Mobility', 'Joint health and range of motion'),
    WorkoutMode.deskRefresh: ('💻', 'Desk Refresh', 'Quick break from sitting'),
    WorkoutMode.fatBurn: ('🔥', 'Fat Burn', 'High-intensity calorie burner'),
    WorkoutMode.beginner: ('🌱', 'Beginner', 'Easy exercises for any fitness level'),
  };
}
