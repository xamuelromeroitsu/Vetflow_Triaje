import 'package:flutter_test/flutter_test.dart';
import 'package:vetflow_triaje/app/di/app_dependencies.dart';
import 'package:vetflow_triaje/shared/domain/result.dart';

void main() {
  group('demo local mode', () {
    test(
      'debe permitir autenticación y registro de mascota sin backend remoto',
      () async {
        final deps = AppDependencies.create(demoMode: true);

        final authResult = await deps.authModule.signInWithEmail(
          email: 'demo@vetflow.local',
          password: 'demo1234',
        );

        expect(authResult.valueOrNull, isNotNull);
        expect(authResult.valueOrNull?.email, 'demo@vetflow.local');

        final petResult = await deps.petModule.registerPet(
          name: 'Luna',
          species: 'perro',
          breed: 'Mestizo',
          ageMonths: 18,
          ownerId: authResult.valueOrNull!.uid,
          sex: 'Hembra',
          neutered: true,
          weightKg: 12.5,
          history: 'Sin antecedentes relevantes',
          allergies: 'Ninguna',
        );

        expect(petResult.valueOrNull, isNotNull);
        expect(petResult.valueOrNull?.name, 'Luna');
      },
    );
  });
}
