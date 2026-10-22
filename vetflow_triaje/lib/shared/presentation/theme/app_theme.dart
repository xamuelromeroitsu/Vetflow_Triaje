/// Tema visual de VetFlow Triaje.
///
/// Colores inspirados en la app de referencia (DOGO Veterinaria 24/7):
/// - Verde primario para botones principales y estado "Red Activa".
/// - Rojo para emergencias.
/// - Naranja para urgencias.
/// - Verde claro para consultas.
library;

import 'package:flutter/material.dart';

/// Color primario de la marca (verde veterinaria).
const Color kPrimaryColor = Color(0xFF2ECC71);

/// Color secundario claro para botones de acción alternativa.
const Color kSecondaryColor = Color(0xFFE8F5E9);

/// Color de superficie para tarjetas y fondos.
const Color kSurfaceColor = Color(0xFFFFFFFF);

/// Color de texto principal.
const Color kTextPrimaryColor = Color(0xFF1F2933);

/// Color de texto secundario.
const Color kTextSecondaryColor = Color(0xFF6B7280);

/// Color de éxito/positivo.
const Color kSuccessColor = Color(0xFF2ECC71);

/// Color de advertencia/urgencia.
const Color kWarningColor = Color(0xFFF59E0B);

/// Color de error/emergencia.
const Color kErrorColor = Color(0xFFEF4444);

/// Color de fondo de la app.
const Color kBackgroundColor = Color(0xFFF9FAFB);

/// Tema de datos de la aplicación.
ThemeData get appTheme {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: kPrimaryColor,
      brightness: Brightness.light,
      surface: kSurfaceColor,
      background: kBackgroundColor,
    ),
    scaffoldBackgroundColor: kBackgroundColor,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: Colors.transparent,
      foregroundColor: kTextPrimaryColor,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: kPrimaryColor,
        minimumSize: const Size(double.infinity, 56),
        side: const BorderSide(color: kPrimaryColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: kTextSecondaryColor,
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kSurfaceColor,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kPrimaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kErrorColor),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 0,
      color: kSurfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: kTextPrimaryColor,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: kTextPrimaryColor,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: kTextPrimaryColor,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: kTextPrimaryColor,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: kTextSecondaryColor,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: kTextPrimaryColor,
      ),
    ),
  );
}

/// Devuelve el color asociado a un nivel de triaje (nunca solo color:
/// siempre se acompaña de ícono y texto).
Color triageLevelColor(String level) {
  switch (level) {
    case 'emergencia':
      return kErrorColor;
    case 'urgencia':
      return kWarningColor;
    case 'consulta':
      return kSuccessColor;
    default:
      return kTextSecondaryColor;
  }
}

/// Devuelve el ícono asociado a un nivel de triaje.
IconData triageLevelIcon(String level) {
  switch (level) {
    case 'emergencia':
      return Icons.error_outline;
    case 'urgencia':
      return Icons.warning_amber_outlined;
    case 'consulta':
      return Icons.check_circle_outline;
    default:
      return Icons.info_outline;
  }
}
