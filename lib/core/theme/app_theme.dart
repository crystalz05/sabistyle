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

  // Dark Colors (Premium Deep Purple Theme)
  static const Color darkBackgroundColor = Color(0xFF0F071D); // Deep luxurious purple background
  static const Color darkSurfaceColor = Color(0xFF1C1233); // Elevated premium purple surface
  static const Color darkAccentColor = Color(0xFFD4AF37); // Premium Metallic Gold accent
  static const Color darkOnBackgroundColor = Color(0xFFF4EDFF); // Crisp purple-tinted white text
  static const Color darkOnSurfaceVariant = Color(0xFFB1A1CE); // Soft lilac for secondary text

  // TextTheme Builder
  static TextTheme _buildTextTheme(Color textColor, {Color? secondaryTextColor, required Color primaryElementColor}) {
    final secondary = secondaryTextColor ?? textColor.withValues(alpha: 0.7);
    return GoogleFonts.poppinsTextTheme().copyWith(
      displayLarge: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w800, color: textColor),
      headlineMedium: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w800, color: textColor),
      titleLarge: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800, color: textColor, letterSpacing: -0.5),
      titleMedium: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: textColor),
      titleSmall: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: textColor),
      bodyLarge: GoogleFonts.poppins(fontSize: 16, color: textColor),
      bodyMedium: GoogleFonts.poppins(fontSize: 14, color: secondary),
      bodySmall: GoogleFonts.poppins(fontSize: 12, color: secondary),
      labelMedium: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: primaryElementColor), // Used for buttons/nav
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
      textTheme: _buildTextTheme(
        lightOnBackgroundColor, 
        secondaryTextColor: const Color(0xFF555555),
        primaryElementColor: primaryColor,
      ),
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
        seedColor: secondaryColor,
        primary: darkAccentColor, // Gold accents for buttons and highlights
        secondary: secondaryColor,
        surface: darkBackgroundColor,
        surfaceContainerHighest: darkSurfaceColor, // Distinct surface color for cards
        error: errorColor,
        onPrimary: const Color(0xFF0F071D), // Dark purple text on gold buttons
        onSecondary: Colors.white,
        onSurface: darkOnBackgroundColor,
        onSurfaceVariant: darkOnSurfaceVariant,
        onError: Colors.white,
        outlineVariant: const Color(0xFF382A54), // Subtle borders matching the purple
      ),
      scaffoldBackgroundColor: darkBackgroundColor,
      textTheme: _buildTextTheme(
        darkOnBackgroundColor, 
        secondaryTextColor: darkOnSurfaceVariant,
        primaryElementColor: darkAccentColor,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: darkBackgroundColor,
        foregroundColor: darkOnBackgroundColor,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkAccentColor,
          foregroundColor: const Color(0xFF0F071D),
          minimumSize: const Size(double.infinity, 50),
          elevation: 4,
          shadowColor: darkAccentColor.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold),
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
          borderSide: const BorderSide(color: darkAccentColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        hintStyle: const TextStyle(color: darkOnSurfaceVariant),
      ),
    );
  }
}
