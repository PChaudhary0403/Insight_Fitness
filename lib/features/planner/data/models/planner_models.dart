import 'package:flutter/material.dart';

/// Task category for planning.
enum TaskCategory { health, productivity, personal }

/// Task status.
enum TaskStatus { pending, completed, missed, late, skipped }

/// A single planned task.
class PlannedTask {
  final String id;
  final String title;
  final TaskCategory category;
  final String? description;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final int pointsValue;
  final bool isRecurring;
  TaskStatus status;
  DateTime? completedAt;

  PlannedTask({
    required this.id,
    required this.title,
    required this.category,
    this.description,
    required this.startTime,
    required this.endTime,
    required this.pointsValue,
    this.isRecurring = false,
    this.status = TaskStatus.pending,
    this.completedAt,
  });

  bool get isCompleted => status == TaskStatus.completed;
  bool get isPending => status == TaskStatus.pending;

  /// Duration in minutes.
  int get durationMin {
    return (endTime.hour * 60 + endTime.minute) - (startTime.hour * 60 + startTime.minute);
  }

  /// Time display string.
  String get timeDisplay {
    return '${_fmt(startTime)} – ${_fmt(endTime)}';
  }

  String _fmt(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final p = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:${t.minute.toString().padLeft(2, '0')} $p';
  }

  /// Category icon.
  IconData get icon => switch (category) {
    TaskCategory.health => Icons.favorite_rounded,
    TaskCategory.productivity => Icons.laptop_rounded,
    TaskCategory.personal => Icons.person_rounded,
  };

  /// Category color.
  Color get color => switch (category) {
    TaskCategory.health => const Color(0xFF22C55E),
    TaskCategory.productivity => const Color(0xFF3B82F6),
    TaskCategory.personal => const Color(0xFF845EF7),
  };

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'category': category.name,
    'description': description,
    'startH': startTime.hour, 'startM': startTime.minute,
    'endH': endTime.hour, 'endM': endTime.minute,
    'points': pointsValue, 'recurring': isRecurring,
    'status': status.name,
    'completedAt': completedAt?.toIso8601String(),
  };

  factory PlannedTask.fromJson(Map<String, dynamic> j) => PlannedTask(
    id: j['id'] ?? '',
    title: j['title'] ?? '',
    category: TaskCategory.values.firstWhere((c) => c.name == j['category'], orElse: () => TaskCategory.personal),
    description: j['description'],
    startTime: TimeOfDay(hour: j['startH'] ?? 0, minute: j['startM'] ?? 0),
    endTime: TimeOfDay(hour: j['endH'] ?? 0, minute: j['endM'] ?? 0),
    pointsValue: j['points'] ?? 10,
    isRecurring: j['recurring'] ?? false,
    status: TaskStatus.values.firstWhere((s) => s.name == j['status'], orElse: () => TaskStatus.pending),
    completedAt: j['completedAt'] != null ? DateTime.tryParse(j['completedAt']) : null,
  );
}

/// Daily plan with all tasks and accountability info.
class DailyPlan {
  final DateTime date;
  final List<PlannedTask> tasks;
  final DateTime? planCreatedAt;
  final bool isPlanned;

  DailyPlan({
    required this.date,
    required this.tasks,
    this.planCreatedAt,
    this.isPlanned = false,
  });

  int get completedCount => tasks.where((t) => t.isCompleted).length;
  int get pendingCount => tasks.where((t) => t.isPending).length;
  int get missedCount => tasks.where((t) => t.status == TaskStatus.missed).length;
  int get totalTasks => tasks.length;
  double get completionRate => totalTasks > 0 ? completedCount / totalTasks : 0;

  int get earnedPoints => tasks.where((t) => t.isCompleted).fold(0, (s, t) => s + t.pointsValue);
  int get possiblePoints => tasks.fold(0, (s, t) => s + t.pointsValue);

  bool get hasHealthTask => tasks.any((t) => t.category == TaskCategory.health);
  bool get hasProductivityTask => tasks.any((t) => t.category == TaskCategory.productivity);

