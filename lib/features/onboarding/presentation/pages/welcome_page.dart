import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_theme.dart';

/// Welcome / Splash screen with animated branding.
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0D1117),
              Color(0xFF0A1628),
              Color(0xFF0D1117),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing32),
            child: Column(
              children: [
                const Spacer(flex: 3),

                // ─── Logo ───────────────────────────────────
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 40,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    size: 56,
                    color: Colors.white,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 800.ms, curve: Curves.easeOut)
                    .scale(
                      begin: const Offset(0.5, 0.5),
                      end: const Offset(1.0, 1.0),
                      duration: 800.ms,
                      curve: Curves.elasticOut,
                    ),

                const SizedBox(height: AppTheme.spacing24),

                // ─── App Name ───────────────────────────────
                Text(
                  'INSIGHT',
                  style: AppTypography.display(
                    color: AppColors.darkTextPrimary,
                  ).copyWith(
                    fontSize: 40,
                    letterSpacing: 8,
                  ),
                )
                    .animate(delay: 400.ms)
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.3, end: 0, duration: 600.ms),

                const SizedBox(height: AppTheme.spacing12),

                // ─── Tagline ────────────────────────────────
                Text(
                  'Your Personal Health Companion',
                  style: AppTypography.bodyLarge(
                    color: AppColors.darkTextSecondary,
                  ),
                )
                    .animate(delay: 700.ms)
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.3, end: 0, duration: 600.ms),

                const Spacer(flex: 3),

                // ─── Get Started Button ─────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => context.go('/onboarding'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Get Started',
                      style: AppTypography.button(color: Colors.white),
                    ),
                  ),
                )
                    .animate(delay: 1000.ms)
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.5, end: 0, duration: 600.ms),

                const SizedBox(height: AppTheme.spacing16),

                // ─── Login Link ─────────────────────────────
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: RichText(
                    text: TextSpan(
                      text: 'Already have an account? ',
                      style: AppTypography.body(
                        color: AppColors.darkTextSecondary,
                      ),
                      children: [
                        TextSpan(
                          text: 'Sign In',
                          style: AppTypography.bodyMedium(
                            color: AppColors.primaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    .animate(delay: 1200.ms)
                    .fadeIn(duration: 600.ms),

                const SizedBox(height: AppTheme.spacing32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
