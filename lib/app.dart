import 'package:flutter/material.dart';
import 'core/config/routes.dart';
import 'core/theme/app_theme.dart';

/// Root application widget.
class InsightApp extends StatelessWidget {
  const InsightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'INSIGHT',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Default to dark for premium feel
      routerConfig: AppRouter.router,
    );
  }
}
