import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/screen_time_models.dart';

// ─── Wellness Score Ring ─────────────────────────────────────
class WellnessScoreRing extends StatelessWidget {
  final DigitalWellnessScore score;
  const WellnessScoreRing({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    final color = _scoreColor(score.score);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0.05)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(children: [
        SizedBox(
          width: 140, height: 140,
          child: Stack(alignment: Alignment.center, children: [
            SizedBox(
              width: 140, height: 140,
              child: CircularProgressIndicator(
                value: score.score / 100,
                strokeWidth: 10,
                backgroundColor: color.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation(color),
                strokeCap: StrokeCap.round,
              ),
            ),
            Column(mainAxisSize: MainAxisSize.min, children: [
              Text('${score.score}', style: AppTypography.score(color: color)),
              Text('/100', style: AppTypography.caption(color: AppColors.textTertiary)),
            ]),
          ]),
        ),
        const SizedBox(height: 12),
        Text(score.label, style: AppTypography.h3(color: color)),
        const SizedBox(height: 4),
        Text('Digital Wellness Score', style: AppTypography.caption(color: AppColors.textSecondary)),
        const SizedBox(height: 16),
        _ScoreBreakdown(score: score, color: color),
      ]),
    );
  }

  Color _scoreColor(int s) {
    if (s >= 90) return AppColors.scoreExcellentStart;
    if (s >= 75) return AppColors.scoreGoodStart;
    if (s >= 60) return AppColors.scoreCautionStart;
    if (s >= 40) return AppColors.scoreWarningStart;
    return AppColors.scoreDangerStart;
  }
}

class _ScoreBreakdown extends StatelessWidget {
  final DigitalWellnessScore score;
  final Color color;
  const _ScoreBreakdown({required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Screen Time', score.screenTimeScore, 25),
      ('Continuous', score.continuousExposureScore, 20),
      ('Bedtime', score.bedtimeScore, 15),
      ('Social Media', score.socialMediaScore, 15),
      ('Productivity', score.productivityScore, 15),
      ('Breaks', score.breakComplianceScore, 10),
    ];
    return Column(
      children: items.map((e) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(children: [
          SizedBox(width: 90, child: Text(e.$1, style: AppTypography.caption(color: AppColors.textSecondary))),
          Expanded(child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: e.$3 > 0 ? (e.$2 / e.$3).clamp(0, 1) : 0,
              minHeight: 5,
              backgroundColor: color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          )),
          const SizedBox(width: 8),
          SizedBox(width: 36, child: Text('${e.$2}/${e.$3}', style: AppTypography.caption(color: AppColors.textTertiary), textAlign: TextAlign.end)),
        ]),
      )).toList(),
    );
  }
}

// ─── App Usage Breakdown ─────────────────────────────────────
class AppUsageBreakdown extends StatelessWidget {
  final List<AppUsageEntry> apps;
  const AppUsageBreakdown({super.key, required this.apps});

  @override
  Widget build(BuildContext context) {
    final sorted = List<AppUsageEntry>.from(apps)..sort((a, b) => b.durationMinutes.compareTo(a.durationMinutes));
    final top = sorted.take(6).toList();
    final colors = [
      const Color(0xFF6C63AC), const Color(0xFF2C7BE5), const Color(0xFF27AE60),
      const Color(0xFFD4A017), const Color(0xFFC0392B), const Color(0xFF4A90A4),
    ];
    return _CardContainer(
      title: 'App Usage Breakdown',
      child: Column(children: [
        SizedBox(
          height: 160,
          child: PieChart(PieChartData(
            sections: List.generate(top.length, (i) => PieChartSectionData(
              value: top[i].durationMinutes.toDouble(),
              color: colors[i % colors.length],
              radius: 35,
              title: '',
            )),
            centerSpaceRadius: 40,
            sectionsSpace: 2,
          )),
        ),
        const SizedBox(height: 16),
        ...List.generate(top.length, (i) => _AppRow(app: top[i], color: colors[i % colors.length])),
      ]),
    );
  }
}

class _AppRow extends StatelessWidget {
  final AppUsageEntry app;
  final Color color;
  const _AppRow({required this.app, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 10),
        Text(app.category.icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 6),
        Expanded(child: Text(app.appName, style: AppTypography.bodySmall(color: AppColors.textPrimary))),
        Text(app.formattedDuration, style: AppTypography.bodyMedium(color: color)),
      ]),
    );
  }
}

// ─── Weekly Trend Chart ──────────────────────────────────────
class WeeklyTrendChart extends StatelessWidget {
  final List<DailyScreenData> weekData;
  const WeeklyTrendChart({super.key, required this.weekData});

  @override
  Widget build(BuildContext context) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return _CardContainer(
      title: 'Weekly Screen Trend',
      child: SizedBox(
        height: 180,
        child: BarChart(BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (weekData.map((d) => d.totalMinutes).reduce((a, b) => a > b ? a : b) + 60).toDouble(),
          barGroups: List.generate(weekData.length, (i) {
            final prod = weekData[i].productiveMinutes.toDouble();
            final nonProd = weekData[i].nonProductiveMinutes.toDouble();
            return BarChartGroupData(x: i, barRods: [
              BarChartRodData(
                toY: prod + nonProd,
                width: 18,
                borderRadius: BorderRadius.circular(4),
                rodStackItems: [
                  BarChartRodStackItem(0, prod, AppColors.primary.withValues(alpha: 0.8)),
                  BarChartRodStackItem(prod, prod + nonProd, AppColors.secondary.withValues(alpha: 0.6)),
                ],
              ),
            ]);
          }),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) => Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(days[v.toInt() % 7], style: AppTypography.caption(color: AppColors.textTertiary)),
              ),
            )),
            leftTitles: AxisTitles(sideTitles: SideTitles(
              showTitles: true, reservedSize: 32,
              getTitlesWidget: (v, _) => Text('${(v / 60).toStringAsFixed(0)}h', style: AppTypography.caption(color: AppColors.textTertiary)),
            )),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(color: AppColors.dividerColor.withValues(alpha: 0.3), strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
        )),
      ),
    );
  }
}

