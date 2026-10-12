/// Adaptador de Firestore para [UserProfileRepository].
///
/// La colección `users` guarda el rol del usuario autenticado. Las reglas
/// impiden que un dueño se cambie el rol desde el cliente.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vetflow_triaje/core/errors.dart';
import 'package:vetflow_triaje/core/result.dart';
import 'package:vetflow_triaje/features/auth/data/user_profile_codec.dart';
import 'package:vetflow_triaje/features/auth/domain/user_profile.dart';
import 'package:vetflow_triaje/features/auth/domain/user_profile_repository.dart';

class UserProfileRepositoryFirestore implements UserProfileRepository {
  UserProfileRepositoryFirestore({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  @override
  Future<Result<UserProfile>> getByUid(String uid) async {
    try {
      final doc = await _users.doc(uid).get();
      final profile = UserProfileCodec.fromMap(uid, doc.data());
      if (profile == null) {
        return Result.failure(
          const DomainError(message: 'El perfil no existe'),
        );
      }
      return Result.ok(profile);
    } on FirebaseException catch (error) {
      return Result.failure(
        DomainError(
          message: 'No se pudo leer el perfil',
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
  Stream<UserProfile?> watchByUid(String uid) {
    return _users.doc(uid).snapshots().map(
          (doc) => UserProfileCodec.fromMap(uid, doc.data()),
        );
  }

  @override
  Future<Result<UserProfile>> create(UserProfile profile) async {
    try {
      await _users.doc(profile.uid).set(UserProfileCodec.toMap(profile));
      return Result.ok(profile);
    } on FirebaseException catch (error) {
      return Result.failure(
        DomainError(
          message: 'No se pudo guardar el perfil',
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
}
