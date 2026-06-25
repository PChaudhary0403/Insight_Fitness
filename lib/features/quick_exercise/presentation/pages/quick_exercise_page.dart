import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/services/user_data_service.dart';
import '../../data/exercise_library.dart';
import '../../data/workout_generator.dart';
import 'workout_session_page.dart';

/// Quick Exercise hub — browse, filter, and launch workouts.
class QuickExercisePage extends StatefulWidget {
  const QuickExercisePage({super.key});

  @override
  State<QuickExercisePage> createState() => _QuickExercisePageState();
}

class _QuickExercisePageState extends State<QuickExercisePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedDuration = 5; // default 5 min
  WorkoutMode? _selectedMode;

  static const _durations = [1, 3, 5, 10];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _startWorkout(WorkoutMode mode, int duration) {
    final profile = UserDataService.instance.profile;
    final workout = WorkoutGenerator.generate(mode: mode, durationMin: duration, profile: profile);
    Navigator.push(context, MaterialPageRoute(builder: (_) => WorkoutSessionPage(workout: workout)));
  }

  @override
  Widget build(BuildContext context) {
    final suggestion = WorkoutGenerator.getSmartSuggestion(UserDataService.instance.profile);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: Text('Quick Exercise', style: AppTypography.h3(color: AppColors.textPrimary)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textTertiary,
          labelStyle: AppTypography.bodySmall(color: AppColors.primary),
          tabs: const [
            Tab(text: 'Quick Start'),
            Tab(text: 'Library'),
            Tab(text: 'Modes'),
            Tab(text: 'Stats'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildQuickStartTab(suggestion),
          _buildLibraryTab(),
          _buildModesTab(),
          _buildStatsTab(),
        ],
      ),
    );
  }

  // ─── Tab 1: Quick Start ──────────────────────────────────

  Widget _buildQuickStartTab(String suggestion) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacing24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Smart suggestion
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary.withValues(alpha: 0.12), AppColors.secondary.withValues(alpha: 0.08)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                const Text('🤖', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('AI Recommendation', style: AppTypography.caption(color: AppColors.primary)),
                      const SizedBox(height: 2),
                      Text(suggestion, style: AppTypography.body(color: AppColors.textPrimary)),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),

          const SizedBox(height: 24),

          // Duration picker
          Text('Duration', style: AppTypography.h4(color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          Row(
            children: _durations.map((d) {
              final isSelected = _selectedDuration == d;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedDuration = d),
                  child: AnimatedContainer(
                    duration: 200.ms,
                    margin: EdgeInsets.only(right: d != _durations.last ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isSelected ? AppColors.primary : AppColors.cardBorder),
                    ),
                    child: Column(
                      children: [
                        Text('$d', style: AppTypography.h3(color: isSelected ? Colors.white : AppColors.textPrimary)),
                        Text('min', style: AppTypography.caption(color: isSelected ? Colors.white70 : AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ).animate(delay: 100.ms).fadeIn(),

          const SizedBox(height: 24),

          // Quick launch modes
          Text('Quick Launch', style: AppTypography.h4(color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          ...WorkoutMode.values.asMap().entries.map((entry) {
            final mode = entry.value;
            final info = WorkoutGenerator.modeInfo[mode]!;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => _startWorkout(mode, _selectedDuration),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      Text(info.$1, style: const TextStyle(fontSize: 28)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(info.$2, style: AppTypography.bodyMedium(color: AppColors.textPrimary)),
                            Text(info.$3, style: AppTypography.caption(color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('$_selectedDuration min', style: AppTypography.caption(color: AppColors.primary)),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.play_circle_filled_rounded, color: AppColors.primary, size: 28),
                    ],
                  ),
                ),
              ),
            ).animate(delay: Duration(milliseconds: 200 + entry.key * 60)).fadeIn().slideX(begin: 0.03, end: 0);
          }),
        ],
      ),
    );
  }

  // ─── Tab 2: Exercise Library ─────────────────────────────

  Widget _buildLibraryTab() {
    final categories = [
      ('💪 Bodyweight', ExerciseCategory.bodyweight, AppColors.exercise),
      ('🧘 Mobility & Stretch', ExerciseCategory.mobility, AppColors.mindfulness),
      ('💻 Desk / Office', ExerciseCategory.desk, AppColors.info),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacing24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: categories.map((cat) {
          final exercises = ExerciseLibrary.byCategory(cat.$2);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(cat.$1, style: AppTypography.h4(color: cat.$3)),
              const SizedBox(height: 8),
              ...exercises.map((ex) => Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(ex.icon, color: cat.$3, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ex.name, style: AppTypography.bodyMedium(color: AppColors.textPrimary)),
                          Text(
                            '${ex.type == ExerciseType.reps ? "${ex.defaultReps} reps" : "${ex.defaultSeconds}s"} • ${ex.caloriesPerMin.toStringAsFixed(0)} cal/min',
                            style: AppTypography.caption(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    _difficultyBadge(ex.difficulty),
                  ],
                ),
              )),
              const SizedBox(height: 16),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _difficultyBadge(Difficulty d) {
    final (label, color) = switch (d) {
      Difficulty.beginner => ('Easy', AppColors.success),
      Difficulty.intermediate => ('Med', AppColors.warning),
      Difficulty.advanced => ('Hard', AppColors.error),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: AppTypography.label(color: color)),
    );
  }

  // ─── Tab 3: Workout Modes ───────────────────────────────

  Widget _buildModesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacing24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Choose a Mode', style: AppTypography.h4(color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text('Pick a focus area. We\'ll build the perfect workout.', style: AppTypography.body(color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: WorkoutMode.values.map((mode) {
              final info = WorkoutGenerator.modeInfo[mode]!;
              final isSelected = _selectedMode == mode;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedMode = mode);
                  _startWorkout(mode, _selectedDuration);
                },
                child: AnimatedContainer(
                  duration: 200.ms,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withValues(alpha: 0.15) : AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isSelected ? AppColors.primary : AppColors.cardBorder),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(info.$1, style: const TextStyle(fontSize: 32)),
                      const SizedBox(height: 8),
                      Text(info.$2, style: AppTypography.bodyMedium(color: AppColors.textPrimary)),
                      const SizedBox(height: 2),
                      Text(info.$3, style: AppTypography.caption(color: AppColors.textSecondary), textAlign: TextAlign.center, maxLines: 2),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ─── Tab 4: Stats ───────────────────────────────────────

  Widget _buildStatsTab() {
    final data = UserDataService.instance;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacing24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Exercise Stats', style: AppTypography.h4(color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatTile('Today', '${data.dailyQuickWorkouts}', 'workouts', AppColors.exercise),
              const SizedBox(width: 12),
              _StatTile('Week', '${data.weeklyQuickWorkouts}', 'workouts', AppColors.movement),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _StatTile('Calories', '${data.dailyQuickCalories}', 'burned', const Color(0xFFFF6B35)),
              const SizedBox(width: 12),
              _StatTile('Streak', '${data.currentStreak}', 'days', AppColors.warning),
            ],
          ),
          const SizedBox(height: 24),

          // Badges
          Text('Achievements', style: AppTypography.h4(color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          ..._buildBadges(data),
        ],
      ),
    );
  }

  List<Widget> _buildBadges(UserDataService data) {
    final badges = [
      ('🏋️', 'First Workout', 'Complete your first quick workout', data.dailyQuickWorkouts > 0),
      ('🔥', 'Movement Streak', 'Exercise 3 days in a row', data.currentStreak >= 3),
      ('💻', 'Desk Warrior', 'Do 5 desk refresh workouts', data.weeklyQuickWorkouts >= 5),
      ('🏆', 'No Zero Days', 'Exercise every day for a week', data.currentStreak >= 7),
      ('⚡', '5 This Week', 'Complete 5 workouts in a week', data.weeklyQuickWorkouts >= 5),
    ];

    return badges.map((b) => Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: b.$4 ? AppColors.success.withValues(alpha: 0.08) : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: b.$4 ? AppColors.success.withValues(alpha: 0.3) : AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Text(b.$1, style: TextStyle(fontSize: 24, color: b.$4 ? null : Colors.grey)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(b.$2, style: AppTypography.bodyMedium(color: b.$4 ? AppColors.success : AppColors.textSecondary)),
                Text(b.$3, style: AppTypography.caption(color: AppColors.textTertiary)),
              ],
            ),
          ),
          Icon(b.$4 ? Icons.check_circle_rounded : Icons.lock_outline_rounded,
              color: b.$4 ? AppColors.success : AppColors.textTertiary, size: 22),
        ],
      ),
    )).toList();
  }
}

class _StatTile extends StatelessWidget {
  final String label, value, sub;
  final Color color;
  const _StatTile(this.label, this.value, this.sub, this.color);
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          children: [
            Text(label, style: AppTypography.caption(color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            Text(value, style: AppTypography.h3(color: color)),
            Text(sub, style: AppTypography.caption(color: AppColors.textTertiary)),
          ],
        ),
      ),
    );
  }
}