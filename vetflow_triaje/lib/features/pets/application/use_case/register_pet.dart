/// Caso de uso: registrar una mascota.
library;

import 'package:vetflow_triaje/shared/domain/errors.dart';
import 'package:vetflow_triaje/shared/domain/result.dart';
import 'package:vetflow_triaje/features/pets/domain/model/pet.dart';
import 'package:vetflow_triaje/features/pets/domain/validation/pet_validation.dart';
import 'package:vetflow_triaje/features/pets/domain/port/pet_repository.dart';

class RegisterPet {
  const RegisterPet({required this.petRepository});

  final PetRepository petRepository;

  Future<Result<Pet>> call({
    required String name,
    required String species,
    required String breed,
    required int ageMonths,
    required String ownerId,
    String? sex,
    bool? neutered,
    String? history,
    String? allergies,
  }) async {
    final validated = validatePet(
      name: name,
      species: species,
      breed: breed,
      ageMonths: ageMonths,
      ownerId: ownerId,
      sex: sex,
      neutered: neutered,
      history: history,
      allergies: allergies,
    );
    final pet = validated.valueOrNull;
    if (pet == null) {
      return Result.failure(
        validated.errorOrNull ??
            const DomainError(message: 'Revisa los datos de la mascota'),
      );
    }

    return petRepository.create(pet);
  }
}
