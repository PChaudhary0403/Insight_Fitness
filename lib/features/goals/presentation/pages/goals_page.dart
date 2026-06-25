import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_theme.dart';

/// Long-term goals page — user-created goals with daily reminders.
class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});
  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  List<_UserGoal> _goals = [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('user_goals');
    if (json != null) {
      final list = jsonDecode(json) as List;
      _goals = list.map((e) => _UserGoal.fromJson(e)).toList();
    }
    setState(() => _loaded = true);
  }

  Future<void> _saveGoals() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_goals', jsonEncode(_goals.map((g) => g.toJson()).toList()));
  }

  void _addGoal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddGoalSheet(onAdd: (goal) {
        setState(() => _goals.add(goal));
        _saveGoals();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Goal added: ${goal.title}'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }),
    );
  }

  void _deleteGoal(int idx) {
    final title = _goals[idx].title;
    setState(() => _goals.removeAt(idx));
    _saveGoals();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Removed: $title'),
      backgroundColor: AppColors.surfaceElevated,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  void _toggleComplete(int idx) {
    setState(() => _goals[idx].isCompleted = !_goals[idx].isCompleted);
    _saveGoals();
  }

  @override
  Widget build(BuildContext context) {
    // Daily reminder check — show a banner if there are active goals
    final activeGoals = _goals.where((g) => !g.isCompleted).toList();
    final hasReminder = activeGoals.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: Text('My Goals', style: AppTypography.h3(color: AppColors.textPrimary)),
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary), onPressed: () => Navigator.pop(context)),
      ),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacing24),
              child: Column(children: [
                // Daily reminder banner
                if (hasReminder)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary.withValues(alpha: 0.12), AppColors.secondary.withValues(alpha: 0.08)],
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
                    ),
                    child: Row(children: [
                      Icon(Icons.notifications_active_rounded, color: AppColors.primary, size: 24),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Active Goals', style: AppTypography.bodyMedium(color: AppColors.primary)),
                        Text(
                          '${activeGoals.length} goal${activeGoals.length > 1 ? "s" : ""} in progress. Next: "${activeGoals.first.title}".',
                          style: AppTypography.caption(color: AppColors.textSecondary),
                          maxLines: 2, overflow: TextOverflow.ellipsis,
                        ),
                      ])),
                    ]),
                  ).animate().fadeIn(duration: 400.ms),

                // Goals list
                if (_goals.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 60),
                    child: Column(children: [
                      Icon(Icons.flag_rounded, color: AppColors.textTertiary, size: 48),
                      const SizedBox(height: 16),
                      Text('No goals defined', style: AppTypography.h4(color: AppColors.textTertiary)),
                      const SizedBox(height: 4),
                      Text('Define long-term objectives to track progress', style: AppTypography.body(color: AppColors.textTertiary)),
                    ]),
                  )
                else
                  ..._goals.asMap().entries.map((e) {
                    final g = e.value;
                    return Dismissible(
                      key: Key(g.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        ),
                        child: const Icon(Icons.delete_rounded, color: AppColors.error),
                      ),
                      onDismissed: (_) => _deleteGoal(e.key),
                      child: GestureDetector(
                        onTap: () => _toggleComplete(e.key),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(AppTheme.spacing20),
                          decoration: BoxDecoration(
                            color: g.isCompleted ? AppColors.success.withValues(alpha: 0.06) : AppColors.surface,
                            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                            border: Border.all(color: g.isCompleted ? AppColors.success.withValues(alpha: 0.25) : AppColors.cardBorder),
                          ),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              Icon(g.categoryIcon, color: g.categoryColor, size: 24),
                              const SizedBox(width: 10),
                              Expanded(child: Text(
                                g.title,
                                style: AppTypography.h4(color: g.isCompleted ? AppColors.textSecondary : AppColors.textPrimary)
                                    .copyWith(decoration: g.isCompleted ? TextDecoration.lineThrough : null),
                              )),
                              Icon(
                                g.isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                color: g.isCompleted ? AppColors.success : AppColors.textTertiary,
                              ),
                            ]),
                            if (g.description.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(g.description, style: AppTypography.body(color: AppColors.textSecondary), maxLines: 2),
                            ],
                            const SizedBox(height: 10),
                            Row(children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(color: g.categoryColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                                child: Text(g.category, style: AppTypography.label(color: g.categoryColor)),
                              ),
                              const SizedBox(width: 8),
                              if (g.deadline != null)
                                Text('Due: ${g.deadline!.day}/${g.deadline!.month}/${g.deadline!.year}', style: AppTypography.caption(color: AppColors.textTertiary)),
                              const Spacer(),
                              Icon(Icons.notifications_active_rounded, color: AppColors.primary, size: 12),
                              const SizedBox(width: 4),
                              Text('Daily reminder', style: AppTypography.label(color: AppColors.primary)),
                            ]),
                          ]),
                        ),
                      ),
                    ).animate(delay: Duration(milliseconds: 100 + e.key * 80)).fadeIn().slideY(begin: 0.05, end: 0);
                  }),

                const SizedBox(height: AppTheme.spacing16),
                // Add goal button
                SizedBox(
                  width: double.infinity, height: 56,
                  child: Container(
                    decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(AppTheme.radiusFull)),
                    child: ElevatedButton.icon(
                      onPressed: _addGoal,
                      icon: const Icon(Icons.add_rounded, color: Colors.white),
                      label: Text('Add New Goal', style: AppTypography.button(color: Colors.white)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusFull))),
                    ),
                  ),
                ),
              ]),
            ),
    );
  }
}

