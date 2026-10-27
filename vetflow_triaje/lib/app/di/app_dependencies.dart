/// Módulo raíz de inyección de dependencias.
///
/// Agrupa todos los módulos de dominio para que la UI (cuando llegue)
/// reciba los casos de uso ya construidos. El gestor de estado y la
/// navegación se decidirán en el ADR-0004.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vetflow_triaje/app/di/auth_dependencies.dart';
import 'package:vetflow_triaje/app/di/clinic_dependencies.dart';
import 'package:vetflow_triaje/app/di/owner_dependencies.dart';
import 'package:vetflow_triaje/app/di/pet_dependencies.dart';
import 'package:vetflow_triaje/app/di/queue_dependencies.dart';
import 'package:vetflow_triaje/app/di/triage_dependencies.dart';
import 'package:vetflow_triaje/app/di/visit_dependencies.dart';
import 'package:vetflow_triaje/infrastructure/firebase/storage/pet_photo_storage.dart';

class AppDependencies {
  const AppDependencies({
    required this.authModule,
    required this.clinicModule,
    required this.ownerModule,
    required this.petModule,
    required this.visitModule,
    required this.triageModule,
    required this.queueModule,
    required this.petPhotoStorage,
  });

  factory AppDependencies.create({
    FirebaseFirestore? firestore,
    bool demoMode = true,
  }) {
    return AppDependencies(
      authModule: AuthModule.create(firestore: firestore, demoMode: demoMode),
      clinicModule: ClinicModule.create(firestore: firestore),
      ownerModule: OwnerModule.create(firestore: firestore, demoMode: demoMode),
      petModule: PetModule.create(firestore: firestore, demoMode: demoMode),
      visitModule: VisitModule.create(firestore: firestore),
      triageModule: TriageModule.create(
        symptomRules: const [],
        redFlagRules: const [],
        speciesProfiles: const [],
        rulesVersion: '0.2',
      ),
      queueModule: QueueModule.create(firestore: firestore),
      petPhotoStorage: PetPhotoStorage(),
    );
  }

  final AuthModule authModule;
  final ClinicModule clinicModule;
  final OwnerModule ownerModule;
  final PetModule petModule;
  final VisitModule visitModule;
  final TriageModule triageModule;
  final QueueModule queueModule;
  final PetPhotoStorage petPhotoStorage;
}
