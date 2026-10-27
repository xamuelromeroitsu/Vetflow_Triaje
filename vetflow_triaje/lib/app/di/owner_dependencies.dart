/// Módulo de inyección de dependencias para dueños.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vetflow_triaje/features/owners/application/use_case/register_owner.dart';
import 'package:vetflow_triaje/features/owners/application/use_case/update_owner.dart';
import 'package:vetflow_triaje/features/owners/domain/port/owner_repository.dart';
import 'package:vetflow_triaje/infrastructure/demo/demo_repositories.dart';
import 'package:vetflow_triaje/infrastructure/firebase/owners/firestore_owner_repository.dart';

class OwnerModule {
  const OwnerModule({required this.registerOwner, required this.updateOwner});

  factory OwnerModule.create({
    FirebaseFirestore? firestore,
    bool demoMode = true,
  }) {
    final ownerRepository = demoMode
        ? DemoOwnerRepository()
        : FirestoreOwnerRepository(firestore: firestore);
    return OwnerModule(
      registerOwner: RegisterOwner(ownerRepository: ownerRepository),
      updateOwner: UpdateOwner(ownerRepository: ownerRepository),
    );
  }

  final RegisterOwner registerOwner;
  final UpdateOwner updateOwner;
}
