/// Módulo de inyección de dependencias para mascotas.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vetflow_triaje/features/pets/application/use_case/register_pet.dart';
import 'package:vetflow_triaje/features/pets/application/use_case/update_pet.dart';
import 'package:vetflow_triaje/features/pets/domain/port/pet_repository.dart';
import 'package:vetflow_triaje/infrastructure/firebase/pets/firestore_pet_repository.dart';

class PetModule {
  const PetModule({
    required this.registerPet,
    required this.updatePet,
  });

  factory PetModule.create({FirebaseFirestore? firestore}) {
    final petRepository = FirestorePetRepository(firestore: firestore);
    return PetModule(
      registerPet: RegisterPet(petRepository: petRepository),
      updatePet: UpdatePet(petRepository: petRepository),
    );
  }

  final RegisterPet registerPet;
  final UpdatePet updatePet;
}
