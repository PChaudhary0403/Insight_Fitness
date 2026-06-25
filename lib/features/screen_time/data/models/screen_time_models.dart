

/// Categorizes apps into productive vs non-productive.
enum AppCategory {
  social,
  entertainment,
  productivity,
  communication,
  education,
  health,
  utility,
  browser,
  gaming,
  other;

  bool get isProductive =>
      this == productivity ||
      this == education ||
      this == health ||
      this == utility;

  String get label {
    switch (this) {
      case social:
        return 'Social Media';
      case entertainment:
        return 'Entertainment';
      case productivity:
        return 'Productivity';
      case communication:
        return 'Communication';
      case education:
        return 'Education';
      case health:
        return 'Health';
      case utility:
        return 'Utility';
      case browser:
        return 'Browser';
      case gaming:
        return 'Gaming';
      case other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case social:
        return '📱';
      case entertainment:
        return '🎬';
      case productivity:
        return '💼';
      case communication:
        return '💬';
      case education:
        return '📚';
      case health:
        return '❤️';
      case utility:
        return '🔧';
      case browser:
        return '🌐';
      case gaming:
        return '🎮';
      case other:
        return '📦';
    }
  }
}

/// Tracks usage for an individual app.
class AppUsageEntry {
  final String appName;
  final AppCategory category;
  final int durationMinutes;
  final int openCount;

  const AppUsageEntry({
    required this.appName,
    required this.category,
    required this.durationMinutes,
    this.openCount = 1,
  });

  Map<String, dynamic> toJson() => {
        'appName': appName,
        'category': category.index,
        'durationMinutes': durationMinutes,
        'openCount': openCount,
      };

  factory AppUsageEntry.fromJson(Map<String, dynamic> json) => AppUsageEntry(
        appName: json['appName'] as String,
        category: AppCategory.values[json['category'] as int],
        durationMinutes: json['durationMinutes'] as int,
        openCount: json['openCount'] as int? ?? 1,
      );

  String get formattedDuration {
    final h = durationMinutes ~/ 60;
    final m = durationMinutes % 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }
}

/// A continuous screen session.
class ScreenSession {
  final DateTime startTime;
  final DateTime endTime;

  const ScreenSession({required this.startTime, required this.endTime});

  int get durationMinutes => endTime.difference(startTime).inMinutes;
  bool get isLateNight => startTime.hour >= 23 || endTime.hour >= 23 || startTime.hour < 5;

  Map<String, dynamic> toJson() => {
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
      };

  factory ScreenSession.fromJson(Map<String, dynamic> json) => ScreenSession(
        startTime: DateTime.parse(json['startTime'] as String),
        endTime: DateTime.parse(json['endTime'] as String),
      );
}

/// Complete daily screen time data.
class DailyScreenData {
  final DateTime date;
  final List<AppUsageEntry> appUsage;
  final List<ScreenSession> sessions;
  final int unlockCount;
  final int breaksTaken;
  final int breaksDismissed;

  const DailyScreenData({
    required this.date,
    this.appUsage = const [],
    this.sessions = const [],
    this.unlockCount = 0,
    this.breaksTaken = 0,
    this.breaksDismissed = 0,
  });

  int get totalMinutes => appUsage.fold(0, (sum, e) => sum + e.durationMinutes);
  int get productiveMinutes => appUsage
      .where((e) => e.category.isProductive)
      .fold(0, (sum, e) => sum + e.durationMinutes);
  int get nonProductiveMinutes => totalMinutes - productiveMinutes;
  int get longestSessionMinutes =>
      sessions.isEmpty ? 0 : sessions.map((s) => s.durationMinutes).reduce((a, b) => a > b ? a : b);
  int get lateNightMinutes =>
      sessions.where((s) => s.isLateNight).fold(0, (sum, s) => sum + s.durationMinutes);
  int get socialMediaMinutes => appUsage
      .where((e) => e.category == AppCategory.social)
      .fold(0, (sum, e) => sum + e.durationMinutes);
  double get productiveRatio =>
      totalMinutes > 0 ? productiveMinutes / totalMinutes : 0;
  double get breakCompliance =>
      (breaksTaken + breaksDismissed) > 0
          ? breaksTaken / (breaksTaken + breaksDismissed)
          : 1.0;

