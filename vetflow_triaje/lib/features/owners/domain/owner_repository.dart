/// Puerto (interfaz) del repositorio de dueños.
library;

import 'package:vetflow_triaje/core/result.dart';
import 'package:vetflow_triaje/features/owners/domain/owner.dart';

abstract class OwnerRepository {
  Future<Result<Owner>> create(Owner owner);

  Future<Result<Owner>> getById(String ownerId);

  Stream<Owner?> watchById(String ownerId);
}
