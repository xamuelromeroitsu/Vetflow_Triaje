/// Adaptador de Firebase Storage para fotos de mascota.
///
/// Sube imágenes a Firebase Storage con rutas alineadas con storage.rules:
/// `mascotas/{petId}/fotos/{fileName}`.
/// Máximo 5 MB, solo JPG/PNG.
library;

import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

class PetPhotoStorage {
  PetPhotoStorage({FirebaseStorage? storage}) : _storageOverride = storage;

  final FirebaseStorage? _storageOverride;

  FirebaseStorage get _storage => _storageOverride ?? FirebaseStorage.instance;

  /// Tamaño máximo permitido: 5 MB.
  static const int maxSizeBytes = 5 * 1024 * 1024;

  /// Sube una foto y devuelve la URL de descarga.
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

    final ref = _storage.ref().child('mascotas/$petId/fotos/$fileName');
    final metadata = SettableMetadata(contentType: contentType);
    final task = await ref.putData(bytes, metadata);
    return task.ref.getDownloadURL();
  }

  /// Elimina una foto.
  Future<void> deletePhoto(String path) async {
    await _storage.ref(path).delete();
  }
}