  String get formattedTotal {
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  String get dateKey => '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'appUsage': appUsage.map((e) => e.toJson()).toList(),
        'sessions': sessions.map((s) => s.toJson()).toList(),
        'unlockCount': unlockCount,
        'breaksTaken': breaksTaken,
        'breaksDismissed': breaksDismissed,
      };

  factory DailyScreenData.fromJson(Map<String, dynamic> json) => DailyScreenData(
        date: DateTime.parse(json['date'] as String),
        appUsage: (json['appUsage'] as List)
            .map((e) => AppUsageEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
        sessions: (json['sessions'] as List)
            .map((s) => ScreenSession.fromJson(s as Map<String, dynamic>))
            .toList(),
        unlockCount: json['unlockCount'] as int? ?? 0,
        breaksTaken: json['breaksTaken'] as int? ?? 0,
        breaksDismissed: json['breaksDismissed'] as int? ?? 0,
      );

  DailyScreenData copyWith({
    DateTime? date,
    List<AppUsageEntry>? appUsage,
    List<ScreenSession>? sessions,
    int? unlockCount,
    int? breaksTaken,
    int? breaksDismissed,
  }) =>
      DailyScreenData(
        date: date ?? this.date,
        appUsage: appUsage ?? this.appUsage,
        sessions: sessions ?? this.sessions,
        unlockCount: unlockCount ?? this.unlockCount,
        breaksTaken: breaksTaken ?? this.breaksTaken,
        breaksDismissed: breaksDismissed ?? this.breaksDismissed,
      );
}

/// User-defined screen time limits.
class ScreenTimeLimits {
  final int dailyTotalMinutes;
  final int socialMediaMinutes;
  final int entertainmentMinutes;
  final int continuousSessionMinutes;
  final int lateNightCutoffHour; // 24h format, e.g. 23 means 11 PM

  const ScreenTimeLimits({
    this.dailyTotalMinutes = 240,       // 4 hours
    this.socialMediaMinutes = 60,       // 1 hour
    this.entertainmentMinutes = 90,     // 1.5 hours
    this.continuousSessionMinutes = 45, // 45 min
    this.lateNightCutoffHour = 23,      // 11 PM
  });

  Map<String, dynamic> toJson() => {
        'dailyTotalMinutes': dailyTotalMinutes,
        'socialMediaMinutes': socialMediaMinutes,
        'entertainmentMinutes': entertainmentMinutes,
        'continuousSessionMinutes': continuousSessionMinutes,
        'lateNightCutoffHour': lateNightCutoffHour,
      };

  factory ScreenTimeLimits.fromJson(Map<String, dynamic> json) => ScreenTimeLimits(
        dailyTotalMinutes: json['dailyTotalMinutes'] as int? ?? 240,
        socialMediaMinutes: json['socialMediaMinutes'] as int? ?? 60,
        entertainmentMinutes: json['entertainmentMinutes'] as int? ?? 90,
        continuousSessionMinutes: json['continuousSessionMinutes'] as int? ?? 45,
        lateNightCutoffHour: json['lateNightCutoffHour'] as int? ?? 23,
      );

  ScreenTimeLimits copyWith({
    int? dailyTotalMinutes,
    int? socialMediaMinutes,
    int? entertainmentMinutes,
    int? continuousSessionMinutes,
    int? lateNightCutoffHour,
  }) =>
      ScreenTimeLimits(
        dailyTotalMinutes: dailyTotalMinutes ?? this.dailyTotalMinutes,
        socialMediaMinutes: socialMediaMinutes ?? this.socialMediaMinutes,
        entertainmentMinutes: entertainmentMinutes ?? this.entertainmentMinutes,
        continuousSessionMinutes: continuousSessionMinutes ?? this.continuousSessionMinutes,
        lateNightCutoffHour: lateNightCutoffHour ?? this.lateNightCutoffHour,
      );
}

/// Risk/alert types for intelligent detection.
enum ScreenRiskType {
  excessiveScreenTime,
  eyeStrainRisk,
  poorSleepRisk,
  doomScrolling,
  productivityLeak,
  lateNightUsage,
  postureRisk,
  mentalFatigue,
  continuousSession;

  String get title {
    switch (this) {
      case excessiveScreenTime:
        return 'Excessive Screen Time';
      case eyeStrainRisk:
        return 'Eye Strain Risk';
      case poorSleepRisk:
        return 'Poor Sleep Risk';
      case doomScrolling:
        return 'Doom Scrolling';
      case productivityLeak:
        return 'Productivity Leak';
      case lateNightUsage:
        return 'Late-Night Usage';
      case postureRisk:
        return 'Posture Risk';
      case mentalFatigue:
        return 'Mental Fatigue';
      case continuousSession:
        return 'Continuous Session';
    }
  }

