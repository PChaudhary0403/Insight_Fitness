import 'dart:math';
import 'package:flutter/material.dart';
import '../data/models/discipline_models.dart';
import '../../../core/theme/app_colors.dart';

/// Discipline Scoring Engine — computes scores, detects patterns, generates insights.
class DisciplineScoringEngine {
  DisciplineScoringEngine._();

  /// Compute discipline score for a check-in based on punctuality.
  static double computeCheckInScore({
    required DisciplineRule rule,
    required DateTime checkInTime,
    required String status,
  }) {
    if (status == 'missed') return 0.0;

    final targetStart = _parseTime(rule.targetTimeStart);
    final targetEnd = _parseTime(rule.targetTimeEnd);
    final checkIn = TimeOfDay(hour: checkInTime.hour, minute: checkInTime.minute);

    if (status == 'on_time') {
      // Perfect or near-perfect
      final minutesInWindow = _minutesBetween(targetStart, targetEnd);
      final minutesFromStart = _minutesBetween(targetStart, checkIn);
      if (minutesFromStart <= minutesInWindow) return 10.0;
      return 9.5;
    }

    // Late check-in: deduct based on how late
    final minutesLate = _minutesBetween(targetEnd, checkIn);
    final strictnessMultiplier = switch (rule.strictness) {
      'strict' => 2.0,
      'moderate' => 1.0,
      'relaxed' => 0.5,
      _ => 1.0,
    };
    final deduction = (minutesLate / 10.0) * strictnessMultiplier;
    return (10.0 - deduction).clamp(1.0, 9.4);
  }

  /// Determine check-in status based on time window.
  static String determineStatus(DisciplineRule rule, DateTime checkInTime) {
    final targetStart = _parseTime(rule.targetTimeStart);
    final targetEnd = _parseTime(rule.targetTimeEnd);
    final checkIn = TimeOfDay(hour: checkInTime.hour, minute: checkInTime.minute);

    final startMinutes = targetStart.hour * 60 + targetStart.minute;
    final endMinutes = targetEnd.hour * 60 + targetEnd.minute;
    final checkMinutes = checkIn.hour * 60 + checkIn.minute;

    // Allow 15min grace before window
    if (checkMinutes >= (startMinutes - 15) && checkMinutes <= endMinutes) {
      return 'on_time';
    }
    return 'late';
  }

