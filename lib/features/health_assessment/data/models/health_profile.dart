// Health Profile model for the health assessment onboarding.

/// Represents the user's complete health profile collected during onboarding.
class HealthProfile {
  // ─── Basic Info ──────────────────────────────────────────
  final String fullName;
  final int age;
  final String gender; // 'male', 'female', 'other'
  final double heightCm;
  final double weightKg;
  final String? bodyType; // 'ectomorph', 'mesomorph', 'endomorph'

  // ─── Lifestyle ──────────────────────────────────────────
  final String activityLevel; // 'sedentary', 'light', 'moderate', 'active', 'very_active'
  final String occupation;
  final double dailySittingHours;
  final String wakeUpTime; // HH:mm format
  final String sleepTime; // HH:mm format
  final String exerciseFrequency; // 'never', '1-2x', '3-4x', '5-6x', 'daily'
  final String dietaryPreference; // 'omnivore', 'vegetarian', 'vegan', 'keto', 'paleo'
  final double waterIntakeLiters;
  final String stressLevel; // 'low', 'moderate', 'high', 'very_high'

  // ─── Optional ───────────────────────────────────────────
  final String? smokingHabit; // 'never', 'occasionally', 'regularly', 'heavy'
  final String? alcoholHabit; // 'never', 'occasionally', 'moderate', 'heavy'
  final List<String> healthConditions;

  // ─── Computed (filled after analysis) ───────────────────
  final double? bmi;
  final String? bmiCategory;
  final double? idealWeightLow;
  final double? idealWeightHigh;
  final double? estimatedCalorieNeeds;
  final double? hydrationRequirement;
  final String? activityRecommendation;
  final double? sedentaryRiskScore;
  final int? overallHealthScore;
  final List<String> flags; // e.g., 'underweight', 'sedentary', 'dehydrated'
  final List<HealthRoadmapItem> roadmap;

  // ─── Timestamp ──────────────────────────────────────────
  final DateTime createdAt;

