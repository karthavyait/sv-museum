import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData build() {
    const primaryColor = Color(0xFF5D4037);
    const secondaryColor = Color(0xFFD7CCC8);

    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
      ),
      scaffoldBackgroundColor: const Color(0xFFF8F5F2),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF5D4037),
        foregroundColor: Colors.white,
      ),
      cardTheme: const CardThemeData(
  elevation: 0.5,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(16)),
  ),
),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      useMaterial3: true,
    );
  }
}
