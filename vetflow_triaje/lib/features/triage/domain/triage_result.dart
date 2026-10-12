/// Resultado del motor de triaje.
///
/// Espeja el mapa `triage` de `visits`
/// (docs/05-arquitectura/modelo-de-datos.md): `suggested`, `confirmed`,
/// `reasons`, `rulesVersion`. `confirmed` lo pone el veterinario después
/// (ADR-0003); aquí siempre queda a null.
library;

import 'package:vetflow_triaje/features/triage/domain/triage_level.dart';

class TriageResult {
  const TriageResult({
    required this.suggested,
    required this.reasons,
    required this.rulesVersion,
    this.pendingValidationRules = const [],
  });

  final TriageLevel suggested;

  /// Motivos legibles del nivel sugerido.
  final List<String> reasons;

  final String rulesVersion;

  /// Reglas del borrador aplicadas que aún no ha validado el veterinario.
  final List<String> pendingValidationRules;

  /// Nivel confirmado por el veterinario. Null hasta que confirme.
  TriageLevel? get confirmed => null;

  Map<String, dynamic> toMap() => {
        'suggested': suggested.name,
        'confirmed': null,
        'reasons': reasons,
        'rulesVersion': rulesVersion,
      };
}
