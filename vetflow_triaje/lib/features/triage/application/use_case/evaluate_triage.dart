/// Caso de uso: evaluar triaje por reglas.
///
/// Orquesta el motor de triaje y devuelve el resultado con nivel sugerido,
/// motivos y versión de reglas. El veterinario confirma por separado.
library;

import 'package:vetflow_triaje/features/triage/domain/model/symptom_entry.dart';
import 'package:vetflow_triaje/features/triage/domain/model/triage_level.dart';
import 'package:vetflow_triaje/features/triage/domain/model/triage_result.dart';
import 'package:vetflow_triaje/features/triage/domain/model/vital_signs.dart';
import 'package:vetflow_triaje/features/triage/domain/service/triage_engine.dart';

class EvaluateTriage {
  const EvaluateTriage({required this.engine});

  final TriageEngine engine;

  TriageResult call({
    required Map<String, bool?> redFlags,
    required List<SymptomEntry> symptoms,
    required VitalSigns vitals,
    String? species,
    bool hasMissingVitals = false,
  }) {
    return engine.evaluate(
      redFlags: redFlags,
      symptoms: symptoms,
      vitals: vitals,
      species: species,
      hasMissingVitals: hasMissingVitals,
    );
  }
}
