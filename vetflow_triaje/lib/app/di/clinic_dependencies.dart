/// Módulo de inyección de dependencias para clínicas.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vetflow_triaje/features/clinics/application/use_case/list_clinics.dart';
import 'package:vetflow_triaje/features/clinics/domain/port/clinic_repository.dart';
import 'package:vetflow_triaje/infrastructure/firebase/clinics/firestore_clinic_repository.dart';

class ClinicModule {
  const ClinicModule({
    required this.listClinics,
    required this.clinicRepository,
  });

  factory ClinicModule.create({FirebaseFirestore? firestore}) {
    final clinicRepository = FirestoreClinicRepository(firestore: firestore);
    return ClinicModule(
      listClinics: ListClinics(clinicRepository: clinicRepository),
      clinicRepository: clinicRepository,
    );
  }

  final ListClinics listClinics;
  final ClinicRepository clinicRepository;
}
