/// Puerto (interfaz) del repositorio de mascotas.
///
/// El dominio solo conoce esta abstracción; el adaptador de Firestore vive en
/// la capa de datos y se inyecta desde fuera.
library;

import 'package:vetflow_triaje/core/result.dart';
import 'package:vetflow_triaje/features/pets/domain/pet.dart';

abstract class PetRepository {
  Future<Result<Pet>> create(Pet pet);

  Future<Result<Pet>> getById(String petId);

  Future<Result<List<Pet>>> byOwner(String ownerId);

  /// Flujo en tiempo real con persistencia offline de Firestore.
  Stream<List<Pet>> watchByOwner(String ownerId);
}
