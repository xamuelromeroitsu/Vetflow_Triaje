/// Puerto (interfaz) del repositorio de mascotas.
library;

import 'package:vetflow_triaje/shared/domain/result.dart';
import 'package:vetflow_triaje/features/pets/domain/model/pet.dart';

abstract class PetRepository {
  Future<Result<Pet>> create(Pet pet);

  Future<Result<Pet?>> findById(String id);

  Future<Result<List<Pet>>> findByOwnerId(String ownerId);

  Future<Result<Pet>> update(Pet pet);
}
