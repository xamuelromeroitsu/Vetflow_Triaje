/// Validación de dueño en el móvil.
///
/// Espejo de la validación en firestore.rules. Ante la duda sobre el
/// identificador del dueño (teléfono vs cédula), no se inventa: email es
/// opcional y teléfono es texto libre.
library;

import 'package:vetflow_triaje/core/errors.dart';
import 'package:vetflow_triaje/core/result.dart';
import 'package:vetflow_triaje/features/owners/domain/owner.dart';

RegExp get _emailPattern => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

Result<Owner> validateOwner({
  required String id,
  required String name,
  String? phone,
  String? email,
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
  final trimmedEmail = email?.trim() ?? '';
  if (trimmedEmail.isNotEmpty && !_emailPattern.hasMatch(trimmedEmail)) {
    errors.add(
      const FieldError(
        field: 'email',
        code: FieldErrorCode.invalid,
        message: 'El email no parece válido',
      ),
    );
  }

  if (errors.isNotEmpty) {
    return Result.failure(
      DomainError(
        message: 'Revisa los campos del dueño',
        fields: errors,
      ),
    );
  }

  return Result.ok(
    Owner(
      id: id,
      name: name.trim(),
      phone: phone?.trim(),
      email: trimmedEmail.isEmpty ? null : trimmedEmail,
    ),
  );
}
