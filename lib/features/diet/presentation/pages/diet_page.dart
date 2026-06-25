import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/services/user_data_service.dart';

/// Diet tracking page — connected to UserDataService.
class DietPage extends StatefulWidget {
  const DietPage({super.key});

  @override
  State<DietPage> createState() => _DietPageState();
}

class _DietPageState extends State<DietPage> {
  final data = UserDataService.instance;

  // Meals logged today (starts empty)
  final List<_LoggedMeal> _meals = [];

  int get _totalCalories => _meals.fold(0, (sum, m) => sum + m.calories);
  int get _totalProtein => _meals.fold(0, (sum, m) => sum + m.protein);
  int get _totalCarbs => _meals.fold(0, (sum, m) => sum + m.carbs);
  int get _totalFat => _meals.fold(0, (sum, m) => sum + m.fat);

  bool _isMealLogged(String slot) => _meals.any((m) => m.slot == slot);

  void _logMeal(String slot) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LogMealSheet(
        slot: slot,
        onLogged: (meal) {
          setState(() {
            _meals.add(meal);
          });
          // Update UserDataService
          data.logMeal();
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('${meal.slot} logged: ${meal.description} • ${meal.calories} kcal'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final calorieTarget = data.calorieTarget.round();
    final proteinTarget = (calorieTarget * 0.25 / 4).round(); // 25% protein
    final carbTarget = (calorieTarget * 0.50 / 4).round();    // 50% carbs
    final fatTarget = (calorieTarget * 0.25 / 9).round();      // 25% fat

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: Text('Diet Today', style: AppTypography.h3(color: AppColors.textPrimary)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacing24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Calorie Summary ────────────────────────
            _buildCalorieSummary(calorieTarget).animate().fadeIn(duration: 500.ms),
            const SizedBox(height: AppTheme.spacing20),

            // ─── Macro Breakdown ────────────────────────
            _buildMacroRow(proteinTarget, carbTarget, fatTarget)
                .animate(delay: 200.ms).fadeIn(duration: 400.ms),
            const SizedBox(height: AppTheme.spacing24),

            // ─── Meal Slots ─────────────────────────────
            _buildMealSlot(Icons.wb_twilight_rounded, 'Breakfast', 'Start your day right', 0),
            const SizedBox(height: AppTheme.spacing12),
            _buildMealSlot(Icons.wb_sunny_rounded, 'Lunch', 'Midday fuel', 1),
            const SizedBox(height: AppTheme.spacing12),
            _buildMealSlot(Icons.nightlight_round, 'Dinner', 'Evening meal', 2),
            const SizedBox(height: AppTheme.spacing12),
            _buildMealSlot(Icons.restaurant_rounded, 'Snack', 'Quick bite', 3),
          ],
        ),
      ),
    );
  }

  Widget _buildCalorieSummary(int target) {
    final consumed = _totalCalories;
    final percent = target > 0 ? (consumed / target).clamp(0.0, 1.0) : 0.0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacing20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Calories', style: AppTypography.caption(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatNumber(consumed),
                style: AppTypography.metric(color: AppColors.textPrimary),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '/ ${_formatNumber(target)} kcal',
                  style: AppTypography.bodySmall(color: AppColors.textTertiary),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 8,
              backgroundColor: AppColors.nutrition.withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation(AppColors.nutrition),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroRow(int proteinTarget, int carbTarget, int fatTarget) {
    return Row(
      children: [
        Expanded(child: _MacroTile(
          label: 'Protein', value: '${_totalProtein}g', target: '/${proteinTarget}g',
          percent: proteinTarget > 0 ? (_totalProtein / proteinTarget).clamp(0.0, 1.0) : 0,
          color: AppColors.exercise,
        )),
        const SizedBox(width: AppTheme.spacing12),
        Expanded(child: _MacroTile(
          label: 'Carbs', value: '${_totalCarbs}g', target: '/${carbTarget}g',
          percent: carbTarget > 0 ? (_totalCarbs / carbTarget).clamp(0.0, 1.0) : 0,
          color: AppColors.nutrition,
        )),
        const SizedBox(width: AppTheme.spacing12),
        Expanded(child: _MacroTile(
          label: 'Fat', value: '${_totalFat}g', target: '/${fatTarget}g',
          percent: fatTarget > 0 ? (_totalFat / fatTarget).clamp(0.0, 1.0) : 0,
          color: AppColors.hydration,
        )),
      ],
    );
  }

  Widget _buildMealSlot(IconData icon, String title, String hint, int delay) {
    final logged = _isMealLogged(title);
    final meal = logged ? _meals.firstWhere((m) => m.slot == title) : null;

    return GestureDetector(
      onTap: logged ? null : () => _logMeal(title),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppTheme.spacing16),
        decoration: BoxDecoration(
          color: logged ? AppColors.success.withValues(alpha: 0.05) : AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: logged ? AppColors.success.withValues(alpha: 0.2) : AppColors.cardBorder,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: logged ? AppColors.success : AppColors.textSecondary, size: 28),
            const SizedBox(width: AppTheme.spacing12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.bodyMedium(color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(
                    logged ? meal!.description : 'Tap to log $hint',
                    style: AppTypography.bodySmall(color: AppColors.textSecondary),
                  ),
                  if (logged) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: List.generate(5, (i) => Icon(
                        i < meal!.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                        size: 14,
                        color: i < meal.rating ? AppColors.nutrition : AppColors.textTertiary,
                      )),
                    ),
                  ],
                ],
              ),
            ),
            if (logged)
              Text('${meal!.calories} kcal', style: AppTypography.bodySmall(color: AppColors.textSecondary)),
            const SizedBox(width: 8),
            logged
                ? const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 24)
                : Icon(Icons.add_circle_outline_rounded, color: AppColors.textTertiary, size: 24),
          ],
        ),
      ),
    ).animate(delay: Duration(milliseconds: 300 + delay * 100)).fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0);
  }

  String _formatNumber(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(0)},${(n % 1000).toString().padLeft(3, '0')}';
    return '$n';
  }
}

