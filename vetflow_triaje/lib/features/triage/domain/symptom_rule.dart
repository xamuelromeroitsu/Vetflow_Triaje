/// Síntoma reconocido con su nivel base (borrador v0.1).
///
/// Los niveles salen de docs/03-triaje-clinico/reglas-por-sintoma.md y están
/// pendientes de validación veterinaria: no inventar ni modificar sin ella.
library;

import 'package:vetflow_triaje/core/domain/species.dart';
import 'package:vetflow_triaje/features/triage/domain/symptom_category.dart';
import 'package:vetflow_triaje/features/triage/domain/triage_level.dart';

class SymptomRule {
  const SymptomRule({
    required this.id,
    required this.label,
    required this.category,
    required this.baseLevel,
    required this.species,
    this.note = '',
  });

  final String id;
  final String label;
  final SymptomCategory category;
  final TriageLevel baseLevel;

  /// Especies a las que aplica. Vacío = todas.
  final List<Species> species;
  final String note;

  bool appliesTo(Species value) => species.isEmpty || species.contains(value);
}
