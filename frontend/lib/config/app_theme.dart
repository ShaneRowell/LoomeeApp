import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color fontColor = Color(0xFF1C2B39);
  static const Color backgroundColor = Color(0xFFF5F0E8);
  static const Color widgetColor = Color(0xFF2C2C2C);
  static const Color accentColor = Color(0xFFB76E79);
  static const Color white = Colors.white;
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color successColor = Color(0xFF388E3C);
  static const Color warningColor = Color(0xFFF57C00);

  // Extended palette
  static const Color deepNavy = Color(0xFF1A2338);
  static const Color charcoal = Color(0xFF121212);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.light(
        primary: widgetColor,
        secondary: accentColor,
        surface: white,
        error: errorColor,
        onPrimary: white,
        onSecondary: white,
        onSurface: fontColor,
        onError: white,
      ),
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: GoogleFonts.poppins(color: fontColor, letterSpacing: -0.5),
        displayMedium: GoogleFonts.poppins(color: fontColor, letterSpacing: -0.3),
        displaySmall: GoogleFonts.poppins(color: fontColor, letterSpacing: -0.2),
        headlineLarge: GoogleFonts.poppins(color: fontColor, fontWeight: FontWeight.w700, letterSpacing: -0.5),
        headlineMedium: GoogleFonts.poppins(color: fontColor, fontWeight: FontWeight.w700, letterSpacing: -0.3),
        headlineSmall: GoogleFonts.poppins(color: fontColor, fontWeight: FontWeight.w600, letterSpacing: -0.2),
        titleLarge: GoogleFonts.poppins(color: fontColor, fontWeight: FontWeight.w600, letterSpacing: 0.1),
        titleMedium: GoogleFonts.poppins(color: fontColor, fontWeight: FontWeight.w500, letterSpacing: 0.1),
        titleSmall: GoogleFonts.poppins(color: fontColor, fontWeight: FontWeight.w500, letterSpacing: 0.15),
        bodyLarge: GoogleFonts.inter(color: fontColor, letterSpacing: 0.1),
        bodyMedium: GoogleFonts.inter(color: fontColor, letterSpacing: 0.1),
        bodySmall: GoogleFonts.inter(color: fontColor, fontWeight: FontWeight.w300, letterSpacing: 0.2),
        labelLarge: GoogleFonts.inter(color: fontColor, fontWeight: FontWeight.w500, letterSpacing: 0.3),
        labelMedium: GoogleFonts.inter(color: fontColor, letterSpacing: 0.2),
        labelSmall: GoogleFonts.inter(color: fontColor, fontWeight: FontWeight.w300, letterSpacing: 0.4),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: fontColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          color: fontColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: white,
        elevation: 2,
        shadowColor: fontColor.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: widgetColor,
          foregroundColor: white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: widgetColor,
          side: const BorderSide(color: widgetColor),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentColor,
          textStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: fontColor.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: fontColor.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: widgetColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor),
        ),
        hintStyle: GoogleFonts.inter(color: fontColor.withValues(alpha: 0.4)),
        labelStyle: GoogleFonts.inter(color: fontColor.withValues(alpha: 0.6)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: white,
        selectedItemColor: widgetColor,
        unselectedItemColor: fontColor.withValues(alpha: 0.4),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: widgetColor,
        foregroundColor: white,
        elevation: 4,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: backgroundColor,
        selectedColor: widgetColor,
        labelStyle: GoogleFonts.inter(fontSize: 13, color: fontColor),
        secondaryLabelStyle: GoogleFonts.inter(fontSize: 13, color: white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide(color: fontColor.withValues(alpha: 0.15)),
      ),
      dividerTheme: DividerThemeData(
        color: fontColor.withValues(alpha: 0.1),
        thickness: 1,
      ),
    );
  }
}
