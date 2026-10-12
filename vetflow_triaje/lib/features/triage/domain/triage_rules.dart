/// Reglas de triaje versionadas (borrador v0.1).
///
/// Cada cambio sube [version] (ADR-0003) y se anota la validación veterinaria
/// en docs/03-triaje-clinico/validacion-veterinaria.md.
///
/// OJO: estos niveles son un borrador para revisión veterinaria. No usar con
/// público sin validar.
library;

import 'package:vetflow_triaje/core/domain/species.dart';
import 'package:vetflow_triaje/features/triage/domain/symptom_category.dart';
import 'package:vetflow_triaje/features/triage/domain/symptom_rule.dart';
import 'package:vetflow_triaje/features/triage/domain/triage_level.dart';

class TriageRules {
  const TriageRules({
    required this.version,
    required this.symptoms,
    this.considerEmergencyOnTwoOrMoreUrgencias = true,
  });

  factory TriageRules.v01() => TriageRules(
        version: '0.1',
        symptoms: _v01Symptoms,
      );

  final String version;
  final List<SymptomRule> symptoms;

  /// "Dos o más síntomas 🟠 → valorar 🔴" (protocolo, marcado "a validar").
  /// Mientras el veterinario no la revise se aplica y queda anotada en
  /// [TriageResult.pendingValidationRules].
  final bool considerEmergencyOnTwoOrMoreUrgencias;

  SymptomRule? symptomById(String id) {
    for (final rule in symptoms) {
      if (rule.id == id) return rule;
    }
    return null;
  }

  static final List<SymptomRule> _v01Symptoms = [
    const SymptomRule(
      id: 'resp_dificultad',
      label: 'Dificultad para respirar',
      category: SymptomCategory.respiratorio,
      baseLevel: TriageLevel.emergencia,
      species: [],
      note: 'Pregunta de descarte',
    ),
    const SymptomRule(
      id: 'neuro_convulsiones',
      label: 'Convulsiones',
      category: SymptomCategory.otro,
      baseLevel: TriageLevel.emergencia,
      species: [],
      note: 'Pregunta de descarte',
    ),
    const SymptomRule(
      id: 'neuro_perdida_conciencia',
      label: 'Pérdida de conciencia',
      category: SymptomCategory.otro,
      baseLevel: TriageLevel.emergencia,
      species: [],
      note: 'Pregunta de descarte',
    ),
    const SymptomRule(
      id: 'trauma_sangrado_atropello',
      label: 'Sangrado abundante / atropello',
      category: SymptomCategory.otro,
      baseLevel: TriageLevel.emergencia,
      species: [],
      note: 'Pregunta de descarte',
    ),
    const SymptomRule(
      id: 'toxico_ingesta',
      label: 'Posible ingesta de veneno',
      category: SymptomCategory.otro,
      baseLevel: TriageLevel.emergencia,
      species: [],
      note: 'Preguntar qué y cuándo',
    ),
    const SymptomRule(
      id: 'dig_abdomen_hinchado',
      label: 'Abdomen hinchado con arcadas',
      category: SymptomCategory.digestivo,
      baseLevel: TriageLevel.emergencia,
      species: [Species.perro],
      note: 'Sospecha de torsión',
    ),
    const SymptomRule(
      id: 'urinario_no_puede_orinar',
      label: 'No puede orinar',
      category: SymptomCategory.otro,
      baseLevel: TriageLevel.emergencia,
      species: [Species.gato],
      note: 'Gato macho',
    ),
    const SymptomRule(
      id: 'dig_vomito_repetido',
      label: 'Vómito repetido',
      category: SymptomCategory.digestivo,
      baseLevel: TriageLevel.urgencia,
      species: [],
      note: 'Considerar duración',
    ),
    const SymptomRule(
      id: 'dig_diarrea_persistente',
      label: 'Diarrea persistente',
      category: SymptomCategory.digestivo,
      baseLevel: TriageLevel.urgencia,
      species: [],
      note: 'Más grave en cachorros',
    ),
    const SymptomRule(
      id: 'mov_cojera_marcada',
      label: 'Cojera marcada',
      category: SymptomCategory.movimiento,
      baseLevel: TriageLevel.urgencia,
      species: [],
    ),
    const SymptomRule(
      id: 'gen_no_come_24h',
      label: 'No come desde hace más de 24 h',
      category: SymptomCategory.otro,
      baseLevel: TriageLevel.urgencia,
      species: [],
      note: 'Gatos: más urgente',
    ),
    const SymptomRule(
      id: 'gen_fiebre',
      label: 'Fiebre',
      category: SymptomCategory.otro,
      baseLevel: TriageLevel.urgencia,
      species: [],
      note: 'Ver signos vitales',
    ),
    const SymptomRule(
      id: 'piel_herida_moderada',
      label: 'Herida abierta moderada',
      category: SymptomCategory.piel,
      baseLevel: TriageLevel.urgencia,
      species: [],
    ),
    const SymptomRule(
      id: 'piel_picazon_leve',
      label: 'Picazón leve',
      category: SymptomCategory.piel,
      baseLevel: TriageLevel.consulta,
      species: [],
    ),
    const SymptomRule(
      id: 'gen_cambio_apetito_leve',
      label: 'Cambio leve de apetito',
      category: SymptomCategory.otro,
      baseLevel: TriageLevel.consulta,
      species: [],
    ),
    const SymptomRule(
      id: 'prev_vacunas_desparasitacion',
      label: 'Vacunas / desparasitación / control',
      category: SymptomCategory.otro,
      baseLevel: TriageLevel.consulta,
      species: [],
    ),
    const SymptomRule(
      id: 'otro_texto_libre',
      label: 'Texto libre sin síntoma reconocido',
      category: SymptomCategory.otro,
      baseLevel: TriageLevel.urgencia,
      species: [],
      note: 'Ante la duda, subir',
    ),
  ];
}
