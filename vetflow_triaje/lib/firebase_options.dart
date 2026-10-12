// Archivo de opciones de Firebase.
//
// Este andamiaje se creó a mano porque todavía no hay claves del proyecto.
// Cuando inicies sesión en la CLI, ejecuta `flutterfire configure` y este
// archivo se regenerará solo con los valores reales.
//
// Hasta entonces `Firebase.initializeApp` fallará en tiempo de ejecución:
// no intentes ejecutar la app contra la nube sin este paso.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions no está configurado para esta plataforma.',
        );
    }
  }

  // TODO(flutterfire-config): reemplazar por los valores reales con
  // `flutterfire configure`.
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'TODO',
    appId: 'TODO',
    messagingSenderId: 'TODO',
    projectId: 'TODO',
    storageBucket: 'TODO',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'TODO',
    appId: 'TODO',
    messagingSenderId: 'TODO',
    projectId: 'TODO',
    storageBucket: 'TODO',
    iosBundleId: 'TODO',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'TODO',
    appId: 'TODO',
    messagingSenderId: 'TODO',
    projectId: 'TODO',
    storageBucket: 'TODO',
    iosBundleId: 'TODO',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'TODO',
    appId: 'TODO',
    messagingSenderId: 'TODO',
    projectId: 'TODO',
    storageBucket: 'TODO',
  );
}
