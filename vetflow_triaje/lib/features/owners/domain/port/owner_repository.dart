/// Puerto (interfaz) del repositorio de dueños.
///
/// El dominio define el contrato; los adaptadores de infraestructura
/// (Firestore, en pruebas, etc.) lo implementan.
library;

import 'package:vetflow_triaje/shared/domain/result.dart';
import 'package:vetflow_triaje/features/owners/domain/model/owner.dart';

abstract class OwnerRepository {
  Future<Result<Owner>> create(Owner owner);

  Future<Result<Owner?>> findById(String id);

  Future<Result<Owner?>> findByPhone(String phone);

  Future<Result<Owner>> update(Owner owner);
}
