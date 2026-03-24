import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF6200EE);
  static const Color secondaryColor = Color(0xFF7C3AED);
  static const Color errorColor = Color(0xFFFF5252);

  // Light Colors
  static const Color lightBackgroundColor = Color(0xFFF7F7FB);
  static const Color lightSurfaceColor = Colors.white;
  static const Color lightOnBackgroundColor = Color(0xFF1A1A2E);

  // Dark Colors
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkSurfaceColor = Color(0xFF1E1E1E);
  static const Color darkOnBackgroundColor = Colors.white;

  // TextTheme Builder
  static TextTheme _buildTextTheme(Color textColor) {
    return GoogleFonts.poppinsTextTheme().copyWith(
      displayLarge: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w800, color: textColor),
      titleLarge: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800, color: textColor, letterSpacing: -0.5),
      titleMedium: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: textColor),
      bodyLarge: GoogleFonts.poppins(fontSize: 16, color: textColor),
      bodyMedium: GoogleFonts.poppins(fontSize: 14, color: textColor),
      bodySmall: GoogleFonts.poppins(fontSize: 12, color: textColor),
      labelMedium: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: primaryColor), // Used for buttons/nav
      labelLarge: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: textColor),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.light,
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: lightBackgroundColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: lightOnBackgroundColor,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: lightBackgroundColor,
      textTheme: _buildTextTheme(lightOnBackgroundColor),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: lightSurfaceColor,
        foregroundColor: lightOnBackgroundColor,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.dark,
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: darkBackgroundColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: darkOnBackgroundColor,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: darkBackgroundColor,
      textTheme: _buildTextTheme(darkOnBackgroundColor),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: darkSurfaceColor,
        foregroundColor: darkOnBackgroundColor,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        hintStyle: TextStyle(color: Colors.grey.shade600),
      ),
    );
  }
}
