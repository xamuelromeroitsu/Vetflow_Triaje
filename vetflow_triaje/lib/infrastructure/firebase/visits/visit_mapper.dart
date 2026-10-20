/// Códec entre documentos de Firestore (visits/{visitId}) y [Visit].
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vetflow_triaje/features/triage/domain/model/visit.dart';

class VisitMapper {
  const VisitMapper._();

  static Visit? fromMap(String id, Map<String, dynamic>? data) {
    if (data == null) return null;

    final petId = data['petId'];
    if (petId is! String) return null;

    return Visit(
      id: id,
      petId: petId,
      companyId: data['companyId'] is String ? data['companyId'] : null,
      redFlags: data['redFlags'] is Map ? data['redFlags'] : null,
      symptoms: data['symptoms'] is Map ? data['symptoms'] : null,
      vitals: data['vitals'] is Map ? data['vitals'] : null,
      photos: data['photos'] is List ? List<String>.from(data['photos']) : null,
      triage: data['triage'] is Map ? data['triage'] : null,
      status: data['status'] is String ? data['status'] : null,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  static Map<String, dynamic> toMap(Visit visit) => {
        'petId': visit.petId,
        if (visit.companyId != null) 'companyId': visit.companyId,
        if (visit.redFlags != null) 'redFlags': visit.redFlags,
        if (visit.symptoms != null) 'symptoms': visit.symptoms,
        if (visit.vitals != null) 'vitals': visit.vitals,
        if (visit.photos != null) 'photos': visit.photos,
        if (visit.triage != null) 'triage': visit.triage,
        if (visit.status != null) 'status': visit.status,
        if (visit.createdAt != null) 'createdAt': visit.createdAt,
        if (visit.updatedAt != null) 'updatedAt': visit.updatedAt,
      };
}
