/// Usuario autenticado de la app.
library;

import 'package:vetflow_triaje/features/auth/domain/model/user_role.dart';

class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    required this.role,
    this.ownerId,
    this.companyId,
  });

  final String uid;
  final String email;
  final UserRole role;

  /// Documento de dueño asociado (owners/{ownerId}), si aplica.
  final String? ownerId;

  /// Clínica asociada (Fase 4).
  final String? companyId;
}
