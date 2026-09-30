import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'screens/auth/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/mobile/mobile_entry_screen.dart';

class I24HApp extends StatelessWidget {
  const I24HApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'I24H — Espace utilisateur',
      theme: AppTheme.light,
      initialRoute: '/',
      routes: {
        '/': (_) => const OnboardingScreen(),
        '/login': (_) => const LoginScreen(),
        '/mobile': (_) => const MobileEntryScreen(),
      },
    );
  }
}
