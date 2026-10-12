/// Códec entre documentos de Firestore y [Owner].
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vetflow_triaje/features/owners/domain/owner.dart';

class OwnerCodec {
  const OwnerCodec._();

  static Owner? fromMap(String id, Object? data) {
    if (data is! Map<String, Object?>) return null;
    final map = data;

    final name = map['name'];
    final phone = map['phone'];
    final email = map['email'];
    final createdAt = map['createdAt'];
    if (name is! String ||
        (phone != null && phone is! String) ||
        (email != null && email is! String) ||
        (createdAt != null && createdAt is! Timestamp)) {
      return null;
    }

    return Owner(
      id: id,
      name: name,
      phone: phone as String?,
      email: email as String?,
      createdAt: (createdAt as Timestamp?)?.toDate(),
    );
  }

  static Map<String, Object?> toMap(Owner owner) => {
        'name': owner.name,
        'phone': owner.phone,
        'email': owner.email,
        'createdAt':
            Timestamp.fromDate(owner.createdAt ?? DateTime.now()),
      };
}
