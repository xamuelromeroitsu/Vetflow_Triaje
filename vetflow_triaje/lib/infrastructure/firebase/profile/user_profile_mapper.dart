/// Códec entre documentos de Firestore (users/{uid}) y [UserProfile].
///
/// Espejo de firestore.rules: si el rol no es conocido o los tipos no cuadran,
/// el documento se descarta.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vetflow_triaje/features/auth/domain/model/user_profile.dart';
import 'package:vetflow_triaje/features/auth/domain/model/user_role.dart';

class UserProfileMapper {
  const UserProfileMapper._();

  static UserProfile? fromMap(String uid, Object? data) {
    if (data is! Map<String, Object?>) return null;
    final map = data;

    final email = map['email'];
    final roleValue = map['role'];
    if (email is! String || roleValue is! String) return null;

    final role = switch (roleValue) {
      'dueno' => UserRole.dueno,
      'personal' => UserRole.personal,
      _ => null,
    };
    if (role == null) return null;

    final ownerId = map['ownerId'];
    final companyId = map['companyId'];
    final createdAt = map['createdAt'];
    if ((ownerId != null && ownerId is! String) ||
        (companyId != null && companyId is! String) ||
        (createdAt != null && createdAt is! Timestamp)) {
      return null;
    }

    return UserProfile(
      uid: uid,
      email: email,
      role: role,
      ownerId: ownerId as String?,
      companyId: companyId as String?,
      createdAt: (createdAt as Timestamp?)?.toDate(),
    );
  }

  static Map<String, Object?> toMap(UserProfile profile) => {
        'email': profile.email,
        'role': profile.role.storageValue,
        'ownerId': profile.ownerId,
        'companyId': profile.companyId,
      };
}
