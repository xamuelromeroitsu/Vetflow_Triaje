/// Módulo raíz de inyección de dependencias.
///
/// Agrupa todos los módulos de dominio para que la UI (cuando llegue)
/// reciba los casos de uso ya construidos. El gestor de estado y la
/// navegación se decidirán en el ADR-0004.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vetflow_triaje/app/di/owner_dependencies.dart';
import 'package:vetflow_triaje/app/di/pet_dependencies.dart';
import 'package:vetflow_triaje/app/di/visit_dependencies.dart';

class AppDependencies {
  const AppDependencies({
    required this.ownerModule,
    required this.petModule,
    required this.visitModule,
  });

  factory AppDependencies.create({FirebaseFirestore? firestore}) {
    return AppDependencies(
      ownerModule: OwnerModule.create(firestore: firestore),
      petModule: PetModule.create(firestore: firestore),
      visitModule: VisitModule.create(firestore: firestore),
    );
  }

  final OwnerModule ownerModule;
  final PetModule petModule;
  final VisitModule visitModule;
}
