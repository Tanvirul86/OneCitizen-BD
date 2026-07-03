import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Brand Colours ───────────────────────────────────────────────────────────
  static const Color primaryGreen = Color(0xFF006A4E);
  static const Color primaryGreenLight = Color(0xFF008C68);
  static const Color primaryGreenDark = Color(0xFF004D38);
  static const Color accentRed = Color(0xFFE8192C);
  static const Color accentRedLight = Color(0xFFFF4458);

  // ── Neutrals ────────────────────────────────────────────────────────────────
  static const Color surfaceLight = Color(0xFFF0F4F8);
  static const Color cardWhite = Colors.white;
  static const Color textPrimary = Color(0xFF0A1628);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color divider = Color(0xFFE2E8F0);
  static const Color inputBorder = Color(0xFFCBD5E1);

  // ── Status Colours ──────────────────────────────────────────────────────────
  static const Color successGreen = Color(0xFF16A34A);
  static const Color warningAmber = Color(0xFFD97706);
  static const Color errorRed = Color(0xFFDC2626);
  static const Color infoBlue = Color(0xFF2563EB);

  // ── Gradients ───────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryGreenDark, primaryGreen, primaryGreenLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF004D38), Color(0xFF006A4E), Color(0xFF007A5A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient redGradient = LinearGradient(
    colors: [accentRedLight, accentRed],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Shadows ─────────────────────────────────────────────────────────────────
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get elevatedShadow => [
        BoxShadow(
          color: primaryGreen.withValues(alpha: 0.2),
          blurRadius: 20,
          offset: const Offset(0, 8),
          spreadRadius: -2,
        ),
      ];

  // ── Theme ───────────────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    final base = GoogleFonts.plusJakartaSansTextTheme();

    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryGreen,
      primary: primaryGreen,
      secondary: accentRed,
      surface: surfaceLight,
      error: errorRed,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: surfaceLight,
      textTheme: base.copyWith(
        displayLarge: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: textPrimary),
        displayMedium: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: textPrimary),
        headlineLarge: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: textPrimary),
        headlineMedium: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: textPrimary),
        headlineSmall: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: textPrimary),
        titleLarge: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: textPrimary),
        titleMedium: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: textPrimary),
        titleSmall: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500, color: textPrimary),
        bodyLarge: GoogleFonts.plusJakartaSans(color: textPrimary),
        bodyMedium: GoogleFonts.plusJakartaSans(color: textSecondary),
        bodySmall: GoogleFonts.plusJakartaSans(color: textTertiary),
        labelLarge: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
        labelMedium: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500),
        labelSmall: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE8EDF4), width: 1),
        ),
        color: Colors.white,
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: errorRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: errorRed, width: 2),
        ),
        labelStyle: GoogleFonts.plusJakartaSans(color: textSecondary, fontSize: 14),
        hintStyle: GoogleFonts.plusJakartaSans(color: textTertiary, fontSize: 14),
        prefixIconColor: textSecondary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGreen,
          side: const BorderSide(color: primaryGreen, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryGreen,
          textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: primaryGreen,
        unselectedItemColor: textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        backgroundColor: Colors.white,
        selectedLabelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 10),
        unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontSize: 10),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: divider,
        space: 1,
        thickness: 1,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 12),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentTextStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: textPrimary,
        ),
      ),
    );
  }
}
