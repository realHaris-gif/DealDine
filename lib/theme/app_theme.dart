import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// AppTheme provides centralized theme configuration for the DealDine app.
/// 
/// It implements Material 3 design guidelines with custom colors,
/// typography, and component styles. Both light and dark themes are provided.
class AppTheme {
  // ============================================
  // Color Palette
  // ============================================
  
  // Light Theme Colors
  static const Color _lightPrimary = Color(0xFF6366F1);      // Indigo
  static const Color _lightOnPrimary = Color(0xFFFFFFFF);    // White
  static const Color _lightPrimaryContainer = Color(0xFFE0E7FF); // Light Indigo
  
  static const Color _lightSecondary = Color(0xFF10B981);    // Emerald
  static const Color _lightTertiary = Color(0xFFF59E0B);     // Amber
  static const Color _lightError = Color(0xFFEF4444);        // Red
  
  static const Color _lightSurface = Color(0xFFFAFAFA);
  static const Color _lightBackground = Color(0xFFFFFFFF);
  static const Color _lightOutline = Color(0xFFE5E7EB);

  // Dark Theme Colors
  static const Color _darkPrimary = Color(0xFF818CF8);       // Light Indigo
  static const Color _darkOnPrimary = Color(0xFF1E1B4B);     // Very Dark
  static const Color _darkPrimaryContainer = Color(0xFF3730A3); // Dark Indigo
  
  static const Color _darkSecondary = Color(0xFF6EE7B7);     // Light Emerald
  static const Color _darkTertiary = Color(0xFFFCD34D);      // Light Amber
  static const Color _darkError = Color(0xFFFCA5A5);         // Light Red
  
  static const Color _darkSurface = Color(0xFF111827);
  static const Color _darkBackground = Color(0xFF0F172A);
  static const Color _darkOutline = Color(0xFF374151);

  // ============================================
  // Light Theme
  // ============================================
  
  /// Creates and returns the light theme configuration.
  /// 
  /// This uses Material 3 design specifications with custom
  /// colors, typography, and component styles optimized for
  /// readability and modern aesthetics.
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // ============ Color Scheme ============
      colorScheme: const ColorScheme.light(
        primary: _lightPrimary,
        onPrimary: _lightOnPrimary,
        primaryContainer: _lightPrimaryContainer,
        secondary: _lightSecondary,
        tertiary: _lightTertiary,
        error: _lightError,
        surface: _lightSurface,
        background: _lightBackground,
        outline: _lightOutline,
      ),
      
      // ============ Typography ============
      textTheme: TextTheme(
        displayLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1F2937),
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1F2937),
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1F2937),
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF374151),
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF374151),
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF6B7280),
        ),
        labelMedium: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF9CA3AF),
        ),
      ),
      
      // ============ App Bar ============
      appBarTheme: AppBarTheme(
        backgroundColor: _lightBackground,
        foregroundColor: _lightPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: _lightPrimary,
        ),
      ),
      
      // ============ Buttons ============
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _lightPrimary,
          foregroundColor: _lightOnPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _lightPrimary,
          side: const BorderSide(color: _lightPrimary, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      
      // ============ Cards ============
      cardTheme: CardThemeData(
        color: _lightBackground,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      
      // ============ Input Fields ============
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _lightOutline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _lightOutline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _lightPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _lightError),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      
      // ============ Slider ============
      sliderTheme: const SliderThemeData(
        activeTrackColor: _lightPrimary,
        inactiveTrackColor: _lightOutline,
        thumbColor: _lightPrimary,
        trackHeight: 8,
      ),
      
      // ============ Dropdown ============
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _lightSurface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _lightOutline),
          ),
        ),
      ),
    );
  }

  // ============================================
  // Dark Theme
  // ============================================
  
  /// Creates and returns the dark theme configuration.
  /// 
  /// This uses Material 3 design specifications optimized for
  /// reduced eye strain in low-light environments with carefully
  /// chosen contrast ratios.
  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // ============ Color Scheme ============
      colorScheme: const ColorScheme.dark(
        primary: _darkPrimary,
        onPrimary: _darkOnPrimary,
        primaryContainer: _darkPrimaryContainer,
        secondary: _darkSecondary,
        tertiary: _darkTertiary,
        error: _darkError,
        surface: _darkSurface,
        background: _darkBackground,
        outline: _darkOutline,
      ),
      
      // ============ Typography ============
      textTheme: TextTheme(
        displayLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFF3F4F6),
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFF3F4F6),
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFE5E7EB),
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFD1D5DB),
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: const Color(0xFFD1D5DB),
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF9CA3AF),
        ),
        labelMedium: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF6B7280),
        ),
      ),
      
      // ============ App Bar ============
      appBarTheme: AppBarTheme(
        backgroundColor: _darkBackground,
        foregroundColor: _darkPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: _darkPrimary,
        ),
      ),
      
      // ============ Buttons ============
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _darkPrimary,
          foregroundColor: _darkOnPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _darkPrimary,
          side: const BorderSide(color: _darkPrimary, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      
      // ============ Cards ============
      cardTheme: CardThemeData(
        color: _darkSurface,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      
      // ============ Input Fields ============
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _darkOutline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _darkOutline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _darkPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _darkError),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      
      // ============ Slider ============
      sliderTheme: const SliderThemeData(
        activeTrackColor: _darkPrimary,
        inactiveTrackColor: _darkOutline,
        thumbColor: _darkPrimary,
        trackHeight: 8,
      ),
      
      // ============ Dropdown ============
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _darkSurface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _darkOutline),
          ),
        ),
      ),
    );
  }
}