/// Errores de dominio puros: sin dependencias de Flutter ni de Firebase.
library;

enum FieldErrorCode {
  missing,
  invalid,
  outOfRange,
}

class FieldError {
  const FieldError({
    required this.field,
    required this.code,
    this.message,
  });

  final String field;
  final FieldErrorCode code;
  final String? message;
}

class DomainError {
  const DomainError({
    required this.message,
    this.fields = const [],
  });

  final String message;
  final List<FieldError> fields;
}
