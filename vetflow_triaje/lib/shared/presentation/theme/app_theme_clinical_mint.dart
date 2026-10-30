/// Tema visual basado en "Clinical Mint" (stitch_dogo_veterinary_triage_app).
library;

import 'package:flutter/material.dart';

class ClinicalMintColors {
  // Surfaces
  static const Color surface = Color(0xFFF8F9FF);
  static const Color surfaceDim = Color(0xFFCBDBF5);
  static const Color surfaceBright = Color(0xFFF8F9FF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFEFF4FF);
  static const Color surfaceContainer = Color(0xFFE5EEFF);
  static const Color surfaceContainerHigh = Color(0xFFDCE9FF);
  static const Color surfaceContainerHighest = Color(0xFFD3E4FE);
  static const Color surfaceVariant = Color(0xFFD3E4FE);

  // Text/Content
  static const Color onSurface = Color(0xFF0B1C30);
  static const Color onSurfaceVariant = Color(0xFF3C4A43);
  static const Color inverseSurface = Color(0xFF213145);
  static const Color inverseOnSurface = Color(0xFFEAF1FF);

  // Outlines
  static const Color outline = Color(0xFF6C7A73);
  static const Color outlineVariant = Color(0xFFBBCAC1);

  // Primary
  static const Color primary = Color(0xFF006C4F);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF32C798);
  static const Color onPrimaryContainer = Color(0xFF004E38);
  static const Color primaryFixed = Color(0xFF71FAC8);
  static const Color primaryFixedDim = Color(0xFF50DDAD);
  static const Color inversePrimary = Color(0xFF50DDAD);

  // Secondary
  static const Color secondary = Color(0xFF545F73);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFD5E0F8);
  static const Color onSecondaryContainer = Color(0xFF586377);
  static const Color secondaryFixed = Color(0xFFD8E3FB);
  static const Color secondaryFixedDim = Color(0xFFBCC7DE);

  // Tertiary/Emergency
  static const Color tertiary = Color(0xFFB91A24);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFFF928B);
  static const Color onTertiaryContainer = Color(0xFF8D0012);
  static const Color tertiaryFixed = Color(0xFFFFDAD7);
  static const Color tertiaryFixedDim = Color(0xFFFFB3AD);

  // Error
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  // Background
  static const Color background = Color(0xFFF8F9FF);
  static const Color onBackground = Color(0xFF0B1C30);
}

ThemeData get clinicalMintTheme {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: ClinicalMintColors.surface,
    colorScheme: const ColorScheme.light(
      primary: ClinicalMintColors.primaryContainer,
      onPrimary: ClinicalMintColors.onPrimary,
      primaryContainer: ClinicalMintColors.primaryContainer,
      onPrimaryContainer: ClinicalMintColors.onPrimaryContainer,
      secondary: ClinicalMintColors.secondary,
      onSecondary: ClinicalMintColors.onSecondary,
      secondaryContainer: ClinicalMintColors.secondaryContainer,
      onSecondaryContainer: ClinicalMintColors.onSecondaryContainer,
      tertiary: ClinicalMintColors.tertiary,
      onTertiary: ClinicalMintColors.onTertiary,
      error: ClinicalMintColors.error,
      onError: ClinicalMintColors.onError,
      surface: ClinicalMintColors.surface,
      onSurface: ClinicalMintColors.onSurface,
      surfaceContainerLowest: ClinicalMintColors.surfaceContainerLowest,
      surfaceContainerLow: ClinicalMintColors.surfaceContainerLow,
      surfaceContainer: ClinicalMintColors.surfaceContainer,
      surfaceContainerHigh: ClinicalMintColors.surfaceContainerHigh,
      surfaceContainerHighest: ClinicalMintColors.surfaceContainerHighest,
      outline: ClinicalMintColors.outline,
      outlineVariant: ClinicalMintColors.outlineVariant,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: ClinicalMintColors.surface,
      foregroundColor: ClinicalMintColors.onSurface,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ClinicalMintColors.primary,
        foregroundColor: ClinicalMintColors.onPrimary,
        elevation: 0,
        minimumSize: const Size(64, 48),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: ClinicalMintColors.primary,
        foregroundColor: ClinicalMintColors.onPrimary,
        elevation: 0,
        minimumSize: const Size(64, 48),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: ClinicalMintColors.primary,
        minimumSize: const Size(64, 48),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        side: const BorderSide(color: ClinicalMintColors.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontFamily: 'Inter',
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.25,
        letterSpacing: -0.02,
        color: ClinicalMintColors.onSurface,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Inter',
        fontSize: 26,
        fontWeight: FontWeight.w700,
        height: 1.31,
        letterSpacing: -0.015,
        color: ClinicalMintColors.onSurface,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'Inter',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.4,
        letterSpacing: -0.01,
        color: ClinicalMintColors.onSurface,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Inter',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.33,
        color: ClinicalMintColors.onSurface,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Inter',
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: ClinicalMintColors.onSurface,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.43,
        color: ClinicalMintColors.onSurfaceVariant,
      ),
      bodySmall: TextStyle(
        fontFamily: 'Inter',
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.38,
        color: ClinicalMintColors.onSurfaceVariant,
      ),
      labelLarge: TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.43,
        letterSpacing: 0.01,
        color: ClinicalMintColors.onSurface,
      ),
      labelMedium: TextStyle(
        fontFamily: 'Inter',
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.33,
        letterSpacing: 0.02,
        color: ClinicalMintColors.onSurface,
      ),
      labelSmall: TextStyle(
        fontFamily: 'Inter',
        fontSize: 11,
        fontWeight: FontWeight.w700,
        height: 1.27,
        letterSpacing: 0.04,
        color: ClinicalMintColors.onSurfaceVariant,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF4F9F6),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        borderSide: BorderSide(
          color: ClinicalMintColors.primaryContainer,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: ClinicalMintColors.error,
          width: 1,
        ),
      ),
    ),
  );
}
