import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/planner_models.dart';
import '../../data/scoring_engine.dart';
import '../../../../shared/services/user_data_service.dart';
import '../../../../shared/services/planner_service.dart';

class PlannerPage extends StatefulWidget {
  const PlannerPage({super.key});
  @override
  State<PlannerPage> createState() => _PlannerPageState();
}

class _PlannerPageState extends State<PlannerPage> {
  final _svc = PlannerService.instance;

  DailyPlan get _plan => _svc.todayPlan;
  int get _prodScore => ScoringEngine.productivityScore(_plan);
  double get _discScore => ScoringEngine.disciplineScore(
        currentStreak: UserDataService.instance.currentStreak,
        plannedOnTime: _svc.isPlanned,
        taskCompletionRate: _plan.completionRate,
      );

  Future<void> _confirmPlan() async {
    if (_svc.tasks.length < 2 || !_plan.hasHealthTask || !_plan.hasProductivityTask) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Need at least 1 health + 1 productivity task'),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      return;
    }
    await _svc.confirmPlan();
    if (mounted) setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Daily plan confirmed.'),
      backgroundColor: AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  Future<void> _toggleTask(int idx) async {
    await _svc.toggleTask(idx);
    if (mounted) setState(() {});
  }

  Future<void> _addTaskFromTemplate(TaskTemplate tmpl) async {
    await _svc.addTaskFromTemplate(tmpl);
    if (mounted) setState(() {});
  }

  Future<void> _addCustomTask(PlannedTask task) async {
    await _svc.addTask(task);
    if (mounted) setState(() {});
  }

