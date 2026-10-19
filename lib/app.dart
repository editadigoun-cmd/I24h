import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/i24h_config.dart';
import 'core/theme/app_theme.dart';
import 'screens/auth/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/mobile/user_app_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/animateur/animateur_dashboard_screen.dart';

class I24HApp extends StatelessWidget {
  const I24HApp({super.key});

  @override
  Widget build(BuildContext context) {
    final hasSession = I24HConfig.backendReady &&
        Supabase.instance.client.auth.currentSession != null;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'I24H',
      theme: AppTheme.light,
      home: hasSession ? const UserAppScreen() : const OnboardingScreen(),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/mobile': (_) => const UserAppScreen(),
        '/admin': (_) => const AdminDashboardScreen(),
        '/animateur': (_) => const AnimateurDashboardScreen(),
      },
    );
  }
}