// ─── Log Meal Bottom Sheet ──────────────────────────────────

class _LogMealSheet extends StatefulWidget {
  final String slot;
  final Function(_LoggedMeal) onLogged;
  const _LogMealSheet({required this.slot, required this.onLogged});

  @override
  State<_LogMealSheet> createState() => _LogMealSheetState();
}

class _LogMealSheetState extends State<_LogMealSheet> {
  final _descController = TextEditingController();
  int _calories = 300;
  int _protein = 15;
  int _carbs = 40;
  int _fat = 10;
  int _rating = 3;

  // Quick meal presets
  static const _presets = {
    'Breakfast': [
      ('Oats + banana + milk', 420, 18, 65, 12),
      ('Eggs + toast', 350, 22, 30, 15),
      ('Poha + tea', 280, 8, 45, 8),
      ('Smoothie bowl', 380, 15, 55, 10),
    ],
    'Lunch': [
      ('Rice + dal + salad', 550, 20, 80, 12),
      ('Roti + sabzi + curd', 480, 18, 60, 15),
      ('Chicken rice bowl', 620, 35, 70, 18),
      ('Pasta + veggies', 500, 15, 72, 14),
    ],
    'Dinner': [
      ('Light khichdi', 380, 12, 55, 8),
      ('Chapati + paneer', 520, 22, 50, 20),
      ('Grilled chicken + salad', 450, 38, 20, 18),
      ('Soup + bread', 320, 10, 40, 12),
    ],
    'Snack': [
      ('Fruit + nuts', 220, 6, 25, 12),
      ('Protein bar', 200, 20, 22, 8),
      ('Yogurt + granola', 280, 12, 35, 10),
      ('Biscuits + tea', 180, 4, 28, 6),
    ],
  };

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final presets = _presets[widget.slot] ?? _presets['Snack']!;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.dividerColor, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text('Log ${widget.slot}', style: AppTypography.h3(color: AppColors.textPrimary)),
            const SizedBox(height: 20),

