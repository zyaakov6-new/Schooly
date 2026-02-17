import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Light theme
  static const Color lightBg = Color(0xFFFAFBFD);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF3F4F8);
  static const Color lightBorder = Color(0xFFE5E7EB);
  static const Color lightText = Color(0xFF0D1117);
  static const Color lightTextSecondary = Color(0xFF6B7280);

  // Dark theme
  static const Color darkBg = Color(0xFF0D1117);
  static const Color darkSurface = Color(0xFF161B22);
  static const Color darkCard = Color(0xFF1C2128);
  static const Color darkBorder = Color(0xFF30363D);
  static const Color darkText = Color(0xFFF0F6FC);
  static const Color darkTextSecondary = Color(0xFF8B949E);

  // Accent
  static const Color accent = Color(0xFF1976D2);
  static const Color accentLight = Color(0xFF1E88E5);
  static const Color accentGlow = Color(0x331976D2);

  // Status
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Glass
  static const Color glassDark = Color(0x1AFFFFFF);
  static const Color glassLight = Color(0x80FFFFFF);
  static const Color glassBorderDark = Color(0x33FFFFFF);
  static const Color glassBorderLight = Color(0x99FFFFFF);

  // Child Colors
  static const List<Color> childColors = [
    Color(0xFF1976D2),
    Color(0xFFE91E63),
    Color(0xFF4CAF50),
    Color(0xFFFF9800),
    Color(0xFF9C27B0),
    Color(0xFF00BCD4),
  ];
}

class AppTheme {
  static ThemeData light() {
    const colors = ColorScheme.light(
      primary: AppColors.accent,
      secondary: AppColors.accentLight,
      surface: AppColors.lightSurface,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.lightText,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colors,
      scaffoldBackgroundColor: AppColors.lightBg,
      textTheme: _buildTextTheme(AppColors.lightText),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.lightText),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.lightText,
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accent, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: GoogleFonts.inter(color: AppColors.lightTextSecondary),
        hintStyle: GoogleFonts.inter(color: AppColors.lightTextSecondary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.lightTextSecondary,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  static ThemeData dark() {
    const colors = ColorScheme.dark(
      primary: AppColors.accentLight,
      secondary: AppColors.accent,
      surface: AppColors.darkSurface,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.darkText,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colors,
      scaffoldBackgroundColor: AppColors.darkBg,
      textTheme: _buildTextTheme(AppColors.darkText),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.darkText),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.darkText,
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentLight,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accentLight, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: GoogleFonts.inter(color: AppColors.darkTextSecondary),
        hintStyle: GoogleFonts.inter(color: AppColors.darkTextSecondary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.accentLight,
        unselectedItemColor: AppColors.darkTextSecondary,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  static TextTheme _buildTextTheme(Color textColor) => TextTheme(
        displayLarge: GoogleFonts.inter(
            fontSize: 57, fontWeight: FontWeight.w700, color: textColor),
        displayMedium: GoogleFonts.inter(
            fontSize: 45, fontWeight: FontWeight.w700, color: textColor),
        displaySmall: GoogleFonts.inter(
            fontSize: 36, fontWeight: FontWeight.w700, color: textColor),
        headlineLarge: GoogleFonts.inter(
            fontSize: 32, fontWeight: FontWeight.w700, color: textColor),
        headlineMedium: GoogleFonts.inter(
            fontSize: 24, fontWeight: FontWeight.w600, color: textColor),
        headlineSmall: GoogleFonts.inter(
            fontSize: 20, fontWeight: FontWeight.w600, color: textColor),
        titleLarge: GoogleFonts.inter(
            fontSize: 18, fontWeight: FontWeight.w600, color: textColor),
        titleMedium: GoogleFonts.inter(
            fontSize: 16, fontWeight: FontWeight.w500, color: textColor),
        titleSmall: GoogleFonts.inter(
            fontSize: 14, fontWeight: FontWeight.w500, color: textColor),
        bodyLarge: GoogleFonts.inter(
            fontSize: 16, fontWeight: FontWeight.w400, color: textColor),
        bodyMedium: GoogleFonts.inter(
            fontSize: 14, fontWeight: FontWeight.w400, color: textColor),
        bodySmall: GoogleFonts.inter(
            fontSize: 12, fontWeight: FontWeight.w400, color: textColor),
        labelLarge: GoogleFonts.inter(
            fontSize: 14, fontWeight: FontWeight.w500, color: textColor),
        labelMedium: GoogleFonts.inter(
            fontSize: 12, fontWeight: FontWeight.w500, color: textColor),
        labelSmall: GoogleFonts.inter(
            fontSize: 11, fontWeight: FontWeight.w400, color: textColor),
      );
}

extension ColorExtension on Color {
  Color withOpacityValue(double opacity) => withOpacity(opacity);
}
