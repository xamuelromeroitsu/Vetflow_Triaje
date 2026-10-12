/// Entrada del motor de triaje.
library;

import 'package:vetflow_triaje/core/domain/species.dart';
import 'package:vetflow_triaje/features/triage/domain/red_flag_question.dart';

/// Signos vitales capturados. Temperatura y peso son obligatorios;
/// frecuencia cardíaca opcional (US-04).
class VitalsInput {
  const VitalsInput({
    this.tempC,
    this.weightKg,
    this.heartRate,
  });

  final double? tempC;
  final double? weightKg;
  final int? heartRate;

  bool get hasRequired => tempC != null && weightKg != null;
}

class TriageInput {
  const TriageInput({
    required this.redFlags,
    required this.species,
    this.symptomIds = const [],
    this.vitals,
    this.ageMonths,
  });

  final Map<RedFlagQuestion, RedFlagAnswer> redFlags;
  final List<String> symptomIds;
  final VitalsInput? vitals;
  final Species species;
  final int? ageMonths;

  /// true si alguna pregunta de descarte se respondió "no sé".
  bool get hasUncertainAnswer => redFlags.containsValue(RedFlagAnswer.noSe);
}
