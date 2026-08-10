
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTheme {


  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: Color(0xFF415f91),
        onPrimary: Color(0xFFffffff),
        secondary: Color(0xFF565f71),
        onSecondary: Color(0xFFffffff),
        error: Color(0xFFba1a1a),
        onError: Color(0xFFffffff),
        surface: Color(0xFFf9f9ff),
        onSurface: Color(0xFF191c20),
      ),
      textTheme: _buildTextTheme(),
      elevatedButtonTheme: _buildButtonTheme(isDark: false),
    );
  }  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: Color(0xFFaaccff), // Более мягкий светлый оттенок для темной темы
        onPrimary: Color(0xFF0a305f),
        secondary: Color(0xFFbfc7da),
        onSecondary: Color(0xFF283141),
        error: Color(0xFFffb4ab),
        onError: Color(0xFF690005),
        surface: Color(0xFF111318),   // Темный фон
        onSurface: Color(0xFFe2e2e9), // Светлый текст на темном фоне
      ),
      textTheme: _buildTextTheme(isDark: true),
      elevatedButtonTheme: _buildButtonTheme(isDark: true),
    );
  }
  
  static TextTheme _buildTextTheme({bool isDark = false}) {
    final baseColor = isDark ? Colors.white70 : Colors.black87;
    final secondaryColor = isDark ? Colors.white54 : Colors.black54;

    return TextTheme(
      displayLarge: TextStyle(fontSize: 46, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.normal, letterSpacing: 0.5),
      bodyLarge: TextStyle(fontSize: 16, color: baseColor, height: 1.5),
      bodyMedium: TextStyle(fontSize: 14, color: secondaryColor),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
    );
  }

  // Выносим стиль кнопок
  static ElevatedButtonThemeData _buildButtonTheme({required bool isDark}) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: isDark ? const Color(0xFFaaccff) : Colors.blue,
        foregroundColor: isDark ? const Color(0xFF0a305f) : Colors.white,
        shadowColor: isDark ? Colors.black54 : Colors.blueGrey,
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



