/// Validación de mascota en el móvil (US-01).
///
/// Debe validar lo mismo que las reglas de Firestore
/// (vetflow_triaje/firestore.rules): obligatorios y tipos.
library;

import 'package:vetflow_triaje/core/domain/species.dart';
import 'package:vetflow_triaje/core/errors.dart';
import 'package:vetflow_triaje/core/result.dart';
import 'package:vetflow_triaje/features/pets/domain/pet.dart';

/// Valida los campos y devuelve la mascota construida, o el error por campo.
Result<Pet> validatePet({
  required String id,
  required String ownerId,
  required String name,
  required Species? species,
  required String breed,
  required int? ageMonths,
  String? sex,
  bool? neutered,
  String? history,
  String? allergies,
}) {
  final errors = <FieldError>[];

  if (name.trim().isEmpty) {
    errors.add(
      const FieldError(
        field: 'name',
        code: FieldErrorCode.missing,
        message: 'El nombre es obligatorio',
      ),
    );
  }
  if (species == null) {
    errors.add(
      const FieldError(
        field: 'species',
        code: FieldErrorCode.missing,
        message: 'La especie es obligatoria',
      ),
    );
  }
  if (breed.trim().isEmpty) {
    errors.add(
      const FieldError(
        field: 'breed',
        code: FieldErrorCode.missing,
        message: 'La raza es obligatoria',
      ),
    );
  }
  if (ageMonths == null) {
    errors.add(
      const FieldError(
        field: 'ageMonths',
        code: FieldErrorCode.missing,
        message: 'La edad es obligatoria',
      ),
    );
  } else if (ageMonths < 0) {
    errors.add(
      const FieldError(
        field: 'ageMonths',
        code: FieldErrorCode.invalid,
        message: 'La edad no puede ser negativa',
      ),
    );
  }
  if (ownerId.trim().isEmpty) {
    errors.add(
      const FieldError(
        field: 'ownerId',
        code: FieldErrorCode.missing,
        message: 'Falta el dueño de la mascota',
      ),
    );
  }

  if (errors.isNotEmpty || species == null || ageMonths == null) {
    return Result.failure(
      DomainError(
        message: 'Revisa los campos de la mascota',
        fields: errors,
      ),
    );
  }

  return Result.ok(
    Pet(
      id: id,
      ownerId: ownerId,
      name: name.trim(),
      species: species,
      breed: breed.trim(),
      ageMonths: ageMonths,
      sex: sex,
      neutered: neutered,
      history: history,
      allergies: allergies,
    ),
  );
}