  /// Check if the plan meets minimum requirements.
  bool get meetsMinimum => hasHealthTask && hasProductivityTask && tasks.length >= 2;

  /// Whether the plan was created within the accountability window.
  bool wasPlannedOnTime(TimeOfDay commitTime) {
    if (planCreatedAt == null) return false;
    final commitMinute = commitTime.hour * 60 + commitTime.minute;
    final plannedMinute = planCreatedAt!.hour * 60 + planCreatedAt!.minute;
    return plannedMinute <= commitMinute + 120; // 2-hour window
  }
}

/// Quick task templates for planning.
class TaskTemplate {
  final String title;
  final TaskCategory category;
  final int pointsValue;
  final int defaultDurationMin;
  final String emoji; // Kept for data compatibility; no longer displayed

  const TaskTemplate({
    required this.title,
    required this.category,
    required this.pointsValue,
    required this.defaultDurationMin,
    this.emoji = '',
  });

  static const List<TaskTemplate> healthTemplates = [
    TaskTemplate(title: 'Morning Workout', category: TaskCategory.health, pointsValue: 20, defaultDurationMin: 30),
    TaskTemplate(title: 'Hydration Goal', category: TaskCategory.health, pointsValue: 15, defaultDurationMin: 0),
    TaskTemplate(title: 'Healthy Breakfast', category: TaskCategory.health, pointsValue: 10, defaultDurationMin: 20),
    TaskTemplate(title: 'Stretching', category: TaskCategory.health, pointsValue: 10, defaultDurationMin: 15),
    TaskTemplate(title: 'Walk / Steps', category: TaskCategory.health, pointsValue: 15, defaultDurationMin: 30),
    TaskTemplate(title: 'Meditation', category: TaskCategory.health, pointsValue: 10, defaultDurationMin: 10),
    TaskTemplate(title: 'Sleep On Time', category: TaskCategory.health, pointsValue: 15, defaultDurationMin: 0),
    TaskTemplate(title: 'Quick Exercise', category: TaskCategory.health, pointsValue: 15, defaultDurationMin: 10),
  ];

  static const List<TaskTemplate> productivityTemplates = [
    TaskTemplate(title: 'Deep Work Session', category: TaskCategory.productivity, pointsValue: 25, defaultDurationMin: 90),
    TaskTemplate(title: 'Study Session', category: TaskCategory.productivity, pointsValue: 20, defaultDurationMin: 60),
    TaskTemplate(title: 'Meeting', category: TaskCategory.productivity, pointsValue: 10, defaultDurationMin: 30),
    TaskTemplate(title: 'Coding / Project', category: TaskCategory.productivity, pointsValue: 25, defaultDurationMin: 120),
    TaskTemplate(title: 'Email / Communication', category: TaskCategory.productivity, pointsValue: 10, defaultDurationMin: 30),
    TaskTemplate(title: 'Learning / Course', category: TaskCategory.productivity, pointsValue: 20, defaultDurationMin: 45),
    TaskTemplate(title: 'Planning / Review', category: TaskCategory.productivity, pointsValue: 15, defaultDurationMin: 20),
  ];

  static const List<TaskTemplate> personalTemplates = [
    TaskTemplate(title: 'Family Time', category: TaskCategory.personal, pointsValue: 15, defaultDurationMin: 60),
    TaskTemplate(title: 'Hobby / Creative', category: TaskCategory.personal, pointsValue: 10, defaultDurationMin: 45),
    TaskTemplate(title: 'Errands', category: TaskCategory.personal, pointsValue: 10, defaultDurationMin: 30),
    TaskTemplate(title: 'Reading', category: TaskCategory.personal, pointsValue: 10, defaultDurationMin: 30),
    TaskTemplate(title: 'Social / Calls', category: TaskCategory.personal, pointsValue: 10, defaultDurationMin: 20),
    TaskTemplate(title: 'Rest / Break', category: TaskCategory.personal, pointsValue: 5, defaultDurationMin: 15),
  ];
}
