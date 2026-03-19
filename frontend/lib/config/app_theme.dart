import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Light palette ──────────────────────────────────────────────────────
  static const Color fontColor = Color(0xFF1C2B39);
  static const Color backgroundColor = Color(0xFFF5F0E8);
  static const Color widgetColor = Color(0xFF2C2C2C);
  static const Color accentColor = Color(0xFF1C2B39);
  static const Color white = Colors.white;
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color successColor = Color(0xFF388E3C);
  static const Color warningColor = Color(0xFFF57C00);

  // ── Dark palette ───────────────────────────────────────────────────────
  // Scaffold: deep dark navy — mirrors the inverted cream of the light theme
  static const Color darkBackgroundColor = Color(0xFF0F1720);
  // Cards / containers: clearly lifted above the scaffold
  static const Color darkSurfaceColor = Color(0xFF1E2B3F);
  // Primary text on dark: exact cream — matches the light-mode scaffold colour
  static const Color darkFontColor = Color(0xFFF5F0E8);
  // Interactive accent on dark: a readable steel-blue
  static const Color darkAccentColor = Color(0xFF5B8BB5);

  // ── Light theme ────────────────────────────────────────────────────────
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
      textTheme: GoogleFonts.playfairDisplayTextTheme().copyWith(
        displayLarge: GoogleFonts.playfairDisplay(color: fontColor),
        displayMedium: GoogleFonts.playfairDisplay(color: fontColor),
        displaySmall: GoogleFonts.playfairDisplay(color: fontColor),
        headlineLarge: GoogleFonts.playfairDisplay(color: fontColor, fontWeight: FontWeight.w600),
        headlineMedium: GoogleFonts.playfairDisplay(color: fontColor, fontWeight: FontWeight.w600),
        headlineSmall: GoogleFonts.playfairDisplay(color: fontColor, fontWeight: FontWeight.w600),
        titleLarge: GoogleFonts.playfairDisplay(color: fontColor, fontWeight: FontWeight.w600),
        titleMedium: GoogleFonts.playfairDisplay(color: fontColor, fontWeight: FontWeight.w500),
        titleSmall: GoogleFonts.playfairDisplay(color: fontColor, fontWeight: FontWeight.w500),
        bodyLarge: GoogleFonts.playfairDisplay(color: fontColor),
        bodyMedium: GoogleFonts.playfairDisplay(color: fontColor),
        bodySmall: GoogleFonts.playfairDisplay(color: fontColor),
        labelLarge: GoogleFonts.playfairDisplay(color: fontColor, fontWeight: FontWeight.w500),
        labelMedium: GoogleFonts.playfairDisplay(color: fontColor),
        labelSmall: GoogleFonts.playfairDisplay(color: fontColor),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: fontColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.playfairDisplay(
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
          backgroundColor: accentColor,
          foregroundColor: white,
          elevation: 0,
          shadowColor: accentColor.withValues(alpha: 0.35),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            // Glass edge: thin white border catches light on the dark button
            side: BorderSide(color: white.withValues(alpha: 0.22), width: 0.8),
          ),
          textStyle: GoogleFonts.playfairDisplay(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accentColor,
          side: BorderSide(color: accentColor.withValues(alpha: 0.55), width: 1.2),
          backgroundColor: white.withValues(alpha: 0.55),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.playfairDisplay(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentColor,
          textStyle: GoogleFonts.playfairDisplay(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        // Glass fill: translucent white over the cream scaffold
        fillColor: white.withValues(alpha: 0.72),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: white.withValues(alpha: 0.70), width: 0.8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: white.withValues(alpha: 0.70), width: 0.8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: widgetColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: errorColor),
        ),
        hintStyle: GoogleFonts.playfairDisplay(color: fontColor.withValues(alpha: 0.4)),
        labelStyle: GoogleFonts.playfairDisplay(color: fontColor.withValues(alpha: 0.6)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: white,
        selectedItemColor: widgetColor,
        unselectedItemColor: fontColor.withValues(alpha: 0.4),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: GoogleFonts.playfairDisplay(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.playfairDisplay(fontSize: 12),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: widgetColor,
        foregroundColor: white,
        elevation: 4,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: white.withValues(alpha: 0.72),
        selectedColor: widgetColor,
        labelStyle: GoogleFonts.playfairDisplay(fontSize: 13, color: fontColor),
        secondaryLabelStyle: GoogleFonts.playfairDisplay(fontSize: 13, color: white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide(color: white.withValues(alpha: 0.75), width: 0.8),
      ),
      dividerTheme: DividerThemeData(
        color: fontColor.withValues(alpha: 0.1),
        thickness: 1,
      ),
    );
  }

  // ── Dark theme ─────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackgroundColor,
      colorScheme: ColorScheme.dark(
        primary: darkAccentColor,
        secondary: darkAccentColor,
        surface: darkSurfaceColor,
        error: errorColor,
        onPrimary: white,
        onSecondary: white,
        onSurface: darkFontColor,
        onError: white,
      ),
      textTheme: GoogleFonts.playfairDisplayTextTheme().copyWith(
        displayLarge: GoogleFonts.playfairDisplay(color: darkFontColor),
        displayMedium: GoogleFonts.playfairDisplay(color: darkFontColor),
        displaySmall: GoogleFonts.playfairDisplay(color: darkFontColor),
        headlineLarge: GoogleFonts.playfairDisplay(color: darkFontColor, fontWeight: FontWeight.w600),
        headlineMedium: GoogleFonts.playfairDisplay(color: darkFontColor, fontWeight: FontWeight.w600),
        headlineSmall: GoogleFonts.playfairDisplay(color: darkFontColor, fontWeight: FontWeight.w600),
        titleLarge: GoogleFonts.playfairDisplay(color: darkFontColor, fontWeight: FontWeight.w600),
        titleMedium: GoogleFonts.playfairDisplay(color: darkFontColor, fontWeight: FontWeight.w500),
        titleSmall: GoogleFonts.playfairDisplay(color: darkFontColor, fontWeight: FontWeight.w500),
        bodyLarge: GoogleFonts.playfairDisplay(color: darkFontColor),
        bodyMedium: GoogleFonts.playfairDisplay(color: darkFontColor),
        bodySmall: GoogleFonts.playfairDisplay(color: darkFontColor),
        labelLarge: GoogleFonts.playfairDisplay(color: darkFontColor, fontWeight: FontWeight.w500),
        labelMedium: GoogleFonts.playfairDisplay(color: darkFontColor),
        labelSmall: GoogleFonts.playfairDisplay(color: darkFontColor),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkBackgroundColor,
        foregroundColor: darkFontColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.playfairDisplay(
          color: darkFontColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkSurfaceColor,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkAccentColor,
          foregroundColor: white,
          elevation: 0,
          shadowColor: darkAccentColor.withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: white.withValues(alpha: 0.25), width: 0.8),
          ),
          textStyle: GoogleFonts.playfairDisplay(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkAccentColor,
          side: BorderSide(color: white.withValues(alpha: 0.25), width: 0.8),
          backgroundColor: white.withValues(alpha: 0.08),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.playfairDisplay(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: darkAccentColor,
          textStyle: GoogleFonts.playfairDisplay(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white.withValues(alpha: 0.08),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: white.withValues(alpha: 0.18), width: 0.8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: white.withValues(alpha: 0.18), width: 0.8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: darkAccentColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: errorColor),
        ),
        hintStyle: GoogleFonts.playfairDisplay(color: darkFontColor.withValues(alpha: 0.4)),
        labelStyle: GoogleFonts.playfairDisplay(color: darkFontColor.withValues(alpha: 0.6)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkSurfaceColor,
        selectedItemColor: darkAccentColor,
        unselectedItemColor: darkFontColor.withValues(alpha: 0.4),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: GoogleFonts.playfairDisplay(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.playfairDisplay(fontSize: 12),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: darkAccentColor,
        foregroundColor: white,
        elevation: 4,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: white.withValues(alpha: 0.10),
        selectedColor: darkAccentColor,
        labelStyle: GoogleFonts.playfairDisplay(fontSize: 13, color: darkFontColor),
        secondaryLabelStyle: GoogleFonts.playfairDisplay(fontSize: 13, color: white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide(color: white.withValues(alpha: 0.22), width: 0.8),
      ),
      dividerTheme: DividerThemeData(
        color: darkFontColor.withValues(alpha: 0.1),
        thickness: 1,
      ),
    );
  }
}
