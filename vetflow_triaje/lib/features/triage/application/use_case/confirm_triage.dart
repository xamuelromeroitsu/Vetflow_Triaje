/// Caso de uso: confirmar o corregir el nivel de triaje.
///
/// Solo un veterinario puede confirmar. Guarda suggested y confirmed
/// por separado, junto con reasons y rulesVersion.
library;

import 'package:vetflow_triaje/features/triage/domain/model/triage_level.dart';
import 'package:vetflow_triaje/features/triage/domain/model/triage_result.dart';

class ConfirmTriage {
  const ConfirmTriage();

  /// Aplica la confirmación del veterinario sobre un resultado previo.
  TriageResult call({
    required TriageResult previous,
    required TriageLevel confirmed,
  }) {
    return TriageResult(
      suggested: previous.suggested,
      confirmed: confirmed,
      reasons: previous.reasons,
      rulesVersion: previous.rulesVersion,
      pendingValidationRules: previous.pendingValidationRules,
    );
  }
}
