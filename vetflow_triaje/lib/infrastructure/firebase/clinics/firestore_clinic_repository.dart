/// Adaptador de Firestore para [ClinicRepository].
///
/// Escribe y lee documentos en la colección `clinics/{clinicId}`.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vetflow_triaje/features/clinics/domain/model/clinic.dart';
import 'package:vetflow_triaje/features/clinics/domain/port/clinic_repository.dart';
import 'package:vetflow_triaje/shared/domain/errors.dart';
import 'package:vetflow_triaje/shared/domain/result.dart';

class FirestoreClinicRepository implements ClinicRepository {
  FirestoreClinicRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _clinics =>
      _firestore.collection('clinics');

  Clinic _docToClinic(String docId, Map<String, dynamic> data) {
    return Clinic(
      id: docId,
      name: data['name'] as String? ?? '',
      address: data['address'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      email: data['email'] as String?,
      specialties: (data['specialties'] as List<dynamic>?)
          ?.cast<String>()
          .toList() ??
          [],
      hours: (data['hours'] as Map<String, dynamic>?) ?? <String, dynamic>{},
      emergency24h: data['emergency24h'] as bool? ?? false,
      services: (data['services'] as List<dynamic>?)
          ?.cast<String>()
          .toList() ?? [],
      latitude: data['latitude'] is num
          ? (data['latitude'] as num).toDouble()
          : null,
      longitude: data['longitude'] is num
          ? (data['longitude'] as num).toDouble()
          : null,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  @override
  Future<Result<Clinic>> create(Clinic clinic) async {
    try {
      final docRef = _clinics.doc(clinic.id.isEmpty ? _generateId() : clinic.id);
      await docRef.set(_toMap(clinic));
      return Result.ok(clinic.copyWith(id: docRef.id));
    } on FirebaseException catch (error) {
      return Result.failure(
        DomainError(
          message: 'No se pudo crear la clínica',
          fields: [
            FieldError(
              field: 'firestore',
              code: FieldErrorCode.invalid,
              message: error.code,
            ),
          ],
        ),
      );
    }
  }

  @override
  Future<Result<Clinic?>> findById(String id) async {
    try {
      final doc = await _clinics.doc(id).get();
      if (!doc.exists) return Result.ok(null);
      return Result.ok(_docToClinic(doc.id, doc.data()!));
    } on FirebaseException catch (error) {
      return Result.failure(
        DomainError(
          message: 'No se pudo leer la clínica',
          fields: [
            FieldError(
              field: 'firestore',
              code: FieldErrorCode.invalid,
              message: error.code,
            ),
          ],
        ),
      );
    }
  }

  @override
  Future<Result<List<Clinic>>> listAll() async {
    try {
      final snapshot = await _clinics.get();
      final clinics = <Clinic>[];
      for (final doc in snapshot.docs) {
        clinics.add(_docToClinic(doc.id, doc.data()));
      }
      return Result.ok(clinics);
    } on FirebaseException catch (error) {
      return Result.failure(
        DomainError(
          message: 'No se pudieron listar las clínicas',
          fields: [
            FieldError(
              field: 'firestore',
              code: FieldErrorCode.invalid,
              message: error.code,
            ),
          ],
        ),
      );
    }
  }

  @override
  Future<Result<List<Clinic>>> listBySpecialties(List<String> specialties) async {
    try {
      // Firestore array-contains filtra documentos que contengan al menos un valor del array.
      // Para múltiples especialidades, consultamos por cada una y combinamos resultados.
      final found = <String, Clinic>{};
      for (final specialty in specialties) {
        final query = await _clinics
            .where('specialties', arrayContains: specialty)
            .get();
        for (final doc in query.docs) {
          found[doc.id] = _docToClinic(doc.id, doc.data());
        }
      }
      return Result.ok(found.values.toList());
    } on FirebaseException catch (error) {
      return Result.failure(
        DomainError(
          message: 'No se pudieron filtrar clínicas por especialidad',
          fields: [
            FieldError(
              field: 'firestore',
              code: FieldErrorCode.invalid,
              message: error.code,
            ),
          ],
        ),
      );
    }
  }

  @override
  Future<Result<List<Clinic>>> listEmergency24h() async {
    try {
      final query = await _clinics
          .where('emergency24h', isEqualTo: true)
          .get();
      final clinics = <Clinic>[];
      for (final doc in query.docs) {
        clinics.add(_docToClinic(doc.id, doc.data()));
      }
      return Result.ok(clinics);
    } on FirebaseException catch (error) {
      return Result.failure(
        DomainError(
          message: 'No se pudieron listar clínicas de emergencia 24h',
          fields: [
            FieldError(
              field: 'firestore',
              code: FieldErrorCode.invalid,
              message: error.code,
            ),
          ],
        ),
      );
    }
  }

  @override
  Future<Result<Clinic>> update(Clinic clinic) async {
    try {
      await _clinics.doc(clinic.id).update(_toMap(clinic));
      return Result.ok(clinic);
    } on FirebaseException catch (error) {
      return Result.failure(
        DomainError(
          message: 'No se pudo actualizar la clínica',
          fields: [
            FieldError(
              field: 'firestore',
              code: FieldErrorCode.invalid,
              message: error.code,
            ),
          ],
        ),
      );
    }
  }

  static Map<String, dynamic> _toMap(Clinic clinic) => {
        'name': clinic.name,
        'address': clinic.address,
        'phone': clinic.phone,
        if (clinic.email != null) 'email': clinic.email,
        'specialties': clinic.specialties,
        'hours': clinic.hours,
        'emergency24h': clinic.emergency24h,
        'services': clinic.services,
        if (clinic.latitude != null) 'latitude': clinic.latitude,
        if (clinic.longitude != null) 'longitude': clinic.longitude,
        if (clinic.createdAt != null) 'createdAt': clinic.createdAt,
        if (clinic.updatedAt != null) 'updatedAt': clinic.updatedAt,
      };

  String _generateId() =>
      DateTime.now().millisecondsSinceEpoch.toString();
}

/// Extensión para copiar una clínica con nuevo id.
extension ClinicCopy on Clinic {
  Clinic copyWith({String? id}) => Clinic(
        id: id ?? this.id,
        name: name,
        address: address,
        phone: phone,
        email: email,
        specialties: specialties,
        hours: hours,
        emergency24h: emergency24h,
        services: services,
        latitude: latitude,
        longitude: longitude,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