            // Quick presets
            Text('Quick Select', style: AppTypography.caption(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            ...presets.map((p) => GestureDetector(
              onTap: () {
                setState(() {
                  _descController.text = p.$1;
                  _calories = p.$2;
                  _protein = p.$3;
                  _carbs = p.$4;
                  _fat = p.$5;
                });
              },
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: _descController.text == p.$1 ? AppColors.primary.withValues(alpha: 0.12) : AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _descController.text == p.$1 ? AppColors.primary.withValues(alpha: 0.4) : Colors.transparent),
                ),
                child: Row(
                  children: [
                    Expanded(child: Text(p.$1, style: AppTypography.body(color: AppColors.textPrimary))),
                    Text('${p.$2} kcal', style: AppTypography.caption(color: AppColors.textSecondary)),
                  ],
                ),
              ),
            )),

            const SizedBox(height: 12),
            // Or custom input
            TextField(
              controller: _descController,
              style: AppTypography.body(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Or type custom meal...',
                hintStyle: AppTypography.body(color: AppColors.textTertiary),
                filled: true,
                fillColor: AppColors.surfaceElevated,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),

            const SizedBox(height: 16),
            // Calories slider
            _sliderRow('Calories', _calories, 100, 1200, 'kcal', (v) => setState(() => _calories = v.round())),
            _sliderRow('Protein', _protein, 0, 80, 'g', (v) => setState(() => _protein = v.round())),
            _sliderRow('Carbs', _carbs, 0, 150, 'g', (v) => setState(() => _carbs = v.round())),
            _sliderRow('Fat', _fat, 0, 60, 'g', (v) => setState(() => _fat = v.round())),

            const SizedBox(height: 12),
            // Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Healthiness: ', style: AppTypography.caption(color: AppColors.textSecondary)),
                ...List.generate(5, (i) => GestureDetector(
                  onTap: () => setState(() => _rating = i + 1),
                  child: Icon(
                    i < _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: i < _rating ? AppColors.nutrition : AppColors.textTertiary,
                    size: 28,
                  ),
                )),
              ],
            ),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _descController.text.isEmpty ? null : () {
                  widget.onLogged(_LoggedMeal(
                    slot: widget.slot,
                    description: _descController.text,
                    calories: _calories,
                    protein: _protein,
                    carbs: _carbs,
                    fat: _fat,
                    rating: _rating,
                    time: TimeOfDay.now(),
                  ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  disabledBackgroundColor: AppColors.surfaceElevated,
                ),
                child: Text('Log ${widget.slot}', style: AppTypography.button(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _sliderRow(String label, int value, int min, int max, String unit, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(width: 60, child: Text(label, style: AppTypography.caption(color: AppColors.textSecondary))),
          Expanded(
            child: Slider(
              value: value.toDouble(), min: min.toDouble(), max: max.toDouble(),
              activeColor: AppColors.primary,
              inactiveColor: AppColors.surfaceElevated,
              onChanged: onChanged,
            ),
          ),
          SizedBox(width: 55, child: Text('$value $unit', style: AppTypography.bodySmall(color: AppColors.textPrimary), textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}

// ─── Models ──────────────────────────────────────────────────

class _LoggedMeal {
  final String slot;
  final String description;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final int rating;
  final TimeOfDay time;
  const _LoggedMeal({
    required this.slot, required this.description, required this.calories,
    required this.protein, required this.carbs, required this.fat,
    required this.rating, required this.time,
  });
}

// ─── Reusable widgets ───────────────────────────────────────

class _MacroTile extends StatelessWidget {
  final String label, value, target;
  final double percent;
  final Color color;
  const _MacroTile({required this.label, required this.value, required this.target, required this.percent, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(children: [
        Text(label, style: AppTypography.caption(color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        Text(value, style: AppTypography.h4(color: color)),
        Text(target, style: AppTypography.label(color: AppColors.textTertiary)),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(value: percent, minHeight: 4, backgroundColor: color.withValues(alpha: 0.15), valueColor: AlwaysStoppedAnimation(color)),
        ),
      ]),
    );
  }
}