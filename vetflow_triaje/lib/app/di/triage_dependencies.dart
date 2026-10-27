/// Módulo de inyección de dependencias para triaje.
library;

import 'package:vetflow_triaje/features/triage/application/use_case/confirm_triage.dart';
import 'package:vetflow_triaje/features/triage/application/use_case/evaluate_triage.dart';
import 'package:vetflow_triaje/features/triage/domain/model/red_flag_rule.dart';
import 'package:vetflow_triaje/features/triage/domain/model/species_clinical_profile.dart';
import 'package:vetflow_triaje/features/triage/domain/model/symptom_rule.dart';
import 'package:vetflow_triaje/features/triage/domain/service/triage_engine.dart';

class TriageModule {
  const TriageModule({
    required this.evaluateTriage,
    required this.confirmTriage,
  });

  factory TriageModule.create({
    required List<SymptomRule> symptomRules,
    required List<RedFlagRule> redFlagRules,
    required List<SpeciesClinicalProfile> speciesProfiles,
    required String rulesVersion,
  }) {
    final rulesEngine = TriageEngine(
      symptomRules: List<SymptomRule>.from(symptomRules),
      redFlagRules: List<RedFlagRule>.from(redFlagRules),
      speciesProfiles: List<SpeciesClinicalProfile>.from(speciesProfiles),
      rulesVersion: rulesVersion,
    );
    return TriageModule._internal(
      evaluateTriage: EvaluateTriage(engine: rulesEngine),
      confirmTriage: ConfirmTriage(),
    );
  }

  const TriageModule._internal({
    required this.evaluateTriage,
    required this.confirmTriage,
  });

  final EvaluateTriage evaluateTriage;
  final ConfirmTriage confirmTriage;
}
