import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/services/user_data_service.dart';
import '../../../../shared/services/planner_service.dart';
import '../../../health_assessment/presentation/widgets/transformation_card.dart';

/// Main dashboard / home page — reads ALL data from UserDataService + PlannerService.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final data = UserDataService.instance;
    final planner = PlannerService.instance;
    final int healthScore = data.healthScore;
    final scoreColors = AppColors.healthScoreGradient(healthScore);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Header ─────────────────────────────────
              _buildHeader(data, scoreColors)
                  .animate()
                  .fadeIn(duration: 500.ms),

              const SizedBox(height: AppTheme.spacing16),

              // ─── Live Date & Time ────────────────────────
              _DateTimeBox()
                  .animate(delay: 150.ms)
                  .fadeIn(duration: 400.ms),

              const SizedBox(height: AppTheme.spacing20),

              // ─── Health Score Card ──────────────────────
              _buildHealthScoreCard(data, healthScore, scoreColors)
                  .animate(delay: 200.ms)
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: 0.05, end: 0),

              const SizedBox(height: AppTheme.spacing20),

              // ─── Quick Actions ──────────────────────────
              _buildQuickActions(context)
                  .animate(delay: 300.ms)
                  .fadeIn(duration: 400.ms),

              const SizedBox(height: AppTheme.spacing20),

              // ─── Transformation Tracking ─────────────────
              TransformationCard(profile: data.profile)
                  .animate(delay: 350.ms)
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: 0.05, end: 0),

              const SizedBox(height: AppTheme.spacing20),

              // ─── Discipline Shortcut ────────────────────
              _buildDisciplineCard(context)
                  .animate(delay: 380.ms)
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: 0.05, end: 0),

              const SizedBox(height: AppTheme.spacing20),

              // ─── Quick Exercise Card ─────────────────────
              _buildQuickExerciseCard(context, data)
                  .animate(delay: 390.ms)
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: 0.05, end: 0),

              const SizedBox(height: AppTheme.spacing20),

              // ─── Daily Progress Summary ────────────────────
              _buildDailyProgressCard(context, planner)
                  .animate(delay: 393.ms)
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: 0.05, end: 0),

              const SizedBox(height: AppTheme.spacing20),

              // ─── Daily Planner Card ──────────────────────
              _buildPlannerCard(context, planner)
                  .animate(delay: 395.ms)
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: 0.05, end: 0),

              const SizedBox(height: AppTheme.spacing20),

              // ─── Screen Time Card ────────────────────────
              _buildScreenTimeCard(context)
                  .animate(delay: 397.ms)
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: 0.05, end: 0),

              const SizedBox(height: AppTheme.spacing20),

              // ─── Stats Grid ─────────────────────────────
              _buildStatsGrid(context, data)
                  .animate(delay: 400.ms)
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: 0.05, end: 0),

              const SizedBox(height: AppTheme.spacing20),

              // ─── Streak Card ────────────────────────────
              _buildStreakCard(data)
                  .animate(delay: 500.ms)
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: 0.05, end: 0),

              const SizedBox(height: AppTheme.spacing20),

              // ─── BMI Card ───────────────────────────────
              _buildBMICard(data)
                  .animate(delay: 600.ms)
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: 0.05, end: 0),

              // ─── Health Flags ───────────────────────────
              if (data.profile != null && data.profile!.flags.isNotEmpty) ...[
                const SizedBox(height: AppTheme.spacing20),
                _buildHealthFlags(data)
                    .animate(delay: 700.ms)
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.05, end: 0),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(UserDataService data, List<Color> scoreColors) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacing24,
        AppTheme.spacing16,
        AppTheme.spacing24,
        0,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scoreColors[0].withValues(alpha: 0.15),
            AppColors.bg,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting(),
                  style: AppTypography.bodyLarge(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.userName.split(' ').first, // First name only
                  style: AppTypography.h1(color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
            ),
            child: Center(
              child: Text(data.userInitial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  )),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthScoreCard(UserDataService data, int score, List<Color> colors) {
    final daysSince = data.daysSinceJoining;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppTheme.spacing24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colors[0].withValues(alpha: 0.2),
              colors[1].withValues(alpha: 0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: Border.all(
            color: colors[0].withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            CircularPercentIndicator(
              radius: 50,
              lineWidth: 8,
              percent: (score / 100).clamp(0.0, 1.0),
              center: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$score',
                    style: AppTypography.metric(color: colors[0]),
                  ),
                  Text(
                    '/100',
                    style: AppTypography.caption(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
              progressColor: colors[0],
              backgroundColor: colors[0].withValues(alpha: 0.15),
              circularStrokeCap: CircularStrokeCap.round,
              animation: true,
              animationDuration: 1200,
            ),
            const SizedBox(width: AppTheme.spacing24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Health Score',
                    style: AppTypography.caption(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppColors.healthScoreLabel(score),
                    style: AppTypography.h2(color: colors[0]),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        daysSince == 0
                            ? Icons.fiber_new_rounded
                            : Icons.calendar_today_rounded,
                        color: AppColors.textTertiary,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        daysSince == 0
                            ? 'Just started today'
                            : 'Day $daysSince of your journey',
                        style: AppTypography.bodySmall(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing24),
      child: Row(
        children: [
          _QuickAction(
            icon: Icons.water_drop_rounded,
            label: 'Add Water',
            color: AppColors.hydration,
            onTap: () => context.push('/hydration'),
          ),
          const SizedBox(width: AppTheme.spacing12),
          _QuickAction(
            icon: Icons.restaurant_rounded,
            label: 'Log Meal',
            color: AppColors.nutrition,
            onTap: () => context.push('/diet'),
          ),
          const SizedBox(width: AppTheme.spacing12),
          _QuickAction(
            icon: Icons.directions_run_rounded,
            label: 'Exercise',
            color: AppColors.exercise,
            onTap: () => context.push('/activity'),
          ),
          const SizedBox(width: AppTheme.spacing12),
          _QuickAction(
            icon: Icons.shield_rounded,
            label: 'Discipline',
            color: AppColors.secondary,
            onTap: () => context.push('/discipline'),
          ),
        ],
      ),
    );
  }

  Widget _buildDisciplineCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing24),
      child: GestureDetector(
        onTap: () => context.push('/discipline'),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppTheme.spacing20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.12),
                AppColors.secondary.withValues(alpha: 0.06),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.shield_rounded, color: AppColors.secondary, size: 24),
              ),
              const SizedBox(width: AppTheme.spacing16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Discipline Tracker', style: AppTypography.h4(color: AppColors.textPrimary)),
                    const SizedBox(height: 2),
                    Text('Set commitments & build streaks', style: AppTypography.bodySmall(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, UserDataService data) {
    final hydrationTarget = data.hydrationTarget;
    final waterDone = data.dailyWaterL;
    final mealsDone = data.dailyMeals;
    final stepsDone = data.dailySteps;
    final exerciseDone = data.dailyExerciseMin;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing24),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.water_drop_rounded,
                  label: 'Hydration',
                  value: '${waterDone.toStringAsFixed(1)}L',
                  target: '/ ${hydrationTarget.toStringAsFixed(1)}L',
                  percent: hydrationTarget > 0 ? (waterDone / hydrationTarget) : 0,
                  color: AppColors.hydration,
                  onTap: () => context.push('/hydration'),
                ),
              ),
              const SizedBox(width: AppTheme.spacing12),
              Expanded(
                child: _StatCard(
                  icon: Icons.restaurant_rounded,
                  label: 'Meals',
                  value: '$mealsDone',
                  target: '/ 4',
                  percent: mealsDone / 4,
                  color: AppColors.nutrition,
                  onTap: () => context.push('/diet'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.directions_walk_rounded,
                  label: 'Steps',
                  value: _formatSteps(stepsDone),
                  target: '/ 10,000',
                  percent: stepsDone / 10000,
                  color: AppColors.movement,
                  onTap: () => context.push('/activity'),
                ),
              ),
              const SizedBox(width: AppTheme.spacing12),
              Expanded(
                child: _StatCard(
                  icon: Icons.fitness_center_rounded,
                  label: 'Exercise',
                  value: '${exerciseDone}min',
                  target: 'today',
                  percent: exerciseDone / 45,
                  color: AppColors.exercise,
                  onTap: () => context.push('/activity'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatSteps(int steps) {
    if (steps >= 1000) return '${(steps / 1000).toStringAsFixed(1)}k';
    return '$steps';
  }

  Widget _buildStreakCard(UserDataService data) {
    final streak = data.currentStreak;
    final best = data.bestStreak;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppTheme.spacing20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B35).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text('🔥', style: TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: AppTheme.spacing16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    streak == 0 ? 'Start Your Streak!' : '$streak Day Streak',
                    style: AppTypography.h4(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    streak == 0
                        ? 'Complete today\'s goals to begin 💪'
                        : 'Best: $best days  •  Keep it going! 💪',
                    style: AppTypography.bodySmall(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBMICard(UserDataService data) {
    final bmi = data.bmi;
    final category = data.bmiCategory;
    final Color bmiColor;
    String statusLabel;

    if (bmi < 18.5) {
      bmiColor = AppColors.warning;
      statusLabel = 'Underweight';
    } else if (bmi < 25) {
      bmiColor = AppColors.success;
      statusLabel = 'Normal';
    } else if (bmi < 30) {
      bmiColor = AppColors.warning;
      statusLabel = 'Overweight';
    } else {
      bmiColor = AppColors.error;
      statusLabel = 'Obese';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppTheme.spacing20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: bmiColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.monitor_weight_rounded,
                color: bmiColor,
                size: 24,
              ),
            ),
            const SizedBox(width: AppTheme.spacing16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BMI: ${bmi.toStringAsFixed(1)}',
                    style: AppTypography.h4(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$category — $statusLabel',
                    style: AppTypography.bodySmall(color: bmiColor),
                  ),
                ],
              ),
            ),
            if (data.profile != null)
              Text(
                '${data.profile!.weightKg.toStringAsFixed(0)} kg',
                style: AppTypography.bodyMedium(color: AppColors.textSecondary),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthFlags(UserDataService data) {
    final flagMap = {
      'underweight': ('Underweight', AppColors.warning),
      'overweight': ('Overweight', AppColors.warning),
      'obese': ('Obese', AppColors.error),
      'sedentary': ('Sedentary', AppColors.error),
      'low_activity': ('Low Activity', AppColors.warning),
      'moderately_active': ('Moderately Active', AppColors.success),
      'highly_active': ('Highly Active', AppColors.success),
      'dehydrated': ('Dehydrated', AppColors.hydration),
      'irregular_lifestyle': ('Irregular Lifestyle', AppColors.sleep),
      'high_stress': ('High Stress', AppColors.error),
      'smoking_risk': ('Smoking Risk', AppColors.error),
      'alcohol_risk': ('Alcohol Risk', AppColors.warning),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppTheme.spacing20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Health Flags',
              style: AppTypography.h4(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: data.profile!.flags.map((f) {
                final info = flagMap[f] ?? ('$f', AppColors.info);
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: info.$2.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: info.$2.withValues(alpha: 0.3)),
                  ),
                  child: Text(info.$1, style: AppTypography.bodySmall(color: info.$2)),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickExerciseCard(BuildContext context, UserDataService data) {
    final hasExercise = data.dailyExerciseCount > 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing24),
      child: GestureDetector(
        onTap: () async {
          await context.push('/activity');
          if (mounted) setState(() {});
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppTheme.spacing16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.exercise.withValues(alpha: 0.12), AppColors.movement.withValues(alpha: 0.06)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.exercise.withValues(alpha: 0.25)),
          ),
          child: Row(children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: AppColors.exercise.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.fitness_center_rounded, color: AppColors.exercise, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Exercise Log', style: AppTypography.bodyMedium(color: AppColors.textPrimary)),
              Text(
                hasExercise
                    ? '${data.dailyExerciseCount} exercise${data.dailyExerciseCount > 1 ? "s" : ""} • ${data.dailyTotalSets} sets • ${data.dailyCaloriesBurned} cal'
                    : 'No exercise today — tap to log',
                style: AppTypography.caption(color: hasExercise ? AppColors.textSecondary : AppColors.warning),
              ),
            ])),
            Icon(hasExercise ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
              color: hasExercise ? AppColors.success : AppColors.exercise, size: 28),
          ]),
        ),
      ),
    );
  }

  Widget _buildDailyProgressCard(BuildContext context, PlannerService planner) {
    final plan = planner.todayPlan;
    final tasks = planner.tasks;
    final completed = plan.completedCount;
    final total = plan.totalTasks;
    final tickPct = (planner.tickCompletionRate * 100).round();
    final prodScore = planner.productivityScore;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppTheme.spacing16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary.withValues(alpha: 0.08), AppColors.secondary.withValues(alpha: 0.04)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('📊 Today\'s Progress', style: AppTypography.h4(color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          Row(children: [
            _ProgressChip('Tasks', total > 0 ? '$completed/$total' : '—', AppColors.info, total > 0 ? completed / total : 0),
            const SizedBox(width: 8),
            _ProgressChip('Activities', '$tickPct%', AppColors.success, planner.tickCompletionRate),
            const SizedBox(width: 8),
            _ProgressChip('Productivity', '$prodScore', AppColors.warning, prodScore / 100),
          ]),
        ]),
      ),
    );
  }

  Widget _buildPlannerCard(BuildContext context, PlannerService planner) {
    final plan = planner.todayPlan;
    final tasks = planner.tasks;
    final hasProgress = tasks.isNotEmpty;
    final subtitle = hasProgress
        ? '${plan.completedCount}/${plan.totalTasks} tasks done • ${plan.earnedPoints} pts'
        : 'Plan tasks, track productivity, earn points';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing24),
      child: GestureDetector(
        onTap: () async {
          await context.push('/planner');
          if (mounted) setState(() {});
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppTheme.spacing16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.info.withValues(alpha: 0.12), AppColors.secondary.withValues(alpha: 0.06)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.info.withValues(alpha: 0.25)),
          ),
          child: Row(children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: AppColors.info.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.calendar_today_rounded, color: AppColors.info, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Daily Planner', style: AppTypography.bodyMedium(color: AppColors.textPrimary)),
              Text(subtitle, style: AppTypography.caption(color: AppColors.textSecondary)),
            ])),
            if (hasProgress)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: AppColors.info.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                child: Text('${(plan.completionRate * 100).round()}%', style: AppTypography.caption(color: AppColors.info)),
              )
            else
              const Icon(Icons.chevron_right_rounded, color: AppColors.info, size: 24),
          ]),
        ),
      ),
    );
  }
  Widget _buildScreenTimeCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing24),
      child: GestureDetector(
        onTap: () async {
          await context.push('/screen-time');
          if (mounted) setState(() {});
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppTheme.spacing16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.sleep.withValues(alpha: 0.12), AppColors.mindfulness.withValues(alpha: 0.06)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.sleep.withValues(alpha: 0.25)),
          ),
          child: Row(children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: AppColors.sleep.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.screen_lock_portrait_rounded, color: AppColors.sleep, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Digital Wellness', style: AppTypography.bodyMedium(color: AppColors.textPrimary)),
              Text('Screen time, focus & wellness score', style: AppTypography.caption(color: AppColors.textSecondary)),
            ])),
            const Icon(Icons.chevron_right_rounded, color: AppColors.sleep, size: 24),
          ]),
        ),
      ),
    );
  }
}

