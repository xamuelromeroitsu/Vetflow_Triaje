import 'package:flutter_test/flutter_test.dart';
import 'package:vetflow_triaje/core/domain/species.dart';
import 'package:vetflow_triaje/core/errors.dart';
import 'package:vetflow_triaje/core/result.dart';
import 'package:vetflow_triaje/features/pets/domain/pet.dart';
import 'package:vetflow_triaje/features/pets/domain/pet_validation.dart';

void main() {
  group('validatePet', () {
    test('acepta una mascota completa', () {
      final result = validatePet(
        id: '',
        ownerId: 'uid-1',
        name: 'Luna',
        species: Species.perro,
        breed: 'Mestiza',
        ageMonths: 24,
      );

      expect(result, isA<Ok<Pet>>());
    });

    test('los campos obligatorios faltantes se reportan por campo', () {
      final result = validatePet(
        id: '',
        ownerId: '',
        name: '   ',
        species: null,
        breed: '',
        ageMonths: null,
      );

      expect(result, isA<Failure<Pet>>());
      final error = (result as Failure<Pet>).error;
      final fields = error.fields.map((f) => f.field).toSet();
      expect(fields, {'name', 'species', 'breed', 'ageMonths', 'ownerId'});
    });

    test('edad negativa es inválida', () {
      final result = validatePet(
        id: '',
        ownerId: 'uid-1',
        name: 'Luna',
        species: Species.gato,
        breed: 'Siamés',
        ageMonths: -1,
      );

      expect(result, isA<Failure<Pet>>());
      expect(
        (result as Failure<Pet>).error.fields.first.code,
        FieldErrorCode.invalid,
      );
    });

    test('recorta espacios en textos', () {
      final result = validatePet(
        id: '',
        ownerId: ' uid-1 ',
        name: '  Luna  ',
        species: Species.gato,
        breed: '  Siamés  ',
        ageMonths: 24,
      );

      final pet = (result as Ok<Pet>).value;
      expect(pet.name, 'Luna');
      expect(pet.breed, 'Siamés');
    });
  });
}
