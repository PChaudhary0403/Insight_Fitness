import 'package:flutter/material.dart';

/// INSIGHT Design System — Color Palette
/// Clean, futuristic, health-tech color system with dynamic health score colors.
class AppColors {
  AppColors._();

  // ─── Brand Colors ───────────────────────────────────────
  static const Color primary = Color(0xFF00C9A7);
  static const Color primaryLight = Color(0xFF00E5BF);
  static const Color primaryDark = Color(0xFF00A88A);
  static const Color secondary = Color(0xFF845EF7);
  static const Color secondaryLight = Color(0xFF9775FA);
  static const Color accent = Color(0xFF3B82F6);

  // ─── Light Mode ─────────────────────────────────────────
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF1A1A2E);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightTextTertiary = Color(0xFF9CA3AF);
  static const Color lightDivider = Color(0xFFE5E7EB);
  static const Color lightCardBorder = Color(0xFFF0F0F5);

  // ─── Dark Mode ──────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0D1117);
  static const Color darkSurface = Color(0xFF161B22);
  static const Color darkSurfaceElevated = Color(0xFF21262D);
  static const Color darkTextPrimary = Color(0xFFF0F6FC);
  static const Color darkTextSecondary = Color(0xFF8B949E);
  static const Color darkTextTertiary = Color(0xFF6E7681);
  static const Color darkDivider = Color(0xFF30363D);
  static const Color darkCardBorder = Color(0xFF21262D);

  // ─── Semantic Colors ────────────────────────────────────
  static const Color success = Color(0xFF22C55E);
  static const Color successDark = Color(0xFF3FB950);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningDark = Color(0xFFD29922);
  static const Color error = Color(0xFFEF4444);
  static const Color errorDark = Color(0xFFF85149);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoDark = Color(0xFF58A6FF);

  // ─── Health Score Dynamic Colors (Color Psychology) ─────
  static const Color scoreDangerStart = Color(0xFFC0392B);
  static const Color scoreDangerEnd = Color(0xFFE74C3C);
  static const Color scoreWarningStart = Color(0xFFE74C3C);
  static const Color scoreWarningEnd = Color(0xFFF39C12);
  static const Color scoreCautionStart = Color(0xFFF39C12);
  static const Color scoreCautionEnd = Color(0xFFF1C40F);
  static const Color scoreImprovingStart = Color(0xFFF1C40F);
  static const Color scoreImprovingEnd = Color(0xFF2ECC71);
  static const Color scoreGoodStart = Color(0xFF27AE60);
  static const Color scoreGoodEnd = Color(0xFF2ECC71);
  static const Color scoreExcellentStart = Color(0xFF1ABC9C);
  static const Color scoreExcellentEnd = Color(0xFF00C9A7);

  // ─── Category Colors ────────────────────────────────────
  static const Color hydration = Color(0xFF3B82F6);
  static const Color nutrition = Color(0xFFF59E0B);
  static const Color movement = Color(0xFF22C55E);
  static const Color exercise = Color(0xFFEF4444);
  static const Color sleep = Color(0xFF845EF7);
  static const Color mindfulness = Color(0xFF06B6D4);

  // ─── Gradient Presets ───────────────────────────────────
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
    colors: [Color(0xFF1A1F2E), Color(0xFF16192A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Returns the gradient colors based on the health score (0-100).
  static List<Color> healthScoreGradient(int score) {
    if (score <= 20) {
      return [scoreDangerStart, scoreDangerEnd];
    } else if (score <= 35) {
      return [scoreWarningStart, scoreWarningEnd];
    } else if (score <= 50) {
      return [scoreCautionStart, scoreCautionEnd];
    } else if (score <= 65) {
      return [scoreImprovingStart, scoreImprovingEnd];
    } else if (score <= 80) {
      return [scoreGoodStart, scoreGoodEnd];
    } else {
      return [scoreExcellentStart, scoreExcellentEnd];
    }
  }

  /// Returns a single representative color for a health score.
  static Color healthScoreColor(int score) {
    if (score <= 20) return scoreDangerStart;
    if (score <= 35) return scoreWarningStart;
    if (score <= 50) return scoreCautionStart;
    if (score <= 65) return scoreImprovingEnd;
    if (score <= 80) return scoreGoodStart;
    return scoreExcellentStart;
  }

  /// Returns the label for a health score.
  static String healthScoreLabel(int score) {
    if (score <= 20) return 'Poor';
    if (score <= 35) return 'Needs Work';
    if (score <= 50) return 'Average';
    if (score <= 65) return 'Good';
    if (score <= 80) return 'Very Good';
    return 'Excellent';
  }
}
