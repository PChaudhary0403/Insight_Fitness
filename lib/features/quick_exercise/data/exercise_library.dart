import 'package:flutter/material.dart';

/// Categories for exercises.
enum ExerciseCategory { bodyweight, mobility, desk }

/// Whether the exercise is rep-based or time-based.
enum ExerciseType { reps, timed }

/// Muscle groups targeted.
enum MuscleGroup { chest, back, shoulders, arms, core, legs, glutes, fullBody, neck, wrists, hips, spine, eyes }

/// Difficulty level.
enum Difficulty { beginner, intermediate, advanced }

/// Workout mode for generating quick workouts.
enum WorkoutMode { strength, cardio, stretching, posture, mobility, deskRefresh, fatBurn, beginner }

/// A single exercise definition.
class Exercise {
  final String id;
  final String name;
  final ExerciseCategory category;
  final ExerciseType type;
  final List<MuscleGroup> muscleGroups;
  final Difficulty difficulty;
  final double caloriesPerMin;
  final int defaultReps;
  final int defaultSeconds;
  final String instructions;
  final IconData icon;

  const Exercise({
    required this.id,
    required this.name,
    required this.category,
    required this.type,
    required this.muscleGroups,
    required this.difficulty,
    required this.caloriesPerMin,
    this.defaultReps = 15,
    this.defaultSeconds = 30,
    required this.instructions,
    required this.icon,
  });

  /// Whether this exercise matches a given workout mode.
  bool matchesMode(WorkoutMode mode) {
    return switch (mode) {
      WorkoutMode.strength => category == ExerciseCategory.bodyweight && type == ExerciseType.reps,
      WorkoutMode.cardio => caloriesPerMin >= 8 || [ExerciseType.reps].contains(type) && caloriesPerMin >= 6,
      WorkoutMode.stretching => category == ExerciseCategory.mobility,
      WorkoutMode.posture => muscleGroups.any((m) => [MuscleGroup.back, MuscleGroup.spine, MuscleGroup.core, MuscleGroup.shoulders].contains(m)),
      WorkoutMode.mobility => category == ExerciseCategory.mobility,
      WorkoutMode.deskRefresh => category == ExerciseCategory.desk,
      WorkoutMode.fatBurn => caloriesPerMin >= 7,
      WorkoutMode.beginner => difficulty == Difficulty.beginner,
    };
  }
}

/// The full exercise library.
class ExerciseLibrary {
  ExerciseLibrary._();

