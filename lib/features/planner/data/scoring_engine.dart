import 'models/planner_models.dart';
import '../../../../shared/services/user_data_service.dart';

/// Composite scoring engine that combines health, productivity, and discipline.
/// 
/// Scoring is mathematically weighted to prevent exploitation through
/// fake tasks while remaining motivating.
class ScoringEngine {
  ScoringEngine._();

  /// Calculate productivity score (0-100) based on today's plan.
  static int productivityScore(DailyPlan? plan) {
    if (plan == null || !plan.isPlanned) return 0;
    if (!plan.meetsMinimum) return 0;

    final baseScore = (plan.completionRate * 80).round();
    
    // Bonus for category diversity
    final categories = plan.tasks.where((t) => t.isCompleted).map((t) => t.category).toSet();
    final diversityBonus = categories.length >= 3 ? 10 : categories.length >= 2 ? 5 : 0;

    // Bonus for completing high-value tasks
    final highValueCompleted = plan.tasks.where((t) => t.isCompleted && t.pointsValue >= 20).length;
    final highValueBonus = (highValueCompleted * 3).clamp(0, 10);

    return (baseScore + diversityBonus + highValueBonus).clamp(0, 100);
  }

  /// Calculate health score modifier from daily tracking.
  /// The base comes from the health assessment; this modifies it.
  ///
  /// Audit-corrected: now includes NEGATIVE modifiers for zero activity.
  /// Previously, doing nothing gave 0 (no penalty). Now it penalizes.
  static int dailyHealthModifier(UserDataService data) {
    int mod = 0;

    // Hydration progress
    final hydrationPct = data.hydrationTarget > 0 ? data.dailyWaterL / data.hydrationTarget : 0;
    if (hydrationPct >= 1.0) mod += 10;
    else if (hydrationPct >= 0.5) mod += 5;
    else if (data.dailyWaterL < 0.5) mod -= 5; // nearly no water = penalty

    // Exercise
    if (data.dailyExerciseMin >= 30 && data.dailyExerciseMin <= 90) mod += 10; // optimal range
    else if (data.dailyExerciseMin > 90) mod += 7; // overtraining diminishing returns
    else if (data.dailyExerciseMin >= 15) mod += 5;
    else if (data.dailyExerciseMin == 0) mod -= 5; // no exercise = penalty

    // Steps
    if (data.dailySteps >= 10000) mod += 10;
    else if (data.dailySteps >= 5000) mod += 5;

    // Meals
    if (data.dailyMeals >= 3) mod += 5;
    else if (data.dailyMeals == 0) mod -= 3; // no meals = penalty

    return mod.clamp(-20, 35);
  }

  /// Calculate discipline score (0-10.0).
  ///
  /// Audit-corrected: base starts at 0, not 5. Users earn their score.
  static double disciplineScore({
    required int currentStreak,
    required bool plannedOnTime,
    required double taskCompletionRate,
  }) {
    double score = 0.0; // start from 0 — score is earned, not given

    // Streak contribution (up to +3.5)
    score += (currentStreak * 0.5).clamp(0, 3.5);

    // Planning punctuality (+2)
    if (plannedOnTime) score += 2.0;

    // Task completion (up to +3.0)
    score += taskCompletionRate * 3.0;

    // Consistency bonus for high completion + streak (+1.5)
    if (taskCompletionRate >= 0.8 && currentStreak >= 3) score += 1.5;

    return score.clamp(0, 10).toDouble();
  }

  /// Calculate overall life performance score (composite).
  static int overallScore({
    required int healthScore,
    required int productivityScoreVal,
    required double disciplineScoreVal,
  }) {
    // Weighted: Health 40%, Productivity 35%, Discipline (scaled to 100) 25%
    final disciplineScaled = (disciplineScoreVal * 10).round();
    final composite = (healthScore * 0.40 + productivityScoreVal * 0.35 + disciplineScaled * 0.25).round();
    return composite.clamp(0, 100);
  }

  /// Points earned from a completed task with anti-exploit validation.
  static int taskPoints(PlannedTask task) {
    if (!task.isCompleted) return 0;

    // Anti-exploitation: tasks < 5 min duration give reduced points
    if (task.durationMin < 5 && task.durationMin > 0) {
      return (task.pointsValue * 0.3).round();
    }

    // Late completion: partial points
    if (task.status == TaskStatus.late) {
      return (task.pointsValue * 0.5).round();
    }

    return task.pointsValue;
  }

  /// Points deducted for missed task.
  static int missedPenalty(PlannedTask task) {
    return -(task.pointsValue * 0.3).round();
  }

  /// Perfect day bonus (all tasks completed).
  static int perfectDayBonus(DailyPlan plan) {
    if (plan.completionRate >= 1.0 && plan.totalTasks >= 3) return 25;
    return 0;
  }

  /// XP calculation for gamification.
  static int calculateXP(DailyPlan plan) {
    int xp = plan.earnedPoints;
    xp += perfectDayBonus(plan);

    // Category diversity bonus
    final cats = plan.tasks.where((t) => t.isCompleted).map((t) => t.category).toSet();
    if (cats.length >= 3) xp += 15;

    return xp;
  }

  /// Level from total XP.
  static int levelFromXP(int totalXP) {
    // XP thresholds: 100, 250, 500, 1000, 2000, 5000, 10000...
    if (totalXP < 100) return 1;
    if (totalXP < 250) return 2;
    if (totalXP < 500) return 3;
    if (totalXP < 1000) return 4;
    if (totalXP < 2000) return 5;
    if (totalXP < 5000) return 6;
    if (totalXP < 10000) return 7;
    return 8 + ((totalXP - 10000) ~/ 5000);
  }

  /// Performance classification.
  static String performanceLabel(int score) {
    if (score < 25) return 'Below Threshold';
    if (score < 50) return 'Developing';
    if (score < 70) return 'Adequate';
    if (score < 85) return 'Proficient';
    return 'Optimal';
  }
}
