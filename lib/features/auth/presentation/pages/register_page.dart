import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_theme.dart';

/// Registration screen.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppTheme.spacing40),

              // ─── Back Button ────────────────────────────
              IconButton(
                onPressed: () => context.go('/welcome'),
                icon: Icon(
                  Icons.arrow_back_ios_rounded,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: AppTheme.spacing16),

              // ─── Header ─────────────────────────────────
              Text(
                'Create\nAccount 🚀',
                style: AppTypography.display(color: AppColors.textPrimary),
              ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.1, end: 0),

              const SizedBox(height: AppTheme.spacing8),
              Text(
                'Start your health journey today',
                style: AppTypography.bodyLarge(
                  color: AppColors.textSecondary,
                ),
              ).animate(delay: 200.ms).fadeIn(duration: 400.ms),

              const SizedBox(height: AppTheme.spacing32),

              // ─── Name Field ─────────────────────────────
              _buildField(
                controller: _nameController,
                hint: 'Full name',
                icon: Icons.person_outline_rounded,
              ).animate(delay: 300.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: AppTheme.spacing16),

              // ─── Email Field ────────────────────────────
              _buildField(
                controller: _emailController,
                hint: 'Email address',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ).animate(delay: 400.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

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
                    color: AppColors.textTertiary,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ).animate(delay: 500.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: AppTheme.spacing32),

              // ─── Create Account Button ──────────────────
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
                    onPressed: () => context.go('/health-assessment'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusFull),
                      ),
                    ),
                    child: Text(
                      'Create Account',
                      style: AppTypography.button(color: Colors.white),
                    ),
                  ),
                ),
              )
                  .animate(delay: 600.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.2, end: 0),

              const SizedBox(height: AppTheme.spacing24),

              // ─── Divider ────────────────────────────────
              Row(
                children: [
                  Expanded(child: Container(height: 1, color: AppColors.dividerColor)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
                    child: Text('or', style: AppTypography.caption(color: AppColors.textTertiary)),
                  ),
                  Expanded(child: Container(height: 1, color: AppColors.dividerColor)),
                ],
              ).animate(delay: 700.ms).fadeIn(duration: 400.ms),

              const SizedBox(height: AppTheme.spacing24),

              // ─── Social Buttons ─────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _buildSocialTile(Icons.g_mobiledata_rounded, AppColors.error, () => context.go('/health-assessment')),
                  ),
                  const SizedBox(width: AppTheme.spacing16),
                  Expanded(
                    child: _buildSocialTile(Icons.apple_rounded, AppColors.textPrimary, () => context.go('/health-assessment')),
                  ),
                ],
              ).animate(delay: 800.ms).fadeIn(duration: 400.ms),

              const SizedBox(height: AppTheme.spacing32),

              // ─── Login Link ─────────────────────────────
              Center(
                child: TextButton(
                  onPressed: () => context.go('/login'),
                  child: RichText(
                    text: TextSpan(
                      text: 'Already have an account? ',
                      style: AppTypography.body(color: AppColors.textSecondary),
                      children: [
                        TextSpan(
                          text: 'Sign In',
                          style: AppTypography.bodyMedium(color: AppColors.primaryLight),
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
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppColors.dividerColor),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscure,
        style: AppTypography.body(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: AppColors.textTertiary, size: 20),
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

  Widget _buildSocialTile(IconData icon, Color color, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(color: AppColors.dividerColor),
        ),
        child: Center(
          child: Icon(icon, color: color, size: 32),
        ),
      ),
    );
  }
}
