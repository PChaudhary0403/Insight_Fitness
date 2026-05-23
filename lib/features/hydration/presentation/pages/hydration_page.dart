import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_theme.dart';

/// Hydration tracking page with wave animation and quick-add buttons.
class HydrationPage extends StatefulWidget {
  const HydrationPage({super.key});

  @override
  State<HydrationPage> createState() => _HydrationPageState();
}

class _HydrationPageState extends State<HydrationPage> {
  int _currentMl = 1750;
  final int _goalMl = 3000;

  void _addWater(int ml) {
    setState(() {
      _currentMl = (_currentMl + ml).clamp(0, 10000);
    });
  }

  @override
  Widget build(BuildContext context) {
    final percent = (_currentMl / _goalMl).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        title: Text('Hydration',
            style: AppTypography.h3(color: AppColors.darkTextPrimary)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: AppColors.darkTextPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacing24),
        child: Column(
          children: [
            // ─── Main Progress Ring ─────────────────────
            CircularPercentIndicator(
              radius: 100,
              lineWidth: 14,
              percent: percent,
              center: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.water_drop_rounded,
                      color: AppColors.hydration, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    '${_currentMl}ml',
                    style: AppTypography.metric(color: AppColors.darkTextPrimary),
                  ),
                  Text(
                    '/ ${_goalMl}ml',
                    style: AppTypography.caption(
                        color: AppColors.darkTextSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(percent * 100).toInt()}%',
                    style: AppTypography.bodyMedium(color: AppColors.hydration),
                  ),
                ],
              ),
              progressColor: AppColors.hydration,
              backgroundColor: AppColors.hydration.withValues(alpha: 0.15),
              circularStrokeCap: CircularStrokeCap.round,
              animation: true,
              animationDuration: 800,
            ).animate().fadeIn(duration: 600.ms).scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.0, 1.0),
                  duration: 600.ms,
                  curve: Curves.easeOut,
                ),

            const SizedBox(height: AppTheme.spacing32),

            // ─── Quick Add Buttons ──────────────────────
            Text('Quick Add',
                style:
                    AppTypography.h4(color: AppColors.darkTextPrimary))
                .animate(delay: 300.ms)
                .fadeIn(duration: 400.ms),

            const SizedBox(height: AppTheme.spacing16),

            Wrap(
              spacing: AppTheme.spacing12,
              runSpacing: AppTheme.spacing12,
              children: [
                _QuickAddButton(label: '250ml', ml: 250, onTap: () => _addWater(250)),
                _QuickAddButton(label: '500ml', ml: 500, onTap: () => _addWater(500)),
                _QuickAddButton(label: '750ml', ml: 750, onTap: () => _addWater(750)),
                _QuickAddButton(label: '1L', ml: 1000, onTap: () => _addWater(1000)),
              ],
            ).animate(delay: 400.ms).fadeIn(duration: 400.ms),

            const SizedBox(height: AppTheme.spacing32),

            // ─── Today's Log ────────────────────────────
            Container(
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
                  Text("Today's Log",
                      style: AppTypography.h4(
                          color: AppColors.darkTextPrimary)),
                  const SizedBox(height: AppTheme.spacing16),
                  _LogEntry(time: '09:00 AM', amount: '500ml', icon: Icons.water_drop_rounded),
                  _LogEntry(time: '10:30 AM', amount: '250ml', icon: Icons.coffee_rounded),
                  _LogEntry(time: '12:00 PM', amount: '500ml', icon: Icons.water_drop_rounded),
                  _LogEntry(time: '02:00 PM', amount: '500ml', icon: Icons.water_drop_rounded),
                ],
              ),
            ).animate(delay: 500.ms).fadeIn(duration: 500.ms),
          ],
        ),
      ),
    );
  }
}

class _QuickAddButton extends StatelessWidget {
  final String label;
  final int ml;
  final VoidCallback onTap;

  const _QuickAddButton({
    required this.label,
    required this.ml,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing16),
        decoration: BoxDecoration(
          color: AppColors.hydration.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(color: AppColors.hydration.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(Icons.water_drop_rounded,
                color: AppColors.hydration, size: 20),
            const SizedBox(height: 4),
            Text(label,
                style: AppTypography.bodyMedium(color: AppColors.hydration)),
          ],
        ),
      ),
    );
  }
}

class _LogEntry extends StatelessWidget {
  final String time;
  final String amount;
  final IconData icon;

  const _LogEntry({
    required this.time,
    required this.amount,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacing12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.hydration, size: 18),
          const SizedBox(width: AppTheme.spacing12),
          Text(time,
              style:
                  AppTypography.bodySmall(color: AppColors.darkTextSecondary)),
          const Spacer(),
          Text(amount,
              style:
                  AppTypography.bodyMedium(color: AppColors.darkTextPrimary)),
        ],
      ),
    );
  }
}
