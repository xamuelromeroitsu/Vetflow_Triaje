/// Puerto transversal: escribe logs.
///
/// Permite que el dominio registre eventos sin depender de `print`
/// ni de un framework de logging concreto.
library;

abstract class Logger {
  const Logger();

  void info(String message);

  void warning(String message);

  void error(String message, [Object? error, StackTrace? stackTrace]);
}
