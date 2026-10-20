/// Caso de uso: actualizar un dueño existente.
library;

import 'package:vetflow_triaje/shared/domain/errors.dart';
import 'package:vetflow_triaje/shared/domain/result.dart';
import 'package:vetflow_triaje/features/owners/domain/model/owner.dart';
import 'package:vetflow_triaje/features/owners/domain/port/owner_repository.dart';

class UpdateOwner {
  const UpdateOwner({required this.ownerRepository});

  final OwnerRepository ownerRepository;

  Future<Result<Owner>> call({
    required String id,
    String? name,
    String? phone,
    String? email,
  }) async {
    final existing = await ownerRepository.findById(id);
    final current = existing.valueOrNull;
    if (current == null) {
      return Result.failure(
        const DomainError(message: 'Dueño no encontrado'),
      );
    }

    final updated = Owner(
      id: current.id,
      name: name ?? current.name,
      phone: phone ?? current.phone,
      email: email ?? current.email,
      ownerId: current.ownerId,
      createdAt: current.createdAt,
      updatedAt: DateTime.now(),
    );

    return ownerRepository.update(updated);
  }
}
