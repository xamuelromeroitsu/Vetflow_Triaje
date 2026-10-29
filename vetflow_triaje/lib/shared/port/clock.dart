/// Puerto transversal: provee la fecha/hora actual.
///
/// El dominio no debe usar `DateTime.now()` directamente para mantener
/// los tests deterministas. Esta interfaz se implementa en la capa de
/// infraestructura o en la composición raíz.
library;

abstract class Clock {
  const Clock();

  DateTime now();
}