  String get icon {
    switch (this) {
      case excessiveScreenTime:
        return '⏰';
      case eyeStrainRisk:
        return '👁️';
      case poorSleepRisk:
        return '😴';
      case doomScrolling:
        return '📲';
      case productivityLeak:
        return '📉';
      case lateNightUsage:
        return '🌙';
      case postureRisk:
        return '🧘';
      case mentalFatigue:
        return '🧠';
      case continuousSession:
        return '⚡';
    }
  }
}

/// An intelligent alert generated by the risk detection engine.
class ScreenAlert {
  final ScreenRiskType type;
  final String message;
  final DateTime timestamp;
  final double severity; // 0.0 - 1.0

  const ScreenAlert({
    required this.type,
    required this.message,
    required this.timestamp,
    this.severity = 0.5,
  });
}

/// Digital Wellness Score out of 100.
class DigitalWellnessScore {
  final int score;
  final int screenTimeScore;
  final int continuousExposureScore;
  final int bedtimeScore;
  final int socialMediaScore;
  final int productivityScore;
  final int breakComplianceScore;

  const DigitalWellnessScore({
    required this.score,
    required this.screenTimeScore,
    required this.continuousExposureScore,
    required this.bedtimeScore,
    required this.socialMediaScore,
    required this.productivityScore,
    required this.breakComplianceScore,
  });

  String get label {
    if (score >= 90) return 'Optimal';
    if (score >= 75) return 'Good';
    if (score >= 60) return 'Moderate';
    if (score >= 40) return 'Below Average';
    return 'Critical';
  }

  String get emoji {
    return ''; // Emojis removed — professional mode
  }

  /// Calculate the digital wellness score from daily data and limits.
  factory DigitalWellnessScore.calculate(DailyScreenData data, ScreenTimeLimits limits) {
    // Screen time score (max 25 points)
    final stRatio = data.totalMinutes / limits.dailyTotalMinutes;
    final stScore = stRatio <= 0.5 ? 25 : stRatio <= 1.0 ? (25 * (1.0 - (stRatio - 0.5))).round() : (stRatio <= 1.5 ? (12 * (1.5 - stRatio) / 0.5).round() : 0);

    // Continuous exposure score (max 20 points)
    final longestPct = data.longestSessionMinutes / limits.continuousSessionMinutes;
    final ceScore = longestPct <= 0.5 ? 20 : longestPct <= 1.0 ? (20 * (1.0 - (longestPct - 0.5))).round() : (longestPct <= 2.0 ? (10 * (2.0 - longestPct)).round() : 0);

    // Bedtime score (max 15 points)
    final btScore = data.lateNightMinutes == 0 ? 15 : data.lateNightMinutes <= 15 ? 10 : data.lateNightMinutes <= 30 ? 5 : 0;

    // Social media score (max 15 points)
    final smRatio = limits.socialMediaMinutes > 0 ? data.socialMediaMinutes / limits.socialMediaMinutes : 0.0;
    final smScore = smRatio <= 0.5 ? 15 : smRatio <= 1.0 ? (15 * (1.0 - (smRatio - 0.5))).round() : (smRatio <= 2.0 ? (7 * (2.0 - smRatio)).round() : 0);

    // Productivity score (max 15 points)
    final pScore = (data.productiveRatio * 15).round().clamp(0, 15);

    // Break compliance score (max 10 points)
    final bcScore = (data.breakCompliance * 10).round().clamp(0, 10);

    final total = (stScore + ceScore + btScore + smScore + pScore + bcScore).clamp(0, 100);

    return DigitalWellnessScore(
      score: total,
      screenTimeScore: stScore,
      continuousExposureScore: ceScore,
      bedtimeScore: btScore,
      socialMediaScore: smScore,
      productivityScore: pScore,
      breakComplianceScore: bcScore,
    );
  }
}

/// AI-generated insight about digital behavior.
class BehavioralInsight {
  final String insight;
  final String icon;
  final double impact; // -1.0 negative to 1.0 positive

  const BehavioralInsight({
    required this.insight,
    required this.icon,
    this.impact = 0,
  });
}
