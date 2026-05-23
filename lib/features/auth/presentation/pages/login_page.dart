import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_theme.dart';

/// Login screen with email/password and social auth.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppTheme.spacing48),

              // ─── Header ─────────────────────────────────
              Text(
                'Welcome\nBack ✨',
                style: AppTypography.display(
                  color: AppColors.darkTextPrimary,
                ),
              ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.1, end: 0),

              const SizedBox(height: AppTheme.spacing8),
              Text(
                'Sign in to continue your health journey',
                style: AppTypography.bodyLarge(
                  color: AppColors.darkTextSecondary,
                ),
              ).animate(delay: 200.ms).fadeIn(duration: 400.ms),

              const SizedBox(height: AppTheme.spacing40),

              // ─── Email Field ────────────────────────────
              _buildField(
                controller: _emailController,
                hint: 'Email address',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ).animate(delay: 300.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: AppTheme.spacing16),

              // ─── Password Field ─────────────────────────
              _buildField(
                controller: _passwordController,
                hint: 'Password',
                icon: Icons.lock_outline_rounded,
                obscure: _obscurePassword,
                suffix: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.darkTextTertiary,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ).animate(delay: 400.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: AppTheme.spacing12),

              // ─── Forgot Password ────────────────────────
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    'Forgot Password?',
                    style: AppTypography.bodySmall(
                      color: AppColors.primaryLight,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppTheme.spacing24),

              // ─── Sign In Button ─────────────────────────
              SizedBox(
                width: double.infinity,
                height: 56,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () => context.go('/home'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusFull),
                      ),
                    ),
                    child: Text(
                      'Sign In',
                      style: AppTypography.button(color: Colors.white),
                    ),
                  ),
                ),
              )
                  .animate(delay: 500.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.2, end: 0),

              const SizedBox(height: AppTheme.spacing32),

              // ─── Divider ────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1,
                      color: AppColors.darkDivider,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacing16),
                    child: Text(
                      'or continue with',
                      style: AppTypography.caption(
                        color: AppColors.darkTextTertiary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: AppColors.darkDivider,
                    ),
                  ),
                ],
              ).animate(delay: 600.ms).fadeIn(duration: 400.ms),

              const SizedBox(height: AppTheme.spacing24),

              // ─── Social Login Buttons ───────────────────
              _buildSocialButton(
                label: 'Continue with Google',
                icon: Icons.g_mobiledata_rounded,
                iconColor: AppColors.error,
                onPressed: () => context.go('/home'),
              ).animate(delay: 700.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: AppTheme.spacing12),

              _buildSocialButton(
                label: 'Continue with Apple',
                icon: Icons.apple_rounded,
                iconColor: AppColors.darkTextPrimary,
                onPressed: () => context.go('/home'),
              ).animate(delay: 800.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: AppTheme.spacing32),

              // ─── Register Link ──────────────────────────
              Center(
                child: TextButton(
                  onPressed: () => context.go('/register'),
                  child: RichText(
                    text: TextSpan(
                      text: "Don't have an account? ",
                      style: AppTypography.body(
                        color: AppColors.darkTextSecondary,
                      ),
                      children: [
                        TextSpan(
                          text: 'Sign Up',
                          style: AppTypography.bodyMedium(
                            color: AppColors.primaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate(delay: 900.ms).fadeIn(duration: 400.ms),

              const SizedBox(height: AppTheme.spacing24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscure = false,
    Widget? suffix,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceElevated,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppColors.darkDivider),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscure,
        style: AppTypography.body(color: AppColors.darkTextPrimary),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: AppColors.darkTextTertiary, size: 20),
          suffixIcon: suffix,
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing20,
            vertical: AppTheme.spacing16,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required String label,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: iconColor, size: 28),
        label: Text(
          label,
          style: AppTypography.bodyMedium(color: AppColors.darkTextPrimary),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.darkDivider),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
          backgroundColor: AppColors.darkSurface,
        ),
      ),
    );
  }
}
