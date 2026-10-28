// Design Tokens compartidos — Sistema DOGO
// Design System: "Clinical Mint"
//
// Uso exclusivo de las pantallas del MVP ubicadas en esta carpeta.
// Toda pantalla nueva DEBE importar estos tokens en lugar de definir
// colores/espaciados propios, para mantener una estructura homogénea.

import 'package:flutter/material.dart';

/// Paleta oficial "Clinical Mint" (ver DESIGN.md del mockup).
class DogoColors {
  static const surface = Color(0xFFF8F9FF);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFEFF4FF);
  static const surfaceContainer = Color(0xFFE5EEFF);
  static const surfaceContainerHigh = Color(0xFFDCE9FF);
  static const surfaceContainerHighest = Color(0xFFD3E4FE);
  static const onSurface = Color(0xFF0B1C30);
  static const onSurfaceVariant = Color(0xFF3C4A43);
  static const outline = Color(0xFF6C7A73);
  static const outlineVariant = Color(0xFFBBCAC1);

  static const primary = Color(0xFF006C4F);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFF32C798);
  static const onPrimaryContainer = Color(0xFF004E38);
  static const primaryFixed = Color(0xFF71FAC8);
  static const onPrimaryFixed = Color(0xFF002116);

  static const secondary = Color(0xFF545F73);
  static const secondaryContainer = Color(0xFFD5E0F8);
  static const onSecondaryContainer = Color(0xFF586377);

  static const tertiary = Color(0xFFB91A24);
  static const onTertiary = Color(0xFFFFFFFF);
  static const tertiaryContainer = Color(0xFFFF928B);
  static const onTertiaryContainer = Color(0xFF8D0012);
  static const tertiaryFixed = Color(0xFFFFDAD7);
  static const onTertiaryFixed = Color(0xFF410004);

  static const error = Color(0xFFBA1A1A);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);
}

/// Escala de espaciado "Clinical Mint" (8px base).
class DogoSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const margin = 16.0;
}

/// Estilos de texto "Clinical Mint".
class DogoText {
  static const headlineLg = TextStyle(
    color: DogoColors.onSurface,
    fontSize: 26,
    fontWeight: FontWeight.w700,
    height: 34 / 26,
    letterSpacing: -0.4,
  );
  static const headlineSm = TextStyle(
    color: DogoColors.onSurface,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 24 / 18,
  );
  static const bodyMd = TextStyle(
    color: DogoColors.onSurface,
    fontSize: 14,
    height: 20 / 14,
  );
  static const bodySm = TextStyle(
    color: DogoColors.onSurfaceVariant,
    fontSize: 13,
    height: 18 / 13,
  );
  static const labelLg = TextStyle(
    color: DogoColors.onSurface,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 20 / 14,
  );
  static const labelMd = TextStyle(
    color: DogoColors.onSurface,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 16 / 12,
  );
  static const labelSm = TextStyle(
    color: DogoColors.onSurface,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    height: 14 / 11,
    letterSpacing: 0.4,
  );
}

/// Sombra Level 1 estándar para tarjetas (ver DESIGN.md — Elevation & Depth).
const kDogoCardShadow = [
  BoxShadow(
    color: Color(0x0D111827),
    blurRadius: 8,
    offset: Offset(0, 2),
  ),
];

/// Sombra de alerta crítica (roja direccional).
const kDogoCriticalShadow = [
  BoxShadow(
    color: Color(0x40EF4444),
    blurRadius: 14,
    offset: Offset(0, 4),
  ),
];
