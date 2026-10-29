/// Módulo de inyección de dependencias para mascotas.
library;

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vetflow_triaje/features/pets/application/use_case/get_pets_by_owner.dart';
import 'package:vetflow_triaje/features/pets/application/use_case/register_pet.dart';
import 'package:vetflow_triaje/features/pets/application/use_case/update_pet.dart';
import 'package:vetflow_triaje/infrastructure/demo/demo_repositories.dart';
import 'package:vetflow_triaje/infrastructure/supabase/supabase_repositories.dart';

class PetModule {
  const PetModule({
    required this.registerPet,
    required this.updatePet,
    required this.getPetsByOwner,
  });

  factory PetModule.create({SupabaseClient? client, bool demoMode = true}) {
    final petRepository = demoMode
        ? DemoPetRepository()
        : SupabasePetRepository(client: client);
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
