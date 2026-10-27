/// Entidad de dominio: dueño de mascota.
///
/// Un dueño está vinculado a un usuario autenticado
/// mediante `ownerId` (que coincide con `auth.uid` en el MVP).
library;

class Owner {
  const Owner({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.ownerId,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String phone;
  final String? email;

  /// ID del usuario autenticado. En el MVP coincide
  /// con el ID del documento de dueño.
  final String ownerId;

  final DateTime? createdAt;
  final DateTime? updatedAt;
}
