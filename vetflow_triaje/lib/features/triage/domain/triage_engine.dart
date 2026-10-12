/// Motor de triaje por reglas (ADR-0003).
///
/// Dart puro: no depende de Flutter ni de Firebase, así se prueba con
/// pruebas unitarias sin emulador ni dispositivo.
///
/// Implementa el pseudocódigo de docs/03-triaje-clinico/protocolo-triaje.md:
/// ```
/// if alguna_pregunta_descarte == "sí":  return EMERGENCIA
/// nivel = max(nivel_base(s) for s in síntomas)
/// nivel = max(nivel, ajuste_por_signos_vitales)
/// if respuesta_no_sé or faltan_signos:  nivel = max(nivel, URGENCIA)
/// ```
/// El nivel **nunca baja**: los datos incompletos, el "no sé" y los signos
/// vitales faltantes solo pueden subirlo o mantenerlo.
library;

import 'package:vetflow_triaje/core/domain/species.dart';
import 'package:vetflow_triaje/features/triage/domain/red_flag_question.dart';
import 'package:vetflow_triaje/features/triage/domain/triage_input.dart';
import 'package:vetflow_triaje/features/triage/domain/triage_level.dart';
import 'package:vetflow_triaje/features/triage/domain/triage_result.dart';
import 'package:vetflow_triaje/features/triage/domain/triage_rules.dart';
import 'package:vetflow_triaje/features/triage/domain/vitals_ranges.dart';

class TriageEngine {
  TriageEngine({TriageRules? rules}) : _rules = rules ?? TriageRules.v01();

  final TriageRules _rules;

  TriageResult evaluate(TriageInput input) {
    // Paso 1 · preguntas de descarte: un "sí" es emergencia directa.
    for (final entry in input.redFlags.entries) {
      if (entry.value == RedFlagAnswer.si) {
        return TriageResult(
          suggested: TriageLevel.emergencia,
          reasons: ['${entry.key.question} — respuesta "sí"'],
          rulesVersion: _rules.version,
        );
      }
    }

    final reasons = <String>[];
    final pendingRules = <String>[];
    var level = TriageLevel.consulta;
    var urgenciaSymptoms = 0;

    // Paso 2 · nivel por síntomas: se toma el más alto.
    for (final id in input.symptomIds) {
      final rule = _rules.symptomById(id);
      if (rule == null) {
        // "Ante la duda, subir" (regla de texto libre del borrador).
        level = maxLevel(level, TriageLevel.urgencia);
        urgenciaSymptoms++;
        reasons.add('Síntoma "$id" no reconocido: ante la duda, subir');
        continue;
      }
      level = maxLevel(level, rule.baseLevel);
      if (rule.baseLevel == TriageLevel.urgencia) urgenciaSymptoms++;
      reasons.add('${rule.label}: ${rule.baseLevel.label}');
    }

    // Paso 3 · ajuste por signos vitales: solo puede subir.
    level = maxLevel(level, _vitalsAdjustment(input, reasons));

    // Paso 4 · reglas de seguridad.
    if (input.hasUncertainAnswer) {
      level = maxLevel(level, TriageLevel.urgencia);
      reasons.add('Respuesta "no sé" en preguntas de descarte: mínimo Urgencia');
    }

    final vitals = input.vitals;
    if (vitals == null || !vitals.hasRequired) {
      level = maxLevel(level, TriageLevel.urgencia);
      reasons.add(
        'Faltan signos vitales obligatorios (temperatura y peso): '
        'mínimo Urgencia',
      );
    }

    if (urgenciaSymptoms >= 2 && _rules.considerEmergencyOnTwoOrMoreUrgencias) {
      pendingRules.add(
        'Dos o más síntomas 🟠 → valorar 🔴 '
        '(protocolo de triaje, pendiente de validación veterinaria)',
      );
      if (level == TriageLevel.urgencia) {
        reasons.add('Dos o más síntomas de urgencia: se valora Emergencia');
        level = TriageLevel.emergencia;
      }
    }

    // Regla de edad (cachorro/geriátrico) y de valor extremo: marcadas
    // "a validar" en el protocolo y sin umbrales definidos por el
    // veterinario. No se aplican mientras los umbrales sean null
    // (no se inventan valores).

    return TriageResult(
      suggested: level,
      reasons: reasons,
      rulesVersion: _rules.version,
      pendingValidationRules: pendingRules,
    );
  }

  TriageLevel _vitalsAdjustment(TriageInput input, List<String> reasons) {
    final vitals = input.vitals;
    if (vitals == null) return TriageLevel.consulta;

    var level = TriageLevel.consulta;

    final temp = vitals.tempC;
    if (temp != null && !_normalTemperature(input.species).contains(temp)) {
      reasons.add(
        'Temperatura $temp°C fuera del rango normal para '
        '${input.species.label}: sube un nivel',
      );
      level = level.raised;
    }

    final heartRate = vitals.heartRate;
    if (heartRate != null &&
        !_normalHeartRate(input.species).contains(heartRate.toDouble())) {
      reasons.add(
        'Frecuencia cardíaca $heartRate lpm fuera del rango normal para '
        '${input.species.label}: sube un nivel',
      );
      level = level.raised;
    }

    return level;
  }

  Range _normalTemperature(Species species) => switch (species) {
        Species.perro => NormalRanges.temperaturePerro,
        Species.gato => NormalRanges.temperatureGato,
      };

  Range _normalHeartRate(Species species) => switch (species) {
        Species.perro => NormalRanges.heartRatePerro,
        Species.gato => NormalRanges.heartRateGato,
      };
}
