/// Puerto (interfaz) del repositorio de clínicas.
library;

import 'package:vetflow_triaje/features/clinics/domain/model/clinic.dart';
import 'package:vetflow_triaje/shared/domain/result.dart';

abstract class ClinicRepository {
  Future<Result<Clinic>> create(Clinic clinic);

  Future<Result<Clinic?>> findById(String id);

  Future<Result<List<Clinic>>> listAll();

  /// Clínicas que ofrecen al menos una de las especialidades dadas.
  Future<Result<List<Clinic>>> listBySpecialties(List<String> specialties);

  /// Clínicas con atención de urgencias 24 horas.
  Future<Result<List<Clinic>>> listEmergency24h();

  Future<Result<Clinic>> update(Clinic clinic);
}