import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/planner/data/models/planner_models.dart';

/// Centralized service that persists planner tasks, discipline data,
/// tick sheet state, and exposes scores for the dashboard.
///
/// Every feature writes through this service so the dashboard always
/// has up-to-date cross-module scores.
class PlannerService {
  PlannerService._();
  static final PlannerService instance = PlannerService._();

  // ─── Storage keys ──────────────────────────────────────────
  static const _tasksKey = 'planner_tasks';
  static const _plannedKey = 'planner_is_planned';
  static const _planCreatedKey = 'planner_plan_created_at';
  static const _planDateKey = 'planner_date';
  static const _nextIdKey = 'planner_next_id';
  static const _tickSheetKey = 'tick_sheet_data';
  static const _tickSheetDateKey = 'tick_sheet_date';
  static const _disciplineRulesKey = 'discipline_rules';
  static const _disciplineCheckInsKey = 'discipline_checkins';
  static const _totalXPKey = 'planner_total_xp';

  // ─── Planner State ─────────────────────────────────────────
  List<PlannedTask> _tasks = [];
  bool _isPlanned = false;
  DateTime? _planCreatedAt;
  int _nextId = 1;
  int _totalXP = 0;

  List<PlannedTask> get tasks => _tasks;
  bool get isPlanned => _isPlanned;
  DateTime? get planCreatedAt => _planCreatedAt;
  int get nextId => _nextId;
  int get totalXP => _totalXP;

  DailyPlan get todayPlan => DailyPlan(
        date: DateTime.now(),
        tasks: _tasks,
        planCreatedAt: _planCreatedAt,
        isPlanned: _isPlanned,
      );

  // ─── Tick Sheet State ──────────────────────────────────────
  List<Map<String, dynamic>> _tickActivities = [];
  List<Map<String, dynamic>> get tickActivities => _tickActivities;
  double get tickCompletion {
    if (_tickActivities.isEmpty) return 0;
    int c = _tickActivities.where((a) => (a['done'] as int) >= (a['goal'] as int)).length;
    return c / _tickActivities.length;
  }

  // ─── Discipline State ──────────────────────────────────────
  List<Map<String, dynamic>> _disciplineRules = [];
  List<Map<String, dynamic>> _disciplineCheckIns = [];
  List<Map<String, dynamic>> get disciplineRules => _disciplineRules;
  List<Map<String, dynamic>> get disciplineCheckIns => _disciplineCheckIns;

  // ─── Composite Scores (for dashboard) ──────────────────────
  int _productivityScore = 0;
  double _disciplineScore = 0;
  int _overallScore = 0;
  double _tickCompletionRate = 0;

  int get productivityScore => _productivityScore;
  double get disciplineScore => _disciplineScore;
  int get overallScore => _overallScore;
  double get tickCompletionRate => _tickCompletionRate;

  // ─── Initialize / Load ─────────────────────────────────────
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();

    // ── Load planner tasks ──
    final savedDate = prefs.getString(_planDateKey) ?? '';
    if (savedDate == today) {
      final tasksJson = prefs.getString(_tasksKey);
      if (tasksJson != null) {
        try {
          final list = jsonDecode(tasksJson) as List;
          _tasks = list.map((e) => PlannedTask.fromJson(e as Map<String, dynamic>)).toList();
        } catch (_) {
          _tasks = [];
        }
      }
      _isPlanned = prefs.getBool(_plannedKey) ?? false;
      final pcStr = prefs.getString(_planCreatedKey);
      _planCreatedAt = pcStr != null ? DateTime.tryParse(pcStr) : null;
      _nextId = prefs.getInt(_nextIdKey) ?? 1;
    } else {
      // New day — reset planner
      _tasks = [];
      _isPlanned = false;
      _planCreatedAt = null;
      _nextId = 1;
      await prefs.setString(_planDateKey, today);
      await _savePlannerData(prefs);
    }

    _totalXP = prefs.getInt(_totalXPKey) ?? 0;

    // ── Load tick sheet ──
    final tickDate = prefs.getString(_tickSheetDateKey) ?? '';
    if (tickDate == today) {
      final tickJson = prefs.getString(_tickSheetKey);
      if (tickJson != null) {
        try {
          final list = jsonDecode(tickJson) as List;
          _tickActivities = list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        } catch (_) {
          _tickActivities = [];
        }
      }
    } else {
      _tickActivities = [];
      await prefs.setString(_tickSheetDateKey, today);
    }

