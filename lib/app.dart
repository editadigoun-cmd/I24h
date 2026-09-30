import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'screens/mobile/user_app_screen.dart';

class I24HApp extends StatelessWidget {
  const I24HApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'I24H',
    theme: AppTheme.light,
    home: const UserAppScreen(),
  );
}
