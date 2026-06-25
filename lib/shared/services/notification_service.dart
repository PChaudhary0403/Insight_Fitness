import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:permission_handler/permission_handler.dart';

/// Handles all local push notifications — hydration, meals, exercise, screen breaks.
///
/// This is a real notification system that creates actual Android/iOS system
/// notifications with sounds, vibration, and scheduled delivery.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool get isInitialized => _initialized;

  // Notification channel IDs
  static const _hydrationChannelId = 'insight_hydration';
  static const _mealChannelId = 'insight_meals';
  static const _exerciseChannelId = 'insight_exercise';
  static const _screenBreakChannelId = 'insight_screen_break';
  static const _generalChannelId = 'insight_general';

  // Notification IDs (ranges to avoid conflicts)
  static const _hydrationBaseId = 1000;
  static const _mealBaseId = 2000;
  static const _exerciseBaseId = 3000;
  static const _screenBreakBaseId = 4000;
  // _generalBaseId used for instant notification ID generation

  /// Initialize the notification system. Must be called before any notifications.
  Future<void> init() async {
    if (_initialized) return;
    if (kIsWeb) return; // Notifications don't work on web

    // Initialize timezone database
    tz_data.initializeTimeZones();

    // Android settings
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS settings
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: darwinInit,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  /// Request notification permission (required on Android 13+).
  Future<bool> requestPermission() async {
    if (kIsWeb) return false;
    if (!Platform.isAndroid && !Platform.isIOS) return false;

    final status = await Permission.notification.request();
    return status.isGranted;
  }

  /// Check if notifications are permitted.
  Future<bool> hasPermission() async {
    if (kIsWeb) return false;
    if (!Platform.isAndroid && !Platform.isIOS) return false;
    return await Permission.notification.isGranted;
  }

  // ─── Hydration Reminders ────────────────────────────────────

  /// Schedule recurring hydration reminders throughout the day.
  /// [intervalMinutes] — how often to remind (e.g., 90 = every 1.5 hours).
  /// [startHour] / [endHour] — active window (e.g., 8 AM to 10 PM).
  Future<void> scheduleHydrationReminders({
    int intervalMinutes = 90,
    int startHour = 8,
    int endHour = 22,
  }) async {
    if (!_initialized) return;

    // Cancel existing hydration reminders first
    await cancelHydrationReminders();

    final now = DateTime.now();
    int id = _hydrationBaseId;

    // Schedule reminders for today from the next interval
    var nextReminder = DateTime(now.year, now.month, now.day, startHour);
    if (nextReminder.isBefore(now)) {
      // Find the next slot after now
      while (nextReminder.isBefore(now)) {
        nextReminder = nextReminder.add(Duration(minutes: intervalMinutes));
      }
    }

    final messages = [
      '💧 Time for water! Stay hydrated.',
      '💧 Drink a glass of water now!',
      '💧 Your body needs hydration — grab some water.',
      '💧 Water break! Keep your energy up.',
      '💧 Hydration reminder — drink up! 🥤',
    ];

    int msgIdx = 0;
    while (nextReminder.hour < endHour && id < _hydrationBaseId + 20) {
      await _scheduleNotification(
        id: id++,
        channelId: _hydrationChannelId,
        channelName: 'Hydration Reminders',
        title: 'Hydration Reminder',
        body: messages[msgIdx % messages.length],
        scheduledTime: nextReminder,
      );
      nextReminder = nextReminder.add(Duration(minutes: intervalMinutes));
      msgIdx++;
    }
  }

  Future<void> cancelHydrationReminders() async {
    for (int i = _hydrationBaseId; i < _hydrationBaseId + 20; i++) {
      await _plugin.cancel(i);
    }
  }

  // ─── Meal Reminders ─────────────────────────────────────────

  /// Schedule meal reminders at specific times.
  Future<void> scheduleMealReminders({
    int breakfastHour = 8,
    int lunchHour = 13,
    int dinnerHour = 20,
    int snackHour = 16,
  }) async {
    if (!_initialized) return;

    await cancelMealReminders();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final meals = [
      (breakfastHour, 'Breakfast', '🌅 Good morning! Time for a healthy breakfast.'),
      (lunchHour, 'Lunch', '☀️ Lunch time! Eat something nutritious.'),
      (snackHour, 'Snack', '🍎 Healthy snack time! Grab some fruit or nuts.'),
      (dinnerHour, 'Dinner', '🌙 Dinner time! Don\'t skip your evening meal.'),
    ];

    int id = _mealBaseId;
    for (final meal in meals) {
      final time = today.add(Duration(hours: meal.$1));
      if (time.isAfter(now)) {
        await _scheduleNotification(
          id: id++,
          channelId: _mealChannelId,
          channelName: 'Meal Reminders',
          title: '${meal.$2} Reminder',
          body: meal.$3,
          scheduledTime: time,
        );
      }
    }
  }

  Future<void> cancelMealReminders() async {
    for (int i = _mealBaseId; i < _mealBaseId + 10; i++) {
      await _plugin.cancel(i);
    }
  }

  // ─── Exercise / Movement Reminders ──────────────────────────

  /// Schedule hourly stand-up / stretch reminders during sedentary hours.
  Future<void> scheduleExerciseReminders({
    int intervalMinutes = 60,
    int startHour = 9,
    int endHour = 18,
  }) async {
    if (!_initialized) return;

    await cancelExerciseReminders();

    final now = DateTime.now();
    int id = _exerciseBaseId;

    var next = DateTime(now.year, now.month, now.day, startHour);
    if (next.isBefore(now)) {
      while (next.isBefore(now)) {
        next = next.add(Duration(minutes: intervalMinutes));
      }
    }

    final messages = [
      '🧘 Stand up and stretch for 2 minutes!',
      '🚶 Time for a quick walk! Move your body.',
      '💪 Stretch break! Roll your neck and shoulders.',
      '🏃 Get moving! Even 5 minutes helps.',
      '🧘 Posture check! Sit up straight and stretch.',
    ];

    int msgIdx = 0;
    while (next.hour < endHour && id < _exerciseBaseId + 15) {
      await _scheduleNotification(
        id: id++,
        channelId: _exerciseChannelId,
        channelName: 'Exercise Reminders',
        title: 'Movement Reminder',
        body: messages[msgIdx % messages.length],
        scheduledTime: next,
      );
      next = next.add(Duration(minutes: intervalMinutes));
      msgIdx++;
    }
  }

  Future<void> cancelExerciseReminders() async {
    for (int i = _exerciseBaseId; i < _exerciseBaseId + 15; i++) {
      await _plugin.cancel(i);
    }
  }

  // ─── Screen Break Reminders ─────────────────────────────────

  /// Schedule screen break reminders (20-20-20 rule).
  Future<void> scheduleScreenBreakReminders({
    int intervalMinutes = 30,
    int startHour = 9,
    int endHour = 23,
  }) async {
    if (!_initialized) return;

    await cancelScreenBreakReminders();

    final now = DateTime.now();
    int id = _screenBreakBaseId;

    var next = DateTime(now.year, now.month, now.day, startHour);
    if (next.isBefore(now)) {
      while (next.isBefore(now)) {
        next = next.add(Duration(minutes: intervalMinutes));
      }
    }

    final messages = [
      '👁️ 20-20-20 Rule: Look 20 feet away for 20 seconds.',
      '📵 Screen break! Rest your eyes for a moment.',
      '👀 Eye strain alert — look away from the screen.',
      '🌿 Take a breather. Your eyes need a rest.',
    ];

    int msgIdx = 0;
    while (next.hour < endHour && id < _screenBreakBaseId + 30) {
      await _scheduleNotification(
        id: id++,
        channelId: _screenBreakChannelId,
        channelName: 'Screen Break Reminders',
        title: 'Screen Break',
        body: messages[msgIdx % messages.length],
        scheduledTime: next,
      );
      next = next.add(Duration(minutes: intervalMinutes));
      msgIdx++;
    }
  }

  Future<void> cancelScreenBreakReminders() async {
    for (int i = _screenBreakBaseId; i < _screenBreakBaseId + 30; i++) {
      await _plugin.cancel(i);
    }
  }

  // ─── Instant Notifications ──────────────────────────────────

  /// Show an immediate notification (e.g., streak milestone, goal reached).
  Future<void> showInstant({
    required String title,
    required String body,
    String? channelId,
  }) async {
    if (!_initialized) return;

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        channelId ?? _generalChannelId,
        'INSIGHT Notifications',
        channelDescription: 'General notifications from INSIGHT',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        enableVibration: true,
      ),
    );

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      title,
      body,
      details,
    );
  }

  // ─── Schedule All Default Reminders ─────────────────────────

  /// Set up all reminders with sensible defaults. Called after onboarding.
  Future<void> scheduleAllDefaults() async {
    await scheduleHydrationReminders();
    await scheduleMealReminders();
    await scheduleExerciseReminders();
    await scheduleScreenBreakReminders();
  }

  /// Cancel all scheduled notifications.
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  // ─── Get Pending Notifications ──────────────────────────────

  Future<List<PendingNotificationRequest>> getPending() async {
    if (!_initialized) return [];
    return await _plugin.pendingNotificationRequests();
  }

  // ─── Private Helpers ────────────────────────────────────────

  Future<void> _scheduleNotification({
    required int id,
    required String channelId,
    required String channelName,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    final tzTime = tz.TZDateTime.from(scheduledTime, tz.local);

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: 'INSIGHT $channelName',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        enableVibration: true,
        playSound: true,
      ),
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzTime,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap — could navigate to relevant screen
    debugPrint('Notification tapped: ${response.payload}');
  }
}
