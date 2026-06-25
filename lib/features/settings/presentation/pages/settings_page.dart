import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/services/theme_service.dart';

/// Settings page with theme toggle and app preferences.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _theme = ThemeService.instance;

  @override
  void initState() {
    super.initState();
    _theme.addListener(_refresh);
  }

  @override
  void dispose() {
    _theme.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final isDark = _theme.isDark;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: Text('Settings', style: AppTypography.h3(color: AppColors.textPrimary)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacing24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ─── Appearance Section ──────────────────────
          Text('Appearance', style: AppTypography.h4(color: AppColors.textPrimary))
              .animate().fadeIn(duration: 300.ms),
          const SizedBox(height: 12),

          // Theme toggle card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface, borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(children: [
              Row(children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    gradient: isDark
                        ? const LinearGradient(colors: [Color(0xFF1a1a2e), Color(0xFF16213e)])
                        : const LinearGradient(colors: [Color(0xFFF8F9FA), Color(0xFFE9ECEF)]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    color: isDark ? const Color(0xFFBB86FC) : const Color(0xFFFF9800),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Theme', style: AppTypography.bodyMedium(color: AppColors.textPrimary)),
                  Text(isDark ? 'Dark Mode' : 'Light Mode',
                    style: AppTypography.caption(color: AppColors.textSecondary)),
                ])),
                Switch(
                  value: isDark,
                  activeColor: AppColors.primary,
                  activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
                  inactiveThumbColor: const Color(0xFFFF9800),
                  inactiveTrackColor: const Color(0xFFFF9800).withValues(alpha: 0.3),
                  onChanged: (_) => _theme.toggle(),
                ),
              ]),
              const SizedBox(height: 12),
              // Visual preview
              Row(children: [
                Expanded(child: _ThemePreview(
                  label: 'Light',
                  isSelected: !isDark,
                  bgColor: const Color(0xFFF8F9FA),
                  surfaceColor: Colors.white,
                  textColor: const Color(0xFF1A1A2E),
                  onTap: () => _theme.setMode(ThemeMode.light),
                )),
                const SizedBox(width: 12),
                Expanded(child: _ThemePreview(
                  label: 'Dark',
                  isSelected: isDark,
                  bgColor: const Color(0xFF0D1117),
                  surfaceColor: const Color(0xFF161B22),
                  textColor: const Color(0xFFF0F6FC),
                  onTap: () => _theme.setMode(ThemeMode.dark),
                )),
              ]),
            ]),
          ).animate(delay: 100.ms).fadeIn(duration: 400.ms),

          const SizedBox(height: 24),

          // ─── General Section ────────────────────────
          Text('General', style: AppTypography.h4(color: AppColors.textPrimary))
              .animate(delay: 200.ms).fadeIn(duration: 300.ms),
          const SizedBox(height: 12),

          _SettingTile(
            icon: Icons.language_rounded, title: 'Language', subtitle: 'English',
            color: AppColors.info,
          ).animate(delay: 250.ms).fadeIn(duration: 400.ms),
          const SizedBox(height: 8),
          _SettingTile(
            icon: Icons.straighten_rounded, title: 'Units', subtitle: 'Metric (kg, cm, L)',
            color: AppColors.movement,
          ).animate(delay: 300.ms).fadeIn(duration: 400.ms),

          const SizedBox(height: 24),

          // ─── About Section ──────────────────────────
          Text('About', style: AppTypography.h4(color: AppColors.textPrimary))
              .animate(delay: 350.ms).fadeIn(duration: 300.ms),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface, borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(children: [
              _aboutRow('App', 'INSIGHT'),
              _aboutRow('Version', '1.0.0'),
              _aboutRow('Build', 'Flutter 3.38'),
              _aboutRow('Platform', Theme.of(context).platform.name),
            ]),
          ).animate(delay: 400.ms).fadeIn(duration: 400.ms),

          const SizedBox(height: 20),
          Center(
            child: Text('Made with ❤️ by Pankaj',
              style: AppTypography.caption(color: AppColors.textSecondary)),
          ).animate(delay: 500.ms).fadeIn(),
        ]),
      ),
    );
  }

  Widget _aboutRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(children: [
      Expanded(child: Text(label, style: AppTypography.bodySmall(color: AppColors.textSecondary))),
      Text(value, style: AppTypography.bodyMedium(color: AppColors.textPrimary)),
    ]),
  );
}

// ─── Theme Preview Mini Card ────────────────────────────────

class _ThemePreview extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color bgColor, surfaceColor, textColor;
  final VoidCallback onTap;
  const _ThemePreview({
    required this.label, required this.isSelected,
    required this.bgColor, required this.surfaceColor, required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: 250.ms,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor, borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(children: [
          Container(height: 6, width: double.infinity,
            decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(3))),
          const SizedBox(height: 6),
          Container(height: 6, width: double.infinity * 0.7,
            decoration: BoxDecoration(color: surfaceColor.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(3))),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 14),
            if (isSelected) const SizedBox(width: 4),
            Text(label, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600)),
          ]),
        ]),
      ),
    );
  }
}

// ─── Setting Tile ───────────────────────────────────────────

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final Color color;
  const _SettingTile({
    required this.icon, required this.title, required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: AppTypography.bodyMedium(color: AppColors.textPrimary)),
          Text(subtitle, style: AppTypography.caption(color: AppColors.textSecondary)),
        ])),
        Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 20),
      ]),
    );
  }
}
