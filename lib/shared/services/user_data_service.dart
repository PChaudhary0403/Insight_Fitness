import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/health_assessment/data/models/health_profile.dart';

/// Singleton service that persists the user's health profile and daily tracking
/// data. Every widget in the app reads from here — no more hardcoded values.
class UserDataService {
  UserDataService._();
  static final UserDataService instance = UserDataService._();

  static const _profileKey = 'health_profile';
  static const _dailyWaterKey = 'daily_water';
  static const _dailyMealsKey = 'daily_meals';
  static const _dailyStepsKey = 'daily_steps';
  static const _dailyExerciseMinKey = 'daily_exercise_min';
  static const _streakKey = 'current_streak';
  static const _bestStreakKey = 'best_streak';
  static const _lastActiveKey = 'last_active_date';
  static const _quickWorkoutsKey = 'daily_quick_workouts';
  static const _weeklyQuickWorkoutsKey = 'weekly_quick_workouts';
  static const _quickCaloriesKey = 'daily_quick_calories';
  static const _exerciseLogKey = 'daily_exercise_log';

  HealthProfile? _profile;
  HealthProfile? get profile => _profile;
  bool get hasProfile => _profile != null;

  // ─── Daily tracking (resets each day) ───────────────────
  double _dailyWaterL = 0;
  int _dailyMeals = 0;
  int _dailySteps = 0;
  int _dailyExerciseMin = 0;
  int _currentStreak = 0;
  int _bestStreak = 0;
  int _dailyQuickWorkouts = 0;
  int _weeklyQuickWorkouts = 0;
  int _dailyQuickCalories = 0;

  double get dailyWaterL => _dailyWaterL;
  int get dailyMeals => _dailyMeals;
  int get dailySteps => _dailySteps;
  int get dailyExerciseMin => _dailyExerciseMin;
  int get currentStreak => _currentStreak;
  int get bestStreak => _bestStreak;
  int get dailyQuickWorkouts => _dailyQuickWorkouts;
  int get weeklyQuickWorkouts => _weeklyQuickWorkouts;
  int get dailyQuickCalories => _dailyQuickCalories;

  // ─── Exercise log (sets & reps based) ───────────────────
  List<Map<String, dynamic>> _exerciseLog = [];
  List<Map<String, dynamic>> get exerciseLog => List.unmodifiable(_exerciseLog);
  int get dailyExerciseCount => _exerciseLog.length;
  int get dailyTotalSets => _exerciseLog.fold(0, (s, e) => s + ((e['sets'] as int?) ?? 0));
  int get dailyTotalReps => _exerciseLog.fold(0, (s, e) => s + (((e['sets'] as int?) ?? 0) * ((e['reps'] as int?) ?? 0)));
  int get dailyCaloriesBurned => _exerciseLog.fold(0, (s, e) => s + ((e['calories'] as int?) ?? 0));

  /// User's name from the health profile.
  String get userName => _profile?.fullName ?? 'User';
  String get userInitial => userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

  /// The health score from the assessment.
  int get healthScore => _profile?.overallHealthScore ?? 0;

  /// BMI from the assessment.
  double get bmi => _profile?.bmi ?? 0;
  String get bmiCategory => _profile?.bmiCategory ?? '—';

  /// Hydration target from the assessment.
  double get hydrationTarget => _profile?.hydrationRequirement ?? 2.5;

  /// Calorie target from the assessment.
  double get calorieTarget => _profile?.estimatedCalorieNeeds ?? 2000;

  /// Days since joining.
  int get daysSinceJoining {
    if (_profile == null) return 0;
    return DateTime.now().difference(_profile!.createdAt).inDays;
  }

  /// Load profile from SharedPreferences.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    // Load profile
    final json = prefs.getString(_profileKey);
    if (json != null) {
      try {
        _profile = HealthProfile.fromJson(jsonDecode(json));
      } catch (_) {
        _profile = null;
      }
    }

    // Check if today's data needs reset
    final lastActive = prefs.getString(_lastActiveKey);
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (lastActive != today) {
      // New day — reset daily counters, update streak
      if (lastActive != null) {
        final lastDate = DateTime.tryParse(lastActive);
        if (lastDate != null) {
          final diff = DateTime.now().difference(lastDate).inDays;
          if (diff == 1) {
            _currentStreak = (prefs.getInt(_streakKey) ?? 0) + 1;
          } else if (diff > 1) {
            _currentStreak = 0; // streak broken
          }
        }
      }
      _dailyWaterL = 0;
      _dailyMeals = 0;
      _dailySteps = 0;
      _dailyExerciseMin = 0;
      _dailyQuickWorkouts = 0;
      _dailyQuickCalories = 0;
      _exerciseLog = [];
      await prefs.setString(_lastActiveKey, today);
      await prefs.setDouble(_dailyWaterKey, 0);
      await prefs.setInt(_dailyMealsKey, 0);
      await prefs.setInt(_dailyStepsKey, 0);
      await prefs.setInt(_dailyExerciseMinKey, 0);
      await prefs.setInt(_quickWorkoutsKey, 0);
      await prefs.setInt(_quickCaloriesKey, 0);
      await prefs.setString(_exerciseLogKey, '[]');
      await prefs.setInt(_streakKey, _currentStreak);
    } else {
      _dailyWaterL = prefs.getDouble(_dailyWaterKey) ?? 0;
      _dailyMeals = prefs.getInt(_dailyMealsKey) ?? 0;
      _dailySteps = prefs.getInt(_dailyStepsKey) ?? 0;
      _dailyExerciseMin = prefs.getInt(_dailyExerciseMinKey) ?? 0;
      _currentStreak = prefs.getInt(_streakKey) ?? 0;
      _dailyQuickWorkouts = prefs.getInt(_quickWorkoutsKey) ?? 0;
      _dailyQuickCalories = prefs.getInt(_quickCaloriesKey) ?? 0;
      _weeklyQuickWorkouts = prefs.getInt(_weeklyQuickWorkoutsKey) ?? 0;
      // Load exercise log
      final logJson = prefs.getString(_exerciseLogKey);
      if (logJson != null) {
        try {
          _exerciseLog = List<Map<String, dynamic>>.from(
            (jsonDecode(logJson) as List).map((e) => Map<String, dynamic>.from(e)),
          );
        } catch (_) {
          _exerciseLog = [];
        }
      }
    }

