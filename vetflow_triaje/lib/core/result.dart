/// Resultado de una operación de dominio: éxito con valor, o fallo con error.
/// Permite que el dominio no dependa de excepciones ni de la UI.
library;

import 'package:vetflow_triaje/core/errors.dart';

sealed class Result<T> {
  const Result();

  factory Result.ok(T value) => Ok(value);

  factory Result.failure(DomainError error) => Failure(error);

  R when<R>({
    required R Function(T value) ok,
    required R Function(DomainError error) failure,
  }) {
    return switch (this) {
      Ok<T>(:final value) => ok(value),
      Failure<T>(:final error) => failure(error),
    };
  }
}

class Ok<T> extends Result<T> {
  const Ok(this.value);

  final T value;
}

class Failure<T> extends Result<T> {
  const Failure(this.error);

  final DomainError error;
}
