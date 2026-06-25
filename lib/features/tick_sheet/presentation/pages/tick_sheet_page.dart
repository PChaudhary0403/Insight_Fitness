import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/services/planner_service.dart';

/// Daily activity tick sheet page — now persisted via PlannerService.
class TickSheetPage extends StatefulWidget {
  const TickSheetPage({super.key});

  @override
  State<TickSheetPage> createState() => _TickSheetPageState();
}

class _TickSheetPageState extends State<TickSheetPage> {
  final _svc = PlannerService.instance;

  static final List<Map<String, dynamic>> _defaultActivities = [
    {'name': 'Drink water', 'icon': Icons.water_drop_rounded, 'color': AppColors.hydration, 'done': 0, 'goal': 8, 'auto': false},
    {'name': 'Breakfast', 'icon': Icons.breakfast_dining_rounded, 'color': AppColors.nutrition, 'done': 0, 'goal': 1, 'auto': false},
    {'name': 'Lunch', 'icon': Icons.lunch_dining_rounded, 'color': AppColors.nutrition, 'done': 0, 'goal': 1, 'auto': false},
    {'name': 'Dinner', 'icon': Icons.dinner_dining_rounded, 'color': AppColors.nutrition, 'done': 0, 'goal': 1, 'auto': false},
    {'name': 'Walk', 'icon': Icons.directions_walk_rounded, 'color': AppColors.movement, 'done': 0, 'goal': 1, 'auto': true},
    {'name': 'Stretch', 'icon': Icons.self_improvement_rounded, 'color': AppColors.mindfulness, 'done': 0, 'goal': 2, 'auto': false},
    {'name': 'Exercise', 'icon': Icons.fitness_center_rounded, 'color': AppColors.exercise, 'done': 0, 'goal': 1, 'auto': true},
    {'name': 'Sleep on time', 'icon': Icons.bedtime_rounded, 'color': AppColors.sleep, 'done': 0, 'goal': 1, 'auto': false},
  ];

  List<Map<String, dynamic>> _activities = [];

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  void _loadActivities() {
    if (_svc.tickActivities.isEmpty) {
      // First time: use defaults
      _activities = _defaultActivities.map((a) => Map<String, dynamic>.from(a)).toList();
      _svc.setTickActivities(_activities);
    } else {
      // Restore saved — re-attach icon/color (not serializable)
      _activities = _svc.tickActivities.map((saved) {
        final match = _defaultActivities.firstWhere(
          (d) => d['name'] == saved['name'],
          orElse: () => <String, dynamic>{},
        );
        if (match.isNotEmpty) {
          return {
            ...saved,
            'icon': match['icon'],
            'color': match['color'],
          };
        }
        // Custom activity — use stored code points
        return {
          ...saved,
          'icon': IconData(saved['iconCode'] ?? 0xe798, fontFamily: 'MaterialIcons'),
          'color': Color(saved['colorValue'] ?? 0xFF3B82F6),
        };
      }).toList();
    }
    setState(() {});
  }

  double get _completion {
    if (_activities.isEmpty) return 0;
    int c = _activities.where((a) => (a['done'] as int) >= (a['goal'] as int)).length;
    return c / _activities.length;
  }

  Future<void> _toggle(int i) async {
    final a = _activities[i];
    final done = a['done'] as int;
    final goal = a['goal'] as int;
    final newDone = done < goal ? done + 1 : 0;
    setState(() => a['done'] = newDone);
    await _svc.updateTickActivity(i, newDone);
  }