  /// Compute aggregate analytics for a discipline rule.
  static DisciplineAnalytics computeAnalytics(
    DisciplineRule rule,
    List<DisciplineCheckIn> checkIns,
  ) {
    if (checkIns.isEmpty) {
      return DisciplineAnalytics(ruleId: rule.id);
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekAgo = today.subtract(const Duration(days: 7));
    final monthAgo = today.subtract(const Duration(days: 30));

    final todayCheckins = checkIns.where((c) => c.timestamp.isAfter(today)).toList();
    final weekCheckins = checkIns.where((c) => c.timestamp.isAfter(weekAgo)).toList();
    final monthCheckins = checkIns.where((c) => c.timestamp.isAfter(monthAgo)).toList();

    double avgScore(List<DisciplineCheckIn> list) {
      if (list.isEmpty) return 0;
      return list.map((c) => c.scoreAwarded).reduce((a, b) => a + b) / list.length;
    }

    // Streak calculation
    int streak = 0;
    int bestStreak = 0;
    final sorted = List.of(checkIns)..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    DateTime? lastDate;
    for (final c in sorted) {
      final date = DateTime(c.timestamp.year, c.timestamp.month, c.timestamp.day);
      if (lastDate == null) {
        streak = 1;
        lastDate = date;
        continue;
      }
      if (lastDate.difference(date).inDays == 1 && c.status != 'missed') {
        streak++;
        lastDate = date;
      } else if (lastDate.difference(date).inDays == 0) {
        continue; // Same day
      } else {
        break;
      }
    }
    bestStreak = max(streak, bestStreak);

    return DisciplineAnalytics(
      ruleId: rule.id,
      dailyScore: double.parse(avgScore(todayCheckins).toStringAsFixed(1)),
      weeklyScore: double.parse(avgScore(weekCheckins).toStringAsFixed(1)),
      monthlyScore: double.parse(avgScore(monthCheckins).toStringAsFixed(1)),
      allTimeScore: double.parse(avgScore(checkIns).toStringAsFixed(1)),
      currentStreak: streak,
      bestStreak: bestStreak,
      totalCheckIns: checkIns.where((c) => c.status != 'missed').length,
      missedCheckIns: checkIns.where((c) => c.status == 'missed').length,
      lateCheckIns: checkIns.where((c) => c.status == 'late').length,
    );
  }

  /// Generate AI-like behavioral insights.
  static List<DisciplineInsight> generateInsights(
    Map<String, DisciplineAnalytics> analyticsMap,
    Map<String, DisciplineRule> rulesMap,
    List<DisciplineCheckIn> allCheckIns,
  ) {
    final insights = <DisciplineInsight>[];
    final now = DateTime.now();

    // Find strongest and weakest disciplines
    if (analyticsMap.length >= 2) {
      final sorted = analyticsMap.entries.toList()
        ..sort((a, b) => b.value.allTimeScore.compareTo(a.value.allTimeScore));
      final strongest = rulesMap[sorted.first.key];
      final weakest = rulesMap[sorted.last.key];
      if (strongest != null && weakest != null) {
        insights.add(DisciplineInsight(
          message: '${strongest.title}: highest consistency score. ${weakest.title}: lowest — consider schedule adjustments.',
          type: 'pattern',
          generatedAt: now,
        ));
      }
    }

    // Weekend pattern detection
    final weekendMisses = allCheckIns.where((c) =>
        c.status == 'missed' &&
        (c.timestamp.weekday == DateTime.saturday || c.timestamp.weekday == DateTime.sunday)).length;
    final totalMisses = allCheckIns.where((c) => c.status == 'missed').length;
    if (totalMisses > 0 && weekendMisses > totalMisses * 0.5) {
      insights.add(DisciplineInsight(
        message: 'Weekend miss rate: ${(weekendMisses / totalMisses * 100).round()}% of all misses. Consider adjusting weekend targets.',
        type: 'pattern',
        generatedAt: now,
      ));
    }

    // Improvement tracking
    for (final entry in analyticsMap.entries) {
      final a = entry.value;
      if (a.weeklyScore > a.monthlyScore && a.monthlyScore > 0) {
        final rule = rulesMap[entry.key];
        if (rule != null) {
          insights.add(DisciplineInsight(
            message: '${rule.title}: weekly score ${a.weeklyScore} vs monthly avg ${a.monthlyScore} — positive trend.',
            type: 'improvement',
            generatedAt: now,
          ));
        }
      }
    }

    // Streak encouragement
    for (final entry in analyticsMap.entries) {
      final a = entry.value;
      if (a.currentStreak >= 7) {
        final rule = rulesMap[entry.key];
        if (rule != null) {
          insights.add(DisciplineInsight(
            message: '${rule.title}: ${a.currentStreak}-day consecutive streak. Habit formation threshold reached.',
            type: 'improvement',
            generatedAt: now,
          ));
        }
      }
    }

    return insights;
  }

  /// Generate badges earned based on analytics.
  static List<DisciplineBadge> checkBadges(
    Map<String, DisciplineAnalytics> analyticsMap,
    Map<String, DisciplineRule> rulesMap,
  ) {
    final badges = <DisciplineBadge>[];
    final now = DateTime.now();

    for (final entry in analyticsMap.entries) {
      final a = entry.value;
      final rule = rulesMap[entry.key];
      if (rule == null) continue;

      if (a.currentStreak >= 7) {
        badges.add(DisciplineBadge(id: '${rule.id}_7day', title: '7-Day Streak', emoji: '', description: '${rule.title}: 7 consecutive days completed.', earnedAt: now));
      }
      if (a.currentStreak >= 30) {
        badges.add(DisciplineBadge(id: '${rule.id}_30day', title: '30-Day Consistency', emoji: '', description: '${rule.title}: 30-day consecutive adherence.', earnedAt: now));
      }
      if (a.allTimeScore >= 9.5) {
        badges.add(DisciplineBadge(id: '${rule.id}_perfect', title: 'Near-Perfect Score', emoji: '', description: '${rule.title}: sustained 9.5+ score.', earnedAt: now));
      }

      // Category-specific milestones
      if (rule.category == 'wake_up' && a.currentStreak >= 7) {
        badges.add(DisciplineBadge(id: 'wake_consistency', title: 'Wake-Up Consistency', emoji: '', description: '7+ day consistent wake schedule.', earnedAt: now));
      }
      if (rule.category == 'exercise' && a.allTimeScore >= 8.0) {
        badges.add(DisciplineBadge(id: 'exercise_adherence', title: 'Exercise Adherence', emoji: '', description: 'Sustained 8.0+ exercise discipline score.', earnedAt: now));
      }
    }

    return badges;
  }

  /// Score classification.
  static String scoreLabel(double score) {
    if (score >= 9.5) return 'Optimal';
    if (score >= 8.5) return 'Proficient';
    if (score >= 7.0) return 'Adequate';
    if (score >= 5.0) return 'Developing';
    if (score >= 3.0) return 'Below Threshold';
    return 'Insufficient';
  }

  /// Score color.
  static Color scoreColor(double score) {
    if (score >= 9.0) return AppColors.success;
    if (score >= 7.0) return AppColors.primary;
    if (score >= 5.0) return AppColors.warning;
    return AppColors.error;
  }

  // ─── Helpers ────────────────────────────────────────────

  static TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  static int _minutesBetween(TimeOfDay a, TimeOfDay b) {
    return (b.hour * 60 + b.minute) - (a.hour * 60 + a.minute);
  }
}
