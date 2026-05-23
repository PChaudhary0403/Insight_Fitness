import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// INSIGHT Design System — Typography
class AppTypography {
  AppTypography._();

  // ─── Display ────────────────────────────────────────────
  static TextStyle display({Color? color}) => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.2,
        letterSpacing: -0.5,
      );

  // ─── Headings ───────────────────────────────────────────
  static TextStyle h1({Color? color}) => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.3,
        letterSpacing: -0.3,
      );

  static TextStyle h2({Color? color}) => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.3,
      );

  static TextStyle h3({Color? color}) => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.4,
      );

  static TextStyle h4({Color? color}) => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.4,
      );

  // ─── Body ───────────────────────────────────────────────
  static TextStyle bodyLarge({Color? color}) => GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.5,
      );

  static TextStyle body({Color? color}) => GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.5,
      );

  static TextStyle bodyMedium({Color? color}) => GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: color,
        height: 1.5,
      );

  static TextStyle bodySmall({Color? color}) => GoogleFonts.outfit(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.5,
      );

  // ─── Caption & Label ────────────────────────────────────
  static TextStyle caption({Color? color}) => GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.4,
      );

  static TextStyle label({Color? color}) => GoogleFonts.outfit(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: color,
        height: 1.3,
        letterSpacing: 0.5,
      );

  // ─── Button ─────────────────────────────────────────────
  static TextStyle button({Color? color}) => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.2,
        letterSpacing: 0.3,
      );

  static TextStyle buttonSmall({Color? color}) => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.2,
      );

  // ─── Numeric / Score ────────────────────────────────────
  static TextStyle score({Color? color}) => GoogleFonts.inter(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.0,
        letterSpacing: -1,
      );

  static TextStyle scoreMedium({Color? color}) => GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.0,
        letterSpacing: -0.5,
      );

  static TextStyle metric({Color? color}) => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.2,
      );
}
