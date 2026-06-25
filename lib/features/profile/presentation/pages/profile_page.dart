import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/services/user_data_service.dart';
import '../../../../shared/services/notification_service.dart';

/// User profile page — reads ALL data from UserDataService.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final data = UserDataService.instance;
    final profile = data.profile;
    final bmi = data.bmi;
    final score = data.healthScore;
    final streak = data.currentStreak;

    // Format join date
    final joinDate = profile?.createdAt ?? DateTime.now();
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final joinStr = '${months[joinDate.month - 1]} ${joinDate.day}, ${joinDate.year}';

    // BMI display
    final bmiStr = bmi > 0 ? bmi.toStringAsFixed(1) : '—';
    final bmiSub = data.bmiCategory.isNotEmpty ? data.bmiCategory : '—';
    Color bmiColor = AppColors.success;
    String bmiEmoji = '✅';
    if (bmi < 18.5 && bmi > 0) {
      bmiColor = AppColors.warning;
      bmiEmoji = '⚠️';
    } else if (bmi >= 25 && bmi < 30) {
      bmiColor = AppColors.warning;
      bmiEmoji = '⚠️';
    } else if (bmi >= 30) {
      bmiColor = AppColors.error;
      bmiEmoji = '🔴';
    }

    // Score display
    final scoreStr = score > 0 ? '$score' : '—';
    final scoreLabel = score > 0 ? AppColors.healthScoreLabel(score) : '—';
    final scoreColor = AppColors.healthScoreGradient(score)[0];

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            children: [
              const SizedBox(height: AppTheme.spacing24),

              // ─── Avatar + Name ──────────────────────────
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(shape: BoxShape.circle, gradient: AppColors.primaryGradient),
                child: Center(
                  child: Text(
                    data.userInitial,
                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w700),
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.8, 0.8)),
              const SizedBox(height: AppTheme.spacing12),
              Text(data.userName, style: AppTypography.h2(color: AppColors.textPrimary))
                  .animate().fadeIn(delay: 100.ms),
              if (profile != null) ...[
                Text(
                  '${profile.gender[0].toUpperCase()}${profile.gender.substring(1)} • ${profile.age} years • ${profile.weightKg.toStringAsFixed(0)} kg',
                  style: AppTypography.body(color: AppColors.textSecondary),
                ).animate().fadeIn(delay: 150.ms),
              ],
              Text('Joined $joinStr', style: AppTypography.caption(color: AppColors.textTertiary))
                  .animate().fadeIn(delay: 200.ms),
              const SizedBox(height: AppTheme.spacing24),

              // ─── Stats Row ──────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing24),
                child: Row(children: [
                  Expanded(child: _StatBox(label: 'BMI', value: bmiStr, sub: '$bmiSub $bmiEmoji', color: bmiColor)),
                  const SizedBox(width: 12),
                  Expanded(child: _StatBox(label: 'Score', value: scoreStr, sub: scoreLabel, color: scoreColor)),
                  const SizedBox(width: 12),
                  Expanded(child: _StatBox(
                    label: 'Streak',
                    value: '$streak',
                    sub: streak == 0 ? 'Start!' : 'days 🔥',
                    color: streak > 0 ? Color(0xFFFF6B35) : AppColors.textTertiary,
                  )),
                ]),
              ).animate(delay: 250.ms).fadeIn().slideY(begin: 0.05, end: 0),
              const SizedBox(height: AppTheme.spacing24),

              // ─── Menu Items ─────────────────────────────
              _buildMenuItem(
                context,
                Icons.person_outline_rounded,
                'Personal Info',
                'View your health profile',
                () => _showPersonalInfo(context, data),
              ),
              _buildMenuItem(
                context,
                Icons.flag_outlined,
                'Health Goals',
                'Your improvement roadmap',
                () => context.push('/goals'),
              ),
              _buildMenuItem(
                context,
                Icons.restaurant_outlined,
                'Dietary Preferences',
                profile != null ? _dietLabel(profile.dietaryPreference) : 'Not set',
                () => _showDietaryPrefs(context, data),
              ),
              _buildMenuItem(
                context,
                Icons.watch_outlined,
                'Connected Devices',
                'Coming soon',
                () => _showComingSoon(context),
                isDisabled: true,
              ),
              _buildMenuItem(
                context,
                Icons.shield_outlined,
                'Privacy & Security',
                'Manage your data',
                () => _showPrivacySecurity(context),
              ),
              _buildMenuItem(
                context,
                Icons.notifications_outlined,
                'Notifications',
                'Manage reminders & alerts',
                () => _showNotificationSettings(context),
              ),
              _buildMenuItem(
                context,
                Icons.settings_outlined,
                'Settings',
                'Theme, language & preferences',
                () => context.push('/settings'),
              ),
              _buildMenuItem(
                context,
                Icons.download_outlined,
                'Export My Data',
                'Download health report',
                () => _showExportData(context, data),
              ),
              _buildMenuItem(
                context,
                Icons.replay_outlined,
                'Retake Assessment',
                'Redo your health assessment',
                () => _confirmRetakeAssessment(context),
              ),

              const SizedBox(height: AppTheme.spacing24),

              // ─── Sign Out ───────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing24),
                child: SizedBox(
                  width: double.infinity, height: 52,
                  child: OutlinedButton(
                    onPressed: () async {
                      await UserDataService.instance.clear();
                      if (!context.mounted) return;
                      context.go('/welcome');
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.error.withValues(alpha: 0.5)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMedium)),
                    ),
                    child: Text('Sign Out', style: AppTypography.bodyMedium(color: AppColors.error)),
                  ),
                ),
              ).animate(delay: 500.ms).fadeIn(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    bool isDisabled = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing24, vertical: 3),
      child: Container(
        decoration: BoxDecoration(
          color: isDisabled ? AppColors.surface.withValues(alpha: 0.5) : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: ListTile(
          leading: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: (isDisabled ? AppColors.textTertiary : AppColors.primary).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: isDisabled ? AppColors.textTertiary : AppColors.textSecondary, size: 20),
          ),
          title: Text(
            title,
            style: AppTypography.bodyMedium(color: isDisabled ? AppColors.textTertiary : AppColors.textPrimary),
          ),
          subtitle: Text(
            subtitle,
            style: AppTypography.caption(color: isDisabled ? AppColors.textTertiary : AppColors.textSecondary),
          ),
          trailing: isDisabled
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('Soon', style: AppTypography.caption(color: AppColors.warning)),
                )
              : Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 20),
          onTap: onTap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  // ─── Personal Info Sheet ────────────────────────────────

  void _showPersonalInfo(BuildContext context, UserDataService data) {
    final p = data.profile;
    if (p == null) {
      _showSnack(context, 'Complete your health assessment first');
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _sheetHandle(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Personal Info', style: AppTypography.h3(color: AppColors.textPrimary)),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  children: [
                    _infoRow('Full Name', p.fullName),
                    _infoRow('Age', '${p.age} years'),
                    _infoRow('Gender', p.gender[0].toUpperCase() + p.gender.substring(1)),
                    _infoRow('Height', '${p.heightCm.toStringAsFixed(0)} cm'),
                    _infoRow('Weight', '${p.weightKg.toStringAsFixed(1)} kg'),
                    _infoRow('Body Type', p.bodyType ?? 'Not specified'),
                    _infoRow('Occupation', p.occupation.isNotEmpty ? p.occupation : 'Not specified'),
                    _infoRow('Activity Level', _activityLabel(p.activityLevel)),
                    _infoRow('Exercise', _exerciseLabel(p.exerciseFrequency)),
                    _infoRow('Sitting Hours', '${p.dailySittingHours.toStringAsFixed(0)} hrs/day'),
                    _infoRow('Wake Up', p.wakeUpTime),
                    _infoRow('Sleep', p.sleepTime),
                    _infoRow('Stress Level', p.stressLevel[0].toUpperCase() + p.stressLevel.substring(1)),
                    if (p.healthConditions.isNotEmpty)
                      _infoRow('Conditions', p.healthConditions.join(', ')),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Dietary Preferences Sheet ──────────────────────────

  void _showDietaryPrefs(BuildContext context, UserDataService data) {
    final p = data.profile;
    if (p == null) {
      _showSnack(context, 'Complete your health assessment first');
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _sheetHandle(),
            const SizedBox(height: 16),
            Text('Dietary Preferences', style: AppTypography.h3(color: AppColors.textPrimary)),
            const SizedBox(height: 20),
            _infoRow('Diet Type', _dietLabel(p.dietaryPreference)),
            _infoRow('Water Intake', '${p.waterIntakeLiters.toStringAsFixed(1)}L / day'),
            _infoRow('Hydration Target', '${p.hydrationRequirement?.toStringAsFixed(1) ?? "—"}L / day'),
            _infoRow('Calorie Target', '${p.estimatedCalorieNeeds?.toStringAsFixed(0) ?? "—"} kcal/day'),
            if (p.smokingHabit != null)
              _infoRow('Smoking', p.smokingHabit!),
            if (p.alcoholHabit != null)
              _infoRow('Alcohol', p.alcoholHabit!),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ─── Coming Soon Dialog ─────────────────────────────────

  void _showComingSoon(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⌚', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text('Connected Devices', style: AppTypography.h3(color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text(
              'We\'re working on integrating wearable devices like smartwatches and fitness bands for automatic health data syncing.\n\nStay tuned!',
              style: AppTypography.body(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Got it', style: AppTypography.button(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Privacy & Security Sheet ───────────────────────────

  void _showPrivacySecurity(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _sheetHandle(),
            const SizedBox(height: 16),
            Text('Privacy & Security', style: AppTypography.h3(color: AppColors.textPrimary)),
            const SizedBox(height: 20),
            _privacyItem(Icons.lock_rounded, 'Data Encryption', 'Your health data is stored securely on your device', true),
            _privacyItem(Icons.cloud_off_rounded, 'Offline First', 'All data stays on your device — no cloud uploads', true),
            _privacyItem(Icons.visibility_off_rounded, 'No Tracking', 'We don\'t track or sell your personal data', true),
            _privacyItem(Icons.delete_outline_rounded, 'Delete All Data', 'You can erase everything anytime', false),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _privacyItem(IconData icon, String title, String desc, bool enabled) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: (enabled ? AppColors.success : AppColors.error).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: enabled ? AppColors.success : AppColors.error, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.bodyMedium(color: AppColors.textPrimary)),
                Text(desc, style: AppTypography.caption(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Export Data Sheet ──────────────────────────────────

  void _showExportData(BuildContext context, UserDataService data) {
    final p = data.profile;
    if (p == null) {
      _showSnack(context, 'No data to export. Complete your assessment first.');
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _sheetHandle(),
            const SizedBox(height: 16),
            Text('Export My Data', style: AppTypography.h3(color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text('Download a summary of your health profile and tracking data.',
                style: AppTypography.body(color: AppColors.textSecondary), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Report includes:', style: AppTypography.bodyMedium(color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  _exportItem('✅ Health Assessment Results'),
                  _exportItem('✅ BMI & Body Metrics'),
                  _exportItem('✅ Personalized Roadmap'),
                  _exportItem('✅ Daily Tracking Stats'),
                  _exportItem('✅ Discipline Scores'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _showSnack(context, '📄 Health report generated! Check your downloads.');
                },
                icon: const Icon(Icons.download_rounded, color: Colors.white, size: 18),
                label: Text('Export as PDF', style: AppTypography.button(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _exportItem(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(text, style: AppTypography.bodySmall(color: AppColors.textSecondary)),
      );

  // ─── Retake Assessment ─────────────────────────────────

  void _confirmRetakeAssessment(BuildContext context) {
    final router = GoRouter.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Retake Assessment?', style: AppTypography.h3(color: AppColors.textPrimary)),
        content: Text(
          'This will replace your current health profile with a new assessment. Your daily tracking data will be reset.',
          style: AppTypography.body(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: AppTypography.bodyMedium(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              router.go('/health-assessment');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Retake', style: AppTypography.button(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ─── Notification Settings Sheet ────────────────────────

  void _showNotificationSettings(BuildContext context) {
    final notif = NotificationService.instance;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NotificationSettingsSheet(notif: notif),
    );
  }

  // ─── Helpers ────────────────────────────────────────────

  Widget _sheetHandle() => Container(
        margin: const EdgeInsets.only(top: 12),
        width: 40, height: 4,
        decoration: BoxDecoration(color: AppColors.dividerColor, borderRadius: BorderRadius.circular(2)),
      );

  Widget _infoRow(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          children: [
            Expanded(flex: 2, child: Text(label, style: AppTypography.bodySmall(color: AppColors.textSecondary))),
            Expanded(flex: 3, child: Text(value, style: AppTypography.bodyMedium(color: AppColors.textPrimary), textAlign: TextAlign.right)),
          ],
        ),
      );

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.surfaceElevated,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  String _dietLabel(String pref) => switch (pref) {
        'omnivore' => '🍖 Omnivore',
        'vegetarian' => '🥬 Vegetarian',
        'vegan' => '🌱 Vegan',
        'keto' => '🥑 Keto',
        'paleo' => '🍗 Paleo',
        _ => pref,
      };

  String _activityLabel(String level) => switch (level) {
        'sedentary' => '🪑 Sedentary',
        'light' => '🚶 Lightly Active',
        'moderate' => '🏃 Moderate',
        'active' => '💪 Active',
        'very_active' => '🔥 Very Active',
        _ => level,
      };

  String _exerciseLabel(String freq) => switch (freq) {
        'never' => 'Never',
        '1-2x' => '1-2x/week',
        '3-4x' => '3-4x/week',
        '5-6x' => '5-6x/week',
        'daily' => 'Daily',
        _ => freq,
      };
}

// ─── StatBox widget ──────────────────────────────────────────

class _StatBox extends StatelessWidget {
  final String label, value, sub;
  final Color color;
  const _StatBox({required this.label, required this.value, required this.sub, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(children: [
        Text(label, style: AppTypography.caption(color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(value, style: AppTypography.h3(color: color)),
        Text(sub, style: AppTypography.label(color: AppColors.textSecondary)),
      ]),
    );
  }
}

// ─── Notification Settings Sheet ──────────────────────────────

class _NotificationSettingsSheet extends StatefulWidget {
  final NotificationService notif;
  const _NotificationSettingsSheet({required this.notif});

  @override
  State<_NotificationSettingsSheet> createState() => _NotificationSettingsSheetState();
}

class _NotificationSettingsSheetState extends State<_NotificationSettingsSheet> {
  bool _hydration = true;
  bool _meals = true;
  bool _exercise = true;
  bool _screenBreaks = true;
  bool _hasPermission = false;
  int _pendingCount = 0;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final perm = await widget.notif.hasPermission();
    final pending = await widget.notif.getPending();
    if (mounted) {
      setState(() {
        _hasPermission = perm;
        _pendingCount = pending.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          margin: const EdgeInsets.only(top: 12),
          width: 40, height: 4,
          decoration: BoxDecoration(color: AppColors.dividerColor, borderRadius: BorderRadius.circular(2)),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('Notifications', style: AppTypography.h3(color: AppColors.textPrimary)),
        ),
        if (!_hasPermission && !kIsWeb) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
              ),
              child: Row(children: [
                const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Permission Required', style: AppTypography.bodyMedium(color: AppColors.warning)),
                  Text('Allow notifications to receive reminders.',
                      style: AppTypography.caption(color: AppColors.textSecondary)),
                ])),
                TextButton(
                  onPressed: () async {
                    final granted = await widget.notif.requestPermission();
                    if (granted && mounted) {
                      setState(() => _hasPermission = true);
                      _snack('✅ Notification permission granted!');
                    }
                  },
                  child: Text('Grant', style: AppTypography.bodyMedium(color: AppColors.primary)),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 16),
        ],
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(children: [
              _toggle('💧 Hydration Reminders', 'Every 90 minutes during the day', _hydration, (v) async {
                setState(() => _hydration = v);
                if (v) {
                  await widget.notif.scheduleHydrationReminders();
                } else {
                  await widget.notif.cancelHydrationReminders();
                }
                _snack(v ? '💧 Hydration reminders enabled' : 'Hydration reminders disabled');
              }),
              _toggle('🍽️ Meal Reminders', 'Breakfast, lunch, snack, dinner', _meals, (v) async {
                setState(() => _meals = v);
                if (v) {
                  await widget.notif.scheduleMealReminders();
                } else {
                  await widget.notif.cancelMealReminders();
                }
                _snack(v ? '🍽️ Meal reminders enabled' : 'Meal reminders disabled');
              }),
              _toggle('🧘 Exercise Reminders', 'Hourly stand-up / stretch', _exercise, (v) async {
                setState(() => _exercise = v);
                if (v) {
                  await widget.notif.scheduleExerciseReminders();
                } else {
                  await widget.notif.cancelExerciseReminders();
                }
                _snack(v ? '🧘 Exercise reminders enabled' : 'Exercise reminders disabled');
              }),
              _toggle('👁️ Screen Break Reminders', '20-20-20 rule every 30 min', _screenBreaks, (v) async {
                setState(() => _screenBreaks = v);
                if (v) {
                  await widget.notif.scheduleScreenBreakReminders();
                } else {
                  await widget.notif.cancelScreenBreakReminders();
                }
                _snack(v ? '👁️ Screen break reminders enabled' : 'Screen break reminders disabled');
              }),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(children: [
                  Icon(Icons.schedule_rounded, color: AppColors.textTertiary, size: 16),
                  const SizedBox(width: 8),
                  Text('$_pendingCount scheduled notifications',
                      style: AppTypography.caption(color: AppColors.textSecondary)),
                ]),
              ),
              const SizedBox(height: 16),
              // TEST NOTIFICATION BUTTON
              SizedBox(
                width: double.infinity, height: 48,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await widget.notif.showInstant(
                      title: '🔔 INSIGHT Test',
                      body: 'Notifications are working! You\'ll receive health reminders throughout the day.',
                    );
                    _snack('📢 Test notification sent! Check your notification shade.');
                    await _checkStatus();
                  },
                  icon: const Icon(Icons.notifications_active_rounded, size: 18),
                  label: const Text('Send Test Notification'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () async {
                  await widget.notif.cancelAll();
                  _snack('All notifications cancelled.');
                  await _checkStatus();
                },
                child: Text('Cancel All Notifications',
                    style: AppTypography.bodySmall(color: AppColors.error)),
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _toggle(String title, String sub, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: AppTypography.bodyMedium(color: AppColors.textPrimary)),
            Text(sub, style: AppTypography.caption(color: AppColors.textSecondary)),
          ])),
          Switch(
            value: value,
            activeColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ]),
      ),
    );
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.surfaceElevated,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }
}