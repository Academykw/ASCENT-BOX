import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryGold = Color(0xFFE8B86D);
  static const Color accentCoral = Color(0xFFFF6B6B);
  static const Color accentMint = Color(0xFF4ECDC4);
  static const Color accentPurple = Color(0xFF9B59B6);
  static const Color darkBg = Color(0xFF0D1117);
  static const Color darkSurface = Color(0xFF161B22);
  static const Color darkCard = Color(0xFF21262D);
  static const Color lightBg = Color(0xFFFFF8F0);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF5F0E8);

  static ThemeData light() => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: lightBg,
        primaryColor: primaryGold,
        colorScheme: const ColorScheme.light(
          primary: primaryGold,
          secondary: accentCoral,
          tertiary: accentMint,
          background: lightBg,
          surface: lightSurface,
        ),
        textTheme: GoogleFonts.playfairDisplayTextTheme().copyWith(
          bodyLarge: GoogleFonts.lato(color: const Color(0xFF2C2C2C)),
          bodyMedium: GoogleFonts.lato(color: const Color(0xFF4A4A4A)),
          bodySmall: GoogleFonts.lato(color: const Color(0xFF6A6A6A)),
        ),
        cardTheme: CardThemeData(
          color: lightCard,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        useMaterial3: true,
      );

  static ThemeData dark() => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: darkBg,
        primaryColor: primaryGold,
        colorScheme: const ColorScheme.dark(
          primary: primaryGold,
          secondary: accentCoral,
          tertiary: accentMint,
          background: darkBg,
          surface: darkSurface,
        ),
        textTheme: GoogleFonts.playfairDisplayTextTheme(ThemeData.dark().textTheme).copyWith(
          bodyLarge: GoogleFonts.lato(color: const Color(0xFFE8E8E8)),
          bodyMedium: GoogleFonts.lato(color: const Color(0xFFB8B8B8)),
          bodySmall: GoogleFonts.lato(color: const Color(0xFF888888)),
        ),
        cardTheme: CardThemeData(
          color: darkCard,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        useMaterial3: true,
      );
}
