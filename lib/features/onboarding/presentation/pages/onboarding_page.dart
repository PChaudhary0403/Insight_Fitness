import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_theme.dart';

class _OnboardingSlide {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;

  const _OnboardingSlide({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
  });
}

/// Onboarding flow with 3 animated slides.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  static const List<_OnboardingSlide> _slides = [
    _OnboardingSlide(
      icon: Icons.track_changes_rounded,
      title: 'Track Everything',
      subtitle:
          'Monitor hydration, diet, exercise, and sleep — all in one beautiful app. Your health, unified.',
      gradient: [Color(0xFF00C9A7), Color(0xFF00E5BF)],
    ),
    _OnboardingSlide(
      icon: Icons.notifications_active_rounded,
      title: 'Smart Reminders',
      subtitle:
          'Adaptive reminders that learn your routine. Whether you\'re at a desk or on the field, INSIGHT adapts to you.',
      gradient: [Color(0xFF845EF7), Color(0xFF9775FA)],
    ),
    _OnboardingSlide(
      icon: Icons.insights_rounded,
      title: 'See Your Progress',
      subtitle:
          'Beautiful analytics, health scores, and streaks. Watch your wellness transform with data-driven insights.',
      gradient: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < _slides.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/register');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Skip Button ──────────────────────────────
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacing16),
                child: TextButton(
                  onPressed: () => context.go('/register'),
                  child: Text(
                    'Skip',
                    style: AppTypography.bodyMedium(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),

            // ─── PageView ─────────────────────────────────
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing32,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon with glow
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: slide.gradient,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: slide.gradient[0].withValues(alpha: 0.4),
                                blurRadius: 50,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: Icon(
                            slide.icon,
                            size: 64,
                            color: Colors.white,
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 500.ms)
                            .scale(
                              begin: const Offset(0.7, 0.7),
                              end: const Offset(1.0, 1.0),
                              duration: 600.ms,
                              curve: Curves.elasticOut,
                            ),

                        const SizedBox(height: AppTheme.spacing48),

                        // Title
                        Text(
                          slide.title,
                          style: AppTypography.h1(
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        )
                            .animate()
                            .fadeIn(delay: 200.ms, duration: 400.ms)
                            .slideY(begin: 0.2, end: 0, duration: 400.ms),

                        const SizedBox(height: AppTheme.spacing16),

                        // Subtitle
                        Text(
                          slide.subtitle,
                          style: AppTypography.bodyLarge(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        )
                            .animate()
                            .fadeIn(delay: 400.ms, duration: 400.ms)
                            .slideY(begin: 0.2, end: 0, duration: 400.ms),
                      ],
                    ),
                  );
                },
              ),
            ),

            // ─── Page Indicator ───────────────────────────
            SmoothPageIndicator(
              controller: _controller,
              count: _slides.length,
              effect: ExpandingDotsEffect(
                activeDotColor: AppColors.primary,
                dotColor: AppColors.surfaceElevated,
                dotHeight: 8,
                dotWidth: 8,
                expansionFactor: 3,
                spacing: 8,
              ),
            ),

            const SizedBox(height: AppTheme.spacing40),

            // ─── Next / Get Started Button ────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing32,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _slides[_currentPage].gradient[0],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    ),
                  ),
                  child: Text(
                    _currentPage == _slides.length - 1
                        ? 'Create Account'
                        : 'Next',
                    style: AppTypography.button(color: Colors.white),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppTheme.spacing32),
          ],
        ),
      ),
    );
  }
}
