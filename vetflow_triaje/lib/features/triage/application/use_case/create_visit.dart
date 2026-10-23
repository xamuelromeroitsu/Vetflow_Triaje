/// Caso de uso: crear una visita de triaje.
library;

import 'package:vetflow_triaje/features/triage/domain/model/visit.dart';
import 'package:vetflow_triaje/features/triage/domain/port/visit_repository.dart';
import 'package:vetflow_triaje/shared/domain/result.dart';

class CreateVisit {
  const CreateVisit({required this.visitRepository});

  final VisitRepository visitRepository;

  Future<Result<Visit>> call({
    required String petId,
    String? companyId,
  }) async {
    final visit = Visit(
      id: '',
      petId: petId,
      companyId: companyId,
      status: 'pendiente',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return visitRepository.create(visit);
  }
}
