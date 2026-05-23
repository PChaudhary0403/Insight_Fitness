import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/services/user_data_service.dart';

/// Analytics page with working time-range tabs and real data.
class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  int _selectedRange = 0; // 0=Day, 1=Week, 2=Month, 3=Year
  final _rangeLabels = const ['Day', 'Week', 'Month', 'Year'];

  @override
  Widget build(BuildContext context) {
    final data = UserDataService.instance;
    final score = data.healthScore;
    final daysSince = data.daysSinceJoining;

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
                    Text('Analytics', style: AppTypography.h1(color: AppColors.darkTextPrimary)),
                    const SizedBox(height: 4),
                    Text(
                      daysSince == 0
                          ? 'Your journey starts today — data will build up here'
                          : 'Day $daysSince of your health journey',
                      style: AppTypography.bodySmall(color: AppColors.darkTextSecondary),
                    ),
                  ],
                ),
              ),

              // ─── Time Range Selector (WORKING) ─────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing24),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.darkSurface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                  child: Row(
                    children: _rangeLabels.asMap().entries.map((e) {
                      final isActive = e.key == _selectedRange;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedRange = e.key),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isActive ? AppColors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                            ),
                            child: Center(
                              child: Text(
                                e.value,
                                style: AppTypography.bodySmall(
                                  color: isActive ? Colors.white : AppColors.darkTextSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms),

              const SizedBox(height: AppTheme.spacing24),

              // ─── Health Score Trend Chart ───────────────
              _buildHealthScoreChart(data, score),

              const SizedBox(height: AppTheme.spacing20),

              // ─── Hydration Chart ───────────────────────
              _buildHydrationChart(data),

              const SizedBox(height: AppTheme.spacing20),

              // ─── Summary Stats ─────────────────────────
              _buildSummaryStats(data),

              const SizedBox(height: AppTheme.spacing20),

              // ─── Activity Breakdown ────────────────────
              _buildActivityBreakdown(data),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Health Score Trend ────────────────────────────────

  Widget _buildHealthScoreChart(UserDataService data, int score) {
    // Real data: for new users or Day view, show just today's point
    // For week/month/year, show the baseline score as a flat line (data will build over time)
    final spots = _getHealthScoreSpots(score);
    final labels = _getXLabels();
    final isNew = data.daysSinceJoining == 0;

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
            Row(
              children: [
                Text('Health Score', style: AppTypography.h4(color: AppColors.darkTextPrimary)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isNew ? AppColors.info : AppColors.success).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isNew ? Icons.fiber_new_rounded : Icons.show_chart_rounded,
                        color: isNew ? AppColors.info : AppColors.success,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isNew ? 'Baseline' : '$score/100',
                        style: AppTypography.label(color: isNew ? AppColors.info : AppColors.success),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacing20),
            SizedBox(
              height: 180,
              child: spots.isEmpty
                  ? Center(
                      child: Text(
                        'Start tracking to see your trend',
                        style: AppTypography.body(color: AppColors.darkTextTertiary),
                      ),
                    )
                  : LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 25,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: AppColors.darkDivider,
                            strokeWidth: 0.5,
                          ),
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final idx = value.toInt();
                                if (idx >= 0 && idx < labels.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(labels[idx], style: AppTypography.label(color: AppColors.darkTextTertiary)),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                              reservedSize: 30,
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        minX: 0,
                        maxX: (labels.length - 1).toDouble(),
                        minY: 0,
                        maxY: 100,
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            color: AppColors.primary,
                            barWidth: 3,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, bar, index) {
                                return FlDotCirclePainter(
                                  radius: index == spots.length - 1 ? 5 : 3,
                                  color: AppColors.primary,
                                  strokeWidth: 2,
                                  strokeColor: AppColors.darkSurface,
                                );
                              },
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppColors.primary.withValues(alpha: 0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    ).animate(delay: 200.ms).fadeIn(duration: 500.ms);
  }

  List<FlSpot> _getHealthScoreSpots(int score) {
    if (score == 0) return [];
    // Show baseline as single or flat line depending on range
    return switch (_selectedRange) {
      0 => [FlSpot(0, score.toDouble())], // Day: just one point
      1 => List.generate(7, (i) => FlSpot(i.toDouble(), score.toDouble())), // Week: flat baseline
      2 => List.generate(4, (i) => FlSpot(i.toDouble(), score.toDouble())), // Month: 4 weeks flat
      3 => List.generate(12, (i) => FlSpot(i.toDouble(), score.toDouble())), // Year: 12 months flat
      _ => [FlSpot(0, score.toDouble())],
    };
  }

  List<String> _getXLabels() {
    return switch (_selectedRange) {
      0 => ['Today'],
      1 => ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
      2 => ['W1', 'W2', 'W3', 'W4'],
      3 => ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'],
      _ => ['Today'],
    };
  }

  // ─── Hydration Chart ──────────────────────────────────

  Widget _buildHydrationChart(UserDataService data) {
    final target = data.hydrationTarget;
    final todayWater = data.dailyWaterL;

    // For Day view, show just today's bar. For others, show empty slots.
    final barCount = switch (_selectedRange) {
      0 => 1,
      1 => 7,
      2 => 4,
      3 => 12,
      _ => 1,
    };

    final barLabels = switch (_selectedRange) {
      0 => ['Today'],
      1 => ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
      2 => ['W1', 'W2', 'W3', 'W4'],
      3 => ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'],
      _ => ['Today'],
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
            Text('Hydration', style: AppTypography.h4(color: AppColors.darkTextPrimary)),
            Text(
              'Today: ${todayWater.toStringAsFixed(1)}L / ${target.toStringAsFixed(1)}L target',
              style: AppTypography.caption(color: AppColors.darkTextSecondary),
            ),
            const SizedBox(height: AppTheme.spacing20),
            SizedBox(
              height: 140,
              child: BarChart(
                BarChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx >= 0 && idx < barLabels.length) {
                            return Text(barLabels[idx], style: AppTypography.label(color: AppColors.darkTextTertiary));
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(barCount, (i) {
                    // Only today (last bar) has real data
                    final isToday = (_selectedRange == 0) || (i == barCount - 1 && _selectedRange == 1);
                    final value = isToday ? todayWater : 0.0;
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: value.clamp(0, target + 1),
                          width: barCount <= 4 ? 28 : 18,
                          color: value >= target ? AppColors.success : AppColors.hydration,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: target,
                            color: AppColors.hydration.withValues(alpha: 0.08),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: 400.ms).fadeIn(duration: 500.ms);
  }

  // ─── Summary Stats ────────────────────────────────────

  Widget _buildSummaryStats(UserDataService data) {
    final profile = data.profile;
    final rangeLabel = _rangeLabels[_selectedRange];

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
            Text('$rangeLabel Summary', style: AppTypography.h4(color: AppColors.darkTextPrimary)),
            const SizedBox(height: 16),
            Row(
              children: [
                _SummaryItem(
                  icon: Icons.water_drop_rounded,
                  label: 'Water',
                  value: '${data.dailyWaterL.toStringAsFixed(1)}L',
                  color: AppColors.hydration,
                ),
                _SummaryItem(
                  icon: Icons.restaurant_rounded,
                  label: 'Meals',
                  value: '${data.dailyMeals}',
                  color: AppColors.nutrition,
                ),
                _SummaryItem(
                  icon: Icons.directions_walk_rounded,
                  label: 'Steps',
                  value: _formatSteps(data.dailySteps),
                  color: AppColors.movement,
                ),
                _SummaryItem(
                  icon: Icons.fitness_center_rounded,
                  label: 'Exercise',
                  value: '${data.dailyExerciseMin}m',
                  color: AppColors.exercise,
                ),
              ],
            ),
            if (profile != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: AppColors.info, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        data.daysSinceJoining == 0
                            ? 'Stats will populate as you track throughout the day.'
                            : 'Showing data for today. Historical trends will build over time.',
                        style: AppTypography.caption(color: AppColors.info),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    ).animate(delay: 500.ms).fadeIn(duration: 500.ms);
  }

  String _formatSteps(int steps) {
    if (steps >= 1000) return '${(steps / 1000).toStringAsFixed(1)}k';
    return '$steps';
  }

  // ─── Activity Breakdown ───────────────────────────────

  Widget _buildActivityBreakdown(UserDataService data) {
    final profile = data.profile;
    if (profile == null) {
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
          child: Center(
            child: Text(
              'Complete your health assessment to see activity breakdown',
              style: AppTypography.body(color: AppColors.darkTextTertiary),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final items = [
      _BreakdownItem('Sedentary Risk', '${profile.sedentaryRiskScore?.toStringAsFixed(1) ?? "0"}/10', _riskColor(profile.sedentaryRiskScore ?? 0)),
      _BreakdownItem('Activity Level', _activityLabel(profile.activityLevel), AppColors.movement),
      _BreakdownItem('Sleep Duration', _sleepDuration(profile), AppColors.sleep),
      _BreakdownItem('Stress Level', profile.stressLevel[0].toUpperCase() + profile.stressLevel.substring(1), _stressColor(profile.stressLevel)),
    ];

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
            Text('Health Breakdown', style: AppTypography.h4(color: AppColors.darkTextPrimary)),
            const SizedBox(height: 16),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(color: item.color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(item.label, style: AppTypography.body(color: AppColors.darkTextSecondary))),
                      Text(item.value, style: AppTypography.bodyMedium(color: item.color)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    ).animate(delay: 600.ms).fadeIn(duration: 500.ms);
  }

  String _activityLabel(String level) => switch (level) {
        'sedentary' => '🪑 Sedentary',
        'light' => '🚶 Light',
        'moderate' => '🏃 Moderate',
        'active' => '💪 Active',
        'very_active' => '🔥 Very Active',
        _ => level,
      };

  String _sleepDuration(dynamic profile) {
    try {
      final sp = profile.sleepTime.split(':');
      final wp = profile.wakeUpTime.split(':');
      final sleepMin = int.parse(sp[0]) * 60 + int.parse(sp[1]);
      final wakeMin = int.parse(wp[0]) * 60 + int.parse(wp[1]);
      var diff = wakeMin - sleepMin;
      if (diff <= 0) diff += 24 * 60;
      return '${(diff / 60).toStringAsFixed(1)}h';
    } catch (_) {
      return '—';
    }
  }

  Color _riskColor(double risk) {
    if (risk <= 3) return AppColors.success;
    if (risk <= 6) return AppColors.warning;
    return AppColors.error;
  }

  Color _stressColor(String level) => switch (level) {
        'low' => AppColors.success,
        'moderate' => AppColors.warning,
        'high' => AppColors.error,
        'very_high' => AppColors.error,
        _ => AppColors.info,
      };
}

// ─── Helper widgets ──────────────────────────────────────────

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _SummaryItem({required this.icon, required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(value, style: AppTypography.h4(color: AppColors.darkTextPrimary)),
          Text(label, style: AppTypography.caption(color: AppColors.darkTextTertiary)),
        ],
      ),
    );
  }
}

class _BreakdownItem {
  final String label;
  final String value;
  final Color color;
  const _BreakdownItem(this.label, this.value, this.color);
}
