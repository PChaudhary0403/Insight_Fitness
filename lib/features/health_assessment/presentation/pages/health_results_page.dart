import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/health_profile.dart';

/// Displays the computed health analysis results and personalized roadmap.
class HealthResultsPage extends StatelessWidget {
  final HealthProfile profile;
  const HealthResultsPage({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final score = profile.overallHealthScore ?? 50;
    final scoreColors = AppColors.healthScoreGradient(score);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 40),
          child: Column(
            children: [
              const SizedBox(height: AppTheme.spacing24),
              // ─── Title ─────────────────────────────────
              Text('Your Health Analysis', style: AppTypography.h2(color: AppColors.darkTextPrimary))
                  .animate().fadeIn(duration: 500.ms),
              Text('Powered by INSIGHT Engine', style: AppTypography.caption(color: AppColors.darkTextTertiary))
                  .animate(delay: 200.ms).fadeIn(),
              const SizedBox(height: AppTheme.spacing24),

              // ─── Score Circle ──────────────────────────
              _buildScoreCircle(score, scoreColors),
              const SizedBox(height: AppTheme.spacing24),

              // ─── Metrics Grid ──────────────────────────
              _buildMetricsGrid(),
              const SizedBox(height: AppTheme.spacing20),

              // ─── Flags ─────────────────────────────────
              if (profile.flags.isNotEmpty) ...[
                _buildFlags(),
                const SizedBox(height: AppTheme.spacing20),
              ],

              // ─── Roadmap ───────────────────────────────
              _buildRoadmap(),
              const SizedBox(height: AppTheme.spacing32),

              // ─── CTA ───────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing24),
                child: SizedBox(
                  width: double.infinity, height: 56,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8))],
                    ),
                    child: ElevatedButton(
                      onPressed: () => context.go('/home'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusFull))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Start Your Journey', style: AppTypography.button(color: Colors.white)),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ).animate(delay: 800.ms).fadeIn().slideY(begin: 0.1, end: 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCircle(int score, List<Color> colors) {
    return CircularPercentIndicator(
      radius: 80, lineWidth: 12,
      percent: (score / 100).clamp(0.0, 1.0),
      center: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$score', style: AppTypography.score(color: colors[0])),
          Text('/100', style: AppTypography.caption(color: AppColors.darkTextTertiary)),
          const SizedBox(height: 2),
          Text(AppColors.healthScoreLabel(score), style: AppTypography.bodyMedium(color: colors[0])),
        ],
      ),
      progressColor: colors[0],
      backgroundColor: colors[0].withValues(alpha: 0.15),
      circularStrokeCap: CircularStrokeCap.round,
      animation: true, animationDuration: 1500,
    ).animate(delay: 300.ms).fadeIn().scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), curve: Curves.elasticOut);
  }

  Widget _buildMetricsGrid() {
    final metrics = [
      ('BMI', '${profile.bmi?.toStringAsFixed(1) ?? "—"}', profile.bmiCategory ?? '', _bmiColor()),
      ('Ideal Weight', '${profile.idealWeightLow?.toStringAsFixed(0) ?? "—"}-${profile.idealWeightHigh?.toStringAsFixed(0) ?? "—"} kg', '', AppColors.accent),
      ('Calories/Day', '${profile.estimatedCalorieNeeds?.toStringAsFixed(0) ?? "—"} kcal', '', AppColors.nutrition),
      ('Hydration', '${profile.hydrationRequirement?.toStringAsFixed(1) ?? "—"} L/day', '', AppColors.hydration),
      ('Sedentary Risk', '${profile.sedentaryRiskScore?.toStringAsFixed(1) ?? "—"}/10', '', _sedentaryColor()),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Health Metrics', style: AppTypography.h4(color: AppColors.darkTextPrimary)),
          const SizedBox(height: 12),
          ...metrics.asMap().entries.map((e) {
            final m = e.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.darkCardBorder),
              ),
              child: Row(
                children: [
                  Container(width: 4, height: 40, decoration: BoxDecoration(color: m.$4, borderRadius: BorderRadius.circular(2))),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(m.$1, style: AppTypography.caption(color: AppColors.darkTextSecondary)),
                    const SizedBox(height: 2),
                    Text(m.$2, style: AppTypography.h4(color: AppColors.darkTextPrimary)),
                  ])),
                  if (m.$3.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: m.$4.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                      child: Text(m.$3, style: AppTypography.caption(color: m.$4)),
                    ),
                ],
              ),
            ).animate(delay: (400 + e.key * 100).ms).fadeIn().slideX(begin: 0.05, end: 0);
          }),
        ],
      ),
    );
  }

  Widget _buildFlags() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Health Flags', style: AppTypography.h4(color: AppColors.darkTextPrimary)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: profile.flags.map((f) {
              final info = flagMap[f] ?? ('🔵 $f', AppColors.info);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
    ).animate(delay: 600.ms).fadeIn();
  }

  Widget _buildRoadmap() {
    if (profile.roadmap.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Improvement Roadmap', style: AppTypography.h4(color: AppColors.darkTextPrimary)),
          const SizedBox(height: 4),
          Text('Personalized plan based on your assessment', style: AppTypography.caption(color: AppColors.darkTextSecondary)),
          const SizedBox(height: 16),
          ...profile.roadmap.asMap().entries.map((e) {
            final item = e.value;
            final priorityColor = item.priority == 'high' ? AppColors.error : item.priority == 'medium' ? AppColors.warning : AppColors.info;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.darkCardBorder),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.icon, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(child: Text(item.title, style: AppTypography.bodyMedium(color: AppColors.darkTextPrimary))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: priorityColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                        child: Text(item.priority.toUpperCase(), style: AppTypography.caption(color: priorityColor)),
                      ),
                    ]),
                    const SizedBox(height: 6),
                    Text(item.description, style: AppTypography.bodySmall(color: AppColors.darkTextSecondary)),
                  ])),
                ],
              ),
            ).animate(delay: (700 + e.key * 100).ms).fadeIn().slideY(begin: 0.05, end: 0);
          }),
        ],
      ),
    );
  }

  Color _bmiColor() {
    final bmi = profile.bmi ?? 22;
    if (bmi < 18.5) return AppColors.warning;
    if (bmi < 25) return AppColors.success;
    if (bmi < 30) return AppColors.warning;
    return AppColors.error;
  }

  Color _sedentaryColor() {
    final risk = profile.sedentaryRiskScore ?? 5;
    if (risk <= 3) return AppColors.success;
    if (risk <= 6) return AppColors.warning;
    return AppColors.error;
  }
}
