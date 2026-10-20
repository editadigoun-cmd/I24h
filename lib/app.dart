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
    final hasSession = I24HConfig.backendReady && Supabase.instance.client.auth.currentSession != null;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'I24H',
      theme: AppTheme.light,
      home: hasSession ? const RoleHomeGate() : const OnboardingScreen(),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/mobile': (_) => const UserAppScreen(),
        '/admin': (_) => const AdminDashboardScreen(),
        '/animateur': (_) => const AnimateurDashboardScreen(),
      },
    );
  }
}

class RoleHomeGate extends StatefulWidget {
  const RoleHomeGate({super.key});
  @override
  State<RoleHomeGate> createState() => _RoleHomeGateState();
}

class _RoleHomeGateState extends State<RoleHomeGate> {
  late Future<String> destination;

  @override
  void initState() {
    super.initState();
    destination = _resolveDestination();
  }

  Future<String> _resolveDestination() async {
    try {
      final client = Supabase.instance.client;
      final user = client.auth.currentUser;
      if (user == null) return '/login';
      final profile = await client.from('profiles').select('role').eq('id', user.id).maybeSingle();
      switch (profile?['role'] as String? ?? 'faithful') {
        case 'admin':
          return '/admin';
        case 'animateur':
          return '/animateur';
        default:
          return '/mobile';
      }
    } catch (error) {
      debugPrint('I24H role routing fallback: $error');
      return '/mobile';
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<String>(
    future: destination,
    builder: (context, snapshot) {
      if (snapshot.hasError || snapshot.connectionState == ConnectionState.done) {
        switch (snapshot.data ?? '/mobile') {
          case '/admin':
            return const AdminDashboardScreen();
          case '/animateur':
            return const AnimateurDashboardScreen();
          case '/login':
            return const LoginScreen();
          default:
            return const UserAppScreen();
        }
      }
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          CircularProgressIndicator(),
          SizedBox(height: 18),
          Text('Préparation de votre espace I24H…', style: TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700)),
        ])),
      );
    },
  );
}
