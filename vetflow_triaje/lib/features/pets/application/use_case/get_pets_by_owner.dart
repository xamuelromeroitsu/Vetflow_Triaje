/// Caso de uso: listar mascotas por dueño.
library;

import 'package:vetflow_triaje/shared/domain/result.dart';
import 'package:vetflow_triaje/features/pets/domain/model/pet.dart';
import 'package:vetflow_triaje/features/pets/domain/port/pet_repository.dart';

class GetPetsByOwner {
  const GetPetsByOwner({required this.petRepository});

  final PetRepository petRepository;

  Future<Result<List<Pet>>> call({required String ownerId}) async {
    return petRepository.findByOwnerId(ownerId);
  }
}