  HealthProfile({
    required this.fullName,
    required this.age,
    required this.gender,
    required this.heightCm,
    required this.weightKg,
    this.bodyType,
    required this.activityLevel,
    required this.occupation,
    required this.dailySittingHours,
    required this.wakeUpTime,
    required this.sleepTime,
    required this.exerciseFrequency,
    required this.dietaryPreference,
    required this.waterIntakeLiters,
    required this.stressLevel,
    this.smokingHabit,
    this.alcoholHabit,
    this.healthConditions = const [],
    this.bmi,
    this.bmiCategory,
    this.idealWeightLow,
    this.idealWeightHigh,
    this.estimatedCalorieNeeds,
    this.hydrationRequirement,
    this.activityRecommendation,
    this.sedentaryRiskScore,
    this.overallHealthScore,
    this.flags = const [],
    this.roadmap = const [],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  HealthProfile copyWith({
    String? fullName,
    int? age,
    String? gender,
    double? heightCm,
    double? weightKg,
    String? bodyType,
    String? activityLevel,
    String? occupation,
    double? dailySittingHours,
    String? wakeUpTime,
    String? sleepTime,
    String? exerciseFrequency,
    String? dietaryPreference,
    double? waterIntakeLiters,
    String? stressLevel,
    String? smokingHabit,
    String? alcoholHabit,
    List<String>? healthConditions,
    double? bmi,
    String? bmiCategory,
    double? idealWeightLow,
    double? idealWeightHigh,
    double? estimatedCalorieNeeds,
    double? hydrationRequirement,
    String? activityRecommendation,
    double? sedentaryRiskScore,
    int? overallHealthScore,
    List<String>? flags,
    List<HealthRoadmapItem>? roadmap,
    DateTime? createdAt,
  }) {
    return HealthProfile(
      fullName: fullName ?? this.fullName,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      bodyType: bodyType ?? this.bodyType,
      activityLevel: activityLevel ?? this.activityLevel,
      occupation: occupation ?? this.occupation,
      dailySittingHours: dailySittingHours ?? this.dailySittingHours,
      wakeUpTime: wakeUpTime ?? this.wakeUpTime,
      sleepTime: sleepTime ?? this.sleepTime,
      exerciseFrequency: exerciseFrequency ?? this.exerciseFrequency,
      dietaryPreference: dietaryPreference ?? this.dietaryPreference,
      waterIntakeLiters: waterIntakeLiters ?? this.waterIntakeLiters,
      stressLevel: stressLevel ?? this.stressLevel,
      smokingHabit: smokingHabit ?? this.smokingHabit,
      alcoholHabit: alcoholHabit ?? this.alcoholHabit,
      healthConditions: healthConditions ?? this.healthConditions,
      bmi: bmi ?? this.bmi,
      bmiCategory: bmiCategory ?? this.bmiCategory,
      idealWeightLow: idealWeightLow ?? this.idealWeightLow,
      idealWeightHigh: idealWeightHigh ?? this.idealWeightHigh,
      estimatedCalorieNeeds: estimatedCalorieNeeds ?? this.estimatedCalorieNeeds,
      hydrationRequirement: hydrationRequirement ?? this.hydrationRequirement,
      activityRecommendation: activityRecommendation ?? this.activityRecommendation,
      sedentaryRiskScore: sedentaryRiskScore ?? this.sedentaryRiskScore,
      overallHealthScore: overallHealthScore ?? this.overallHealthScore,
      flags: flags ?? this.flags,
      roadmap: roadmap ?? this.roadmap,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'age': age,
      'gender': gender,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'bodyType': bodyType,
      'activityLevel': activityLevel,
      'occupation': occupation,
      'dailySittingHours': dailySittingHours,
      'wakeUpTime': wakeUpTime,
      'sleepTime': sleepTime,
      'exerciseFrequency': exerciseFrequency,
      'dietaryPreference': dietaryPreference,
      'waterIntakeLiters': waterIntakeLiters,
      'stressLevel': stressLevel,
      'smokingHabit': smokingHabit,
      'alcoholHabit': alcoholHabit,
      'healthConditions': healthConditions,
      'bmi': bmi,
      'bmiCategory': bmiCategory,
      'idealWeightLow': idealWeightLow,
      'idealWeightHigh': idealWeightHigh,
      'estimatedCalorieNeeds': estimatedCalorieNeeds,
      'hydrationRequirement': hydrationRequirement,
      'activityRecommendation': activityRecommendation,
      'sedentaryRiskScore': sedentaryRiskScore,
      'overallHealthScore': overallHealthScore,
      'flags': flags,
      'roadmap': roadmap.map((r) => r.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory HealthProfile.fromJson(Map<String, dynamic> json) {
    return HealthProfile(
      fullName: json['fullName'] ?? '',
      age: json['age'] ?? 25,
      gender: json['gender'] ?? 'male',
      heightCm: (json['heightCm'] ?? 170).toDouble(),
      weightKg: (json['weightKg'] ?? 70).toDouble(),
      bodyType: json['bodyType'],
      activityLevel: json['activityLevel'] ?? 'sedentary',
      occupation: json['occupation'] ?? '',
      dailySittingHours: (json['dailySittingHours'] ?? 8).toDouble(),
      wakeUpTime: json['wakeUpTime'] ?? '07:00',
      sleepTime: json['sleepTime'] ?? '23:00',
      exerciseFrequency: json['exerciseFrequency'] ?? 'never',
      dietaryPreference: json['dietaryPreference'] ?? 'omnivore',
      waterIntakeLiters: (json['waterIntakeLiters'] ?? 2).toDouble(),
      stressLevel: json['stressLevel'] ?? 'moderate',
      smokingHabit: json['smokingHabit'],
      alcoholHabit: json['alcoholHabit'],
      healthConditions: List<String>.from(json['healthConditions'] ?? []),
      bmi: json['bmi']?.toDouble(),
      bmiCategory: json['bmiCategory'],
      idealWeightLow: json['idealWeightLow']?.toDouble(),
      idealWeightHigh: json['idealWeightHigh']?.toDouble(),
      estimatedCalorieNeeds: json['estimatedCalorieNeeds']?.toDouble(),
      hydrationRequirement: json['hydrationRequirement']?.toDouble(),
      activityRecommendation: json['activityRecommendation'],
      sedentaryRiskScore: json['sedentaryRiskScore']?.toDouble(),
      overallHealthScore: json['overallHealthScore'],
      flags: List<String>.from(json['flags'] ?? []),
      roadmap: (json['roadmap'] as List?)
              ?.map((r) => HealthRoadmapItem.fromJson(r))
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}

/// A single item in the personalized improvement roadmap.
class HealthRoadmapItem {
  final String category; // 'weight', 'movement', 'hydration', 'sleep', 'diet', 'stress'
  final String title;
  final String description;
  final String priority; // 'high', 'medium', 'low'
  final String icon;

  const HealthRoadmapItem({
    required this.category,
    required this.title,
    required this.description,
    required this.priority,
    this.icon = '🎯',
  });

  Map<String, dynamic> toJson() => {
        'category': category,
        'title': title,
        'description': description,
        'priority': priority,
        'icon': icon,
      };

  factory HealthRoadmapItem.fromJson(Map<String, dynamic> json) {
    return HealthRoadmapItem(
      category: json['category'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      priority: json['priority'] ?? 'medium',
      icon: json['icon'] ?? '🎯',
    );
  }
}

