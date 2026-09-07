import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class YawColors {
  YawColors._();
  static const background = Color(0xFF0B0F14);
  static const surface = Color(0xFF121820);
  static const surface2 = Color(0xFF1A232F);
  static const surface3 = Color(0xFF243041);
  static const primary = Color(0xFF00E5FF);
  static const primaryDim = Color(0xFF00B8CC);
  static const secondary = Color(0xFF7C4DFF);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textMuted = Color(0xFF8B95A5);
  static const textDim = Color(0xFF5A6678);
  static const success = Color(0xFF00E676);
  static const warning = Color(0xFFFFB300);
  static const error = Color(0xFFFF5252);
  static const border = Color(0xFF1E2A3A);
  static const divider = Color(0xFF1E2A3A);
}

class YawTheme {
  YawTheme._();

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    final textTheme = GoogleFonts.spaceGroteskTextTheme(base.textTheme).copyWith(
      displayLarge: GoogleFonts.spaceGrotesk(
        fontSize: 48, fontWeight: FontWeight.w700, letterSpacing: -1.5, color: YawColors.textPrimary, height: 0.95),
      displayMedium: GoogleFonts.spaceGrotesk(
        fontSize: 36, fontWeight: FontWeight.w700, letterSpacing: -1, color: YawColors.textPrimary),
      headlineLarge: GoogleFonts.spaceGrotesk(
        fontSize: 28, fontWeight: FontWeight.w700, color: YawColors.textPrimary),
      headlineMedium: GoogleFonts.spaceGrotesk(
        fontSize: 22, fontWeight: FontWeight.w600, color: YawColors.textPrimary),
      titleLarge: GoogleFonts.spaceGrotesk(
        fontSize: 18, fontWeight: FontWeight.w600, color: YawColors.textPrimary),
      titleMedium: GoogleFonts.spaceGrotesk(
        fontSize: 15, fontWeight: FontWeight.w600, color: YawColors.textPrimary),
      bodyLarge: GoogleFonts.inter(
        fontSize: 15, fontWeight: FontWeight.w400, color: YawColors.textPrimary, height: 1.5),
      bodyMedium: GoogleFonts.inter(
        fontSize: 13, fontWeight: FontWeight.w400, color: YawColors.textMuted, height: 1.5),
      labelLarge: GoogleFonts.spaceGrotesk(
        fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.8, color: YawColors.textPrimary),
      labelSmall: GoogleFonts.inter(
        fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.6, color: YawColors.textMuted),
    );

    return base.copyWith(
      scaffoldBackgroundColor: YawColors.background,
      colorScheme: const ColorScheme.dark(
        primary: YawColors.primary,
        secondary: YawColors.secondary,
        surface: YawColors.surface,
        error: YawColors.error,
        onSurface: YawColors.textPrimary,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: YawColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: 2, color: YawColors.textPrimary),
        iconTheme: const IconThemeData(color: YawColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: YawColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: YawColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: YawColors.surface2,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: YawColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: YawColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: YawColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: YawColors.error),
        ),
        hintStyle: GoogleFonts.inter(fontSize: 13, color: YawColors.textDim),
        labelStyle: GoogleFonts.inter(fontSize: 13, color: YawColors.textMuted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: YawColors.primary,
          foregroundColor: YawColors.background,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 1),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: YawColors.textPrimary,
          side: const BorderSide(color: YawColors.border),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: YawColors.surface2,
        side: const BorderSide(color: YawColors.border),
        labelStyle: GoogleFonts.inter(fontSize: 12, color: YawColors.textMuted),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerTheme: const DividerThemeData(color: YawColors.divider, thickness: 1),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: YawColors.surface,
        selectedItemColor: YawColors.primary,
        unselectedItemColor: YawColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: YawColors.surface,
        indicatorColor: YawColors.primary.withValues(alpha: 0.15),
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
