/// Caso de uso: obtener el perfil de dueño asociado a una cuenta.
library;

import 'package:vetflow_triaje/features/owners/domain/model/owner.dart';
import 'package:vetflow_triaje/features/owners/domain/port/owner_repository.dart';
import 'package:vetflow_triaje/shared/domain/result.dart';

class GetOwnerById {
  const GetOwnerById({required this.ownerRepository});

  final OwnerRepository ownerRepository;

  Future<Result<Owner?>> call({required String id}) {
    return ownerRepository.findById(id);
  }
}
