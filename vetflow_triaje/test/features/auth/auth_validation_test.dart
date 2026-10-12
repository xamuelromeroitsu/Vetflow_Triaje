import 'package:flutter_test/flutter_test.dart';
import 'package:vetflow_triaje/core/result.dart';
import 'package:vetflow_triaje/features/auth/domain/auth_validation.dart';
import 'package:vetflow_triaje/features/auth/domain/credentials.dart';

void main() {
  group('validateCredentials', () {
    test('acepta email y contraseña válidos', () {
      final result = validateCredentials(
        email: 'ana@ejemplo.com',
        password: 'secreto123',
      );

      expect(result, isA<Ok<Credentials>>());
      expect((result as Ok<Credentials>).value.email, 'ana@ejemplo.com');
    });

    test('falta email', () {
      final result = validateCredentials(email: '', password: 'secreto123');

      expect(result, isA<Failure<Credentials>>());
      final fields = (result as Failure<Credentials>).error.fields;
      expect(fields.single.field, 'email');
    });

    test('contraseña corta (mínimo de Firebase Auth: 6)', () {
      final result = validateCredentials(
        email: 'ana@ejemplo.com',
        password: '12345',
      );

      expect(result, isA<Failure<Credentials>>());
      expect(
        (result as Failure<Credentials>).error.fields.single.field,
        'password',
      );
    });
  });
}
