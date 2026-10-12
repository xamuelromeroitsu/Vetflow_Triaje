/// Errores de dominio puros: sin dependencias de Flutter ni de Firebase.
library;

/// Motivo por el que un campo no es válido.
enum FieldErrorCode {
  missing,
  invalid,
  outOfRange,
}

/// Error asociado a un campo concreto de un formulario o documento.
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

/// Error de dominio. Puede agrupar varios campos inválidos.
class DomainError {
  const DomainError({
    required this.message,
    this.fields = const [],
  });

  final String message;
  final List<FieldError> fields;
}
