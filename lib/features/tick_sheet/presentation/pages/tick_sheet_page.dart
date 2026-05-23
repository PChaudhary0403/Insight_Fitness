import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_theme.dart';

/// Daily activity tick sheet page.
class TickSheetPage extends StatefulWidget {
  const TickSheetPage({super.key});

  @override
  State<TickSheetPage> createState() => _TickSheetPageState();
}

class _TickSheetPageState extends State<TickSheetPage> {
  final List<Map<String, dynamic>> _activities = [
    {'name': 'Drink water', 'icon': Icons.water_drop_rounded, 'color': AppColors.hydration, 'done': 0, 'goal': 8, 'auto': false},
    {'name': 'Breakfast', 'icon': Icons.breakfast_dining_rounded, 'color': AppColors.nutrition, 'done': 0, 'goal': 1, 'auto': false},
    {'name': 'Lunch', 'icon': Icons.lunch_dining_rounded, 'color': AppColors.nutrition, 'done': 0, 'goal': 1, 'auto': false},
    {'name': 'Dinner', 'icon': Icons.dinner_dining_rounded, 'color': AppColors.nutrition, 'done': 0, 'goal': 1, 'auto': false},
    {'name': 'Walk', 'icon': Icons.directions_walk_rounded, 'color': AppColors.movement, 'done': 0, 'goal': 1, 'auto': true},
    {'name': 'Stretch', 'icon': Icons.self_improvement_rounded, 'color': AppColors.mindfulness, 'done': 0, 'goal': 2, 'auto': false},
    {'name': 'Exercise', 'icon': Icons.fitness_center_rounded, 'color': AppColors.exercise, 'done': 0, 'goal': 1, 'auto': true},
    {'name': 'Sleep on time', 'icon': Icons.bedtime_rounded, 'color': AppColors.sleep, 'done': 0, 'goal': 1, 'auto': false},
  ];

  double get _completion {
    int c = _activities.where((a) => (a['done'] as int) >= (a['goal'] as int)).length;
    return c / _activities.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
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
                    Text('Daily Activities', style: AppTypography.h1(color: AppColors.darkTextPrimary)),
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
                    onTap: () => setState(() => a['done'] = done < goal ? done + 1 : 0),
                    child: AnimatedContainer(
                      duration: 300.ms,
                      padding: const EdgeInsets.all(AppTheme.spacing16),
                      decoration: BoxDecoration(
                        color: complete ? AppColors.success.withValues(alpha: 0.06) : AppColors.darkSurface,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        border: Border.all(color: complete ? AppColors.success.withValues(alpha: 0.25) : AppColors.darkCardBorder),
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
                                  Text(a['name'] as String, style: AppTypography.bodyMedium(color: AppColors.darkTextPrimary)),
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
                          Text('$done/$goal', style: AppTypography.bodyMedium(color: complete ? AppColors.success : AppColors.darkTextSecondary)),
                          const SizedBox(width: 8),
                          Icon(complete ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                              color: complete ? AppColors.success : AppColors.darkTextTertiary, size: 24),
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
                    onPressed: () {},
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
