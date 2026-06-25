import 'package:flutter/material.dart';
import 'core/config/routes.dart';
import 'core/theme/app_theme.dart';
import 'shared/services/theme_service.dart';

/// Root application widget — listens to ThemeService for live theme switching.
class InsightApp extends StatefulWidget {
  const InsightApp({super.key});

  @override
  State<InsightApp> createState() => _InsightAppState();
}

class _InsightAppState extends State<InsightApp> {
  final _theme = ThemeService.instance;

  @override
  void initState() {
    super.initState();
    _theme.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    _theme.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'INSIGHT',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _theme.mode,
      routerConfig: AppRouter.router,
    );
  }
}
