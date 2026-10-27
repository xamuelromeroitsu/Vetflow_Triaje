/// Módulo de inyección de dependencias para mascotas.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vetflow_triaje/features/pets/application/use_case/get_pets_by_owner.dart';
import 'package:vetflow_triaje/features/pets/application/use_case/register_pet.dart';
import 'package:vetflow_triaje/features/pets/application/use_case/update_pet.dart';
import 'package:vetflow_triaje/features/pets/domain/port/pet_repository.dart';
import 'package:vetflow_triaje/infrastructure/demo/demo_repositories.dart';
import 'package:vetflow_triaje/infrastructure/firebase/pets/firestore_pet_repository.dart';

class PetModule {
  const PetModule({
    required this.registerPet,
    required this.updatePet,
    required this.getPetsByOwner,
  });

  factory PetModule.create({
    FirebaseFirestore? firestore,
    bool demoMode = true,
  }) {
    final petRepository = demoMode
        ? DemoPetRepository()
        : FirestorePetRepository(firestore: firestore);
    return PetModule(
      registerPet: RegisterPet(petRepository: petRepository),
      updatePet: UpdatePet(petRepository: petRepository),
      getPetsByOwner: GetPetsByOwner(petRepository: petRepository),
    );
  }

  final RegisterPet registerPet;
  final UpdatePet updatePet;
  final GetPetsByOwner getPetsByOwner;
}
