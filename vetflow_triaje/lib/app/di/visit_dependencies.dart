/// Módulo de inyección de dependencias para visitas.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vetflow_triaje/features/triage/domain/port/visit_repository.dart';
import 'package:vetflow_triaje/infrastructure/firebase/visits/firestore_visit_repository.dart';

class VisitModule {
  const VisitModule();

  factory VisitModule.create({FirebaseFirestore? firestore}) {
    final visitRepository = FirestoreVisitRepository(firestore: firestore);
    return VisitModule._internal(visitRepository: visitRepository);
  }

  const VisitModule._internal({required this.visitRepository});

  final VisitRepository visitRepository;
}
