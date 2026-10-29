import 'package:flutter_test/flutter_test.dart';
import 'package:vetflow_triaje/features/pets/application/use_case/register_pet.dart';
import 'package:vetflow_triaje/features/pets/domain/model/pet.dart';
import 'package:vetflow_triaje/features/pets/domain/port/pet_repository.dart';
import 'package:vetflow_triaje/shared/domain/result.dart';

void main() {
  group('RegisterPet', () {
    test('persists validated pet data for the authenticated owner', () async {
      final repository = _RecordingPetRepository();
      final useCase = RegisterPet(petRepository: repository);

      final result = await useCase(
        name: ' Luna ',
        species: 'perro',
        breed: ' Mestiza ',
        ageMonths: 18,
        ownerId: 'authenticated-user-id',
      );

      expect(result.valueOrNull, isNotNull);
      expect(repository.createdPet?.name, 'Luna');
      expect(repository.createdPet?.breed, 'Mestiza');
      expect(repository.createdPet?.ownerId, 'authenticated-user-id');
      expect(repository.createCalls, 1);
    });

    test('does not persist pet data without an owner id', () async {
      final repository = _RecordingPetRepository();
      final useCase = RegisterPet(petRepository: repository);

      final result = await useCase(
        name: 'Luna',
        species: 'perro',
        breed: 'Mestiza',
        ageMonths: 18,
        ownerId: '',
      );

      expect(result.valueOrNull, isNull);
      expect(result.errorOrNull, isNotNull);
      expect(repository.createCalls, 0);
    });
  });
}

class _RecordingPetRepository implements PetRepository {
  Pet? createdPet;
  int createCalls = 0;

  @override
  Future<Result<Pet>> create(Pet pet) async {
    createCalls++;
    createdPet = pet;
    return Result.ok(pet);
  }

  @override
  Future<Result<Pet?>> findById(String id) async => Result.ok(null);

  @override
  Future<Result<List<Pet>>> findByOwnerId(String ownerId) async =>
      Result.ok(const []);

  @override
  Future<Result<Pet>> update(Pet pet) async => Result.ok(pet);
}
