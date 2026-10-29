/// Caso de uso: listar clínicas con filtros de especialidad y disponibilidad.
library;

import 'package:vetflow_triaje/features/clinics/domain/model/clinic.dart';
import 'package:vetflow_triaje/features/clinics/domain/port/clinic_repository.dart';
import 'package:vetflow_triaje/shared/domain/result.dart';

class ListClinics {
  const ListClinics({required this.clinicRepository});

  final ClinicRepository clinicRepository;

  Future<Result<List<Clinic>>> call({
    List<String>? specialties,
    bool emergency24hOnly = false,
  }) async {
    if (emergency24hOnly) {
      return clinicRepository.listEmergency24h();
    }

    if (specialties != null && specialties.isNotEmpty) {
      return clinicRepository.listBySpecialties(specialties);
    }

    return clinicRepository.listAll();
  }
}