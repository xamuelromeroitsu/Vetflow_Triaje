/// Caso de uso: registrar un dueño.
library;

import 'package:vetflow_triaje/shared/domain/errors.dart';
import 'package:vetflow_triaje/shared/domain/result.dart';
import 'package:vetflow_triaje/features/owners/domain/model/owner.dart';
import 'package:vetflow_triaje/features/owners/domain/validation/owner_validation.dart';
import 'package:vetflow_triaje/features/owners/domain/port/owner_repository.dart';

class RegisterOwner {
  const RegisterOwner({required this.ownerRepository});

  final OwnerRepository ownerRepository;

  Future<Result<Owner>> call({
    required String name,
    required String phone,
    String? email,
    required String ownerId,
  }) async {
    final validated = validateOwner(
      name: name,
      phone: phone,
      email: email,
      ownerId: ownerId,
    );
    final owner = validated.valueOrNull;
    if (owner == null) {
      return Result.failure(
        validated.errorOrNull ??
            const DomainError(message: 'Revisa los datos del dueño'),
      );
    }

    return ownerRepository.create(owner);
  }
}