  static const List<Exercise> all = [
    // ─── Bodyweight Exercises ──────────────────────────────
    Exercise(id: 'pushups', name: 'Push-ups', category: ExerciseCategory.bodyweight, type: ExerciseType.reps,
      muscleGroups: [MuscleGroup.chest, MuscleGroup.arms, MuscleGroup.shoulders], difficulty: Difficulty.intermediate,
      caloriesPerMin: 7, defaultReps: 20, instructions: 'Keep body straight. Lower chest to floor, push back up.', icon: Icons.fitness_center_rounded),
    Exercise(id: 'pullups', name: 'Pull-ups', category: ExerciseCategory.bodyweight, type: ExerciseType.reps,
      muscleGroups: [MuscleGroup.back, MuscleGroup.arms], difficulty: Difficulty.advanced,
      caloriesPerMin: 8, defaultReps: 8, instructions: 'Grip bar overhead, pull chin above bar.', icon: Icons.fitness_center_rounded),
    Exercise(id: 'squats', name: 'Squats', category: ExerciseCategory.bodyweight, type: ExerciseType.reps,
      muscleGroups: [MuscleGroup.legs, MuscleGroup.glutes], difficulty: Difficulty.beginner,
      caloriesPerMin: 6, defaultReps: 20, instructions: 'Feet shoulder-width. Sit back, thighs parallel to floor.', icon: Icons.directions_walk_rounded),
    Exercise(id: 'lunges', name: 'Lunges', category: ExerciseCategory.bodyweight, type: ExerciseType.reps,
      muscleGroups: [MuscleGroup.legs, MuscleGroup.glutes], difficulty: Difficulty.beginner,
      caloriesPerMin: 6, defaultReps: 16, instructions: 'Step forward, lower back knee toward floor. Alternate legs.', icon: Icons.directions_walk_rounded),
    Exercise(id: 'jumping_jacks', name: 'Jumping Jacks', category: ExerciseCategory.bodyweight, type: ExerciseType.reps,
      muscleGroups: [MuscleGroup.fullBody], difficulty: Difficulty.beginner,
      caloriesPerMin: 10, defaultReps: 30, instructions: 'Jump feet wide, raise arms. Jump back, lower arms.', icon: Icons.sports_gymnastics_rounded),
    Exercise(id: 'burpees', name: 'Burpees', category: ExerciseCategory.bodyweight, type: ExerciseType.reps,
      muscleGroups: [MuscleGroup.fullBody], difficulty: Difficulty.advanced,
      caloriesPerMin: 12, defaultReps: 10, instructions: 'Squat, jump feet back, push-up, jump feet forward, jump up.', icon: Icons.sports_gymnastics_rounded),
    Exercise(id: 'mountain_climbers', name: 'Mountain Climbers', category: ExerciseCategory.bodyweight, type: ExerciseType.timed,
      muscleGroups: [MuscleGroup.core, MuscleGroup.legs], difficulty: Difficulty.intermediate,
      caloriesPerMin: 11, defaultSeconds: 30, instructions: 'Plank position, drive knees to chest alternately, fast.', icon: Icons.terrain_rounded),
    Exercise(id: 'plank', name: 'Plank', category: ExerciseCategory.bodyweight, type: ExerciseType.timed,
      muscleGroups: [MuscleGroup.core, MuscleGroup.shoulders], difficulty: Difficulty.beginner,
      caloriesPerMin: 4, defaultSeconds: 45, instructions: 'Forearms on floor, body straight. Hold steady.', icon: Icons.rectangle_rounded),
    Exercise(id: 'side_plank', name: 'Side Plank', category: ExerciseCategory.bodyweight, type: ExerciseType.timed,
      muscleGroups: [MuscleGroup.core], difficulty: Difficulty.intermediate,
      caloriesPerMin: 4, defaultSeconds: 30, instructions: 'Lie on side, prop on forearm, lift hips. Hold.', icon: Icons.rectangle_rounded),
    Exercise(id: 'crunches', name: 'Crunches', category: ExerciseCategory.bodyweight, type: ExerciseType.reps,
      muscleGroups: [MuscleGroup.core], difficulty: Difficulty.beginner,
      caloriesPerMin: 5, defaultReps: 25, instructions: 'Lie on back, hands behind head, curl upper body toward knees.', icon: Icons.accessibility_new_rounded),
    Exercise(id: 'situps', name: 'Sit-ups', category: ExerciseCategory.bodyweight, type: ExerciseType.reps,
      muscleGroups: [MuscleGroup.core], difficulty: Difficulty.beginner,
      caloriesPerMin: 5, defaultReps: 20, instructions: 'Lie on back, hands behind head, sit all the way up.', icon: Icons.accessibility_new_rounded),
    Exercise(id: 'high_knees', name: 'High Knees', category: ExerciseCategory.bodyweight, type: ExerciseType.timed,
      muscleGroups: [MuscleGroup.legs, MuscleGroup.core], difficulty: Difficulty.beginner,
      caloriesPerMin: 10, defaultSeconds: 30, instructions: 'Run in place, driving knees as high as possible.', icon: Icons.directions_run_rounded),
    Exercise(id: 'wall_sit', name: 'Wall Sit', category: ExerciseCategory.bodyweight, type: ExerciseType.timed,
      muscleGroups: [MuscleGroup.legs, MuscleGroup.glutes], difficulty: Difficulty.beginner,
      caloriesPerMin: 4, defaultSeconds: 45, instructions: 'Back against wall, slide down until thighs are parallel.', icon: Icons.chair_rounded),
    Exercise(id: 'tricep_dips', name: 'Tricep Dips', category: ExerciseCategory.bodyweight, type: ExerciseType.reps,
      muscleGroups: [MuscleGroup.arms], difficulty: Difficulty.intermediate,
      caloriesPerMin: 6, defaultReps: 15, instructions: 'Hands on edge of chair, lower body by bending elbows.', icon: Icons.fitness_center_rounded),
    Exercise(id: 'calf_raises', name: 'Calf Raises', category: ExerciseCategory.bodyweight, type: ExerciseType.reps,
      muscleGroups: [MuscleGroup.legs], difficulty: Difficulty.beginner,
      caloriesPerMin: 3, defaultReps: 25, instructions: 'Stand on toes, lift heels high, lower slowly.', icon: Icons.directions_walk_rounded),
    Exercise(id: 'glute_bridges', name: 'Glute Bridges', category: ExerciseCategory.bodyweight, type: ExerciseType.reps,
      muscleGroups: [MuscleGroup.glutes, MuscleGroup.core], difficulty: Difficulty.beginner,
      caloriesPerMin: 4, defaultReps: 20, instructions: 'Lie on back, feet flat, lift hips to ceiling. Squeeze glutes.', icon: Icons.accessibility_new_rounded),
    Exercise(id: 'superman', name: 'Superman Hold', category: ExerciseCategory.bodyweight, type: ExerciseType.timed,
      muscleGroups: [MuscleGroup.back, MuscleGroup.glutes], difficulty: Difficulty.beginner,
      caloriesPerMin: 4, defaultSeconds: 30, instructions: 'Lie face down, lift arms and legs off floor. Hold.', icon: Icons.flight_rounded),

    // ─── Mobility / Stretch Exercises ──────────────────────
    Exercise(id: 'neck_stretch', name: 'Neck Stretch', category: ExerciseCategory.mobility, type: ExerciseType.timed,
      muscleGroups: [MuscleGroup.neck], difficulty: Difficulty.beginner,
      caloriesPerMin: 2, defaultSeconds: 30, instructions: 'Tilt head to each side, hold 10s each. Roll gently.', icon: Icons.self_improvement_rounded),
    Exercise(id: 'shoulder_rolls', name: 'Shoulder Rolls', category: ExerciseCategory.mobility, type: ExerciseType.timed,
      muscleGroups: [MuscleGroup.shoulders], difficulty: Difficulty.beginner,
      caloriesPerMin: 2, defaultSeconds: 30, instructions: 'Roll shoulders forward 10x, backward 10x.', icon: Icons.self_improvement_rounded),
    Exercise(id: 'wrist_stretch', name: 'Wrist Stretch', category: ExerciseCategory.mobility, type: ExerciseType.timed,
      muscleGroups: [MuscleGroup.wrists], difficulty: Difficulty.beginner,
      caloriesPerMin: 1, defaultSeconds: 30, instructions: 'Extend arm, pull fingers back gently. Hold 15s each hand.', icon: Icons.pan_tool_rounded),
    Exercise(id: 'back_stretch', name: 'Back Stretch', category: ExerciseCategory.mobility, type: ExerciseType.timed,
      muscleGroups: [MuscleGroup.back, MuscleGroup.spine], difficulty: Difficulty.beginner,
      caloriesPerMin: 2, defaultSeconds: 40, instructions: 'Cat-cow stretch. On all fours, arch and round back.', icon: Icons.self_improvement_rounded),
    Exercise(id: 'spinal_twist', name: 'Spinal Twist', category: ExerciseCategory.mobility, type: ExerciseType.timed,
      muscleGroups: [MuscleGroup.spine, MuscleGroup.core], difficulty: Difficulty.beginner,
      caloriesPerMin: 2, defaultSeconds: 40, instructions: 'Seated, cross one leg over, twist torso. Hold 20s each side.', icon: Icons.rotate_right_rounded),
    Exercise(id: 'hamstring_stretch', name: 'Hamstring Stretch', category: ExerciseCategory.mobility, type: ExerciseType.timed,
      muscleGroups: [MuscleGroup.legs], difficulty: Difficulty.beginner,
      caloriesPerMin: 2, defaultSeconds: 30, instructions: 'Sit, extend one leg. Reach for toes. Hold 15s each.', icon: Icons.self_improvement_rounded),
    Exercise(id: 'hip_opener', name: 'Hip Opener', category: ExerciseCategory.mobility, type: ExerciseType.timed,
      muscleGroups: [MuscleGroup.hips, MuscleGroup.legs], difficulty: Difficulty.beginner,
      caloriesPerMin: 2, defaultSeconds: 40, instructions: 'Pigeon pose or butterfly stretch. Open hips gently.', icon: Icons.self_improvement_rounded),
    Exercise(id: 'ankle_rotation', name: 'Ankle Rotation', category: ExerciseCategory.mobility, type: ExerciseType.timed,
      muscleGroups: [MuscleGroup.legs], difficulty: Difficulty.beginner,
      caloriesPerMin: 1, defaultSeconds: 30, instructions: 'Rotate each ankle 10x clockwise, 10x counter-clockwise.', icon: Icons.rotate_left_rounded),
    Exercise(id: 'seated_stretch', name: 'Seated Stretch Routine', category: ExerciseCategory.mobility, type: ExerciseType.timed,
      muscleGroups: [MuscleGroup.fullBody], difficulty: Difficulty.beginner,
      caloriesPerMin: 2, defaultSeconds: 60, instructions: 'Full seated stretch: neck, shoulders, torso, hamstrings.', icon: Icons.chair_rounded),

    // ─── Desk / Office Exercises ──────────────────────────
    Exercise(id: 'chair_squats', name: 'Chair Squats', category: ExerciseCategory.desk, type: ExerciseType.reps,
      muscleGroups: [MuscleGroup.legs, MuscleGroup.glutes], difficulty: Difficulty.beginner,
      caloriesPerMin: 5, defaultReps: 15, instructions: 'Stand in front of chair. Sit and stand without using hands.', icon: Icons.chair_rounded),
    Exercise(id: 'seated_leg_raises', name: 'Seated Leg Raises', category: ExerciseCategory.desk, type: ExerciseType.reps,
      muscleGroups: [MuscleGroup.legs, MuscleGroup.core], difficulty: Difficulty.beginner,
      caloriesPerMin: 3, defaultReps: 20, instructions: 'Sit upright, extend one leg straight, hold 3s. Alternate.', icon: Icons.chair_rounded),
    Exercise(id: 'desk_shoulder_stretch', name: 'Desk Shoulder Stretch', category: ExerciseCategory.desk, type: ExerciseType.timed,
      muscleGroups: [MuscleGroup.shoulders], difficulty: Difficulty.beginner,
      caloriesPerMin: 1, defaultSeconds: 30, instructions: 'Reach one arm across chest, hold with other hand. 15s each.', icon: Icons.self_improvement_rounded),
    Exercise(id: 'seated_torso_twist', name: 'Seated Torso Twist', category: ExerciseCategory.desk, type: ExerciseType.reps,
      muscleGroups: [MuscleGroup.core, MuscleGroup.spine], difficulty: Difficulty.beginner,
      caloriesPerMin: 2, defaultReps: 20, instructions: 'Sit upright, twist torso left then right. 10 each side.', icon: Icons.rotate_right_rounded),
    Exercise(id: 'standing_calf_raises', name: 'Standing Calf Raises', category: ExerciseCategory.desk, type: ExerciseType.reps,
      muscleGroups: [MuscleGroup.legs], difficulty: Difficulty.beginner,
      caloriesPerMin: 3, defaultReps: 25, instructions: 'Stand near desk for balance, rise on toes, hold 2s, lower.', icon: Icons.directions_walk_rounded),
    Exercise(id: 'posture_drill', name: 'Posture Correction Drill', category: ExerciseCategory.desk, type: ExerciseType.timed,
      muscleGroups: [MuscleGroup.back, MuscleGroup.shoulders, MuscleGroup.spine], difficulty: Difficulty.beginner,
      caloriesPerMin: 2, defaultSeconds: 45, instructions: 'Chin tuck + shoulder blade squeeze + wall press. Hold 15s x 3.', icon: Icons.accessibility_new_rounded),
    Exercise(id: 'eye_relaxation', name: 'Eye Relaxation', category: ExerciseCategory.desk, type: ExerciseType.timed,
      muscleGroups: [MuscleGroup.eyes], difficulty: Difficulty.beginner,
      caloriesPerMin: 0.5, defaultSeconds: 60, instructions: '20-20-20 rule: Look 20ft away for 20s. Repeat. Palm eyes 20s.', icon: Icons.visibility_rounded),
  ];

  /// Get exercises by category.
  static List<Exercise> byCategory(ExerciseCategory cat) => all.where((e) => e.category == cat).toList();

  /// Get exercises that match a workout mode.
  static List<Exercise> byMode(WorkoutMode mode) => all.where((e) => e.matchesMode(mode)).toList();

  /// Get exercises suitable for the user's difficulty level.
  static List<Exercise> forDifficulty(Difficulty d) => all.where((e) => e.difficulty.index <= d.index).toList();
}
