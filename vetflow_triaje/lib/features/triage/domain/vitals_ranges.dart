/// Rangos de signos vitales.
///
/// Valores de referencia general del borrador clínico
/// (docs/03-triaje-clinico/signos-vitales-por-especie.md). Pendientes de
/// confirmación por el veterinario.
library;

class Range {
  const Range(this.min, this.max);

  final double min;
  final double max;

  bool contains(double value) => value >= min && value <= max;
}

/// Rangos normales de referencia por especie.
class NormalRanges {
  const NormalRanges._();

  static const Range temperaturePerro = Range(38.3, 39.2);
  static const Range temperatureGato = Range(38.1, 39.2);

  static const Range heartRatePerro = Range(60, 140);
  static const Range heartRateGato = Range(140, 220);

  /// Peso esperado por raza: pendiente con el veterinario
  /// ("¿se compara con el peso esperado por raza?").
}

/// Rangos de captura: no son clínicos, solo evitan errores de tipeo.
class CaptureRanges {
  const CaptureRanges._();

  static const Range temperatureC = Range(30, 45);
  static const Range weightKg = Range(0.05, 120);
  static const Range heartRate = Range(20, 300);
}

/// Umbral de valor "extremo" por especie (subiría a emergencia).
///
/// Pendiente de definir con el veterinario. Mientras sea `null`, el motor no
/// aplica esa regla: no se inventan umbrales.
class ExtremeThresholds {
  const ExtremeThresholds._();

  static const double? temperaturePerroC = null;
  static const double? temperatureGatoC = null;
}
