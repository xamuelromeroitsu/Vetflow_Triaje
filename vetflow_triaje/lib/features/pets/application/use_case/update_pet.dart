/// Caso de uso: actualizar una mascota existente.
library;

import 'package:vetflow_triaje/shared/domain/errors.dart';
import 'package:vetflow_triaje/shared/domain/result.dart';
import 'package:vetflow_triaje/features/pets/domain/model/pet.dart';
import 'package:vetflow_triaje/features/pets/domain/port/pet_repository.dart';

class UpdatePet {
  const UpdatePet({required this.petRepository});

  final PetRepository petRepository;

  Future<Result<Pet>> call({
    required String id,
    String? name,
    String? species,
    String? breed,
    int? ageMonths,
    String? sex,
    bool? neutered,
    String? history,
    String? allergies,
  }) async {
    final existing = await petRepository.findById(id);
    final current = existing.valueOrNull;
    if (current == null) {
      return Result.failure(
        const DomainError(message: 'Mascota no encontrada'),
      );
    }

    final updated = Pet(
      id: current.id,
      ownerId: current.ownerId,
      name: name ?? current.name,
      species: species ?? current.species,
      breed: breed ?? current.breed,
      ageMonths: ageMonths ?? current.ageMonths,
      sex: sex ?? current.sex,
      neutered: neutered ?? current.neutered,
      history: history ?? current.history,
      allergies: allergies ?? current.allergies,
      createdAt: current.createdAt,
      updatedAt: DateTime.now(),
    );

    return petRepository.update(updated);
  }
}
