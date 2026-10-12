/// Dueño de la mascota (docs/05-arquitectura/modelo-de-datos.md).
library;

class Owner {
  const Owner({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.createdAt,
  });

  final String id;
  final String name;

  /// Identificador posible del dueño. Falta decidir entre teléfono o cédula
  /// (docs/07-gestion/preguntas-pendientes.md, pregunta 4).
  final String? phone;
  final String? email;
  final DateTime? createdAt;
}
