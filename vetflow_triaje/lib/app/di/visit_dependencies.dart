/// Módulo de inyección de dependencias para visitas.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vetflow_triaje/features/triage/application/use_case/create_visit.dart';
import 'package:vetflow_triaje/features/triage/application/use_case/update_visit.dart';
import 'package:vetflow_triaje/features/triage/domain/port/visit_repository.dart';
import 'package:vetflow_triaje/infrastructure/firebase/visits/firestore_visit_repository.dart';

class VisitModule {
  const VisitModule({
    required this.createVisit,
    required this.updateVisit,
    required this.visitRepository,
  });

  factory VisitModule.create({FirebaseFirestore? firestore}) {
    final visitRepository = FirestoreVisitRepository(firestore: firestore);
    return VisitModule(
      createVisit: CreateVisit(visitRepository: visitRepository),
      updateVisit: UpdateVisit(visitRepository: visitRepository),
      visitRepository: visitRepository,
    );
  }

  final CreateVisit createVisit;
  final UpdateVisit updateVisit;
  final VisitRepository visitRepository;
}
