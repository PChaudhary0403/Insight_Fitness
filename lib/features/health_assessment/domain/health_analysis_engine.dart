import 'dart:math';
import '../data/models/health_profile.dart';

/// Health Analysis Engine — calculates all health metrics from onboarding data.
///
/// This engine uses medically-referenced formulas (Mifflin-St Jeor for BMR,
/// WHO BMI classifications) and behavioral science scoring to produce an
/// actionable health assessment.
class HealthAnalysisEngine {
  HealthAnalysisEngine._();

  /// Runs the full analysis pipeline on raw onboarding data and returns
  /// the enriched [HealthProfile] with all computed fields.
  static HealthProfile analyze(HealthProfile raw) {
    final bmi = _calculateBMI(raw.weightKg, raw.heightCm);
    final bmiCategory = _bmiCategory(bmi);
    final idealRange = _idealWeightRange(raw.heightCm);
    final calories = _estimateCalorieNeeds(raw);
    final hydration = _hydrationRequirement(raw.weightKg, raw.activityLevel);
    final activityRec = _activityRecommendation(raw);
    final sedentaryRisk = _sedentaryRiskScore(raw);
    final flags = _detectFlags(raw, bmi, hydration);
    final healthScore = _overallHealthScore(raw, bmi, sedentaryRisk, flags);
    final roadmap = _buildRoadmap(raw, bmi, bmiCategory, idealRange, hydration, flags);

    return raw.copyWith(
      bmi: double.parse(bmi.toStringAsFixed(1)),
      bmiCategory: bmiCategory,
      idealWeightLow: idealRange[0],
      idealWeightHigh: idealRange[1],
      estimatedCalorieNeeds: calories,
      hydrationRequirement: hydration,
      activityRecommendation: activityRec,
      sedentaryRiskScore: sedentaryRisk,
      overallHealthScore: healthScore,
      flags: flags,
      roadmap: roadmap,
      createdAt: DateTime.now(),
    );
  }

  // ─── BMI ─────────────────────────────────────────────────

