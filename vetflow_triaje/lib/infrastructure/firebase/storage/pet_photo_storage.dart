/// Adaptador de Firebase Storage para fotos de mascota.
///
/// Sube imágenes a Firebase Storage con rutas por usuario.
/// Máximo 5 MB, solo JPG/PNG.
library;

import 'package:firebase_storage/firebase_storage.dart';

class PetPhotoStorage {
  PetPhotoStorage({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  /// Sube una foto y devuelve la URL de descarga.
  ///
  /// [path] debe ser una ruta única dentro del bucket (ej.
  /// `pets/{ownerId}/{petId}/{fileName}`).
  Future<String> uploadPhoto({
    required String path,
    required List<int> bytes,
    required String contentType,
  }) async {
    if (contentType != 'image/jpeg' && contentType != 'image/png') {
      throw ArgumentError('Solo se permiten imágenes JPG y PNG');
    }

    final ref = _storage.ref().child(path);
    await ref.putData(bytes, SettableMetadata(contentType: contentType));
    return ref.getDownloadURL();
  }

  /// Elimina una foto de Storage.
  Future<void> deletePhoto({required String path}) async {
    await _storage.ref().child(path).delete();
  }
}
