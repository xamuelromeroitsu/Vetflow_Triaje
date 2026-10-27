/// Motor de reglas de triaje (domain service puro).
///
/// No depende de Flutter, Firebase ni de la UI. Todo el cálculo es
/// determinista y testeable con pruebas unitarias.
///
/// Reglas del protocolo (borrador, pendiente validación veterinaria):
/// 1. Si alguna pregunta de descarte == "sí" → EMERGENCIA.
/// 2. Nivel = máximo nivel base de los síntomas seleccionados.
/// 3. Nivel = máximo(nivel, ajuste por signos vitales) — solo subir.
/// 4. Si respuesta "no sé" o faltan signos vitales obligatorios → mínimo URGENCIA.
/// 5. El nivel nunca baja.
library;

import 'package:vetflow_triaje/features/triage/domain/model/red_flag_rule.dart';
import 'package:vetflow_triaje/features/triage/domain/model/species_clinical_profile.dart';
import 'package:vetflow_triaje/features/triage/domain/model/symptom_entry.dart';
import 'package:vetflow_triaje/features/triage/domain/model/symptom_rule.dart';
import 'package:vetflow_triaje/features/triage/domain/model/triage_level.dart';
import 'package:vetflow_triaje/features/triage/domain/model/triage_result.dart';
import 'package:vetflow_triaje/features/triage/domain/model/vital_signs.dart';

class TriageEngine {
  const TriageEngine({
    required this.symptomRules,
    required this.redFlagRules,
    required this.speciesProfiles,
    required this.rulesVersion,
  });

  final List<SymptomRule> symptomRules;
  final List<RedFlagRule> redFlagRules;
  final List<SpeciesClinicalProfile> speciesProfiles;
  final String rulesVersion;

  /// Evalúa el triaje a partir de los datos capturados.
  TriageResult evaluate({
    required Map<String, bool?> redFlags,
    required List<SymptomEntry> symptoms,
    required VitalSigns vitals,
    String? species,
    bool hasMissingVitals = false,
  }) {
    final reasons = <String>[];
    final pendingValidation = <String>[];
    var level = TriageLevel.consulta;

    // Paso 1: Preguntas de descarte. Un "sí" → Emergencia directa.
    for (final rule in redFlagRules) {
      if (!rule.appliesToSpecies(species)) continue;
      final answered = redFlags[rule.id];
      if (answered == true) {
        reasons.add(
          'Descarte positivo: ${rule.question} → ${TriageLevel.emergencia.label}',
        );
        return TriageResult(
          suggested: TriageLevel.emergencia,
          reasons: reasons,
          rulesVersion: rulesVersion,
          pendingValidationRules: pendingValidation.isNotEmpty
              ? pendingValidation
              : null,
        );
      }
      if (answered == null) {
        // "No sé" en descarte → mínimo Urgencia (regla de seguridad).
        reasons.add(
          'Respuesta "no sé" en descarte: ${rule.question}',
        );
        level = TriageLevelX.max(level, TriageLevel.urgencia);
        pendingValidation.add('respuesta_incompleta_descarte_${rule.id}');
      }
    }

    // Paso 2: Nivel por síntomas (tomar el más alto).
    for (final symptom in symptoms) {
      final items = symptom.items;
      for (final item in items) {
        final matchingRules = symptomRules.where(
          (r) => r.category == symptom.category &&
              r.item == item &&
              r.appliesToSpecies(species),
        );
        if (matchingRules.isEmpty) {
          // Síntoma sin regla reconocida para esta especie → mínimo Urgencia.
          reasons.add(
            'Síntoma sin regla para especie "${species ?? 'desconocida'}": '
            '$item → mínimo ${TriageLevel.urgencia.label}',
          );
          level = TriageLevelX.max(level, TriageLevel.urgencia);
          pendingValidation.add('sin_regla_${symptom.category}_$item');
          continue;
        }
        for (final rule in matchingRules) {
          reasons.add(
            '${rule.category} - ${rule.item}: ${rule.level.label}',
          );
          level = TriageLevelX.max(level, rule.level);
        }
      }
    }

    // Paso 3: Ajuste por signos vitales (solo subir, nunca bajar).
    final vitalAdjustment = _adjustByVitals(vitals, species);
    if (vitalAdjustment != null) {
      reasons.addAll(vitalAdjustment.reasons);
      if (vitalAdjustment.level != null) {
        level = TriageLevelX.max(level, vitalAdjustment.level!);
      }
      if (vitalAdjustment.pendingValidation != null) {
        pendingValidation.addAll(vitalAdjustment.pendingValidation!);
      }
    }

    // Paso 4: Reglas de seguridad.
    if (hasMissingVitals) {
      reasons.add(
        'Faltan signos vitales obligatorios → mínimo ${TriageLevel.urgencia.label}',
      );
      level = TriageLevelX.max(level, TriageLevel.urgencia);
    }

    return TriageResult(
      suggested: level,
      reasons: reasons,
      rulesVersion: rulesVersion,
      pendingValidationRules: pendingValidation.isNotEmpty
          ? pendingValidation
          : null,
    );
  }

