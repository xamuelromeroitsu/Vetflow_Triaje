/// Puerto (interfaz) del repositorio de visitas.
library;

import 'package:vetflow_triaje/shared/domain/result.dart';
import 'package:vetflow_triaje/features/triage/domain/model/visit.dart';

abstract class VisitRepository {
  Future<Result<Visit>> create(Visit visit);

  Future<Result<Visit?>> findById(String id);

  Future<Result<Visit>> update(Visit visit);
}
