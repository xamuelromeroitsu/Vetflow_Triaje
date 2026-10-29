/// Módulo de inyección de dependencias para visitas.
library;

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vetflow_triaje/features/triage/application/use_case/create_visit.dart';
import 'package:vetflow_triaje/features/triage/application/use_case/update_visit.dart';
import 'package:vetflow_triaje/features/triage/domain/port/visit_repository.dart';
import 'package:vetflow_triaje/infrastructure/supabase/supabase_repositories.dart';

class VisitModule {
  const VisitModule({
    required this.createVisit,
    required this.updateVisit,
    required this.visitRepository,
  });

  factory VisitModule.create({SupabaseClient? client}) {
    final visitRepository = SupabaseVisitRepository(client: client);
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
