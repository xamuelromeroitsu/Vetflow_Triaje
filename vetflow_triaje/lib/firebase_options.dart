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
    apiKey: 'AIzaSyBqRkGgAwx2TddjPggFPxisMVjEHkrdxd8',
    appId: '1:722035172290:android:ab78b043813cf2187b6c5b',
    messagingSenderId: '722035172290',
    projectId: 'vetflow-triaje-firebase',
    storageBucket: 'vetflow-triaje-firebase.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC-_kbRQuGHjp5wq7ngFAOlwnPUpMY4Fa8',
    appId: '1:722035172290:ios:53245dce821e924d7b6c5b',
    messagingSenderId: '722035172290',
    projectId: 'vetflow-triaje-firebase',
    storageBucket: 'vetflow-triaje-firebase.firebasestorage.app',
    iosBundleId: 'com.example.vetflowTriaje',
  );
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC-_kbRQuGHjp5wq7ngFAOlwnPUpMY4Fa8',
    appId: '1:722035172290:ios:53245dce821e924d7b6c5b',
    messagingSenderId: '722035172290',
    projectId: 'vetflow-triaje-firebase',
    storageBucket: 'vetflow-triaje-firebase.firebasestorage.app',
    iosBundleId: 'com.example.vetflowTriaje',
  );
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD7N5TZU3nlpk1MBpphXFfd9dL4xDsVi9o',
    appId: '1:722035172290:web:3e68d85e8dfa77d57b6c5b',
    messagingSenderId: '722035172290',
    projectId: 'vetflow-triaje-firebase',
    authDomain: 'vetflow-triaje-firebase.firebaseapp.com',
    storageBucket: 'vetflow-triaje-firebase.firebasestorage.app',
    measurementId: 'G-Q8N5N6YE4T',
  );
}
