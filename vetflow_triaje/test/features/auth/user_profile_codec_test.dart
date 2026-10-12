import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vetflow_triaje/features/auth/data/user_profile_codec.dart';
import 'package:vetflow_triaje/features/auth/domain/user_profile.dart';
import 'package:vetflow_triaje/features/auth/domain/user_role.dart';

void main() {
  group('UserProfileCodec', () {
    test('roundtrip dueño', () {
      const profile = UserProfile(
        uid: 'uid-1',
        email: 'ana@ejemplo.com',
        role: UserRole.dueno,
        ownerId: 'uid-1',
      );

      final map = UserProfileCodec.toMap(profile);
      final decoded = UserProfileCodec.fromMap(profile.uid, map);

      expect(decoded, isNotNull);
      expect(decoded!.role, UserRole.dueno);
      expect(decoded.email, 'ana@ejemplo.com');
      expect(decoded.ownerId, 'uid-1');
    });

    test('acepta personal (esquema listo para Fase 2)', () {
      const profile = UserProfile(
        uid: 'uid-2',
        email: 'vet@ejemplo.com',
        role: UserRole.personal,
        companyId: 'empresa-1',
      );

      final decoded = UserProfileCodec.fromMap(
        profile.uid,
        UserProfileCodec.toMap(profile),
      );

      expect(decoded?.role, UserRole.personal);
      expect(decoded?.companyId, 'empresa-1');
    });

    test('rechaza roles desconocidos', () {
      final decoded = UserProfileCodec.fromMap('uid-1', {
        'email': 'ana@ejemplo.com',
        'role': 'admin_magico',
      });

      expect(decoded, isNull);
    });

    test('rechaza tipos inválidos', () {
      final decoded = UserProfileCodec.fromMap('uid-1', {
        'email': 42,
        'role': 'dueno',
      });

      expect(decoded, isNull);
    });

    test('createdAt se lee como timestamp de Firestore', () {
      final now = DateTime.utc(2026, 10, 12, 12);
      final decoded = UserProfileCodec.fromMap('uid-1', {
        'email': 'ana@ejemplo.com',
        'role': 'dueno',
        'createdAt': Timestamp.fromDate(now),
      });

      expect(decoded?.createdAt?.toUtc(), now);
    });
  });
}