  void _showAddCustom() {
    final nameCtrl = TextEditingController();
    int goal = 1;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.dividerColor, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text('Add Custom Activity', style: AppTypography.h3(color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              onChanged: (_) => setSheetState(() {}),
              style: AppTypography.body(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Activity name',
                hintStyle: AppTypography.body(color: AppColors.textTertiary),
                filled: true, fillColor: AppColors.surfaceElevated,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Text('Daily goal: ', style: AppTypography.bodyMedium(color: AppColors.textSecondary)),
              ...[1, 2, 3, 5, 8].map((g) => GestureDetector(
                onTap: () => setSheetState(() => goal = g),
                child: Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: goal == g ? AppColors.primary.withValues(alpha: 0.2) : AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: goal == g ? AppColors.primary : Colors.transparent),
                  ),
                  child: Text('$g', style: AppTypography.bodySmall(color: goal == g ? AppColors.primary : AppColors.textTertiary)),
                ),
              )),
            ]),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: nameCtrl.text.trim().isEmpty ? null : () async {
                  final activity = {
                    'name': nameCtrl.text.trim(),
                    'icon': Icons.star_rounded,
                    'color': AppColors.primary,
                    'done': 0,
                    'goal': goal,
                    'auto': false,
                    'isCustom': true,
                    'iconCode': Icons.star_rounded.codePoint,
                    'colorValue': AppColors.primary.toARGB32(),
                  };
                  _activities.add(activity);
                  await _svc.setTickActivities(_activities);
                  if (mounted) setState(() {});
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('✅ Added: ${nameCtrl.text.trim()}'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  disabledBackgroundColor: AppColors.surfaceElevated,
                ),
                child: Text('Add Activity', style: AppTypography.button(color: Colors.white)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacing24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Daily Activities', style: AppTypography.h1(color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    Text('${(_completion * 100).toInt()}% complete', style: AppTypography.bodyLarge(color: AppColors.primary)),
                    const SizedBox(height: AppTheme.spacing12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: _completion,
                        minHeight: 8,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                        valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms),

              ...List.generate(_activities.length, (i) {
                final a = _activities[i];
                final done = a['done'] as int;
                final goal = a['goal'] as int;
                final complete = done >= goal;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing24, vertical: 4),
                  child: GestureDetector(
                    onTap: () => _toggle(i),
                    child: AnimatedContainer(
                      duration: 300.ms,
                      padding: const EdgeInsets.all(AppTheme.spacing16),
                      decoration: BoxDecoration(
                        color: complete ? AppColors.success.withValues(alpha: 0.06) : AppColors.surface,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        border: Border.all(color: complete ? AppColors.success.withValues(alpha: 0.25) : AppColors.cardBorder),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42, height: 42,
                            decoration: BoxDecoration(color: (a['color'] as Color).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                            child: Icon(a['icon'] as IconData, color: a['color'] as Color, size: 22),
                          ),
                          const SizedBox(width: AppTheme.spacing12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Text(a['name'] as String, style: AppTypography.bodyMedium(color: AppColors.textPrimary)),
                                  if (a['auto'] == true) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                                      child: Text('Auto', style: AppTypography.label(color: AppColors.primary).copyWith(fontSize: 9)),
                                    ),
                                  ],
                                ]),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(3),
                                  child: LinearProgressIndicator(
                                    value: goal > 0 ? (done / goal).clamp(0, 1).toDouble() : 0,
                                    minHeight: 4,
                                    backgroundColor: (a['color'] as Color).withValues(alpha: 0.1),
                                    valueColor: AlwaysStoppedAnimation(a['color'] as Color),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text('$done/$goal', style: AppTypography.bodyMedium(color: complete ? AppColors.success : AppColors.textSecondary)),
                          const SizedBox(width: 8),
                          Icon(complete ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                              color: complete ? AppColors.success : AppColors.textTertiary, size: 24),
                        ],
                      ),
                    ),
                  ),
                ).animate(delay: Duration(milliseconds: 150 + i * 60)).fadeIn(duration: 400.ms);
              }),

              const SizedBox(height: AppTheme.spacing24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing24),
                child: SizedBox(
                  width: double.infinity, height: 52,
                  child: OutlinedButton.icon(
                    onPressed: _showAddCustom,
                    icon: const Icon(Icons.add_rounded),
                    label: Text('Add Custom Activity', style: AppTypography.bodyMedium(color: AppColors.primaryLight)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMedium)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
