/// Módulo de inyección de dependencias para clínicas.
library;

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vetflow_triaje/features/clinics/application/use_case/list_clinics.dart';
import 'package:vetflow_triaje/features/clinics/domain/port/clinic_repository.dart';
import 'package:vetflow_triaje/infrastructure/supabase/supabase_repositories.dart';

class ClinicModule {
  const ClinicModule({
    required this.listClinics,
    required this.clinicRepository,
  });

  factory ClinicModule.create({SupabaseClient? client}) {
    final clinicRepository = SupabaseClinicRepository(client: client);
    return ClinicModule(
      listClinics: ListClinics(clinicRepository: clinicRepository),
      clinicRepository: clinicRepository,
    );
  }

  final ListClinics listClinics;
  final ClinicRepository clinicRepository;
}
