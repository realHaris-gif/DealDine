import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Light Theme - Premium Minimal
  static const Color _lightPrimary = Color(0xFFFFFFFF);        // White
  static const Color _lightOnPrimary = Color(0xFF111111);      // Almost Black
  static const Color _lightSecondary = Color(0xFFF7F7F7);      // Very Light Gray
  static const Color _lightTertiary = Color(0xFF666666);       // Secondary Text
  static const Color _lightAccent = Color(0xFFD62828);         // Deep Red
  static const Color _lightSuccess = Color(0xFF22C55E);        // Green
  static const Color _lightError = Color(0xFFEF4444);          // Light Red

  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      colorScheme: const ColorScheme.light(
        primary: _lightAccent,
        onPrimary: _lightPrimary,
        primaryContainer: Color(0xFFFFEAEA),
        secondary: _lightSuccess,
        tertiary: _lightTertiary,
        error: _lightError,
        surface: _lightSecondary,
        background: _lightPrimary,
        outline: Color(0xFFE5E5E5),
      ),
      
      scaffoldBackgroundColor: _lightPrimary,
      
      textTheme: TextTheme(
        displayLarge: GoogleFonts.sansita(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: _lightOnPrimary,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.sansita(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: _lightOnPrimary,
          letterSpacing: -0.5,
        ),
        titleLarge: GoogleFonts.sansita(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: _lightOnPrimary,
          letterSpacing: -0.3,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: _lightOnPrimary,
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: _lightOnPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: _lightOnPrimary,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: _lightTertiary,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: _lightTertiary,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: _lightOnPrimary,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: _lightTertiary,
        ),
      ),
      
      appBarTheme: AppBarTheme(
        backgroundColor: _lightPrimary,
        foregroundColor: _lightOnPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.sansita(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: _lightOnPrimary,
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _lightAccent,
          foregroundColor: _lightPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _lightOnPrimary,
          side: const BorderSide(color: Color(0xFFE5E5E5), width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _lightAccent,
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      
      cardTheme: CardThemeData(
        color: _lightPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: EdgeInsets.zero,
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _lightSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _lightAccent, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: GoogleFonts.inter(color: _lightTertiary),
      ),
      
      sliderTheme: const SliderThemeData(
        activeTrackColor: _lightAccent,
        inactiveTrackColor: Color(0xFFE5E5E5),
        thumbColor: _lightAccent,
        trackHeight: 6,
      ),
      
      dividerTheme: const DividerThemeData(
        color: Color(0xFFF0F0F0),
        thickness: 1,
      ),
      
      chipTheme: ChipThemeData(
        backgroundColor: _lightSecondary,
        selectedColor: _lightAccent,
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: _lightOnPrimary,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static ThemeData darkTheme() {
    return lightTheme();
  }
}