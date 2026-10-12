/// Rol del usuario autenticado (email + contraseña).
///
/// El personal (recepción / veterinario) llega con las clínicas en Fase 4
/// (companies/staff); en el MVP el rol efectivo es [UserRole.dueno].
library;

enum UserRole {
  dueno,
  personal,
}

extension UserRoleX on UserRole {
  String get label => switch (this) {
        UserRole.dueno => 'Dueño',
        UserRole.personal => 'Personal',
      };

  String get storageValue => name;

  static UserRole fromStorage(String value) => switch (value) {
        'dueno' => UserRole.dueno,
        'personal' => UserRole.personal,
        _ => UserRole.dueno,
      };
}
