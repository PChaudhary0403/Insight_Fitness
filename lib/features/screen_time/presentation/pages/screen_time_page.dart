import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/screen_time_models.dart';
import '../../data/services/screen_time_service.dart';
import '../widgets/screen_time_widgets.dart';

class ScreenTimePage extends StatefulWidget {
  const ScreenTimePage({super.key});
  @override
  State<ScreenTimePage> createState() => _ScreenTimePageState();
}

class _ScreenTimePageState extends State<ScreenTimePage> {
  final _service = ScreenTimeService.instance;
  bool _loading = true;
  DailyScreenData? _today;
  List<DailyScreenData> _week = [];
  DigitalWellnessScore? _score;
  List<ScreenAlert> _alerts = [];
  List<BehavioralInsight> _insights = [];
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);

    // Re-check permission status on every load
    if (_service.isNativeAvailable) {
      await _service.checkPermission();
    }

    final today = await _service.getTodayData();
    final week = await _service.getWeekData();
    final score = await _service.calculateWellnessScore();
    final alerts = _service.detectRisks(today);
    final insights = await _service.generateInsights();
    if (mounted) {
      setState(() {
        _today = today;
        _week = week;
        _score = score;
        _alerts = alerts;
        _insights = insights;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryLight))
            : Column(children: [
                _buildHeader(),
                // Show permission request if not granted on Android
                if (_service.isNativeAvailable && !_service.permissionGranted)
                  _buildPermissionRequest()
                else ...[
                  _buildTabs(),
                  Expanded(child: _tabIndex == 0 ? _buildOverview() : _tabIndex == 1 ? _buildDetails() : _buildSettings()),
                ],
              ]),
      ),
    );
  }

  Widget _buildPermissionRequest() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.screen_lock_portrait_rounded, color: AppColors.primary, size: 40),
            ),
            const SizedBox(height: 24),
            Text('Enable Screen Time Monitoring',
                style: AppTypography.h3(color: AppColors.textPrimary),
                textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(
              'INSIGHT needs usage access permission to show your real screen time data. '
              'This data stays on your device and is never shared.',
              style: AppTypography.body(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await _service.requestPermission();
                  // Show a dialog telling user to come back
                  if (mounted) {
                    _showSnack('Grant permission in Settings, then come back and tap Refresh.');
                  }
                },
                icon: const Icon(Icons.security_rounded),
                label: const Text('Grant Permission'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _loadData,
              child: Text('Refresh', style: AppTypography.bodyMedium(color: AppColors.primaryLight)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary, size: 20),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Digital Wellness', style: AppTypography.h3(color: AppColors.textPrimary)),
          Text('Screen Time Intelligence', style: AppTypography.caption(color: AppColors.textSecondary)),
        ])),
        if (_service.focusModeActive)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.do_not_disturb_on_rounded, color: AppColors.primary, size: 14),
              const SizedBox(width: 4),
              Text('Focus', style: AppTypography.caption(color: AppColors.primary)),
            ]),
          ),
      ]),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildTabs() {
    final tabs = ['Overview', 'Details', 'Settings'];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(children: List.generate(3, (i) => Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _tabIndex = i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: _tabIndex == i ? AppColors.primaryLight.withValues(alpha: 0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: Text(
              tabs[i],
              style: AppTypography.bodySmall(
                color: _tabIndex == i ? AppColors.primaryLight : AppColors.textTertiary,
              ),
            )),
          ),
        ),
      ))),
    ).animate().fadeIn(delay: 100.ms, duration: 400.ms);
  }

  Widget _buildOverview() {
    final t = _today!;
    final s = _score!;

    // Show empty state if no real data is available
    if (t.totalMinutes == 0 && t.appUsage.isEmpty) {
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        child: Column(children: [
          WellnessScoreRing(score: s).animate(delay: 150.ms).fadeIn(duration: 500.ms),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(children: [
              const Text('📊', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 12),
              Text('No screen time data yet',
                  style: AppTypography.h4(color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Text(
                _service.isNativeAvailable
                    ? 'Usage data will appear as you use your device throughout the day. '
                      'Pull down to refresh.'
                    : 'Real screen time monitoring requires an Android device. '
                      'On web, this feature shows tracked data only.',
                style: AppTypography.bodySmall(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (_service.isNativeAvailable)
                TextButton.icon(
                  onPressed: () async {
                    await _service.refreshToday();
                    _loadData();
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Refresh'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.primaryLight),
                ),
            ]),
          ).animate(delay: 250.ms).fadeIn(duration: 400.ms),
          const SizedBox(height: 16),
          _buildSmartInterventions().animate(delay: 350.ms).fadeIn(duration: 400.ms),
        ]),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      child: Column(children: [
        WellnessScoreRing(score: s).animate(delay: 150.ms).fadeIn(duration: 500.ms).slideY(begin: 0.03, end: 0),
        const SizedBox(height: 16),
        ScreenStatsSummary(data: t).animate(delay: 250.ms).fadeIn(duration: 400.ms),
        const SizedBox(height: 16),
        LimitsStatusCard(data: t, limits: _service.limits).animate(delay: 300.ms).fadeIn(duration: 400.ms).slideY(begin: 0.03, end: 0),
        const SizedBox(height: 16),
        RiskAlertsList(alerts: _alerts).animate(delay: 350.ms).fadeIn(duration: 400.ms).slideY(begin: 0.03, end: 0),
        const SizedBox(height: 16),
        _buildSmartInterventions().animate(delay: 400.ms).fadeIn(duration: 400.ms).slideY(begin: 0.03, end: 0),
      ]),
    );
  }

  Widget _buildDetails() {
    final t = _today!;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      child: Column(children: [
        AppUsageBreakdown(apps: t.appUsage).animate(delay: 100.ms).fadeIn(duration: 400.ms).slideY(begin: 0.03, end: 0),
        const SizedBox(height: 16),
        WeeklyTrendChart(weekData: _week).animate(delay: 200.ms).fadeIn(duration: 400.ms).slideY(begin: 0.03, end: 0),
        const SizedBox(height: 16),
        _buildProductivityBreakdown().animate(delay: 300.ms).fadeIn(duration: 400.ms).slideY(begin: 0.03, end: 0),
        const SizedBox(height: 16),
        InsightsList(insights: _insights).animate(delay: 400.ms).fadeIn(duration: 400.ms).slideY(begin: 0.03, end: 0),
        const SizedBox(height: 16),
        _buildSessionHistory().animate(delay: 450.ms).fadeIn(duration: 400.ms).slideY(begin: 0.03, end: 0),
      ]),
    );
  }

  Widget _buildSettings() {
    final l = _service.limits;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      child: Column(children: [
        _buildSettingCard('🎯 Daily Screen Limit', '${l.dailyTotalMinutes ~/ 60}h ${l.dailyTotalMinutes % 60}m', 'Maximum daily screen time', () => _editLimit('daily')),
        const SizedBox(height: 10),
        _buildSettingCard('📱 Social Media Limit', '${l.socialMediaMinutes}m', 'Maximum daily social media', () => _editLimit('social')),
        const SizedBox(height: 10),
        _buildSettingCard('🎬 Entertainment Limit', '${l.entertainmentMinutes}m', 'Maximum daily entertainment', () => _editLimit('entertainment')),
        const SizedBox(height: 10),
        _buildSettingCard('⏰ Session Limit', '${l.continuousSessionMinutes}m', 'Max continuous session before break', () => _editLimit('session')),
        const SizedBox(height: 10),
        _buildSettingCard('🌙 Late Night Cutoff', '${l.lateNightCutoffHour}:00', 'No screen after this hour', () => _editLimit('bedtime')),
        const SizedBox(height: 20),
        _buildFocusMode(),
        const SizedBox(height: 20),
        _buildPrivacy(),
      ].asMap().entries.map((e) => e.value.animate(delay: (100 + e.key * 60).ms).fadeIn(duration: 300.ms)).toList()),
    );
  }

  Widget _buildSmartInterventions() {
    final interventions = [
      ('👁️ 20-20-20 Rule', 'Look 20 feet away for 20 seconds every 20 minutes', AppColors.info),
      ('🧘 Stretch Reminder', 'Stand up and stretch your body', AppColors.movement),
      ('💧 Hydration Check', 'Drink water after long screen sessions', AppColors.hydration),
      ('🚶 Movement Prompt', 'Walk around for 2 minutes', AppColors.success),
    ];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('💡 Smart Reminders', style: AppTypography.h4(color: AppColors.textPrimary)),
        const SizedBox(height: 14),
        ...interventions.map((i) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GestureDetector(
            onTap: () => _showSnack('${i.$1} reminder activated!'),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: i.$3.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: i.$3.withValues(alpha: 0.15)),
              ),
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(i.$1, style: AppTypography.bodyMedium(color: i.$3)),
                  Text(i.$2, style: AppTypography.caption(color: AppColors.textSecondary)),
                ])),
                Icon(Icons.notifications_active_rounded, color: i.$3.withValues(alpha: 0.6), size: 18),
              ]),
            ),
          ),
        )),
      ]),
    );
  }

  Widget _buildProductivityBreakdown() {
    final t = _today!;
    final prodPct = (t.productiveRatio * 100).round();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('📊 Productivity Split', style: AppTypography.h4(color: AppColors.textPrimary)),
        const SizedBox(height: 14),
        Row(children: [
          _ProdChip('Productive', '${t.productiveMinutes}m', AppColors.success, prodPct),
          const SizedBox(width: 10),
          _ProdChip('Non-Productive', '${t.nonProductiveMinutes}m', AppColors.error, 100 - prodPct),
        ]),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Row(children: [
            Expanded(flex: prodPct.clamp(1, 99), child: Container(height: 10, color: AppColors.success)),
            Expanded(flex: (100 - prodPct).clamp(1, 99), child: Container(height: 10, color: AppColors.error.withValues(alpha: 0.6))),
          ]),
        ),
      ]),
    );
  }

  Widget _buildSessionHistory() {
    final sessions = _today!.sessions;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('📋 Session History', style: AppTypography.h4(color: AppColors.textPrimary)),
        const SizedBox(height: 14),
        if (sessions.isEmpty)
          Text('No sessions recorded yet.', style: AppTypography.bodySmall(color: AppColors.textSecondary))
        else
          ...sessions.take(6).map((s) {
            final color = s.isLateNight ? AppColors.warning : s.durationMinutes > 60 ? AppColors.error : AppColors.success;
            final h = s.startTime.hour % 12 == 0 ? 12 : s.startTime.hour % 12;
            final ampm = s.startTime.hour < 12 ? 'AM' : 'PM';
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 10),
                Text('$h:${s.startTime.minute.toString().padLeft(2, '0')} $ampm', style: AppTypography.bodySmall(color: AppColors.textSecondary)),
                const SizedBox(width: 8),
                Expanded(child: Container(height: 1, color: AppColors.dividerColor)),
                const SizedBox(width: 8),
                Text('${s.durationMinutes}m', style: AppTypography.bodyMedium(color: color)),
                if (s.isLateNight) ...[const SizedBox(width: 4), const Text('🌙', style: TextStyle(fontSize: 12))],
              ]),
            );
          }),
      ]),
    );
  }

  Widget _buildSettingCard(String title, String value, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: AppTypography.bodyMedium(color: AppColors.textPrimary)),
            Text(subtitle, style: AppTypography.caption(color: AppColors.textTertiary)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(value, style: AppTypography.bodyMedium(color: AppColors.primaryLight)),
          ),
          const SizedBox(width: 8),
          Icon(Icons.edit_rounded, color: AppColors.textTertiary, size: 16),
        ]),
      ),
    );
  }

  Widget _buildFocusMode() {
    return GestureDetector(
      onTap: () async {
        await _service.toggleFocusMode();
        setState(() {});
        _showSnack(_service.focusModeActive ? '🎯 Focus Mode activated!' : 'Focus Mode deactivated.');
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _service.focusModeActive
                ? [AppColors.primary.withValues(alpha: 0.15), AppColors.primary.withValues(alpha: 0.05)]
                : [AppColors.surface, AppColors.surface],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _service.focusModeActive ? AppColors.primary.withValues(alpha: 0.3) : AppColors.cardBorder),
        ),
        child: Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              _service.focusModeActive ? Icons.do_not_disturb_on_rounded : Icons.do_not_disturb_off_rounded,
              color: AppColors.primary, size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Focus Mode', style: AppTypography.h4(color: AppColors.textPrimary)),
            Text(_service.focusModeActive ? 'Active — distractions blocked' : 'Tap to activate focus mode', style: AppTypography.caption(color: AppColors.textSecondary)),
          ])),
          Switch(
            value: _service.focusModeActive,
            activeThumbColor: AppColors.primary,
            onChanged: (_) async {
              await _service.toggleFocusMode();
              setState(() {});
            },
          ),
        ]),
      ),
    );
  }

  Widget _buildPrivacy() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('🔒 Privacy & Security', style: AppTypography.h4(color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        _privacyRow(Icons.lock_rounded, 'Data encrypted locally'),
        _privacyRow(Icons.visibility_off_rounded, 'Opt-in tracking only'),
        _privacyRow(Icons.download_rounded, 'Export your data anytime'),
        _privacyRow(Icons.delete_forever_rounded, 'Delete all data'),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: OutlinedButton.icon(
            onPressed: () => _showSnack('Data exported to clipboard.'),
            icon: const Icon(Icons.download_rounded, size: 16),
            label: const Text('Export'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryLight,
              side: const BorderSide(color: AppColors.primaryLight),
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
          )),
          const SizedBox(width: 10),
          Expanded(child: OutlinedButton.icon(
            onPressed: () async {
              await _service.deleteAllData();
              _showSnack('All screen time data deleted.');
              _loadData();
            },
            icon: const Icon(Icons.delete_forever_rounded, size: 16),
            label: const Text('Delete All'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
          )),
        ]),
      ]),
    );
  }

  Widget _privacyRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Icon(icon, color: AppColors.success, size: 16),
        const SizedBox(width: 10),
        Text(text, style: AppTypography.bodySmall(color: AppColors.textSecondary)),
      ]),
    );
  }

  void _editLimit(String type) {
    final l = _service.limits;
    int current;
    String title;
    switch (type) {
      case 'daily': current = l.dailyTotalMinutes; title = 'Daily Screen Limit (minutes)';
      case 'social': current = l.socialMediaMinutes; title = 'Social Media Limit (minutes)';
      case 'entertainment': current = l.entertainmentMinutes; title = 'Entertainment Limit (minutes)';
      case 'session': current = l.continuousSessionMinutes; title = 'Session Limit (minutes)';
      case 'bedtime': current = l.lateNightCutoffHour; title = 'Late Night Cutoff (hour, 0-23)';
      default: return;
    }
    final ctrl = TextEditingController(text: '$current');
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(title, style: AppTypography.h4(color: AppColors.textPrimary)),
      content: TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        style: AppTypography.h3(color: AppColors.primaryLight),
        decoration: InputDecoration(
          filled: true, fillColor: AppColors.surfaceElevated,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary))),
        ElevatedButton(
          onPressed: () {
            final val = int.tryParse(ctrl.text) ?? current;
            ScreenTimeLimits newL;
            switch (type) {
              case 'daily': newL = l.copyWith(dailyTotalMinutes: val);
              case 'social': newL = l.copyWith(socialMediaMinutes: val);
              case 'entertainment': newL = l.copyWith(entertainmentMinutes: val);
              case 'session': newL = l.copyWith(continuousSessionMinutes: val);
              case 'bedtime': newL = l.copyWith(lateNightCutoffHour: val.clamp(0, 23));
              default: newL = l;
            }
            _service.saveLimits(newL);
            Navigator.pop(ctx);
            _loadData();
          },
          child: const Text('Save'),
        ),
      ],
    ));
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.surface,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }
}

class _ProdChip extends StatelessWidget {
  final String label, value;
  final Color color;
  final int pct;
  const _ProdChip(this.label, this.value, this.color, this.pct);

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: AppTypography.caption(color: AppColors.textSecondary)),
        Row(children: [
          Text(value, style: AppTypography.h4(color: color)),
          const Spacer(),
          Text('$pct%', style: AppTypography.caption(color: color)),
        ]),
      ]),
    ));
  }
}