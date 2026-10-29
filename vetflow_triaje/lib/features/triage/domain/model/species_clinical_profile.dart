/// Perfil clínico por especie (ADR-0005).
///
/// Define rangos de signos vitales y estado de validación por especie.
/// Las especies con estado pendingVet no ajustan el nivel por signos
/// vitales (no se inventan umbrales).
library;

import 'package:vetflow_triaje/features/triage/domain/model/triage_level.dart';

class SpeciesClinicalProfile {
  const SpeciesClinicalProfile({
    required this.species,
    required this.state,
    this.tempMinC,
    this.tempMaxC,
    this.heartRateMin,
    this.heartRateMax,
    this.weightMinKg,
    this.weightMaxKg,
    this.puppyThresholdMonths,
    this.geriatricThresholdMonths,
  });

  final String species;
  final SpeciesClinicalState state;

  /// Rango de temperatura válido (°C).
  final double? tempMinC;
  final double? tempMaxC;

  /// Rango de frecuencia cardíaca válida (lpm).
  final int? heartRateMin;
  final int? heartRateMax;

  /// Rango de peso válido (kg).
  final double? weightMinKg;
  final double? weightMaxKg;

  /// Umbral de edad para cachorro (meses).
  final int? puppyThresholdMonths;

  /// Umbral de edad para geriátrico (meses).
  final int? geriatricThresholdMonths;

  /// Indica si los rangos están validados por veterinario.
  bool get isValidated => state == SpeciesClinicalState.validated;
}
