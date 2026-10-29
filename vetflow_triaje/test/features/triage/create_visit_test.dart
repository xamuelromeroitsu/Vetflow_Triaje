import 'package:flutter_test/flutter_test.dart';
import 'package:vetflow_triaje/features/triage/application/use_case/create_visit.dart';
import 'package:vetflow_triaje/features/triage/domain/model/visit.dart';
import 'package:vetflow_triaje/features/triage/domain/port/visit_repository.dart';
import 'package:vetflow_triaje/shared/domain/result.dart';

void main() {
  test('returns the database-generated visit ID for navigation', () async {
    final useCase = CreateVisit(visitRepository: _GeneratedIdVisitRepository());

    final result = await useCase(petId: 'pet-1');

    expect(result.valueOrNull?.id, 'generated-visit-id');
  });
}

class _GeneratedIdVisitRepository implements VisitRepository {
  @override
  Future<Result<Visit>> create(Visit visit) async => Result.ok(
    Visit(
      id: 'generated-visit-id',
      petId: visit.petId,
      companyId: visit.companyId,
      redFlags: visit.redFlags,
      symptoms: visit.symptoms,
      vitals: visit.vitals,
      photos: visit.photos,
      triage: visit.triage,
      status: visit.status,
      createdAt: visit.createdAt,
      updatedAt: visit.updatedAt,
    ),
  );

  @override
  Future<Result<Visit?>> findById(String id) async => Result.ok(null);

  @override
  Future<Result<Visit>> update(Visit visit) async => Result.ok(visit);
}
