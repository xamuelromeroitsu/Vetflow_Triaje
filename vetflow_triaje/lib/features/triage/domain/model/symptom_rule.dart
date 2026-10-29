/// Regla de síntoma con su nivel base y especies aplicables.
///
/// Parte del borrador clínico (reglas-por-sintoma.md). Está sujeta a
/// validación veterinaria antes de usarse con público.
library;

import 'package:vetflow_triaje/features/triage/domain/model/triage_level.dart';

class SymptomRule {
  const SymptomRule({
    required this.id,
    required this.category,
    required this.item,
    required this.level,
    this.appliesTo, // null = todas las especies
    this.notes,
  });

  final String id;
  final String category;
  final String item;
  final TriageLevel level;

  /// Especies a las que aplica esta regla. Null = todas las especies del MVP.
  final List<String>? appliesTo;

  final String? notes;

  /// Indica si la regla aplica para la especie dada.
  bool appliesToSpecies(String? species) {
    if (appliesTo == null || appliesTo!.isEmpty) return true;
    if (species == null) return false;
    return appliesTo!.contains(species.toLowerCase());
  }
}
