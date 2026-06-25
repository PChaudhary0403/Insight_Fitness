import 'package:flutter/material.dart';
import '../../shared/services/theme_service.dart';

/// INSIGHT Design System — Color Palette
/// Professional, data-driven analytics platform color system.
class AppColors {
  AppColors._();

  static bool get _isDark => ThemeService.instance.isDark;

  // ─── Theme-Adaptive Getters ─────────────────────────────
  static Color get bg => _isDark ? darkBackground : lightBackground;
  static Color get surface => _isDark ? darkSurface : lightSurface;
  static Color get surfaceElevated => _isDark ? darkSurfaceElevated : lightSurfaceElevated;
  static Color get textPrimary => _isDark ? darkTextPrimary : lightTextPrimary;
  static Color get textSecondary => _isDark ? darkTextSecondary : lightTextSecondary;
  static Color get textTertiary => _isDark ? darkTextTertiary : lightTextTertiary;
  static Color get dividerColor => _isDark ? darkDivider : lightDivider;
  static Color get cardBorder => _isDark ? darkCardBorder : lightCardBorder;

  // ─── Brand Colors (Professional, muted) ─────────────────
  static const Color primary = Color(0xFF4A90A4);      // Muted teal — trustworthy
  static const Color primaryLight = Color(0xFF5BA3B8);
  static const Color primaryDark = Color(0xFF3A7A8E);
  static const Color secondary = Color(0xFF6B7B8D);    // Slate — professional
  static const Color secondaryLight = Color(0xFF7D8D9F);
  static const Color accent = Color(0xFF4B6584);        // Navy-slate accent

  // ─── Light Mode ─────────────────────────────────────────
  static const Color lightBackground = Color(0xFFF7F8FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF1B2631);
  static const Color lightTextSecondary = Color(0xFF5D6D7E);
  static const Color lightTextTertiary = Color(0xFF95A5A6);
  static const Color lightDivider = Color(0xFFE8ECF0);
  static const Color lightCardBorder = Color(0xFFEBEEF2);

  // ─── Dark Mode (Charcoal / Dark Slate) ──────────────────
  static const Color darkBackground = Color(0xFF0F1419);
  static const Color darkSurface = Color(0xFF1A1F27);
  static const Color darkSurfaceElevated = Color(0xFF242B35);
  static const Color darkTextPrimary = Color(0xFFE8ECF0);
  static const Color darkTextSecondary = Color(0xFF8B949E);
  static const Color darkTextTertiary = Color(0xFF6B7685);
  static const Color darkDivider = Color(0xFF2D3540);
  static const Color darkCardBorder = Color(0xFF242B35);

  // ─── Semantic Colors (Muted, professional) ──────────────
  static const Color success = Color(0xFF27AE60);
  static const Color successDark = Color(0xFF2ECC71);
  static const Color warning = Color(0xFFD4A017);
  static const Color warningDark = Color(0xFFC79B1B);
  static const Color error = Color(0xFFC0392B);
  static const Color errorDark = Color(0xFFE74C3C);
  static const Color info = Color(0xFF2C7BE5);
  static const Color infoDark = Color(0xFF4A9BF5);

  // ─── Score Colors (Subdued, analytical) ─────────────────
  static const Color scoreDangerStart = Color(0xFF922B21);
  static const Color scoreDangerEnd = Color(0xFFC0392B);
  static const Color scoreWarningStart = Color(0xFFC0392B);
  static const Color scoreWarningEnd = Color(0xFFD4A017);
  static const Color scoreCautionStart = Color(0xFFD4A017);
  static const Color scoreCautionEnd = Color(0xFFD4B83B);
  static const Color scoreImprovingStart = Color(0xFFD4B83B);
  static const Color scoreImprovingEnd = Color(0xFF27AE60);
  static const Color scoreGoodStart = Color(0xFF1E8449);
  static const Color scoreGoodEnd = Color(0xFF27AE60);
  static const Color scoreExcellentStart = Color(0xFF148F77);
  static const Color scoreExcellentEnd = Color(0xFF4A90A4);

  // ─── Category Colors (Muted, consistent) ────────────────
  static const Color hydration = Color(0xFF2C7BE5);
  static const Color nutrition = Color(0xFFD4A017);
  static const Color movement = Color(0xFF27AE60);
  static const Color exercise = Color(0xFFC0392B);
  static const Color sleep = Color(0xFF6C63AC);
  static const Color mindfulness = Color(0xFF4A90A4);

  // ─── Gradient Presets (Subtle, professional) ─────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF1A1F27), Color(0xFF151A22)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Returns gradient colors based on score (0-100).
  static List<Color> healthScoreGradient(int score) {
    if (score <= 20) return [scoreDangerStart, scoreDangerEnd];
    if (score <= 35) return [scoreWarningStart, scoreWarningEnd];
    if (score <= 50) return [scoreCautionStart, scoreCautionEnd];
    if (score <= 65) return [scoreImprovingStart, scoreImprovingEnd];
    if (score <= 80) return [scoreGoodStart, scoreGoodEnd];
    return [scoreExcellentStart, scoreExcellentEnd];
  }

  /// Returns a single color for a score.
  static Color healthScoreColor(int score) {
    if (score <= 20) return scoreDangerStart;
    if (score <= 35) return scoreWarningStart;
    if (score <= 50) return scoreCautionStart;
    if (score <= 65) return scoreImprovingEnd;
    if (score <= 80) return scoreGoodStart;
    return scoreExcellentStart;
  }

  /// Returns analytical label for a score.
  static String healthScoreLabel(int score) {
    if (score <= 20) return 'Critical';
    if (score <= 35) return 'Below Average';
    if (score <= 50) return 'Average';
    if (score <= 65) return 'Above Average';
    if (score <= 80) return 'Good';
    return 'Optimal';
  }
}
