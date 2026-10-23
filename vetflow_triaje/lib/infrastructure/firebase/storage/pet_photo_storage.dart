/// Adaptador de Firebase Storage para fotos de mascota.
///
/// Sube imágenes a Firebase Storage con rutas alineadas con storage.rules:
/// `mascotas/{petId}/fotos/{fileName}`.
/// Máximo 5 MB, solo JPG/PNG.
library;

import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

class PetPhotoStorage {
  PetPhotoStorage({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  /// Tamaño máximo permitido: 5 MB.
  static const int maxSizeBytes = 5 * 1024 * 1024;

  /// Sube una foto y devuelve la URL de descarga.
  ///
    [petId] es el ID de la mascota. [fileName] es el nombre del archivo.
    [bytes] son los datos de la imagen. [contentType] debe ser image/jpeg o
    image/png.
  Future<String> uploadPhoto({
    required String petId,
    required String fileName,
    required Uint8List bytes,
    required String contentType,
  }) async {
    if (contentType != 'image/jpeg' && contentType != 'image/png') {
      throw ArgumentError('Solo se permiten imágenes JPG y PNG');
    }

    if (bytes.lengthInBytes > maxSizeBytes) {
      throw ArgumentError(
        'La imagen supera los 5 MB. Tamaño: ${(bytes.lengthInBytes / (1024 * 1024)).toStringAsFixed(2)} MB',
      );
    }

    final path = 'mascotas/$petId/fotos/$fileName';
    final ref = _storage.ref().child(path);
    await ref.putData(bytes, SettableMetadata(contentType: contentType));
    return ref.getDownloadURL();
  }

  /// Elimina una foto de Storage.
  Future<void> deletePhoto({required String petId, required String fileName}) async {
    final path = 'mascotas/$petId/fotos/$fileName';
    await _storage.ref().child(path).delete();
  }
}
