import 'package:flutter/material.dart';

class AppTheme {
  // Colores del tema oscuro
  static const Color background = Color(0xFF0E1320);
  static const Color card = Color(0xFF151B2C);
  static const Color panel = Color(0xFF111726);
  static const Color border = Color(0xFF2B3246);
  static const Color text = Color(0xFFE7EAF3);
  static const Color subtle = Color(0xFF98A3B8);
  static const Color accent = Color(0xFF4DA3FF);
  static const Color progressBg = Color(0xFF27334A);
  static const Color gold = Color(0xFFF3C86A);

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        brightness: Brightness.dark,
      ).copyWith(
        primary: accent,
        secondary: gold,
        surface: card,
        onSurface: text,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        foregroundColor: text,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        labelStyle: const TextStyle(color: text),
        floatingLabelStyle: const TextStyle(color: text),
        hintStyle: const TextStyle(color: subtle),
      ),
    );
  }
}

