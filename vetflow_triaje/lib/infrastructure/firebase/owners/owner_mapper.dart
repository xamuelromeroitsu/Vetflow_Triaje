/// Códec entre documentos de Firestore (owners/{ownerId}) y [Owner].
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vetflow_triaje/features/owners/domain/model/owner.dart';

class OwnerMapper {
  const OwnerMapper._();

  static Owner? fromMap(String id, Map<String, dynamic>? data) {
    if (data == null) return null;

    final name = data['name'];
    final phone = data['phone'];
    final ownerId = data['ownerId'];
    if (name is! String || phone is! String || ownerId is! String) {
      return null;
    }

    return Owner(
      id: id,
      name: name,
      phone: phone,
      email: data['email'] is String ? data['email'] : null,
      ownerId: ownerId,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  static Map<String, dynamic> toMap(Owner owner) => {
        'name': owner.name,
        'phone': owner.phone,
        if (owner.email != null) 'email': owner.email,
        'ownerId': owner.ownerId,
        if (owner.createdAt != null) 'createdAt': owner.createdAt,
        if (owner.updatedAt != null) 'updatedAt': owner.updatedAt,
      };
}
