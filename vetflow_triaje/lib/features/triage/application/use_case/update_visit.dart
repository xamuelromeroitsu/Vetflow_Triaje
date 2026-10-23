/// Caso de uso: actualizar una visita existente.
library;

import 'package:vetflow_triaje/features/triage/domain/model/visit.dart';
import 'package:vetflow_triaje/features/triage/domain/port/visit_repository.dart';
import 'package:vetflow_triaje/shared/domain/result.dart';

class UpdateVisit {
  const UpdateVisit({required this.visitRepository});

  final VisitRepository visitRepository;

  Future<Result<Visit>> call(Visit visit) {
    return visitRepository.update(visit);
  }
}
