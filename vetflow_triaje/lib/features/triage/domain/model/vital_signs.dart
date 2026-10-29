/// Signos vitales de la mascota.
///
/// Parte de EPC-01: captura de signos vitales.
/// Los rangos válidos por especie son borrador hasta validación
/// veterinaria (ADR-0005). No se inventan umbrales aquí.
library;

class VitalSigns {
  const VitalSigns({
    this.tempC,
    this.weightKg,
    this.heartRate,
    this.flags,
  });

  final double? tempC;
  final double? weightKg;
  final int? heartRate;
  final List<String>? flags;
}
