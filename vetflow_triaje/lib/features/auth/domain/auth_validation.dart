/// Validación de credenciales en el móvil.
///
/// Firebase Auth exige contraseñas de 6 caracteres o más; es una restricción
/// de plataforma, no una regla clínica.
library;

import 'package:vetflow_triaje/core/errors.dart';
import 'package:vetflow_triaje/core/result.dart';
import 'package:vetflow_triaje/features/auth/domain/credentials.dart';

RegExp get _emailPattern => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

Result<Credentials> validateCredentials({
  required String email,
  required String password,
}) {
  final errors = <FieldError>[];
  final trimmedEmail = email.trim();

  if (trimmedEmail.isEmpty) {
    errors.add(
      const FieldError(
        field: 'email',
        code: FieldErrorCode.missing,
        message: 'El email es obligatorio',
      ),
    );
  } else if (!_emailPattern.hasMatch(trimmedEmail)) {
    errors.add(
      const FieldError(
        field: 'email',
        code: FieldErrorCode.invalid,
        message: 'El email no parece válido',
      ),
    );
  }

  if (password.length < 6) {
    errors.add(
      const FieldError(
        field: 'password',
        code: FieldErrorCode.invalid,
        message: 'La contraseña debe tener al menos 6 caracteres',
      ),
    );
  }

  if (errors.isNotEmpty) {
    return Result.failure(
      DomainError(
        message: 'Revisa el email y la contraseña',
        fields: errors,
      ),
    );
  }

  return Result.ok(Credentials(email: trimmedEmail, password: password));
}
