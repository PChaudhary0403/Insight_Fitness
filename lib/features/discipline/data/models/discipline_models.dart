import 'package:flutter/material.dart';

/// A discipline commitment that users create and track.
class DisciplineRule {
  final String id;
  final String title;
  final String description;
  final String category; // 'wake_up', 'sleep', 'exercise', 'diet', 'study', 'meditation', 'screen', 'custom'
  final IconData icon;
  final Color color;
  final String targetTimeStart; // HH:mm
  final String targetTimeEnd; // HH:mm
  final String recurrence; // 'daily', 'weekdays', 'weekends', 'custom'
  final String strictness; // 'strict', 'moderate', 'relaxed'
  final String verificationMethod; // 'manual_checkin', 'button_confirm', 'timestamp_log'
  final bool isActive;
  final DateTime createdAt;

  const DisciplineRule({
    required this.id,
    required this.title,
    this.description = '',
    required this.category,
    required this.icon,
    required this.color,
    required this.targetTimeStart,
    required this.targetTimeEnd,
    required this.recurrence,
    this.strictness = 'moderate',
    this.verificationMethod = 'manual_checkin',
    this.isActive = true,
    required this.createdAt,
  });

  DisciplineRule copyWith({bool? isActive}) => DisciplineRule(
        id: id, title: title, description: description, category: category,
        icon: icon, color: color, targetTimeStart: targetTimeStart,
        targetTimeEnd: targetTimeEnd, recurrence: recurrence,
        strictness: strictness, verificationMethod: verificationMethod,
        isActive: isActive ?? this.isActive, createdAt: createdAt,
      );
}

/// A single check-in record for a discipline rule.
class DisciplineCheckIn {
  final String ruleId;
  final DateTime timestamp;
  final String status; // 'on_time', 'late', 'missed'
  final double scoreAwarded;
  final String? note;

  const DisciplineCheckIn({
    required this.ruleId,
    required this.timestamp,
    required this.status,
    required this.scoreAwarded,
    this.note,
  });
}

/// Aggregate discipline analytics for a rule.
class DisciplineAnalytics {
  final String ruleId;
  final double dailyScore;
  final double weeklyScore;
  final double monthlyScore;
  final double allTimeScore;
  final int currentStreak;
  final int bestStreak;
  final int totalCheckIns;
  final int missedCheckIns;
  final int lateCheckIns;

  const DisciplineAnalytics({
    required this.ruleId,
    this.dailyScore = 0,
    this.weeklyScore = 0,
    this.monthlyScore = 0,
    this.allTimeScore = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.totalCheckIns = 0,
    this.missedCheckIns = 0,
    this.lateCheckIns = 0,
  });
}

/// Badge earned through discipline behavior.
class DisciplineBadge {
  final String id;
  final String title;
  final String emoji;
  final String description;
  final DateTime earnedAt;

  const DisciplineBadge({
    required this.id,
    required this.title,
    required this.emoji,
    required this.description,
    required this.earnedAt,
  });
}

/// AI coaching insight about discipline patterns.
class DisciplineInsight {
  final String message;
  final String type; // 'pattern', 'improvement', 'correction'
  final DateTime generatedAt;

  const DisciplineInsight({
    required this.message,
    required this.type,
    required this.generatedAt,
  });
}
