import 'package:flutter/material.dart';

class AppTheme {
  // Базовый синий цвет, из которого генерируется вся палитра Material 3
  static const Color _seedColor = Color(0xFF415f91);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seedColor,
        brightness: Brightness.light,
      ),
      textTheme: _buildTextTheme(),
      elevatedButtonTheme: _buildButtonTheme(isDark: false),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seedColor,
        brightness: Brightness.dark,
      ),
      textTheme: _buildTextTheme(isDark: true),
      elevatedButtonTheme: _buildButtonTheme(isDark: true),
    );
  }

  static TextTheme _buildTextTheme({bool isDark = false}) {
    final baseColor = isDark ? Colors.white70 : Colors.black87;
    final secondaryColor = isDark ? Colors.white54 : Colors.black54;

    return TextTheme(
      displayLarge: const TextStyle(fontSize: 46, fontWeight: FontWeight.bold),
      titleLarge: const TextStyle(fontSize: 22, fontWeight: FontWeight.normal, letterSpacing: 0.5),
      bodyLarge: TextStyle(fontSize: 16, color: baseColor, height: 1.5),
      bodyMedium: TextStyle(fontSize: 14, color: secondaryColor),
      labelLarge: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
    );
  }

  static ElevatedButtonThemeData _buildButtonTheme({required bool isDark}) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 5,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