  static double _calculateBMI(double weightKg, double heightCm) {
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  static String _bmiCategory(double bmi) {
    if (bmi < 16) return 'Severely Underweight';
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    if (bmi < 35) return 'Obese (Class I)';
    if (bmi < 40) return 'Obese (Class II)';
    return 'Obese (Class III)';
  }

  // ─── Ideal Weight (Devine Formula) ──────────────────────

  static List<double> _idealWeightRange(double heightCm) {
    final heightM = heightCm / 100;
    final low = 18.5 * heightM * heightM;
    final high = 24.9 * heightM * heightM;
    return [
      double.parse(low.toStringAsFixed(1)),
      double.parse(high.toStringAsFixed(1)),
    ];
  }

  // ─── Calorie Needs (Mifflin-St Jeor) ───────────────────

  static double _estimateCalorieNeeds(HealthProfile p) {
    double bmr;
    if (p.gender == 'male') {
      bmr = 10 * p.weightKg + 6.25 * p.heightCm - 5 * p.age + 5;
    } else {
      bmr = 10 * p.weightKg + 6.25 * p.heightCm - 5 * p.age - 161;
    }

    final multiplier = switch (p.activityLevel) {
      'sedentary' => 1.2,
      'light' => 1.375,
      'moderate' => 1.55,
      'active' => 1.725,
      'very_active' => 1.9,
      _ => 1.2,
    };

    return double.parse((bmr * multiplier).toStringAsFixed(0));
  }

  // ─── Hydration ──────────────────────────────────────────

  static double _hydrationRequirement(double weightKg, String activityLevel) {
    var base = weightKg * 0.033; // 33ml per kg baseline
    if (activityLevel == 'active' || activityLevel == 'very_active') {
      base *= 1.3;
    } else if (activityLevel == 'moderate') {
      base *= 1.15;
    }
    return double.parse(base.toStringAsFixed(1));
  }

  // ─── Activity Recommendation ────────────────────────────

  static String _activityRecommendation(HealthProfile p) {
    if (p.dailySittingHours >= 10) {
      return 'Critical: Movement correction needed. Start with 5-min walks every hour.';
    }
    if (p.dailySittingHours >= 8) {
      return 'High sedentary risk. Aim for 30 min daily exercise + hourly stretches.';
    }
    if (p.exerciseFrequency == 'never' || p.exerciseFrequency == '1-2x') {
      return 'Increase exercise to 3-4x per week. Mix cardio + strength training.';
    }
    if (p.activityLevel == 'active' || p.activityLevel == 'very_active') {
      return 'Great activity level! Focus on recovery, flexibility, and nutrition.';
    }
    return 'Maintain current routine. Consider adding variety to workouts.';
  }

  // ─── Sedentary Risk Score (0-10) ────────────────────────

  static double _sedentaryRiskScore(HealthProfile p) {
    double score = 0;

    // Sitting hours (0-4 points)
    if (p.dailySittingHours >= 12) {
      score += 4;
    } else if (p.dailySittingHours >= 10) {
      score += 3.5;
    } else if (p.dailySittingHours >= 8) {
      score += 2.5;
    } else if (p.dailySittingHours >= 6) {
      score += 1.5;
    } else {
      score += 0.5;
    }

    // Exercise frequency (0-3 points)
    score += switch (p.exerciseFrequency) {
      'never' => 3.0,
      '1-2x' => 2.0,
      '3-4x' => 1.0,
      '5-6x' => 0.3,
      'daily' => 0.0,
      _ => 2.0,
    };

    // Activity level (0-2 points)
    score += switch (p.activityLevel) {
      'sedentary' => 2.0,
      'light' => 1.5,
      'moderate' => 0.8,
      'active' => 0.3,
      'very_active' => 0.0,
      _ => 1.5,
    };

    // Occupation modifier (0-1 point)
    final deskJobs = ['developer', 'engineer', 'designer', 'writer', 'student', 'office', 'desk'];
    if (deskJobs.any((j) => p.occupation.toLowerCase().contains(j))) {
      score += 1;
    }

    return double.parse(min(10.0, score).toStringAsFixed(1));
  }

  // ─── Flag Detection ─────────────────────────────────────

  static List<String> _detectFlags(HealthProfile p, double bmi, double hydrationReq) {
    final flags = <String>[];

    if (bmi < 18.5) flags.add('underweight');
    if (bmi >= 25 && bmi < 30) flags.add('overweight');
    if (bmi >= 30) flags.add('obese');

    if (p.activityLevel == 'sedentary' || p.dailySittingHours >= 10) {
      flags.add('sedentary');
    } else if (p.activityLevel == 'light') {
      flags.add('low_activity');
    } else if (p.activityLevel == 'active' || p.activityLevel == 'very_active') {
      flags.add('highly_active');
    } else {
      flags.add('moderately_active');
    }

    if (p.waterIntakeLiters < hydrationReq * 0.7) {
      flags.add('dehydrated');
    }

    // Irregular lifestyle detection
    final wakeHour = int.tryParse(p.wakeUpTime.split(':')[0]) ?? 7;
    final sleepHour = int.tryParse(p.sleepTime.split(':')[0]) ?? 23;
    final sleepDuration = (24 - sleepHour + wakeHour) % 24;
    if (sleepDuration < 6 || sleepDuration > 10 || wakeHour >= 10) {
      flags.add('irregular_lifestyle');
    }

    if (p.stressLevel == 'high' || p.stressLevel == 'very_high') {
      flags.add('high_stress');
    }

    if (p.smokingHabit == 'regularly' || p.smokingHabit == 'heavy') {
      flags.add('smoking_risk');
    }

    if (p.alcoholHabit == 'moderate' || p.alcoholHabit == 'heavy') {
      flags.add('alcohol_risk');
    }

    return flags;
  }

  // ─── Overall Health Score (0-100) ───────────────────────

  static int _overallHealthScore(
    HealthProfile p,
    double bmi,
    double sedentaryRisk,
    List<String> flags,
  ) {
    double score = 100;

    // BMI penalty (max -25)
    if (bmi < 18.5) {
      score -= (18.5 - bmi) * 4;
    } else if (bmi > 25) {
      score -= (bmi - 25) * 3;
    }

    // Sedentary risk penalty (max -20)
    score -= sedentaryRisk * 2;

    // Exercise bonus/penalty (max ±10)
    score += switch (p.exerciseFrequency) {
      'daily' => 5.0,
      '5-6x' => 3.0,
      '3-4x' => 0.0,
      '1-2x' => -5.0,
      'never' => -10.0,
      _ => -3.0,
    };

    // Hydration penalty
    if (flags.contains('dehydrated')) score -= 8;

    // Sleep/lifestyle penalty
    if (flags.contains('irregular_lifestyle')) score -= 10;

    // Stress penalty
    if (flags.contains('high_stress')) score -= 8;

    // Smoking/alcohol penalty
    if (flags.contains('smoking_risk')) score -= 10;
    if (flags.contains('alcohol_risk')) score -= 5;

    // Dietary bonus
    if (p.dietaryPreference == 'vegetarian' || p.dietaryPreference == 'vegan') {
      score += 3;
    }

    return score.clamp(5, 100).round();
  }

  // ─── Roadmap Builder ────────────────────────────────────

  static List<HealthRoadmapItem> _buildRoadmap(
    HealthProfile p,
    double bmi,
    String bmiCategory,
    List<double> idealRange,
    double hydrationReq,
    List<String> flags,
  ) {
    final items = <HealthRoadmapItem>[];

    // Weight goals
    if (flags.contains('underweight')) {
      final gain = (idealRange[0] - p.weightKg).abs().toStringAsFixed(1);
      items.add(HealthRoadmapItem(
        category: 'weight',
        title: 'Weight Gain Goal',
        description:
            'Your BMI indicates underweight ($bmiCategory). Goal: gain ${gain}kg safely with nutrient-dense meals.',
        priority: 'high',
        icon: '⚖️',
      ));
    } else if (flags.contains('overweight') || flags.contains('obese')) {
      final lose = (p.weightKg - idealRange[1]).abs().toStringAsFixed(1);
      items.add(HealthRoadmapItem(
        category: 'weight',
        title: 'Weight Management Goal',
        description:
            'Your BMI indicates $bmiCategory. Goal: lose ${lose}kg through balanced diet + exercise.',
        priority: 'high',
        icon: '⚖️',
      ));
    }

    // Movement correction
    if (flags.contains('sedentary')) {
      items.add(HealthRoadmapItem(
        category: 'movement',
        title: 'Movement Correction Plan',
        description:
            'You sit ${p.dailySittingHours.toStringAsFixed(0)} hours/day. Movement correction plan activated. Start with hourly 5-min walks.',
        priority: 'high',
        icon: '🏃',
      ));
    }

    // Hydration
    if (flags.contains('dehydrated')) {
      items.add(HealthRoadmapItem(
        category: 'hydration',
        title: 'Hydration Improvement',
        description:
            'Hydration habits are below healthy baseline. Target: ${hydrationReq}L/day. Set hourly reminders.',
        priority: 'high',
        icon: '💧',
      ));
    }

    // Sleep/lifestyle
    if (flags.contains('irregular_lifestyle')) {
      items.add(HealthRoadmapItem(
        category: 'sleep',
        title: 'Sleep Schedule Fix',
        description:
            'Irregular sleep pattern detected. Aim for 7-8 hours of sleep with consistent wake-up times.',
        priority: 'medium',
        icon: '🌙',
      ));
    }

    // Stress management
    if (flags.contains('high_stress')) {
      items.add(HealthRoadmapItem(
        category: 'stress',
        title: 'Stress Management',
        description:
            'High stress detected. Introduce daily meditation, breathing exercises, or journaling.',
        priority: 'medium',
        icon: '🧘',
      ));
    }

    // Exercise improvement
    if (p.exerciseFrequency == 'never' || p.exerciseFrequency == '1-2x') {
      items.add(HealthRoadmapItem(
        category: 'exercise',
        title: 'Exercise Ramp-Up',
        description:
            'Current exercise: ${p.exerciseFrequency}/week. Target: 3-4x/week with progressive intensity.',
        priority: 'medium',
        icon: '💪',
      ));
    }

    // Diet optimization
    items.add(HealthRoadmapItem(
      category: 'diet',
      title: 'Nutrition Optimization',
      description:
          'Daily calorie target: ${p.estimatedCalorieNeeds?.toStringAsFixed(0) ?? '—'} kcal. Focus on protein, fiber, and micronutrients.',
      priority: 'low',
      icon: '🥗',
    ));

    // Smoking cessation
    if (flags.contains('smoking_risk')) {
      items.add(HealthRoadmapItem(
        category: 'habits',
        title: 'Smoking Reduction',
        description: 'Smoking significantly impacts health. Begin gradual reduction plan.',
        priority: 'high',
        icon: '🚭',
      ));
    }

    return items;
  }
}
