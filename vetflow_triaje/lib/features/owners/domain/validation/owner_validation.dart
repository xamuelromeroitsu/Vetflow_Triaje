/// Validación de datos de dueño en el móvil.
library;

import 'package:vetflow_triaje/shared/domain/errors.dart';
import 'package:vetflow_triaje/shared/domain/result.dart';
import 'package:vetflow_triaje/features/owners/domain/model/owner.dart';

RegExp get _phonePattern => RegExp(r'^\+?[\d\s\-\(\)]{7,}$');

RegExp get _emailPattern => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

Result<Owner> validateOwner({
  required String name,
  required String phone,
  String? email,
  required String ownerId,
}) {
  final errors = <FieldError>[];
  final trimmedName = name.trim();
  final trimmedPhone = phone.trim();

  if (trimmedName.isEmpty) {
    errors.add(
      const FieldError(
        field: 'name',
        code: FieldErrorCode.missing,
        message: 'El nombre es obligatorio',
      ),
    );
  }

  if (trimmedPhone.isEmpty) {
    errors.add(
      const FieldError(
        field: 'phone',
        code: FieldErrorCode.missing,
        message: 'El teléfono es obligatorio',
      ),
    );
  } else if (!_phonePattern.hasMatch(trimmedPhone)) {
    errors.add(
      const FieldError(
        field: 'phone',
        code: FieldErrorCode.invalid,
        message: 'El teléfono no parece válido',
      ),
    );
  }

  if (email != null && email.isNotEmpty && !_emailPattern.hasMatch(email.trim())) {
    errors.add(
      const FieldError(
        field: 'email',
        code: FieldErrorCode.invalid,
        message: 'El email no parece válido',
      ),
    );
  }

  if (ownerId.isEmpty) {
    errors.add(
      const FieldError(
        field: 'ownerId',
        code: FieldErrorCode.missing,
        message: 'El ID del dueño es obligatorio',
      ),
    );
  }

  if (errors.isNotEmpty) {
    return Result.failure(
      DomainError(
        message: 'Revisa los datos del dueño',
        fields: errors,
      ),
    );
  }

  return Result.ok(
    Owner(
      id: '',
      name: trimmedName,
      phone: trimmedPhone,
      email: email?.trim().isNotEmpty == true ? email.trim() : null,
      ownerId: ownerId,
    ),
  );
}
