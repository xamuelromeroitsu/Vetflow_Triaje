/// Validación de datos de mascota en el móvil.
///
/// Las especies válidas son las 7 del MVP definidas en ADR-0005:
/// perro, gato, hurón, conejo, ave, roedor, reptil.
library;

import 'package:vetflow_triaje/shared/domain/errors.dart';
import 'package:vetflow_triaje/shared/domain/result.dart';
import 'package:vetflow_triaje/features/pets/domain/model/pet.dart';

const List<String> _validSpecies = [
  'perro',
  'gato',
  'huron',
  'conejo',
  'ave',
  'roedor',
  'reptil',
];

Result<Pet> validatePet({
  required String name,
  required String species,
  required String breed,
  required int ageMonths,
  required String ownerId,
  String? sex,
  bool? neutered,
  double? weightKg,
  String? history,
  String? allergies,
}) {
  final errors = <FieldError>[];
  final trimmedName = name.trim();
  final trimmedSpecies = species.trim().toLowerCase();
  final trimmedBreed = breed.trim();

  if (trimmedName.isEmpty) {
    errors.add(
      const FieldError(
        field: 'name',
        code: FieldErrorCode.missing,
        message: 'El nombre es obligatorio',
      ),
    );
  }

  if (trimmedSpecies.isEmpty) {
    errors.add(
      const FieldError(
        field: 'species',
        code: FieldErrorCode.missing,
        message: 'La especie es obligatoria',
      ),
    );
  } else if (!_validSpecies.contains(trimmedSpecies)) {
    errors.add(
      FieldError(
        field: 'species',
        code: FieldErrorCode.invalid,
        message: 'Especie no válida para el MVP',
      ),
    );
  }

  if (trimmedBreed.isEmpty) {
    errors.add(
      const FieldError(
        field: 'breed',
        code: FieldErrorCode.missing,
        message: 'La raza es obligatoria',
      ),
    );
  }

  if (ageMonths < 0) {
    errors.add(
      const FieldError(
        field: 'ageMonths',
        code: FieldErrorCode.outOfRange,
        message: 'La edad en meses no puede ser negativa',
      ),
    );
  }

  if (weightKg != null && weightKg! <= 0) {
    errors.add(
      const FieldError(
        field: 'weightKg',
        code: FieldErrorCode.outOfRange,
        message: 'El peso debe ser mayor a 0 kg',
      ),
    );
  }

  if (ownerId.isEmpty) {
    errors.add(
      const FieldError(
        field: 'ownerId',
        code: FieldErrorCode.missing,
        message: 'El ID del dueño es obligatorio',
      ),
    );
  }

  if (errors.isNotEmpty) {
    return Result.failure(
      DomainError(
        message: 'Revisa los datos de la mascota',
        fields: errors,
      ),
    );
  }

  return Result.ok(
    Pet(
      id: '',
      ownerId: ownerId,
      name: trimmedName,
      species: trimmedSpecies,
      breed: trimmedBreed,
      ageMonths: ageMonths,
      sex: sex?.trim().isNotEmpty == true ? sex : null,
      neutered: neutered,
      weightKg: weightKg,
      history: history?.trim().isNotEmpty == true ? history : null,
      allergies: allergies?.trim().isNotEmpty == true ? allergies : null,
    ),
  );
}
