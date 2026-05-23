import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_theme.dart';

/// Goals tracking page.
class GoalsPage extends StatelessWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        title: Text('My Goals', style: AppTypography.h3(color: AppColors.darkTextPrimary)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.darkTextPrimary), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacing24),
        child: Column(children: [
          _GoalCard(icon: '🎯', title: 'Lose 10 kg', progress: 0.62, detail: '-6.2 kg / -10 kg', streak: 14, eta: 'Jul 2026', color: AppColors.exercise)
              .animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0),
          const SizedBox(height: 12),
          _GoalCard(icon: '💧', title: 'Drink 3L/day', progress: 0.85, detail: '7-day avg: 2.55L', streak: 8, eta: 'Ongoing', color: AppColors.hydration)
              .animate(delay: 100.ms).fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0),
          const SizedBox(height: 12),
          _GoalCard(icon: '👟', title: '10K steps/day', progress: 0.48, detail: '7-day avg: 4,800', streak: 3, eta: 'Ongoing', color: AppColors.movement)
              .animate(delay: 200.ms).fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0),
          const SizedBox(height: 12),
          _GoalCard(icon: '🏋️', title: 'Exercise 5 days/week', progress: 0.60, detail: '3/5 this week', streak: 6, eta: 'Ongoing', color: AppColors.exercise)
              .animate(delay: 300.ms).fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0),
          const SizedBox(height: AppTheme.spacing24),
          SizedBox(
            width: double.infinity, height: 56,
            child: Container(
              decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(AppTheme.radiusFull)),
              child: ElevatedButton.icon(
                onPressed: () {},
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

class _GoalCard extends StatelessWidget {
  final String icon, title, detail, eta;
  final double progress;
  final int streak;
  final Color color;
  const _GoalCard({required this.icon, required this.title, required this.progress, required this.detail, required this.streak, required this.eta, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing20),
      decoration: BoxDecoration(color: AppColors.darkSurface, borderRadius: BorderRadius.circular(AppTheme.radiusMedium), border: Border.all(color: AppColors.darkCardBorder)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Expanded(child: Text(title, style: AppTypography.h4(color: AppColors.darkTextPrimary))),
          Text('${(progress * 100).toInt()}%', style: AppTypography.bodyMedium(color: color)),
        ]),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(value: progress, minHeight: 8, backgroundColor: color.withValues(alpha: 0.15), valueColor: AlwaysStoppedAnimation(color)),
        ),
        const SizedBox(height: 10),
        Row(children: [
          Text(detail, style: AppTypography.bodySmall(color: AppColors.darkTextSecondary)),
          const Spacer(),
          const Text('🔥', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text('$streak days', style: AppTypography.label(color: AppColors.darkTextSecondary)),
        ]),
        const SizedBox(height: 4),
        Text('Est: $eta', style: AppTypography.caption(color: AppColors.darkTextTertiary)),
      ]),
    );
  }
}
