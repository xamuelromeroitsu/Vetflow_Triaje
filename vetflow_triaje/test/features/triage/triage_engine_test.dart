import 'package:flutter_test/flutter_test.dart';
import 'package:vetflow_triaje/core/domain/species.dart';
import 'package:vetflow_triaje/features/triage/domain/red_flag_question.dart';
import 'package:vetflow_triaje/features/triage/domain/triage_engine.dart';
import 'package:vetflow_triaje/features/triage/domain/triage_input.dart';
import 'package:vetflow_triaje/features/triage/domain/triage_level.dart';
import 'package:vetflow_triaje/features/triage/domain/triage_result.dart';
import 'package:vetflow_triaje/features/triage/domain/vitals_ranges.dart';

/// Cada pregunta de descarte con su respuesta "sí" lleva a emergencia.
void main() {
  final engine = TriageEngine();
  final allNo = <RedFlagQuestion, RedFlagAnswer>{
    for (final question in RedFlagQuestion.values)
      question: RedFlagAnswer.no,
  };

  TriageResult evaluate({
    Map<RedFlagQuestion, RedFlagAnswer> redFlags = const {},
    List<String> symptomIds = const [],
    VitalsInput? vitals,
    Species species = Species.perro,
    int? ageMonths,
  }) {
    return engine.evaluate(
      TriageInput(
        redFlags: redFlags.isEmpty ? allNo : redFlags,
        symptomIds: symptomIds,
        vitals: vitals,
        species: species,
        ageMonths: ageMonths,
      ),
    );
  }

  VitalsInput normalVitals({
    Species species = Species.perro,
    int? heartRate = 100,
  }) {
    return VitalsInput(
      tempC: species == Species.perro ? 38.8 : 38.6,
      weightKg: 12.4,
      heartRate: heartRate,
    );
  }

  group('Paso 1 · preguntas de descarte', () {
    for (final question in RedFlagQuestion.values) {
      test('"sí" en ${question.name} sugiere emergencia', () {
        final result = evaluate(
          redFlags: {question: RedFlagAnswer.si},
          symptomIds: const ['piel_picazon_leve'],
          vitals: normalVitals(),
        );
        expect(result.suggested, TriageLevel.emergencia);
        expect(result.reasons.first, contains('respuesta "sí"'));
      });
    }

    test('todas "no" no sube el nivel por sí solo', () {
      final result = evaluate(
        redFlags: allNo,
        symptomIds: const ['piel_picazon_leve'],
        vitals: normalVitals(),
      );
      expect(result.suggested, TriageLevel.consulta);
    });
  });

  group('Paso 2 · nivel por síntomas', () {
    test('se toma el nivel más alto de los seleccionados', () {
      final result = evaluate(
        symptomIds: const ['piel_picazon_leve', 'dig_vomito_repetido'],
        vitals: normalVitals(),
      );
      expect(result.suggested, TriageLevel.urgencia);
    });

    test('síntoma no reconocido sube a urgencia (ante la duda, subir)', () {
      final result = evaluate(
        symptomIds: const ['no_existe'],
        vitals: normalVitals(),
      );
      expect(result.suggested, TriageLevel.urgencia);
      expect(result.reasons, anyElement(contains('ante la duda')));
    });

    test('sin síntomas y signos normales queda en consulta', () {
      final result = evaluate(vitals: normalVitals());
      expect(result.suggested, TriageLevel.consulta);
    });
  });

  group('Paso 3 · ajuste por signos vitales', () {
    test('temperatura fuera del rango normal sube un nivel', () {
      final result = evaluate(
        symptomIds: const ['piel_picazon_leve'],
        vitals: const VitalsInput(tempC: 35, weightKg: 12),
      );
      expect(result.suggested, TriageLevel.urgencia);
      expect(result.reasons, anyElement(contains('Temperatura')));
    });

    test('frecuencia cardíaca fuera de rango sube un nivel', () {
      final result = evaluate(
        symptomIds: const ['piel_picazon_leve'],
        vitals: const VitalsInput(tempC: 38.8, weightKg: 12, heartRate: 400),
      );
      expect(result.suggested, TriageLevel.urgencia);
    });

    test('los signos vitales nunca bajan el nivel', () {
      final result = evaluate(
        symptomIds: const ['dig_vomito_repetido'],
        vitals: normalVitals(),
      );
      expect(result.suggested, TriageLevel.urgencia);
    });

    test('las temperaturas normales de cada especie no alteran el nivel', () {
      for (final species in Species.values) {
        final result = evaluate(
          species: species,
          symptomIds: const ['piel_picazon_leve'],
          vitals: normalVitals(
            species: species,
            heartRate: species == Species.perro ? 100 : 180,
          ),
        );
        expect(result.suggested, TriageLevel.consulta);
      }
    });
  });

  group('Paso 4 · reglas de seguridad', () {
    test('"no sé" en descarte: mínimo urgencia', () {
      final result = evaluate(
        redFlags: {
          RedFlagQuestion.posibleToxico: RedFlagAnswer.noSe,
        },
        symptomIds: const ['piel_picazon_leve'],
        vitals: normalVitals(),
      );
      expect(result.suggested, TriageLevel.urgencia);
    });

    test('sin signos vitales: mínimo urgencia', () {
      final result = evaluate(symptomIds: const ['piel_picazon_leve']);
      expect(result.suggested, TriageLevel.urgencia);
    });

    test('sin temperatura (obligatoria): mínimo urgencia', () {
      final result = evaluate(
        symptomIds: const ['piel_picazon_leve'],
        vitals: const VitalsInput(weightKg: 12),
      );
      expect(result.suggested, TriageLevel.urgencia);
    });

    test('"no sé" no baja un nivel ya alto', () {
      final result = evaluate(
        redFlags: {RedFlagQuestion.sangradoSinParar: RedFlagAnswer.noSe},
        symptomIds: const ['dig_vomito_repetido'],
        vitals: normalVitals(),
      );
      expect(result.suggested, TriageLevel.urgencia);
    });

    test('dos síntomas de urgencia valoran emergencia (regla a validar)', () {
      final result = evaluate(
        symptomIds: const ['dig_vomito_repetido', 'dig_diarrea_persistente'],
        vitals: normalVitals(),
      );
      expect(result.suggested, TriageLevel.emergencia);
      expect(result.pendingValidationRules, isNotEmpty);
    });

    test('un solo síntoma de urgencia se queda en urgencia', () {
      final result = evaluate(
        symptomIds: const ['dig_vomito_repetido'],
        vitals: normalVitals(),
      );
      expect(result.suggested, TriageLevel.urgencia);
    });
  });

  group('Resultado', () {
    test('lleva la versión de reglas usada', () {
      final result = evaluate(vitals: normalVitals());
      expect(result.rulesVersion, '0.1');
    });

    test('confirmado queda null hasta que el veterinario confirme', () {
      final result = evaluate(vitals: normalVitals());
      expect(result.confirmed, isNull);
    });

    test('el mapa espeja el campo triage de visits', () {
      final result = evaluate(vitals: normalVitals());
      final map = result.toMap();
      expect(map.keys.toSet(), {
        'suggested',
        'confirmed',
        'reasons',
        'rulesVersion',
      });
      expect(map['suggested'], 'consulta');
      expect(map['confirmed'], isNull);
      expect(map['rulesVersion'], '0.1');
    });

    test('los rangos de referencia del borrador no cambian', () {
      expect(NormalRanges.temperaturePerro.contains(38.8), isTrue);
      expect(NormalRanges.temperatureGato.contains(38.8), isTrue);
      expect(CaptureRanges.temperatureC.contains(35), isTrue);
    });
  });
}