    // ── Load discipline ──
    final rulesJson = prefs.getString(_disciplineRulesKey);
    if (rulesJson != null) {
      try {
        _disciplineRules = (jsonDecode(rulesJson) as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      } catch (_) {}
    }
    final checkInsJson = prefs.getString(_disciplineCheckInsKey);
    if (checkInsJson != null) {
      try {
        _disciplineCheckIns = (jsonDecode(checkInsJson) as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      } catch (_) {}
    }

    _recalculateScores();
  }

  // ─── Planner Operations ────────────────────────────────────
  Future<void> addTask(PlannedTask task) async {
    final t = PlannedTask(
      id: '${_nextId++}',
      title: task.title,
      category: task.category,
      description: task.description,
      startTime: task.startTime,
      endTime: task.endTime,
      pointsValue: task.pointsValue,
      isRecurring: task.isRecurring,
    );
    _tasks.add(t);
    _tasks.sort((a, b) => (a.startTime.hour * 60 + a.startTime.minute)
        .compareTo(b.startTime.hour * 60 + b.startTime.minute));
    await _persist();
  }

  Future<void> addTaskFromTemplate(TaskTemplate tmpl) async {
    final now = TimeOfDay.now();
    final start = TimeOfDay(hour: now.hour, minute: 0);
    final end = TimeOfDay(
      hour: (now.hour + (tmpl.defaultDurationMin ~/ 60)).clamp(0, 23),
      minute: tmpl.defaultDurationMin % 60,
    );
    await addTask(PlannedTask(
      id: '',
      title: tmpl.title,
      category: tmpl.category,
      startTime: start,
      endTime: end,
      pointsValue: tmpl.pointsValue,
    ));
  }

  Future<void> toggleTask(int idx) async {
    final t = _tasks[idx];
    t.status = t.isCompleted ? TaskStatus.pending : TaskStatus.completed;
    t.completedAt = t.isCompleted ? DateTime.now() : null;
    _recalculateScores();
    await _persist();
  }

  Future<void> removeTask(int idx) async {
    _tasks.removeAt(idx);
    _recalculateScores();
    await _persist();
  }

  Future<void> confirmPlan() async {
    _isPlanned = true;
    _planCreatedAt = DateTime.now();
    _recalculateScores();
    await _persist();
  }

  // ─── Tick Sheet Operations ─────────────────────────────────
  Future<void> setTickActivities(List<Map<String, dynamic>> activities) async {
    _tickActivities = activities;
    _tickCompletionRate = tickCompletion;
    await _persist();
  }

  Future<void> updateTickActivity(int idx, int newDone) async {
    if (idx < _tickActivities.length) {
      _tickActivities[idx]['done'] = newDone;
      _tickCompletionRate = tickCompletion;
      await _persist();
    }
  }

  Future<void> addCustomTickActivity(Map<String, dynamic> activity) async {
    _tickActivities.add(activity);
    _tickCompletionRate = tickCompletion;
    await _persist();
  }

  // ─── Discipline Operations ─────────────────────────────────
  Future<void> addDisciplineRule(Map<String, dynamic> rule) async {
    _disciplineRules.add(rule);
    await _persistDiscipline();
  }

  Future<void> addDisciplineCheckIn(Map<String, dynamic> checkIn) async {
    _disciplineCheckIns.add(checkIn);
    _recalculateScores();
    await _persistDiscipline();
  }

  Future<void> saveDisciplineRules(List<Map<String, dynamic>> rules) async {
    _disciplineRules = rules;
    await _persistDiscipline();
  }

  Future<void> saveDisciplineCheckIns(List<Map<String, dynamic>> checkIns) async {
    _disciplineCheckIns = checkIns;
    _recalculateScores();
    await _persistDiscipline();
  }

  // ─── Score Recalculation ───────────────────────────────────
  void _recalculateScores() {
    // Productivity score from planner
    final plan = todayPlan;
    if (!plan.isPlanned || !plan.meetsMinimum) {
      _productivityScore = 0;
    } else {
      final baseScore = (plan.completionRate * 80).round();
      final cats = plan.tasks.where((t) => t.isCompleted).map((t) => t.category).toSet();
      final diversityBonus = cats.length >= 3 ? 10 : cats.length >= 2 ? 5 : 0;
      final hvCompleted = plan.tasks.where((t) => t.isCompleted && t.pointsValue >= 20).length;
      final hvBonus = (hvCompleted * 3).clamp(0, 10);
      _productivityScore = (baseScore + diversityBonus + hvBonus).clamp(0, 100);
    }

    // Discipline score (simplified for dashboard)
    _disciplineScore = 5.0;
    final todayCheckIns = _disciplineCheckIns.where((c) {
      final ts = DateTime.tryParse(c['timestamp'] ?? '');
      if (ts == null) return false;
      final now = DateTime.now();
      return ts.year == now.year && ts.month == now.month && ts.day == now.day;
    }).toList();
    if (todayCheckIns.isNotEmpty && _disciplineRules.isNotEmpty) {
      final checkedCount = todayCheckIns.length;
      final ruleCount = _disciplineRules.length;
      _disciplineScore = (5.0 + (checkedCount / ruleCount) * 5.0).clamp(0, 10);
    }

    // Tick completion
    _tickCompletionRate = tickCompletion;
  }

  // ─── Persistence ───────────────────────────────────────────
  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await _savePlannerData(prefs);
    await _saveTickSheet(prefs);
    _recalculateScores();
  }

  Future<void> _savePlannerData(SharedPreferences prefs) async {
    await prefs.setString(_tasksKey, jsonEncode(_tasks.map((t) => t.toJson()).toList()));
    await prefs.setBool(_plannedKey, _isPlanned);
    await prefs.setString(_planDateKey, _todayKey());
    await prefs.setInt(_nextIdKey, _nextId);
    if (_planCreatedAt != null) {
      await prefs.setString(_planCreatedKey, _planCreatedAt!.toIso8601String());
    }
    await prefs.setInt(_totalXPKey, _totalXP);
  }

  Future<void> _saveTickSheet(SharedPreferences prefs) async {
    // Serialize tick activities — strip non-serializable fields
    final serializable = _tickActivities.map((a) => {
          'name': a['name'],
          'done': a['done'],
          'goal': a['goal'],
          'auto': a['auto'],
          'iconCode': (a['icon'] as IconData?)?.codePoint ?? 0xe798,
          'colorValue': (a['color'] as Color?)?.toARGB32() ?? 0xFF3B82F6,
          'isCustom': a['isCustom'] ?? false,
        }).toList();
    await prefs.setString(_tickSheetKey, jsonEncode(serializable));
    await prefs.setString(_tickSheetDateKey, _todayKey());
  }

  Future<void> _persistDiscipline() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_disciplineRulesKey, jsonEncode(_disciplineRules));
    await prefs.setString(_disciplineCheckInsKey, jsonEncode(_disciplineCheckIns));
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Add XP and persist.
  Future<void> addXP(int xp) async {
    _totalXP += xp;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_totalXPKey, _totalXP);
  }
}