    _bestStreak = prefs.getInt(_bestStreakKey) ?? 0;
    if (_currentStreak > _bestStreak) {
      _bestStreak = _currentStreak;
      await prefs.setInt(_bestStreakKey, _bestStreak);
    }
  }

  /// Save a new health profile (called after onboarding assessment).
  Future<void> saveProfile(HealthProfile profile) async {
    _profile = profile;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(profile.toJson()));
    // Set today as first active day and reset everything
    final today = DateTime.now().toIso8601String().substring(0, 10);
    await prefs.setString(_lastActiveKey, today);
    _currentStreak = 0;
    _bestStreak = 0;
    _dailyWaterL = 0;
    _dailyMeals = 0;
    _dailySteps = 0;
    _dailyExerciseMin = 0;
    await prefs.setInt(_streakKey, 0);
    await prefs.setInt(_bestStreakKey, 0);
    await prefs.setDouble(_dailyWaterKey, 0);
    await prefs.setInt(_dailyMealsKey, 0);
    await prefs.setInt(_dailyStepsKey, 0);
    await prefs.setInt(_dailyExerciseMinKey, 0);
  }

  /// Add water intake.
  Future<void> addWater(double liters) async {
    _dailyWaterL += liters;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_dailyWaterKey, _dailyWaterL);
  }

  /// Log a meal.
  Future<void> logMeal() async {
    _dailyMeals++;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_dailyMealsKey, _dailyMeals);
  }

  /// Add steps.
  Future<void> addSteps(int steps) async {
    _dailySteps += steps;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_dailyStepsKey, _dailySteps);
  }

  /// Log exercise minutes.
  Future<void> logExercise(int minutes) async {
    _dailyExerciseMin += minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_dailyExerciseMinKey, _dailyExerciseMin);
  }

  /// Log a completed quick workout.
  Future<void> logQuickWorkout(int caloriesBurned) async {
    _dailyQuickWorkouts++;
    _weeklyQuickWorkouts++;
    _dailyQuickCalories += caloriesBurned;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_quickWorkoutsKey, _dailyQuickWorkouts);
    await prefs.setInt(_weeklyQuickWorkoutsKey, _weeklyQuickWorkouts);
    await prefs.setInt(_quickCaloriesKey, _dailyQuickCalories);
  }

  /// Log a specific exercise with sets, reps, and estimated duration/calories.
  Future<void> logExerciseEntry({
    required String name,
    required String icon,
    required int sets,
    required int reps,
    required int estimatedMinutes,
    required int caloriesBurned,
  }) async {
    final entry = {
      'name': name,
      'icon': icon,
      'sets': sets,
      'reps': reps,
      'minutes': estimatedMinutes,
      'calories': caloriesBurned,
      'time': DateTime.now().toIso8601String(),
    };
    _exerciseLog.add(entry);
    _dailyExerciseMin += estimatedMinutes;
    _dailyQuickWorkouts++;
    _dailyQuickCalories += caloriesBurned;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_exerciseLogKey, jsonEncode(_exerciseLog));
    await prefs.setInt(_dailyExerciseMinKey, _dailyExerciseMin);
    await prefs.setInt(_quickWorkoutsKey, _dailyQuickWorkouts);
    await prefs.setInt(_quickCaloriesKey, _dailyQuickCalories);
  }

  /// Remove a logged exercise by index.
  Future<void> removeExerciseEntry(int index) async {
    if (index < 0 || index >= _exerciseLog.length) return;
    final entry = _exerciseLog[index];
    final minutes = (entry['minutes'] as int?) ?? 0;
    final calories = (entry['calories'] as int?) ?? 0;
    _exerciseLog.removeAt(index);
    _dailyExerciseMin = (_dailyExerciseMin - minutes).clamp(0, 9999);
    _dailyQuickWorkouts = (_dailyQuickWorkouts - 1).clamp(0, 9999);
    _dailyQuickCalories = (_dailyQuickCalories - calories).clamp(0, 99999);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_exerciseLogKey, jsonEncode(_exerciseLog));
    await prefs.setInt(_dailyExerciseMinKey, _dailyExerciseMin);
    await prefs.setInt(_quickWorkoutsKey, _dailyQuickWorkouts);
    await prefs.setInt(_quickCaloriesKey, _dailyQuickCalories);
  }

  /// Clear all data (for testing / logout).
  Future<void> clear() async {
    _profile = null;
    _dailyWaterL = 0;
    _dailyMeals = 0;
    _dailySteps = 0;
    _dailyExerciseMin = 0;
    _currentStreak = 0;
    _bestStreak = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