  void _showAddTask() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddTaskSheet(
        onAdd: _addTaskFromTemplate,
        onAddCustom: _addCustomTask,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = UserDataService.instance;
    final tasks = _svc.tasks;
    final overall = ScoringEngine.overallScore(
      healthScore: data.healthScore,
      productivityScoreVal: _prodScore,
      disciplineScoreVal: _discScore,
    );

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: Text('Daily Planner', style: AppTypography.h3(color: AppColors.textPrimary)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.add_rounded, color: AppColors.primary), onPressed: _showAddTask),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacing24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Score cards
          Row(children: [
            _ScoreCard('Health', '${data.healthScore}', AppColors.success),
            const SizedBox(width: 8),
            _ScoreCard('Productivity', '$_prodScore', AppColors.info),
            const SizedBox(width: 8),
            _ScoreCard('Overall', '$overall', AppColors.primary),
          ]).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 16),

          // Discipline bar
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.cardBorder)),
            child: Row(children: [
              Icon(Icons.shield_rounded, color: AppColors.warning, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Discipline: ${_discScore.toStringAsFixed(1)}/10', style: AppTypography.bodyMedium(color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                ClipRRect(borderRadius: BorderRadius.circular(3), child: LinearProgressIndicator(value: _discScore / 10, minHeight: 4, backgroundColor: AppColors.warning.withValues(alpha: 0.15), valueColor: const AlwaysStoppedAnimation(AppColors.warning))),
              ])),
            ]),
          ).animate(delay: 100.ms).fadeIn(),
          const SizedBox(height: 20),

          // Plan status
          if (!_svc.isPlanned) ...[
            Container(
              width: double.infinity, padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.warning.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.warning.withValues(alpha: 0.3))),
              child: Column(children: [
                Icon(Icons.assignment_rounded, color: AppColors.warning, size: 32),
                const SizedBox(height: 8),
                Text('Plan Your Day', style: AppTypography.h4(color: AppColors.warning)),
                Text('Add tasks and confirm your plan to earn productivity points.', style: AppTypography.caption(color: AppColors.textSecondary), textAlign: TextAlign.center),
                const SizedBox(height: 12),
                SizedBox(width: double.infinity, child: ElevatedButton(
                  onPressed: tasks.isEmpty ? _showAddTask : _confirmPlan,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: Text(tasks.isEmpty ? 'Add Tasks' : 'Confirm Plan', style: AppTypography.button(color: Colors.white)),
                )),
              ]),
            ).animate(delay: 200.ms).fadeIn(),
            const SizedBox(height: 20),
          ],

          // Task list header
          Row(children: [
            Text('Today\'s Tasks', style: AppTypography.h4(color: AppColors.textPrimary)),
            const Spacer(),
            if (tasks.isNotEmpty) Text('${_plan.completedCount}/${_plan.totalTasks} done', style: AppTypography.caption(color: AppColors.textSecondary)),
          ]),
          const SizedBox(height: 12),

          if (tasks.isEmpty)
            Center(child: Padding(padding: const EdgeInsets.symmetric(vertical: 40), child: Column(children: [
              Icon(Icons.event_note_rounded, color: AppColors.textTertiary, size: 48),
              const SizedBox(height: 12),
              Text('No tasks yet', style: AppTypography.body(color: AppColors.textTertiary)),
              const SizedBox(height: 4),
              Text('Tap + to plan your day', style: AppTypography.caption(color: AppColors.textTertiary)),
            ])))
          else
            ...tasks.asMap().entries.map((e) {
              final t = e.value;
              return Dismissible(
                key: Key(t.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.delete_rounded, color: AppColors.error),
                ),
                onDismissed: (_) async {
                  await _svc.removeTask(e.key);
                  if (mounted) setState(() {});
                },
                child: GestureDetector(
                  onTap: () => _toggleTask(e.key),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: t.isCompleted ? AppColors.success.withValues(alpha: 0.06) : AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: t.isCompleted ? AppColors.success.withValues(alpha: 0.25) : AppColors.cardBorder),
                    ),
                    child: Row(children: [
                      Icon(t.isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, color: t.isCompleted ? AppColors.success : t.color, size: 24),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(t.title, style: AppTypography.bodyMedium(color: t.isCompleted ? AppColors.textSecondary : AppColors.textPrimary).copyWith(decoration: t.isCompleted ? TextDecoration.lineThrough : null)),
                        Text('${t.timeDisplay} • +${t.pointsValue} pts', style: AppTypography.caption(color: AppColors.textTertiary)),
                      ])),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: t.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)), child: Text(t.category.name, style: AppTypography.label(color: t.color))),
                    ]),
                  ),
                ),
              ).animate(delay: Duration(milliseconds: 250 + e.key * 60)).fadeIn().slideX(begin: 0.02, end: 0);
            }),

          // Points summary
          if (tasks.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.cardBorder)),
              child: Row(children: [
                Icon(Icons.star_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: 10),
                Text('Points: ${_plan.earnedPoints} / ${_plan.possiblePoints}', style: AppTypography.bodyMedium(color: AppColors.textPrimary)),
                const Spacer(),
                if (_plan.completionRate >= 1.0 && _plan.totalTasks >= 3) Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                  child: Text('100% Completion', style: AppTypography.caption(color: AppColors.success)),
                ),
              ]),
            ),
          ],
        ]),
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final String label, value;
  final Color color;
  const _ScoreCard(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) {
    return Expanded(child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.cardBorder)),
      child: Column(children: [
        Text(value, style: AppTypography.h3(color: color)),
        Text(label, style: AppTypography.caption(color: AppColors.textSecondary)),
      ]),
    ));
  }
}

class _AddTaskSheet extends StatefulWidget {
  final Function(TaskTemplate) onAdd;
  final Function(PlannedTask)? onAddCustom;
  const _AddTaskSheet({required this.onAdd, this.onAddCustom});

