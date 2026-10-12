/// Perfil de usuario en Firestore (users/{uid}).
///
/// Aquí vive el rol. El auto-registro solo puede crear `dueno`; el personal
/// se dará de alta por invitación en Fase 2 (docs/08-admin/sistema-admin.md),
/// pero el esquema ya lo contempla.
library;

import 'package:vetflow_triaje/features/auth/domain/model/user_role.dart';

class UserProfile {
  const UserProfile({
    required this.uid,
    required this.email,
    required this.role,
    this.ownerId,
    this.companyId,
    this.createdAt,
  });

  final String uid;
  final String email;
  final UserRole role;

  /// Documento de dueño asociado (owners/{ownerId}), si aplica.
  final String? ownerId;

  /// Clínica asociada (personal, Fase 4).
  final String? companyId;
  final DateTime? createdAt;
}
