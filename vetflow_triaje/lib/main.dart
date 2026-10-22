import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'app/app.dart';
import 'app/di/app_dependencies.dart';

final AppDependencies appDependencies = AppDependencies.create();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialización de Firebase (Auth, Firestore, Storage).
  //
  // Las opciones reales las genera `flutterfire configure` sobre
  // lib/firebase_options.dart. Hasta que eso pase, la app arranca igual en el
  // emulador y el inicio de sesión queda desactivado (se avisa por consola).
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Persistencia offline de Firestore: permite capturar mascotas,
    // síntomas y signos vitales sin conexión y reenviar al volver.
    await FirebaseFirestore.instance.setSettings(
      const Settings(
        persistenceEnabled: true,
      ),
    );
  } catch (error) {
    debugPrint(
      'Firebase no inicializado: ejecuta `flutterfire configure`. ($error)',
    );
  }

  runApp(const VetFlowApp());
}
