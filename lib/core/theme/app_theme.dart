import 'package:flutter/material.dart';

class AppColors {
  static const navy = Color(0xFF0B1F3A);
  static const blue = Color(0xFF1463FF);
  static const sky = Color(0xFFEAF2FF);
  static const gold = Color(0xFFC89B3C);
  static const ink = Color(0xFF111827);
  static const muted = Color(0xFF667085);
  static const background = Color(0xFFF7F9FC);
  static const surface = Colors.white;
  static const line = Color(0xFFE4E7EC);
}

class AppTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(seedColor: AppColors.blue, brightness: Brightness.light);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme.copyWith(primary: AppColors.blue, surface: AppColors.surface),
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0, foregroundColor: AppColors.ink),
      textTheme: const TextTheme(
        displaySmall: TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink, letterSpacing: -0.8),
        headlineSmall: TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink, letterSpacing: -0.4),
        titleLarge: TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink),
        titleMedium: TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink),
        bodyLarge: TextStyle(color: AppColors.ink, height: 1.45),
        bodyMedium: TextStyle(color: AppColors.muted, height: 1.4),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.line)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.line)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.blue, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), textStyle: const TextStyle(fontWeight: FontWeight.w700))),
      cardTheme: CardThemeData(color: Colors.white, elevation: 0, margin: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: AppColors.line))),
    );
  }
}
