import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'shared/services/user_data_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load persisted user data (health profile, daily stats)
  await UserDataService.instance.load();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0D1117),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const InsightApp());
}
