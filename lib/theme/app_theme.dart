
import 'package:flutter/material.dart';

class AppTheme {
  // Warna utama Daymark
  static const Color primaryColor = Color(0xFF8B7BE8);
  static const Color secondaryColor = Color(0xFFE9E5FF);

  // Warna Light Mode
  static const Color lightBackground = Color(0xFFF8F8FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF29283A);
  static const Color lightSecondaryText = Color(0xFF85849A);

  // Warna Dark Mode
  static const Color darkBackground = Color(0xFF171624);
  static const Color darkSurface = Color(0xFF232235);
  static const Color darkText = Color(0xFFF4F2FF);
  static const Color darkSecondaryText = Color(0xFFAAA8BD);

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Roboto',
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,

      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: lightSurface,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: lightBackground,
        foregroundColor: lightText,
        elevation: 0,
        centerTitle: false,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE8E7F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE8E7F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: primaryColor,
            width: 1.5,
          ),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Roboto',
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,

      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        primary: const Color(0xFFAA9EFF),
        secondary: const Color(0xFF655A9E),
        surface: darkSurface,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        foregroundColor: darkText,
        elevation: 0,
        centerTitle: false,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF3A394D)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF3A394D)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFAA9EFF),
            width: 1.5,
          ),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFAA9EFF),
          foregroundColor: const Color(0xFF171624),
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
