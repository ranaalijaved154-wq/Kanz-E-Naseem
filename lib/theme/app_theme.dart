import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Palette
  static const Color primaryEmerald = Color(0xFF0F5132);
  static const Color primaryDark = Color(0xFF072F1D);
  static const Color primaryLight = Color(0xFF1B7347);

  static const Color accentGold = Color(0xFFC59B27);
  static const Color accentGoldLight = Color(0xFFDFBA4E);
  static const Color accentGoldDark = Color(0xFF9E7A18);

  static const Color backgroundLight = Color(0xFFF9F9F6);
  static const Color surfaceWhite = Colors.white;

  static const Color textDark = Color(0xFF1A202C);
  static const Color textMuted = Color(0xFF718096);
  static const Color borderGrey = Color(0xFFE2E8F0);

  static const Color badgePendingBg = Color(0xFFFEF3C7);
  static const Color badgePendingText = Color(0xFF92400E);
  static const Color badgeApprovedBg = Color(0xFFD1FAE5);
  static const Color badgeApprovedText = Color(0xFF065F46);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryEmerald,
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryEmerald,
        primary: primaryEmerald,
        secondary: accentGold,
        surface: surfaceWhite,
      ),
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        displayLarge: GoogleFonts.amiri(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: primaryDark,
        ),
        displayMedium: GoogleFonts.amiri(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: primaryDark,
        ),
        headlineSmall: GoogleFonts.amiri(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: primaryEmerald,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        bodyLarge: GoogleFonts.outfit(
          fontSize: 16,
          color: textDark,
        ),
        bodyMedium: GoogleFonts.outfit(
          fontSize: 14,
          color: textMuted,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryEmerald,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.amiri(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: surfaceWhite,
        ),
        iconTheme: const IconThemeData(color: surfaceWhite),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderGrey, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderGrey, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: accentGold, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
        labelStyle: GoogleFonts.outfit(color: textMuted, fontSize: 14),
        hintStyle: GoogleFonts.outfit(color: textMuted.withOpacity(0.6), fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryEmerald,
          foregroundColor: surfaceWhite,
          elevation: 2,
          shadowColor: primaryEmerald.withOpacity(0.3),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryEmerald,
          side: const BorderSide(color: primaryEmerald, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardTheme(
        color: surfaceWhite,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }
}
