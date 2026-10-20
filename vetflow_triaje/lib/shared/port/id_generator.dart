/// Puerto transversal: genera identificadores únicos.
///
/// El dominio no debe depender de una librería concreta de UUIDs para
/// mantenerse independiente del entorno. Esta interfaz se implementa
/// en la capa de infraestructura o en la composición raíz.
library;

abstract class IdGenerator {
  const IdGenerator();

  String generate();
}
