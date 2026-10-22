/// Resultado de una evaluación de triaje.
///
/// Se guarda `suggested` y `confirmed` por separado, junto con `reasons`
/// y `rulesVersion` para auditoría. El veterinario confirma o corrige.
library;

import 'package:vetflow_triaje/features/triage/domain/model/triage_level.dart';

class TriageResult {
  const TriageResult({
    required this.suggested,
    this.confirmed,
    required this.reasons,
    required this.rulesVersion,
    this.pendingValidationRules,
  });

  /// Nivel sugerido por el motor de reglas.
  final TriageLevel suggested;

  /// Nivel confirmado por el veterinario (null hasta confirmar).
  final TriageLevel? confirmed;

  /// Motivos que llevaron al nivel sugerido.
  final List<String> reasons;

  /// Versión de las reglas aplicadas (ADR-0003).
  final String rulesVersion;

  /// Reglas pendientes de validación veterinaria (ADR-0005).
  final List<String>? pendingValidationRules;

  /// Nivel efectivo: confirmado si existe, si no el sugerido.
  TriageLevel get effectiveLevel => confirmed ?? suggested;

  /// Indica si el triaje ya fue confirmado por un veterinario.
  bool get isConfirmed => confirmed != null;
}
