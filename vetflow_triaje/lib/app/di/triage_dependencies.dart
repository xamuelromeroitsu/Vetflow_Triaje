/// Módulo de inyección de dependencias para triaje.
library;

import 'package:vetflow_triaje/features/triage/application/use_case/confirm_triage.dart';
import 'package:vetflow_triaje/features/triage/application/use_case/evaluate_triage.dart';
import 'package:vetflow_triaje/features/triage/domain/service/triage_engine.dart';

class TriageModule {
  const TriageModule({
    required this.evaluateTriage,
    required this.confirmTriage,
  });

  factory TriageModule.create({
    required List symptomRules,
    required List redFlagRules,
    required List speciesProfiles,
    required String rulesVersion,
  }) {
    final engine = TriageEngine(
      symptomRules: symptomRules,
      redFlagRules: redFlagRules,
      speciesProfiles: speciesProfiles,
      rulesVersion: rulesVersion,
    );
    return TriageModule._internal(
      evaluateTriage: EvaluateTriage(engine: engine),
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
