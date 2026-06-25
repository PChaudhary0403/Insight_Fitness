import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/screen_time_models.dart';

/// Service for REAL screen time monitoring via Android UsageStats API.
///
/// On Android, this communicates with the native UsageStatsManager via a
/// platform channel. On web/unsupported platforms, it shows empty state.
/// NO simulated/fake data is generated.
class ScreenTimeService {
  ScreenTimeService._();
  static final ScreenTimeService instance = ScreenTimeService._();

  static const _channel = MethodChannel('com.insight.health/usage_stats');
  static const _limitsKey = 'screen_time_limits';
  static const _permissionKey = 'screen_time_permission';
  static const _enabledKey = 'screen_time_enabled';
  static const _focusModeKey = 'focus_mode_active';
  static const _historyKeyPrefix = 'screen_data_';

  ScreenTimeLimits _limits = const ScreenTimeLimits();
  ScreenTimeLimits get limits => _limits;

  bool _permissionGranted = false;
  bool get permissionGranted => _permissionGranted;

  bool _enabled = false;
  bool get enabled => _enabled;

  bool _focusModeActive = false;
  bool get focusModeActive => _focusModeActive;

  bool _isNativeAvailable = false;
  bool get isNativeAvailable => _isNativeAvailable;

  final Map<String, DailyScreenData> _cache = {};

  // ─── Known app name/category mapping ──────────────────────
  static const _appCategories = <String, AppCategory>{
    'instagram': AppCategory.social,
    'facebook': AppCategory.social,
    'twitter': AppCategory.social,
    'snapchat': AppCategory.social,
    'tiktok': AppCategory.social,
    'reddit': AppCategory.social,
    'threads': AppCategory.social,
    'linkedin': AppCategory.social,
    'pinterest': AppCategory.social,
    'youtube': AppCategory.entertainment,
    'netflix': AppCategory.entertainment,
    'spotify': AppCategory.entertainment,
    'prime video': AppCategory.entertainment,
    'disney': AppCategory.entertainment,
    'hotstar': AppCategory.entertainment,
    'jiocinema': AppCategory.entertainment,
    'chrome': AppCategory.browser,
    'firefox': AppCategory.browser,
    'edge': AppCategory.browser,
    'brave': AppCategory.browser,
    'samsung internet': AppCategory.browser,
    'whatsapp': AppCategory.communication,
    'telegram': AppCategory.communication,
    'signal': AppCategory.communication,
    'messages': AppCategory.communication,
    'phone': AppCategory.communication,
    'gmail': AppCategory.communication,
    'outlook': AppCategory.communication,
    'slack': AppCategory.productivity,
    'notion': AppCategory.productivity,
    'google docs': AppCategory.productivity,
    'sheets': AppCategory.productivity,
    'drive': AppCategory.productivity,
    'files': AppCategory.utility,
    'calculator': AppCategory.utility,
    'clock': AppCategory.utility,
    'settings': AppCategory.utility,
    'camera': AppCategory.utility,
    'gallery': AppCategory.utility,
    'photos': AppCategory.utility,
    'duolingo': AppCategory.education,
    'coursera': AppCategory.education,
    'udemy': AppCategory.education,
    'kindle': AppCategory.education,
    'health': AppCategory.health,
    'fit': AppCategory.health,
    'insight': AppCategory.health,
    'strava': AppCategory.health,
  };

  // ─── Initialization ────────────────────────────────────────
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _permissionGranted = prefs.getBool(_permissionKey) ?? false;
    _enabled = prefs.getBool(_enabledKey) ?? false;
    _focusModeActive = prefs.getBool(_focusModeKey) ?? false;

    final limitsJson = prefs.getString(_limitsKey);
    if (limitsJson != null) {
      try {
        _limits = ScreenTimeLimits.fromJson(jsonDecode(limitsJson));
      } catch (_) {}
    }

