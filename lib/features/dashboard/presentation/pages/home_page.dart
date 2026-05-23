import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/services/user_data_service.dart';
import '../../../health_assessment/presentation/widgets/transformation_card.dart';

/// Main dashboard / home page — reads ALL data from UserDataService.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final data = UserDataService.instance;
    final int healthScore = data.healthScore;
    final scoreColors = AppColors.healthScoreGradient(healthScore);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
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

              const SizedBox(height: AppTheme.spacing24),

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
            AppColors.darkBackground,
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
                  '${_greeting()} 👋',
                  style: AppTypography.bodyLarge(
                    color: AppColors.darkTextSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.userName.split(' ').first, // First name only
                  style: AppTypography.h1(color: AppColors.darkTextPrimary),
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
                      color: AppColors.darkTextTertiary,
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
                      color: AppColors.darkTextSecondary,
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
                        color: AppColors.darkTextTertiary,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        daysSince == 0
                            ? 'Just started today'
                            : 'Day $daysSince of your journey',
                        style: AppTypography.bodySmall(
                          color: AppColors.darkTextSecondary,
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
                    Text('Discipline Tracker', style: AppTypography.h4(color: AppColors.darkTextPrimary)),
                    const SizedBox(height: 2),
                    Text('Set commitments & build streaks', style: AppTypography.bodySmall(color: AppColors.darkTextSecondary)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.darkTextTertiary),
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
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(color: AppColors.darkCardBorder),
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
                    style: AppTypography.h4(color: AppColors.darkTextPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    streak == 0
                        ? 'Complete today\'s goals to begin 💪'
                        : 'Best: $best days  •  Keep it going! 💪',
                    style: AppTypography.bodySmall(
                      color: AppColors.darkTextSecondary,
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
    final String emoji;

    if (bmi < 18.5) {
      bmiColor = AppColors.warning;
      emoji = '⚠️';
    } else if (bmi < 25) {
      bmiColor = AppColors.success;
      emoji = '✅';
    } else if (bmi < 30) {
      bmiColor = AppColors.warning;
      emoji = '⚠️';
    } else {
      bmiColor = AppColors.error;
      emoji = '🔴';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppTheme.spacing20),
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(color: AppColors.darkCardBorder),
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
                    style: AppTypography.h4(color: AppColors.darkTextPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$category $emoji',
                    style: AppTypography.bodySmall(color: bmiColor),
                  ),
                ],
              ),
            ),
            if (data.profile != null)
              Text(
                '${data.profile!.weightKg.toStringAsFixed(0)} kg',
                style: AppTypography.bodyMedium(color: AppColors.darkTextSecondary),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthFlags(UserDataService data) {
    final flagMap = {
      'underweight': ('⚠️ Underweight', AppColors.warning),
      'overweight': ('⚠️ Overweight', AppColors.warning),
      'obese': ('🔴 Obese', AppColors.error),
      'sedentary': ('🪑 Sedentary', AppColors.error),
      'low_activity': ('🚶 Low Activity', AppColors.warning),
      'moderately_active': ('🏃 Moderately Active', AppColors.success),
      'highly_active': ('💪 Highly Active', AppColors.success),
      'dehydrated': ('💧 Dehydrated', AppColors.hydration),
      'irregular_lifestyle': ('🌙 Irregular Lifestyle', AppColors.sleep),
      'high_stress': ('😰 High Stress', AppColors.error),
      'smoking_risk': ('🚬 Smoking Risk', AppColors.error),
      'alcohol_risk': ('🍺 Alcohol Risk', AppColors.warning),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppTheme.spacing20),
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(color: AppColors.darkCardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Health Flags',
              style: AppTypography.h4(color: AppColors.darkTextPrimary),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: data.profile!.flags.map((f) {
                final info = flagMap[f] ?? ('🔵 $f', AppColors.info);
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
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(color: AppColors.darkCardBorder),
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
                        color: AppColors.darkTextSecondary)),
              ],
            ),
            const SizedBox(height: AppTheme.spacing12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(value, style: AppTypography.h3(color: AppColors.darkTextPrimary)),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(target,
                      style: AppTypography.caption(
                          color: AppColors.darkTextTertiary)),
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