  @override
  State<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<_AddTaskSheet> {
  final _customCtrl = TextEditingController();
  TaskCategory _customCategory = TaskCategory.personal;
  int _customPoints = 15;
  int _customDuration = 30;

  @override
  void dispose() { _customCtrl.dispose(); super.dispose(); }

  void _addCustomTask(BuildContext ctx) {
    if (_customCtrl.text.trim().isEmpty) return;
    final now = TimeOfDay.now();
    final start = TimeOfDay(hour: now.hour, minute: 0);
    final end = TimeOfDay(hour: (now.hour + (_customDuration ~/ 60)).clamp(0, 23), minute: _customDuration % 60);
    final task = PlannedTask(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _customCtrl.text.trim(),
      category: _customCategory,
      startTime: start, endTime: end,
      pointsValue: _customPoints,
    );
    if (widget.onAddCustom != null) {
      widget.onAddCustom!(task);
    } else {
      widget.onAdd(TaskTemplate(
        title: _customCtrl.text.trim(),
        category: _customCategory,
        pointsValue: _customPoints,
        defaultDurationMin: _customDuration,
        emoji: '',
      ));
    }
    Navigator.pop(ctx);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(margin: EdgeInsets.only(top: 12), width: 40, height: 4, decoration: BoxDecoration(color: AppColors.dividerColor, borderRadius: BorderRadius.circular(2))),
        Padding(padding: EdgeInsets.all(20), child: Text('Add Task', style: AppTypography.h3(color: AppColors.textPrimary))),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // ─── Custom Task Section ──────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Create Custom Task', style: AppTypography.bodyMedium(color: AppColors.primary)),
                const SizedBox(height: 10),
                TextField(
                  controller: _customCtrl,
                  onChanged: (_) => setState(() {}),
                  style: AppTypography.body(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'What do you need to do?',
                    hintStyle: AppTypography.body(color: AppColors.textTertiary),
                    filled: true, fillColor: AppColors.surfaceElevated,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 10),
                Row(children: [
                  Text('Category: ', style: AppTypography.caption(color: AppColors.textSecondary)),
                  const SizedBox(width: 4),
                  ...TaskCategory.values.map((c) {
                    final isSelected = _customCategory == c;
                    final (label, color) = switch (c) {
                      TaskCategory.health => ('Health', AppColors.success),
                      TaskCategory.productivity => ('Work', AppColors.info),
                      TaskCategory.personal => ('Personal', AppColors.secondary),
                    };
                    return GestureDetector(
                      onTap: () => setState(() => _customCategory = c),
                      child: Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isSelected ? color : AppColors.cardBorder),
                        ),
                        child: Text(label, style: AppTypography.caption(color: isSelected ? color : AppColors.textSecondary)),
                      ),
                    );
                  }),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Text('Points: ', style: AppTypography.caption(color: AppColors.textSecondary)),
                  ...[5, 10, 15, 20, 25].map((p) => GestureDetector(
                    onTap: () => setState(() => _customPoints = p),
                    child: Container(
                      margin: const EdgeInsets.only(right: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _customPoints == p ? AppColors.primary.withValues(alpha: 0.2) : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('$p', style: AppTypography.caption(color: _customPoints == p ? AppColors.primary : AppColors.textTertiary)),
                    ),
                  )),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Text('Duration: ', style: AppTypography.caption(color: AppColors.textSecondary)),
                  ...[15, 30, 60, 90, 120].map((d) => GestureDetector(
                    onTap: () => setState(() => _customDuration = d),
                    child: Container(
                      margin: const EdgeInsets.only(right: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _customDuration == d ? AppColors.primary.withValues(alpha: 0.2) : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('${d}m', style: AppTypography.caption(color: _customDuration == d ? AppColors.primary : AppColors.textTertiary)),
                    ),
                  )),
                ]),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _customCtrl.text.trim().isEmpty ? null : () => _addCustomTask(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      disabledBackgroundColor: AppColors.surfaceElevated,
                    ),
                    child: Text('Add Custom Task', style: AppTypography.button(color: Colors.white)),
                  ),
                ),
              ]),
            ),

            const SizedBox(height: 20),
            Text('── Or choose a template ──', style: AppTypography.caption(color: AppColors.textTertiary), textAlign: TextAlign.center),
            const SizedBox(height: 12),

            _section('Health', TaskTemplate.healthTemplates, context),
            _section('Productivity', TaskTemplate.productivityTemplates, context),
            _section('Personal', TaskTemplate.personalTemplates, context),
          ]),
        )),
      ]),
    );
  }

  Widget _section(String title, List<TaskTemplate> templates, BuildContext ctx) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: AppTypography.h4(color: AppColors.textPrimary)),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8, children: templates.map((t) => GestureDetector(
        onTap: () { widget.onAdd(t); Navigator.pop(ctx); },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: AppColors.surfaceElevated, borderRadius: BorderRadius.circular(10)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(t.title, style: AppTypography.bodySmall(color: AppColors.textPrimary)),
            const SizedBox(width: 6),
            Text('+${t.pointsValue}', style: AppTypography.label(color: AppColors.primary)),
          ]),
        ),
      )).toList()),
      const SizedBox(height: 16),
    ]);
  }
}