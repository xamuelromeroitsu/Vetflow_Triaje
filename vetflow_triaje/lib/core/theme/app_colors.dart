import 'package:flutter/material.dart';

/// Paleta "Clinical Mint" extraída del design system de DOGO.
abstract final class AppColors {
  // Surfaces
  static const surface = Color(0xFFF8F9FF);
  static const surfaceDim = Color(0xFFCBDBF5);
  static const surfaceBright = Color(0xFFF8F9FF);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFEFF4FF);
  static const surfaceContainer = Color(0xFFE5EEFF);
  static const surfaceContainerHigh = Color(0xFFDCE9FF);
  static const surfaceContainerHighest = Color(0xFFD3E4FE);
  static const surfaceVariant = Color(0xFFD3E4FE);

  // On surfaces
  static const onSurface = Color(0xFF0B1C30);
  static const onSurfaceVariant = Color(0xFF3C4A43);
  static const inverseSurface = Color(0xFF213145);
  static const inverseOnSurface = Color(0xFFEAF1FF);

  // Outline
  static const outline = Color(0xFF6C7A73);
  static const outlineVariant = Color(0xFFBBCAC1);

  // Primary
  static const primary = Color(0xFF006C4F);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFF32C798);
  static const onPrimaryContainer = Color(0xFF004E38);
  static const inversePrimary = Color(0xFF50DDAD);
  static const surfaceTint = Color(0xFF006C4F);

  // Secondary
  static const secondary = Color(0xFF545F73);
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFFD5E0F8);
  static const onSecondaryContainer = Color(0xFF586377);

  // Tertiary / Error
  static const tertiary = Color(0xFFB91A24);
  static const onTertiary = Color(0xFFFFFFFF);
  static const tertiaryContainer = Color(0xFFFF928B);
  static const error = Color(0xFFBA1A1A);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);

  // Fondo general
  static const background = Color(0xFFF8F9FF);
  static const onBackground = Color(0xFF0B1C30);

  // Extras del módulo de login
  static const inputFill = Color(0xFFF4F9F6);
  static const primaryPressed = Color(0xFF28A77E);
  // NEW: password error/weak strength color (≈ #F59E0B)
  static const passwordError = Color(0xFFFFA726);
}
