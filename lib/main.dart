import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/router.dart';
import 'theme/app_theme.dart';

/// Main entry point of the DealDine application.
/// 
/// The app is wrapped in ProviderScope to enable Riverpod state management,
/// and uses Material 3 design with Material You dynamic theming support.
void main() {
  runApp(
    const ProviderScope(
      child: DealDineApp(),
    ),
  );
}

/// DealDineApp is the root widget of the application.
/// 
/// It configures:
/// - GoRouter for navigation
/// - Material 3 themes (light and dark)
/// - App branding and metadata
class DealDineApp extends StatelessWidget {
  /// Creates the DealDineApp widget.
  const DealDineApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // ============ Branding ============
      title: 'DealDine',
      debugShowCheckedModeBanner: false,
      
      // ============ Theming ============
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.system,
      
      // ============ Routing ============
      routerConfig: AppRouter.createRouter(),
    );
  }
}