// ─── Reusable Widgets ────────────────────────────────────────

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 6),
              Text(
                label,
                style: AppTypography.label(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String target;
  final double percent;
  final Color color;
  final VoidCallback onTap;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.target,
    required this.percent,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 6),
                Text(label,
                    style: AppTypography.caption(
                        color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: AppTheme.spacing12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(value, style: AppTypography.h3(color: AppColors.textPrimary)),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(target,
                      style: AppTypography.caption(
                          color: AppColors.textTertiary)),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacing8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percent.clamp(0, 1),
                minHeight: 6,
                backgroundColor: color.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateTimeBox extends StatefulWidget {
  const _DateTimeBox();
  @override
  State<_DateTimeBox> createState() => _DateTimeBoxState();
}

class _DateTimeBoxState extends State<_DateTimeBox> {
  late DateTime _now;

  static const _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now()).listen((dt) {
      if (mounted) setState(() => _now = dt);
    });
  }

  @override
  Widget build(BuildContext context) {
    final h = _now.hour;
    final iconData = h < 6 ? Icons.nightlight_round : h < 12 ? Icons.wb_sunny_rounded : h < 17 ? Icons.wb_cloudy_rounded : h < 20 ? Icons.wb_twilight_rounded : Icons.nightlight_round;
    final hour12 = _now.hour % 12 == 0 ? 12 : _now.hour % 12;
    final ampm = _now.hour < 12 ? 'AM' : 'PM';
    final time = '$hour12:${_now.minute.toString().padLeft(2, '0')}:${_now.second.toString().padLeft(2, '0')} $ampm';
    final date = '${_days[_now.weekday - 1]}, ${_now.day} ${_months[_now.month - 1]} ${_now.year}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.secondary.withValues(alpha: 0.10), AppColors.primary.withValues(alpha: 0.06)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.secondary.withValues(alpha: 0.18)),
        ),
        child: Row(
          children: [
            Icon(iconData, color: AppColors.secondary, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(time, style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22, fontWeight: FontWeight.w700,
                    fontFeatures: [FontFeature.tabularFigures()],
                  )),
                  Text(date, style: AppTypography.caption(color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressChip extends StatelessWidget {
  final String label, value;
  final Color color;
  final double progress;
  const _ProgressChip(this.label, this.value, this.color, this.progress);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: AppTypography.caption(color: AppColors.textTertiary)),
          const SizedBox(height: 4),
          Text(value, style: AppTypography.h4(color: color)),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress.clamp(0, 1),
              minHeight: 3,
              backgroundColor: color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ]),
      ),
    );
  }
}