// ─── Goal Model ──────────────────────────────────────────

class _UserGoal {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final String category;
  final DateTime createdAt;
  final DateTime? deadline;
  bool isCompleted;

  _UserGoal({
    required this.id, required this.title, this.description = '',
    this.emoji = '', this.category = 'General', required this.createdAt,
    this.deadline, this.isCompleted = false,
  });

  Color get categoryColor => switch (category) {
    'Health' => AppColors.success,
    'Fitness' => AppColors.exercise,
    'Career' => AppColors.info,
    'Learning' => AppColors.secondary,
    'Finance' => AppColors.warning,
    'Personal' => AppColors.mindfulness,
    _ => AppColors.primary,
  };

  IconData get categoryIcon => switch (category) {
    'Health' => Icons.favorite_rounded,
    'Fitness' => Icons.fitness_center_rounded,
    'Career' => Icons.work_rounded,
    'Learning' => Icons.school_rounded,
    'Finance' => Icons.account_balance_rounded,
    'Personal' => Icons.person_rounded,
    _ => Icons.flag_rounded,
  };

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'description': description,
    'emoji': emoji, 'category': category,
    'createdAt': createdAt.toIso8601String(),
    'deadline': deadline?.toIso8601String(),
    'isCompleted': isCompleted,
  };

  factory _UserGoal.fromJson(Map<String, dynamic> j) => _UserGoal(
    id: j['id'] ?? '', title: j['title'] ?? '', description: j['description'] ?? '',
    emoji: j['emoji'] ?? '', category: j['category'] ?? 'General',
    createdAt: DateTime.tryParse(j['createdAt'] ?? '') ?? DateTime.now(),
    deadline: j['deadline'] != null ? DateTime.tryParse(j['deadline']) : null,
    isCompleted: j['isCompleted'] ?? false,
  );
}

// ─── Add Goal Sheet ──────────────────────────────────────

class _AddGoalSheet extends StatefulWidget {
  final Function(_UserGoal) onAdd;
  const _AddGoalSheet({required this.onAdd});
  @override
  State<_AddGoalSheet> createState() => _AddGoalSheetState();
}

class _AddGoalSheetState extends State<_AddGoalSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _category = 'General';
  DateTime? _deadline;

  static const _categories = ['General', 'Health', 'Fitness', 'Career', 'Learning', 'Finance', 'Personal'];

  @override
  void dispose() { _titleCtrl.dispose(); _descCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.dividerColor, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Text('Define Goal', style: AppTypography.h3(color: AppColors.textPrimary)),
          const SizedBox(height: 20),

          // Category selector (replaces emoji picker)
          // Title
          TextField(
            controller: _titleCtrl,
            onChanged: (_) => setState(() {}),
            style: AppTypography.body(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'What do you want to achieve?',
              hintStyle: AppTypography.body(color: AppColors.textTertiary),
              filled: true, fillColor: AppColors.surfaceElevated,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 10),
          // Description
          TextField(
            controller: _descCtrl,
            style: AppTypography.body(color: AppColors.textPrimary),
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Why is this important? (optional)',
              hintStyle: AppTypography.body(color: AppColors.textTertiary),
              filled: true, fillColor: AppColors.surfaceElevated,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),

          const SizedBox(height: 12),
          // Category
          SizedBox(
            height: 36,
            child: ListView(scrollDirection: Axis.horizontal, children: _categories.map((c) => GestureDetector(
              onTap: () => setState(() => _category = c),
              child: Container(
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _category == c ? AppColors.primary.withValues(alpha: 0.2) : AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _category == c ? AppColors.primary : Colors.transparent),
                ),
                child: Text(c, style: AppTypography.caption(color: _category == c ? AppColors.primary : AppColors.textSecondary)),
              ),
            )).toList()),
          ),

          const SizedBox(height: 12),
          // Deadline
          GestureDetector(
            onTap: () async {
              final d = await showDatePicker(context: context, initialDate: DateTime.now().add(const Duration(days: 30)), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 3650)));
              if (d != null) setState(() => _deadline = d);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.surfaceElevated, borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                Icon(Icons.calendar_today_rounded, color: AppColors.textSecondary, size: 18),
                const SizedBox(width: 10),
                Text(
                  _deadline != null ? 'Deadline: ${_deadline!.day}/${_deadline!.month}/${_deadline!.year}' : 'Set deadline (optional)',
                  style: AppTypography.body(color: _deadline != null ? AppColors.textPrimary : AppColors.textTertiary),
                ),
              ]),
            ),
          ),

          const SizedBox(height: 8),
          // Reminder notice
          Row(children: [
            const Icon(Icons.notifications_active_rounded, color: AppColors.primary, size: 16),
            const SizedBox(width: 6),
            Text('Daily reminder will be enabled automatically', style: AppTypography.caption(color: AppColors.primary)),
          ]),

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _titleCtrl.text.trim().isEmpty ? null : () {
                widget.onAdd(_UserGoal(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: _titleCtrl.text.trim(),
                  description: _descCtrl.text.trim(),
                  category: _category,
                  createdAt: DateTime.now(),
                  deadline: _deadline,
                ));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                disabledBackgroundColor: AppColors.surfaceElevated,
              ),
              child: Text('Set Goal', style: AppTypography.button(color: Colors.white)),
            ),
          ),
        ]),
      ),
    );
  }
}