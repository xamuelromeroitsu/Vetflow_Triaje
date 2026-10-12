import 'package:flutter_test/flutter_test.dart';
import 'package:vetflow_triaje/core/result.dart';
import 'package:vetflow_triaje/features/owners/domain/owner.dart';
import 'package:vetflow_triaje/features/owners/domain/owner_validation.dart';

void main() {
  group('validateOwner', () {
    test('acepta nombre con teléfono', () {
      final result = validateOwner(
        id: 'uid-1',
        name: 'Ana Pérez',
        phone: '0412-1234567',
      );

      expect(result, isA<Ok<Owner>>());
    });

    test('exige el nombre', () {
      final result = validateOwner(id: 'uid-1', name: '  ');

      expect(result, isA<Failure<Owner>>());
      expect((result as Failure<Owner>).error.fields.single.field, 'name');
    });

    test('rechaza emails con formato inválido', () {
      final result = validateOwner(
        id: 'uid-1',
        name: 'Ana Pérez',
        email: 'ana@',
      );

      expect(result, isA<Failure<Owner>>());
      expect((result as Failure<Owner>).error.fields.single.field, 'email');
    });

    test('email vacío se guarda como null', () {
      final result = validateOwner(
        id: 'uid-1',
        name: 'Ana Pérez',
        email: '   ',
      );

      expect((result as Ok<Owner>).value.email, isNull);
    });
  });
}