    // Check if native platform channel is available
    if (!kIsWeb) {
      try {
        final hasPermission = await _channel.invokeMethod<bool>('hasPermission');
        _isNativeAvailable = true;
        _permissionGranted = hasPermission ?? false;
        if (_permissionGranted) {
          _enabled = true;
          await prefs.setBool(_permissionKey, true);
          await prefs.setBool(_enabledKey, true);
        }
      } on MissingPluginException {
        _isNativeAvailable = false;
      } catch (e) {
        debugPrint('ScreenTimeService: Platform channel error: $e');
        _isNativeAvailable = false;
      }
    }
  }

  // ─── Permission ────────────────────────────────────────────
  Future<bool> requestPermission() async {
    if (!_isNativeAvailable) return false;

    try {
      await _channel.invokeMethod('requestPermission');
      // User will be taken to settings — check after they return
      return true;
    } catch (e) {
      debugPrint('ScreenTimeService: requestPermission error: $e');
      return false;
    }
  }

  Future<bool> checkPermission() async {
    if (!_isNativeAvailable) return false;

    try {
      final result = await _channel.invokeMethod<bool>('hasPermission');
      _permissionGranted = result ?? false;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_permissionKey, _permissionGranted);
      if (_permissionGranted) {
        _enabled = true;
        await prefs.setBool(_enabledKey, true);
      }
      return _permissionGranted;
    } catch (e) {
      return false;
    }
  }

  Future<void> grantPermission() async {
    _permissionGranted = true;
    _enabled = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_permissionKey, true);
    await prefs.setBool(_enabledKey, true);
  }

  Future<void> revokePermission() async {
    _permissionGranted = false;
    _enabled = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_permissionKey, false);
    await prefs.setBool(_enabledKey, false);
  }

  Future<void> setEnabled(bool value) async {
    _enabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, value);
  }

  // ─── Focus Mode ────────────────────────────────────────────
  Future<void> toggleFocusMode() async {
    _focusModeActive = !_focusModeActive;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_focusModeKey, _focusModeActive);
  }

  // ─── Limits ────────────────────────────────────────────────
  Future<void> saveLimits(ScreenTimeLimits limits) async {
    _limits = limits;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_limitsKey, jsonEncode(limits.toJson()));
  }

  // ─── Daily Data (REAL from platform channel) ───────────────
  Future<DailyScreenData> getDailyData(DateTime date) async {
    final key = _dateKey(date);
    if (_cache.containsKey(key)) return _cache[key]!;

    // Try loading from local cache first
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('$_historyKeyPrefix$key');
    if (json != null) {
      try {
        final data = DailyScreenData.fromJson(jsonDecode(json));
        _cache[key] = data;
        return data;
      } catch (_) {}
    }

    // Fetch REAL data from Android UsageStats
    if (_isNativeAvailable && _permissionGranted) {
      try {
        final daysBack = DateTime.now().difference(date).inDays;
        final rawStats = await _channel.invokeMethod<List<dynamic>>('getUsageStats', {
          'daysBack': daysBack,
        });

        if (rawStats != null && rawStats.isNotEmpty) {
          final data = _parseRealUsageStats(date, rawStats);
          _cache[key] = data;
          await _saveDailyData(data);
          return data;
        }
      } catch (e) {
        debugPrint('ScreenTimeService: getUsageStats error: $e');
      }
    }

    // No data available — return empty (NOT simulated)
    final empty = DailyScreenData(date: date);
    _cache[key] = empty;
    return empty;
  }

  Future<DailyScreenData> getTodayData() => getDailyData(DateTime.now());

  Future<List<DailyScreenData>> getWeekData() async {
    final now = DateTime.now();
    final results = <DailyScreenData>[];
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      results.add(await getDailyData(date));
    }
    return results;
  }

  Future<List<DailyScreenData>> getMonthData() async {
    final now = DateTime.now();
    final results = <DailyScreenData>[];
    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      results.add(await getDailyData(date));
    }
    return results;
  }

  /// Force refresh today's data from the platform.
  Future<DailyScreenData> refreshToday() async {
    final key = _dateKey(DateTime.now());
    _cache.remove(key);
    return getTodayData();
  }

  Future<void> _saveDailyData(DailyScreenData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        '$_historyKeyPrefix${data.dateKey}', jsonEncode(data.toJson()));
  }

  // ─── Parse Real Android Usage Stats ────────────────────────
  DailyScreenData _parseRealUsageStats(DateTime date, List<dynamic> rawStats) {
    final apps = <AppUsageEntry>[];

    for (final raw in rawStats) {
      if (raw is! Map) continue;
      final packageName = (raw['packageName'] as String?) ?? '';
      final totalMinutes = (raw['totalMinutes'] as num?)?.toInt() ?? 0;

      if (totalMinutes <= 0) continue;

      // Extract readable app name from package name
      final appName = _packageToAppName(packageName);
      final category = _categorizeApp(packageName, appName);

      apps.add(AppUsageEntry(
        appName: appName,
        category: category,
        durationMinutes: totalMinutes,
        openCount: 1, // UsageStats doesn't provide per-day open count easily
      ));
    }

    // Sort by duration descending
    apps.sort((a, b) => b.durationMinutes.compareTo(a.durationMinutes));

    return DailyScreenData(
      date: date,
      appUsage: apps,
      sessions: [], // Sessions would require more detailed event queries
      unlockCount: 0, // Would need separate API
      breaksTaken: 0,
      breaksDismissed: 0,
    );
  }

  /// Convert Android package name to human-readable app name.
  String _packageToAppName(String packageName) {
    // Common package name mappings
    const known = {
      'com.instagram.android': 'Instagram',
      'com.facebook.katana': 'Facebook',
      'com.twitter.android': 'Twitter',
      'com.google.android.youtube': 'YouTube',
      'com.whatsapp': 'WhatsApp',
      'com.snapchat.android': 'Snapchat',
      'com.zhiliaoapp.musically': 'TikTok',
      'com.reddit.frontpage': 'Reddit',
      'com.spotify.music': 'Spotify',
      'com.netflix.mediaclient': 'Netflix',
      'com.google.android.apps.messaging': 'Messages',
      'com.google.android.gm': 'Gmail',
      'com.google.android.apps.docs': 'Google Docs',
      'com.google.android.apps.maps': 'Google Maps',
      'com.google.android.apps.photos': 'Google Photos',
      'com.google.android.apps.nbu.files': 'Files',
      'com.android.chrome': 'Chrome',
      'org.mozilla.firefox': 'Firefox',
      'com.microsoft.emmx': 'Edge',
      'com.brave.browser': 'Brave',
      'com.samsung.android.app.sbrowser': 'Samsung Internet',
      'org.telegram.messenger': 'Telegram',
      'org.thoughtcrime.securesms': 'Signal',
      'com.slack': 'Slack',
      'com.amazon.avod': 'Prime Video',
      'in.startv.hotstar': 'Hotstar',
      'com.jio.media.ondemand': 'JioCinema',
      'com.linkedin.android': 'LinkedIn',
      'com.pinterest': 'Pinterest',
      'com.threads.android': 'Threads',
      'com.google.android.dialer': 'Phone',
      'com.google.android.contacts': 'Contacts',
      'com.google.android.calendar': 'Calendar',
      'com.android.settings': 'Settings',
      'com.samsung.android.messaging': 'Messages',
      'com.samsung.android.dialer': 'Phone',
      'com.miui.home': 'Launcher',
      'com.miui.securitycenter': 'Security',
      'com.xiaomi.market': 'Mi Store',
    };

    if (known.containsKey(packageName)) return known[packageName]!;

    // Fallback: extract last part of package name and capitalize
    final parts = packageName.split('.');
    final last = parts.length > 1 ? parts.last : packageName;
    return last[0].toUpperCase() + last.substring(1);
  }

  /// Categorize an app as productive/non-productive based on its name/package.
  AppCategory _categorizeApp(String packageName, String appName) {
    final lower = appName.toLowerCase();

    // Check known categories
    for (final entry in _appCategories.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }

    // Package-based heuristics
    if (packageName.contains('game') || packageName.contains('gaming')) {
      return AppCategory.gaming;
    }
    if (packageName.contains('music') || packageName.contains('video') || packageName.contains('player')) {
      return AppCategory.entertainment;
    }
    if (packageName.contains('office') || packageName.contains('work') || packageName.contains('docs')) {
      return AppCategory.productivity;
    }
    if (packageName.contains('education') || packageName.contains('learn')) {
      return AppCategory.education;
    }
    if (packageName.contains('health') || packageName.contains('fitness') || packageName.contains('workout')) {
      return AppCategory.health;
    }
    if (packageName.contains('launcher') || packageName.contains('settings') || packageName.contains('system')) {
      return AppCategory.utility;
    }

    return AppCategory.other;
  }

  // ─── Break Logging ─────────────────────────────────────────
  Future<void> logBreakTaken() async {
    final today = await getTodayData();
    final updated = today.copyWith(breaksTaken: today.breaksTaken + 1);
    _cache[updated.dateKey] = updated;
    await _saveDailyData(updated);
  }

  Future<void> logBreakDismissed() async {
    final today = await getTodayData();
    final updated = today.copyWith(breaksDismissed: today.breaksDismissed + 1);
    _cache[updated.dateKey] = updated;
    await _saveDailyData(updated);
  }

  // ─── Risk Detection Engine ─────────────────────────────────
  List<ScreenAlert> detectRisks(DailyScreenData data) {
    final alerts = <ScreenAlert>[];
    final now = DateTime.now();

    if (data.totalMinutes > _limits.dailyTotalMinutes) {
      alerts.add(ScreenAlert(
        type: ScreenRiskType.excessiveScreenTime,
        message:
            'Daily screen time (${data.formattedTotal}) exceeded your ${_limits.dailyTotalMinutes ~/ 60}h limit.',
        timestamp: now,
        severity: 0.8,
      ));
    }

    if (data.totalMinutes > 120) {
      alerts.add(ScreenAlert(
        type: ScreenRiskType.eyeStrainRisk,
        message: 'High screen exposure detected. Take a 5-minute eye break.',
        timestamp: now,
        severity: 0.6,
      ));
    }

    if (data.lateNightMinutes > 0) {
      alerts.add(ScreenAlert(
        type: ScreenRiskType.poorSleepRisk,
        message:
            'Late-night screen usage (${data.lateNightMinutes}m) may impact sleep quality.',
        timestamp: now,
        severity: 0.75,
      ));
    }

    if (data.socialMediaMinutes > _limits.socialMediaMinutes) {
      alerts.add(ScreenAlert(
        type: ScreenRiskType.doomScrolling,
        message:
            'Social media usage exceeded healthy threshold by ${data.socialMediaMinutes - _limits.socialMediaMinutes}m.',
        timestamp: now,
        severity: 0.65,
      ));
    }

    if (data.productiveRatio < 0.3 && data.totalMinutes > 60) {
      alerts.add(ScreenAlert(
        type: ScreenRiskType.productivityLeak,
        message:
            'Only ${(data.productiveRatio * 100).round()}% of screen time was productive today.',
        timestamp: now,
        severity: 0.5,
      ));
    }

    return alerts;
  }

  // ─── AI Behavioral Analysis (REAL data-driven) ─────────────
  Future<List<BehavioralInsight>> generateInsights() async {
    final week = await getWeekData();
    final insights = <BehavioralInsight>[];

    // Only generate insights if we have real data
    final hasData = week.any((d) => d.totalMinutes > 0);
    if (!hasData) {
      insights.add(const BehavioralInsight(
        insight: 'No screen time data available yet. Grant permission to start tracking.',
        icon: '📊',
        impact: 0,
      ));
      return insights;
    }

    // Avg screen time
    final daysWithData = week.where((d) => d.totalMinutes > 0).toList();
    if (daysWithData.isNotEmpty) {
      final avgTotal =
          daysWithData.fold(0, (sum, d) => sum + d.totalMinutes) / daysWithData.length;
      insights.add(BehavioralInsight(
        insight:
            'Average daily screen time this week: ${(avgTotal ~/ 60)}h ${(avgTotal % 60).round()}m.',
        icon: '📊',
        impact: avgTotal > _limits.dailyTotalMinutes ? -0.5 : 0.5,
      ));
    }

    // Weekend vs weekday comparison
    final weekdayData = daysWithData.where((d) => d.date.weekday <= 5).toList();
    final weekendData = daysWithData.where((d) => d.date.weekday > 5).toList();
    if (weekdayData.isNotEmpty && weekendData.isNotEmpty) {
      final weekdaySocial = weekdayData.fold(0, (sum, d) => sum + d.socialMediaMinutes);
      final weekendSocial = weekendData.fold(0, (sum, d) => sum + d.socialMediaMinutes);
      final avgWeekday = weekdaySocial / weekdayData.length;
      final avgWeekend = weekendSocial / weekendData.length;

      if (avgWeekday > 0 && avgWeekend / avgWeekday > 1.5) {
        insights.add(BehavioralInsight(
          insight:
              'Weekend social media usage is ${(avgWeekend / avgWeekday).toStringAsFixed(1)}x higher than weekdays.',
          icon: '📱',
          impact: -0.4,
        ));
      }
    }

    // Productive ratio analysis
    final avgProd = daysWithData.fold(0.0, (sum, d) => sum + d.productiveRatio) /
        daysWithData.length;
    if (avgProd > 0.6) {
      insights.add(BehavioralInsight(
        insight: 'Great productive ratio (${(avgProd * 100).round()}%). Keep it up!',
        icon: '💪',
        impact: 0.7,
      ));
    } else if (avgProd < 0.3 && daysWithData.length >= 3) {
      insights.add(BehavioralInsight(
        insight:
            'Low productive ratio (${(avgProd * 100).round()}%). Consider reducing social media time.',
        icon: '📉',
        impact: -0.5,
      ));
    }

    // Top app analysis
    final today = await getTodayData();
    if (today.appUsage.isNotEmpty) {
      final topApp = today.appUsage.first;
      insights.add(BehavioralInsight(
        insight: 'Most used app today: ${topApp.appName} (${topApp.formattedDuration}).',
        icon: '📱',
        impact: topApp.category.isProductive ? 0.3 : -0.3,
      ));
    }

    return insights;
  }

  // ─── Digital Wellness Score ────────────────────────────────
  Future<DigitalWellnessScore> calculateWellnessScore() async {
    final data = await getTodayData();
    return DigitalWellnessScore.calculate(data, _limits);
  }

  // ─── Data Export / Delete ──────────────────────────────────
  Future<String> exportData() async {
    final week = await getWeekData();
    return jsonEncode(week.map((d) => d.toJson()).toList());
  }

  Future<void> deleteAllData() async {
    _cache.clear();
    final prefs = await SharedPreferences.getInstance();
    final keys =
        prefs.getKeys().where((k) => k.startsWith(_historyKeyPrefix));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  // ─── Helpers ───────────────────────────────────────────────
  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
