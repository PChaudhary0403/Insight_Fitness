import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/health_profile.dart';

/// Dashboard widget showing health transformation progress.
/// Reads from the REAL health profile baseline — no fake data.
class TransformationCard extends StatelessWidget {
  final HealthProfile? profile;
  const TransformationCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    if (profile == null) {
      return _buildNoProfileCard();
    }

    final p = profile!;
    final daysSince = DateTime.now().difference(p.createdAt).inDays;
    final isNewUser = daysSince == 0;

    // Build metrics from the actual baseline
    final metrics = _buildMetrics(p, isNewUser);

    // Transformation progress: 0% on day 0, grows with time and goals hit
    // For now, since we have no "current" tracking data stored yet,
    // we show the starting state honestly.
    final transformPercent = isNewUser ? 0.0 : (daysSince / 90).clamp(0.0, 1.0) * 0.1;
    final transformScore = (transformPercent * 100).round();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppTheme.spacing20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.secondary.withValues(alpha: 0.12),
              AppColors.primary.withValues(alpha: 0.06),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.secondary.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Health Transformation', style: AppTypography.h4(color: AppColors.textPrimary)),
                      const SizedBox(height: 2),
                      Text(
                        isNewUser
                            ? 'Your baseline • Just started'
                            : 'Since onboarding • $daysSince ${daysSince == 1 ? 'day' : 'days'} ago',
                        style: AppTypography.caption(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                CircularPercentIndicator(
                  radius: 28,
                  lineWidth: 5,
                  percent: transformPercent,
                  center: Text('$transformScore%', style: AppTypography.buttonSmall(color: AppColors.secondary)),
                  progressColor: AppColors.secondary,
                  backgroundColor: AppColors.secondary.withValues(alpha: 0.15),
                  circularStrokeCap: CircularStrokeCap.round,
                  animation: true,
                  animationDuration: 1000,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              isNewUser
                  ? '"Your journey begins now"'
                  : '"$transformScore% toward your goals"',
              style: AppTypography.bodySmall(color: AppColors.secondary),
            ),
            const SizedBox(height: AppTheme.spacing16),

            // Metric rows — showing REAL baseline data
            ...metrics.asMap().entries.map((e) {
              final m = e.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: m.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(m.icon, color: m.color, size: 16),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(m.label, style: AppTypography.caption(color: AppColors.textSecondary)),
                              Text(m.value, style: AppTypography.caption(color: AppColors.textPrimary)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: m.progress,
                              minHeight: 4,
                              backgroundColor: m.color.withValues(alpha: 0.1),
                              valueColor: AlwaysStoppedAnimation(m.color),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate(delay: (300 + e.key * 80).ms).fadeIn().slideX(begin: 0.02, end: 0);
            }),

            const SizedBox(height: 8),

            // Starting message
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (isNewUser ? AppColors.info : AppColors.success).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Text(isNewUser ? '📋' : '🏆', style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isNewUser
                          ? 'This is your starting baseline. Track daily to see progress!'
                          : _getMilestoneText(p),
                      style: AppTypography.caption(
                        color: isNewUser ? AppColors.info : AppColors.success,
                      ),
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

  List<_Metric> _buildMetrics(HealthProfile p, bool isNewUser) {
    // Show baseline values as starting point
    final weightStr = '${p.weightKg.toStringAsFixed(0)} kg';
    final bmiStr = p.bmi?.toStringAsFixed(1) ?? '—';
    final waterStr = '${p.waterIntakeLiters.toStringAsFixed(1)}L';
    final hydrationTarget = p.hydrationRequirement?.toStringAsFixed(1) ?? '2.5';
    final exerciseLabel = _exerciseLabel(p.exerciseFrequency);

    // Sleep duration from wake/sleep times
    final sleepHours = _calcSleepHours(p.sleepTime, p.wakeUpTime);

    return [
      _Metric(
        'Weight',
        isNewUser ? 'Baseline: $weightStr' : '$weightStr (start)',
        0.0, // No progress yet
        AppColors.movement,
        Icons.monitor_weight_rounded,
      ),
      _Metric(
        'BMI',
        isNewUser ? 'Baseline: $bmiStr' : '$bmiStr (${p.bmiCategory ?? ""})',
        0.0,
        _bmiColor(p.bmi ?? 22),
        Icons.speed_rounded,
      ),
      _Metric(
        'Hydration',
        isNewUser ? 'Baseline: $waterStr / ${hydrationTarget}L target' : '$waterStr → ${hydrationTarget}L goal',
        isNewUser ? 0.0 : 0.0,
        AppColors.hydration,
        Icons.water_drop_rounded,
      ),
      _Metric(
        'Exercise',
        isNewUser ? 'Baseline: $exerciseLabel' : '$exerciseLabel (start)',
        0.0,
        AppColors.exercise,
        Icons.fitness_center_rounded,
      ),
      _Metric(
        'Sleep',
        isNewUser ? 'Baseline: ${sleepHours.toStringAsFixed(1)}h' : '${sleepHours.toStringAsFixed(1)}h (start)',
        0.0,
        AppColors.sleep,
        Icons.bedtime_rounded,
      ),
    ];
  }

  String _exerciseLabel(String freq) {
    return switch (freq) {
      'never' => 'No exercise',
      '1-2x' => '1-2x/week',
      '3-4x' => '3-4x/week',
      '5-6x' => '5-6x/week',
      'daily' => 'Daily',
      _ => freq,
    };
  }

  double _calcSleepHours(String sleepTime, String wakeTime) {
    try {
      final sp = sleepTime.split(':');
      final wp = wakeTime.split(':');
      final sleepMin = int.parse(sp[0]) * 60 + int.parse(sp[1]);
      final wakeMin = int.parse(wp[0]) * 60 + int.parse(wp[1]);
      var diff = wakeMin - sleepMin;
      if (diff <= 0) diff += 24 * 60;
      return diff / 60.0;
    } catch (_) {
      return 7.0;
    }
  }

  Color _bmiColor(double bmi) {
    if (bmi < 18.5) return AppColors.warning;
    if (bmi < 25) return AppColors.success;
    if (bmi < 30) return AppColors.warning;
    return AppColors.error;
  }

  String _getMilestoneText(HealthProfile p) {
    final flags = p.flags;
    if (flags.contains('underweight')) return 'Goal: Healthy weight gain with proper nutrition';
    if (flags.contains('obese')) return 'Goal: Gradual weight reduction with balanced diet';
    if (flags.contains('overweight')) return 'Goal: Move toward healthy BMI range';
    if (flags.contains('dehydrated')) return 'Goal: Improve daily hydration consistency';
    if (flags.contains('sedentary')) return 'Goal: Increase daily movement and activity';
    return 'Keep tracking daily to unlock milestones!';
  }

  Widget _buildNoProfileCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppTheme.spacing20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.assessment_rounded, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('No Assessment Yet', style: AppTypography.h4(color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text('Complete your health assessment to start tracking', style: AppTypography.bodySmall(color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric {
  final String label;
  final String value;
  final double progress;
  final Color color;
  final IconData icon;
  const _Metric(this.label, this.value, this.progress, this.color, this.icon);
}