// ─── Risk Alerts ─────────────────────────────────────────────
class RiskAlertsList extends StatelessWidget {
  final List<ScreenAlert> alerts;
  const RiskAlertsList({super.key, required this.alerts});

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) {
      return _CardContainer(
        title: 'No Active Alerts',
        child: Text('Digital habits are within acceptable parameters.', style: AppTypography.bodySmall(color: AppColors.textSecondary)),
      );
    }
    return _CardContainer(
      title: 'Risk Alerts (${alerts.length})',
      child: Column(children: alerts.map((a) {
        final color = a.severity > 0.7 ? AppColors.error : a.severity > 0.5 ? AppColors.warning : AppColors.info;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Row(children: [
            Icon(Icons.info_outline_rounded, color: color, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(a.type.title, style: AppTypography.bodyMedium(color: color)),
              const SizedBox(height: 2),
              Text(a.message, style: AppTypography.caption(color: AppColors.textSecondary)),
            ])),
          ]),
        );
      }).toList()),
    );
  }
}

// ─── Insights List ───────────────────────────────────────────
class InsightsList extends StatelessWidget {
  final List<BehavioralInsight> insights;
  const InsightsList({super.key, required this.insights});

  @override
  Widget build(BuildContext context) {
    return _CardContainer(
      title: 'Behavioral Insights',
      child: Column(children: insights.map((i) {
        final color = i.impact > 0 ? AppColors.success : i.impact < -0.3 ? AppColors.error : AppColors.warning;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.insights_rounded, color: color, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(i.insight, style: AppTypography.bodySmall(color: AppColors.textSecondary))),
            Icon(i.impact > 0 ? Icons.trending_up : Icons.trending_down, color: color, size: 16),
          ]),
        );
      }).toList()),
    );
  }
}

// ─── Stats Summary Row ───────────────────────────────────────
class ScreenStatsSummary extends StatelessWidget {
  final DailyScreenData data;
  const ScreenStatsSummary({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      _MiniStat(icon: Icons.schedule_rounded, label: 'Total', value: data.formattedTotal, color: AppColors.accent),
      const SizedBox(width: 8),
      _MiniStat(icon: Icons.lock_open_rounded, label: 'Unlocks', value: '${data.unlockCount}', color: AppColors.secondary),
      const SizedBox(width: 8),
      _MiniStat(icon: Icons.timer_rounded, label: 'Longest', value: '${data.longestSessionMinutes}m', color: AppColors.warning),
      const SizedBox(width: 8),
      _MiniStat(icon: Icons.nightlight_round, label: 'Late', value: '${data.lateNightMinutes}m', color: AppColors.sleep),
    ]);
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _MiniStat({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 4),
        Text(value, style: AppTypography.bodyMedium(color: AppColors.textPrimary)),
        Text(label, style: AppTypography.caption(color: AppColors.textTertiary)),
      ]),
    ));
  }
}

// ─── Limits Card ─────────────────────────────────────────────
class LimitsStatusCard extends StatelessWidget {
  final DailyScreenData data;
  final ScreenTimeLimits limits;
  const LimitsStatusCard({super.key, required this.data, required this.limits});

  @override
  Widget build(BuildContext context) {
    return _CardContainer(
      title: 'Limit Status',
      child: Column(children: [
        _LimitRow('Daily Total', data.totalMinutes, limits.dailyTotalMinutes),
        _LimitRow('Social Media', data.socialMediaMinutes, limits.socialMediaMinutes),
        _LimitRow('Entertainment', data.appUsage.where((a) => a.category == AppCategory.entertainment).fold(0, (s, a) => s + a.durationMinutes), limits.entertainmentMinutes),
        _LimitRow('Max Session', data.longestSessionMinutes, limits.continuousSessionMinutes),
      ]),
    );
  }
}

class _LimitRow extends StatelessWidget {
  final String label;
  final int current, limit;
  const _LimitRow(this.label, this.current, this.limit);

  @override
  Widget build(BuildContext context) {
    final ratio = limit > 0 ? current / limit : 0.0;
    final exceeded = ratio > 1.0;
    final color = exceeded ? AppColors.error : ratio > 0.75 ? AppColors.warning : AppColors.success;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(label, style: AppTypography.bodySmall(color: AppColors.textSecondary))),
          Text('${current}m / ${limit}m', style: AppTypography.caption(color: exceeded ? AppColors.error : AppColors.textTertiary)),
          if (exceeded) const Padding(padding: EdgeInsets.only(left: 4), child: Icon(Icons.warning_rounded, color: AppColors.error, size: 14)),
        ]),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: ratio.clamp(0, 1).toDouble(),
            minHeight: 5,
            backgroundColor: color.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ]),
    );
  }
}

// ─── Shared Card Container ───────────────────────────────────
class _CardContainer extends StatelessWidget {
  final String title;
  final Widget child;
  const _CardContainer({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: AppTypography.h4(color: AppColors.textPrimary)),
        const SizedBox(height: 14),
        child,
      ]),
    );
  }
}