  /// Ajuste por signos vitales según el perfil clínico de la especie.
  ///
  /// El nivel solo puede subir. Si la especie está pendingVet, no se ajusta
  /// y se anota para revisión veterinaria.
  _VitalAdjustment? _adjustByVitals(VitalSigns vitals, String? species) {
    final profile = speciesProfiles.firstWhere(
      (p) => p.species == species?.toLowerCase(),
      orElse: () => SpeciesClinicalProfile(
        species: species ?? 'desconocida',
        state: SpeciesClinicalState.pendingVet,
      ),
    );

    if (!profile.isValidated) {
      // Especies pendingVet: no ajustar por signos vitales (ADR-0005).
      return _VitalAdjustment(
        level: null,
        reasons: [
          'Especie "${species ?? 'desconocida'}" sin rangos validados. '
          'No se ajusta por signos vitales.',
        ],
        pendingValidation: ['rangi_vitales_${species ?? 'desconocida'}'],
      );
    }

    final reasons = <String>[];
    var adjustment = TriageLevel.consulta;
    bool hasChange = false;

    if (vitals.tempC != null &&
        profile.tempMinC != null &&
        profile.tempMaxC != null) {
      final temp = vitals.tempC!;
      if (temp < profile.tempMinC! || temp > profile.tempMaxC!) {
        reasons.add(
          'Temperatura ${temp}°C fuera de rango '
          '(${profile.tempMinC}–${profile.tempMaxC}°C) → subir nivel',
        );
        adjustment = TriageLevelX.max(adjustment, TriageLevel.urgencia);
        hasChange = true;
      }
    }

    if (vitals.heartRate != null &&
        profile.heartRateMin != null &&
        profile.heartRateMax != null) {
      final hr = vitals.heartRate!;
      if (hr < profile.heartRateMin! || hr > profile.heartRateMax!) {
        reasons.add(
          'Frecuencia cardíaca ${hr} lpm fuera de rango '
          '(${profile.heartRateMin}–${profile.heartRateMax} lpm) → subir nivel',
        );
        adjustment = TriageLevelX.max(adjustment, TriageLevel.urgencia);
        hasChange = true;
      }
    }

    if (vitals.weightKg != null &&
        profile.weightMinKg != null &&
        profile.weightMaxKg != null) {
      final w = vitals.weightKg!;
      if (w < profile.weightMinKg! || w > profile.weightMaxKg!) {
        reasons.add(
          'Peso ${w} kg fuera de rango '
          '(${profile.weightMinKg}–${profile.weightMaxKg} kg)',
        );
        hasChange = true;
      }
    }

    if (!hasChange) return null;

    return _VitalAdjustment(
      level: adjustment,
      reasons: reasons,
    );
  }
}

class _VitalAdjustment {
  const _VitalAdjustment({
    this.level,
    required this.reasons,
    this.pendingValidation,
  });

  final TriageLevel? level;
  final List<String> reasons;
  final List<String>? pendingValidation;
}
