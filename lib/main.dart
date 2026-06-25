import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'shared/services/user_data_service.dart';
import 'shared/services/planner_service.dart';
import 'shared/services/notification_service.dart';
import 'shared/services/theme_service.dart';
import 'features/screen_time/data/services/screen_time_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load persisted user data (health profile, daily stats)
  await UserDataService.instance.load();

  // Load planner, tick sheet, discipline data
  await PlannerService.instance.load();

  // Load screen time monitoring data
  await ScreenTimeService.instance.load();

  // Load theme preference
  await ThemeService.instance.load();

  // Initialize notification system
  await NotificationService.instance.init();

  // Request notification permission (Android 13+)
  final hasNotifPermission = await NotificationService.instance.requestPermission();
  if (hasNotifPermission) {
    // Schedule all default reminders
    await NotificationService.instance.scheduleAllDefaults();
  }

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style based on theme
  final isDark = ThemeService.instance.isDark;
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: isDark ? const Color(0xFF0D1117) : const Color(0xFFF8F9FA),
      systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    ),
  );

  runApp(const InsightApp());
}

