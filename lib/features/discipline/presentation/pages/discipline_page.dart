import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/discipline_models.dart';
import '../../domain/discipline_scoring_engine.dart';
import '../widgets/create_discipline_sheet.dart';

/// Main discipline tracker page with scoring, analytics, gamification.
class DisciplinePage extends StatefulWidget {
  const DisciplinePage({super.key});

  @override
  State<DisciplinePage> createState() => _DisciplinePageState();
}

class _DisciplinePageState extends State<DisciplinePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ─── Real Data (starts empty, user creates disciplines) ───
  final List<DisciplineRule> _rules = [];

  late final List<DisciplineCheckIn> _checkIns;
  late Map<String, DisciplineAnalytics> _analytics;
  late List<DisciplineInsight> _insights;
  late List<DisciplineBadge> _badges;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _checkIns = []; // No fake history — start clean
    _recompute();
  }

  void _recompute() {
    final rulesMap = {for (var r in _rules) r.id: r};
    _analytics = {
      for (var r in _rules)
        r.id: DisciplineScoringEngine.computeAnalytics(r, _checkIns.where((c) => c.ruleId == r.id).toList()),
    };
    _insights = DisciplineScoringEngine.generateInsights(_analytics, rulesMap, _checkIns);
    _badges = DisciplineScoringEngine.checkBadges(_analytics, rulesMap);
  }

  void _checkIn(DisciplineRule rule) {
    final now = DateTime.now();
    final status = DisciplineScoringEngine.determineStatus(rule, now);
    final score = DisciplineScoringEngine.computeCheckInScore(rule: rule, checkInTime: now, status: status);

    setState(() {
      _checkIns.add(DisciplineCheckIn(ruleId: rule.id, timestamp: now, status: status, scoreAwarded: score));
      _recompute();
    });

    // Show feedback
    final emoji = status == 'on_time' ? '✅' : '⏰';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('$emoji ${rule.title}: ${score.toStringAsFixed(1)}/10 ($status)'),
      backgroundColor: status == 'on_time' ? AppColors.success : AppColors.warning,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  void _addDiscipline(DisciplineRule rule) {
    setState(() { _rules.add(rule); _recompute(); });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  double get _overallScore {
    if (_analytics.isEmpty) return 0;
    return _analytics.values.map((a) => a.weeklyScore).reduce((a, b) => a + b) / _analytics.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          context: context, isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => CreateDisciplineSheet(onCreated: _addDiscipline),
        ),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            _buildHeader().animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 8),
            // Tab bar
            _buildTabBar(),
            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDisciplinesTab(),
                  _buildAnalyticsTab(),
                  _buildBadgesTab(),
                  _buildInsightsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final score = _overallScore;
    final color = DisciplineScoringEngine.scoreColor(score);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: AppColors.darkSurfaceElevated, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.darkTextPrimary, size: 18),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Discipline Tracker', style: AppTypography.h3(color: AppColors.darkTextPrimary)),
                Text('${DisciplineScoringEngine.scoreLabel(score)} • ${score.toStringAsFixed(1)}/10', style: AppTypography.caption(color: color)),
              ],
            ),
          ),
          CircularPercentIndicator(
            radius: 24, lineWidth: 4,
            percent: (score / 10).clamp(0, 1),
            center: Text(score.toStringAsFixed(1), style: AppTypography.buttonSmall(color: color)),
            progressColor: color,
            backgroundColor: color.withValues(alpha: 0.15),
            circularStrokeCap: CircularStrokeCap.round,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceElevated,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.darkTextTertiary,
        labelStyle: AppTypography.buttonSmall(),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Active'),
          Tab(text: 'Stats'),
          Tab(text: 'Badges'),
          Tab(text: 'AI'),
        ],
      ),
    );
  }

  // ─── Tab 1: Active Disciplines ──────────────────────────

  Widget _buildDisciplinesTab() {
    if (_rules.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🛡️', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text('No disciplines yet', style: AppTypography.h4(color: AppColors.darkTextSecondary)),
            const SizedBox(height: 4),
            Text('Tap + to create your first commitment', style: AppTypography.bodySmall(color: AppColors.darkTextTertiary)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
      itemCount: _rules.length,
      itemBuilder: (ctx, i) {
        final rule = _rules[i];
        final analytics = _analytics[rule.id];
        final todayChecked = _checkIns.any((c) =>
            c.ruleId == rule.id &&
            c.timestamp.day == DateTime.now().day &&
            c.timestamp.month == DateTime.now().month &&
            c.status != 'missed');

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: todayChecked ? rule.color.withValues(alpha: 0.4) : AppColors.darkCardBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: rule.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(rule.icon, color: rule.color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(rule.title, style: AppTypography.bodyMedium(color: AppColors.darkTextPrimary)),
                    const SizedBox(height: 2),
                    Text(
                      '${rule.targetTimeStart} - ${rule.targetTimeEnd} • ${rule.recurrence} • ${analytics?.currentStreak ?? 0}🔥',
                      style: AppTypography.caption(color: AppColors.darkTextSecondary),
                    ),
                    const SizedBox(height: 6),
                    // Score bar
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: ((analytics?.weeklyScore ?? 0) / 10).clamp(0, 1),
                              minHeight: 4,
                              backgroundColor: rule.color.withValues(alpha: 0.1),
                              valueColor: AlwaysStoppedAnimation(rule.color),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${analytics?.weeklyScore.toStringAsFixed(1) ?? "0.0"}',
                          style: AppTypography.caption(color: rule.color),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: todayChecked ? null : () => _checkIn(rule),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: todayChecked ? rule.color.withValues(alpha: 0.2) : rule.color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    todayChecked ? Icons.check_rounded : Icons.touch_app_rounded,
                    color: todayChecked ? rule.color : Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ).animate(delay: (i * 80).ms).fadeIn().slideX(begin: 0.03, end: 0);
      },
    );
  }

  // ─── Tab 2: Analytics ───────────────────────────────────

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overall Score Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                AppColors.primary.withValues(alpha: 0.15),
                AppColors.secondary.withValues(alpha: 0.08),
              ], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Text('Weekly Discipline Score', style: AppTypography.caption(color: AppColors.darkTextSecondary)),
                const SizedBox(height: 12),
                Text(_overallScore.toStringAsFixed(1), style: AppTypography.score(color: DisciplineScoringEngine.scoreColor(_overallScore))),
                Text('/ 10.0', style: AppTypography.caption(color: AppColors.darkTextTertiary)),
                const SizedBox(height: 8),
                Text(DisciplineScoringEngine.scoreLabel(_overallScore), style: AppTypography.bodyMedium(color: DisciplineScoringEngine.scoreColor(_overallScore))),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.95, 0.95)),
          const SizedBox(height: 20),

          Text('Per-Discipline Breakdown', style: AppTypography.h4(color: AppColors.darkTextPrimary)),
          const SizedBox(height: 12),
          ..._rules.asMap().entries.map((e) {
            final rule = e.value;
            final a = _analytics[rule.id]!;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.darkCardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(rule.icon, color: rule.color, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(rule.title, style: AppTypography.bodyMedium(color: AppColors.darkTextPrimary))),
                    Text('${a.currentStreak}🔥', style: AppTypography.bodySmall(color: AppColors.darkTextSecondary)),
                  ]),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _miniStat('Daily', a.dailyScore, rule.color),
                      _miniStat('Weekly', a.weeklyScore, rule.color),
                      _miniStat('Monthly', a.monthlyScore, rule.color),
                      _miniStat('All-time', a.allTimeScore, rule.color),
                    ],
                  ),
                ],
              ),
            ).animate(delay: (e.key * 80).ms).fadeIn();
          }),
        ],
      ),
    );
  }

  Widget _miniStat(String label, double value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(value.toStringAsFixed(1), style: AppTypography.h4(color: value >= 7 ? color : AppColors.darkTextSecondary)),
          Text(label, style: AppTypography.caption(color: AppColors.darkTextTertiary)),
        ],
      ),
    );
  }

  // ─── Tab 3: Badges ──────────────────────────────────────

  Widget _buildBadgesTab() {
    if (_badges.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🏅', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text('No badges yet', style: AppTypography.h4(color: AppColors.darkTextSecondary)),
            Text('Keep building streaks to earn badges!', style: AppTypography.bodySmall(color: AppColors.darkTextTertiary)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.1,
      ),
      itemCount: _badges.length,
      itemBuilder: (ctx, i) {
        final badge = _badges[i];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              AppColors.secondary.withValues(alpha: 0.12),
              AppColors.primary.withValues(alpha: 0.06),
            ], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(badge.emoji, style: const TextStyle(fontSize: 36)),
              const SizedBox(height: 8),
              Text(badge.title, style: AppTypography.bodyMedium(color: AppColors.darkTextPrimary), textAlign: TextAlign.center),
              const SizedBox(height: 4),
              Text(badge.description, style: AppTypography.caption(color: AppColors.darkTextSecondary), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
        ).animate(delay: (i * 100).ms).fadeIn().scale(begin: const Offset(0.9, 0.9));
      },
    );
  }

  // ─── Tab 4: AI Insights ─────────────────────────────────

  Widget _buildInsightsTab() {
    if (_insights.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🤖', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text('Collecting data...', style: AppTypography.h4(color: AppColors.darkTextSecondary)),
            Text('AI insights will appear as patterns emerge', style: AppTypography.bodySmall(color: AppColors.darkTextTertiary)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
      itemCount: _insights.length + 1,
      itemBuilder: (ctx, i) {
        if (i == 0) {
          // Trust score info
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.verified_user_rounded, color: AppColors.info, size: 20),
                const SizedBox(width: 10),
                Expanded(child: Text(
                  'Trust Score: Manual check-ins have lower trust. Use timestamp logging or wearable integration for higher confidence.',
                  style: AppTypography.caption(color: AppColors.info),
                )),
              ],
            ),
          ).animate().fadeIn();
        }

        final insight = _insights[i - 1];
        final isImprovement = insight.type == 'improvement';
        final color = isImprovement ? AppColors.success : insight.type == 'correction' ? AppColors.error : AppColors.accent;
        final icon = isImprovement ? Icons.trending_up_rounded : insight.type == 'correction' ? Icons.warning_rounded : Icons.psychology_rounded;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(insight.type.toUpperCase(), style: AppTypography.caption(color: color)),
                  const SizedBox(height: 4),
                  Text(insight.message, style: AppTypography.body(color: AppColors.darkTextPrimary)),
                ],
              )),
            ],
          ),
        ).animate(delay: (i * 100).ms).fadeIn().slideY(begin: 0.03, end: 0);
      },
    );
  }
}
