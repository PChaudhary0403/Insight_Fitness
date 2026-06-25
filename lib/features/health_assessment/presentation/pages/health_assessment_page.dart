import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/services/user_data_service.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/health_profile.dart';
import '../../domain/health_analysis_engine.dart';
import '../widgets/assessment_step_basic.dart';
import '../widgets/assessment_step_lifestyle.dart';
import '../widgets/assessment_step_habits.dart';
import '../widgets/assessment_step_optional.dart';
import 'health_results_page.dart';

/// Multi-step health assessment onboarding wizard.
class HealthAssessmentPage extends StatefulWidget {
  const HealthAssessmentPage({super.key});

  @override
  State<HealthAssessmentPage> createState() => _HealthAssessmentPageState();
}

class _HealthAssessmentPageState extends State<HealthAssessmentPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  static const int _totalSteps = 4;

  // ─── Form data ──────────────────────────────────────────
  String _fullName = '';
  int _age = 25;
  String _gender = 'male';
  double _heightCm = 170;
  double _weightKg = 70;
  String? _bodyType;
  String _activityLevel = 'sedentary';
  String _occupation = '';
  double _dailySittingHours = 8;
  String _wakeUpTime = '07:00';
  String _sleepTime = '23:00';
  String _exerciseFrequency = 'never';
  String _dietaryPreference = 'omnivore';
  double _waterIntakeLiters = 2.0;
  String _stressLevel = 'moderate';
  String? _smokingHabit;
  String? _alcoholHabit;
  List<String> _healthConditions = [];

  final _stepTitles = [
    'Basic Health Info',
    'Lifestyle & Activity',
    'Diet & Wellness',
    'Optional Details',
  ];

  final _stepSubtitles = [
    'Let\'s start with the basics',
    'Tell us about your daily routine',
    'Your diet and wellness habits',
    'Help us fine-tune your plan',
  ];



  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _submitAssessment();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _submitAssessment() async {
    final raw = HealthProfile(
      fullName: _fullName,
      age: _age,
      gender: _gender,
      heightCm: _heightCm,
      weightKg: _weightKg,
      bodyType: _bodyType,
      activityLevel: _activityLevel,
      occupation: _occupation,
      dailySittingHours: _dailySittingHours,
      wakeUpTime: _wakeUpTime,
      sleepTime: _sleepTime,
      exerciseFrequency: _exerciseFrequency,
      dietaryPreference: _dietaryPreference,
      waterIntakeLiters: _waterIntakeLiters,
      stressLevel: _stressLevel,
      smokingHabit: _smokingHabit,
      alcoholHabit: _alcoholHabit,
      healthConditions: _healthConditions,
    );

    final analyzed = HealthAnalysisEngine.analyze(raw);

    // Persist the profile so the dashboard reads real data
    await UserDataService.instance.saveProfile(analyzed);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => HealthResultsPage(profile: analyzed),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header ────────────────────────────────────
            _buildHeader(),
            // ─── Progress ──────────────────────────────────
            _buildProgress(),
            const SizedBox(height: AppTheme.spacing16),
            // ─── Step Content ──────────────────────────────
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentStep = i),
                children: [
                  AssessmentStepBasic(
                    fullName: _fullName,
                    age: _age,
                    gender: _gender,
                    heightCm: _heightCm,
                    weightKg: _weightKg,
                    onChanged: (name, age, gender, height, weight) {
                      setState(() {
                        _fullName = name;
                        _age = age;
                        _gender = gender;
                        _heightCm = height;
                        _weightKg = weight;
                      });
                    },
                  ),
                  AssessmentStepLifestyle(
                    activityLevel: _activityLevel,
                    occupation: _occupation,
                    dailySittingHours: _dailySittingHours,
                    wakeUpTime: _wakeUpTime,
                    sleepTime: _sleepTime,
                    exerciseFrequency: _exerciseFrequency,
                    onChanged: (activity, occ, sitting, wake, sleep, exercise) {
                      setState(() {
                        _activityLevel = activity;
                        _occupation = occ;
                        _dailySittingHours = sitting;
                        _wakeUpTime = wake;
                        _sleepTime = sleep;
                        _exerciseFrequency = exercise;
                      });
                    },
                  ),
                  AssessmentStepHabits(
                    dietaryPreference: _dietaryPreference,
                    waterIntakeLiters: _waterIntakeLiters,
                    stressLevel: _stressLevel,
                    onChanged: (diet, water, stress) {
                      setState(() {
                        _dietaryPreference = diet;
                        _waterIntakeLiters = water;
                        _stressLevel = stress;
                      });
                    },
                  ),
                  AssessmentStepOptional(
                    bodyType: _bodyType,
                    smokingHabit: _smokingHabit,
                    alcoholHabit: _alcoholHabit,
                    healthConditions: _healthConditions,
                    onChanged: (body, smoking, alcohol, conditions) {
                      setState(() {
                        _bodyType = body;
                        _smokingHabit = smoking;
                        _alcoholHabit = alcohol;
                        _healthConditions = conditions;
                      });
                    },
                  ),
                ],
              ),
            ),
            // ─── Navigation ────────────────────────────────
            _buildNavButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacing24, AppTheme.spacing16, AppTheme.spacing24, 0,
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            GestureDetector(
              onTap: _prevStep,
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.arrow_back_ios_new_rounded,
                    color: AppColors.textPrimary, size: 18),
              ),
            )
          else
            const SizedBox(width: 40),
          Expanded(
            child: Column(
              children: [
                Text(
                  _stepTitles[_currentStep],
                  style: AppTypography.h4(color: AppColors.textPrimary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  _stepSubtitles[_currentStep],
                  style: AppTypography.caption(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Text(
            '${_currentStep + 1}/$_totalSteps',
            style: AppTypography.bodyMedium(color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildProgress() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing24, vertical: AppTheme.spacing12,
      ),
      child: Row(
        children: List.generate(_totalSteps, (i) {
          final isActive = i <= _currentStep;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 4,
              margin: EdgeInsets.only(right: i < _totalSteps - 1 ? 6 : 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: isActive
                    ? const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryLight],
                      )
                    : null,
                color: isActive ? null : AppColors.surfaceElevated,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNavButtons() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacing24),
      child: SizedBox(
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
            onPressed: _nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _currentStep == _totalSteps - 1 ? 'Analyze My Health' : 'Continue',
                  style: AppTypography.button(color: Colors.white),
                ),
                const SizedBox(width: 8),
                Icon(
                  _currentStep == _totalSteps - 1
                      ? Icons.auto_awesome_rounded
                      : Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
