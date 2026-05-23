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

  double get dailyWaterL => _dailyWaterL;
  int get dailyMeals => _dailyMeals;
  int get dailySteps => _dailySteps;
  int get dailyExerciseMin => _dailyExerciseMin;
  int get currentStreak => _currentStreak;
  int get bestStreak => _bestStreak;

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
      await prefs.setString(_lastActiveKey, today);
      await prefs.setDouble(_dailyWaterKey, 0);
      await prefs.setInt(_dailyMealsKey, 0);
      await prefs.setInt(_dailyStepsKey, 0);
      await prefs.setInt(_dailyExerciseMinKey, 0);
      await prefs.setInt(_streakKey, _currentStreak);
    } else {
      _dailyWaterL = prefs.getDouble(_dailyWaterKey) ?? 0;
      _dailyMeals = prefs.getInt(_dailyMealsKey) ?? 0;
      _dailySteps = prefs.getInt(_dailyStepsKey) ?? 0;
      _dailyExerciseMin = prefs.getInt(_dailyExerciseMinKey) ?? 0;
      _currentStreak = prefs.getInt(_streakKey) ?? 0;
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
