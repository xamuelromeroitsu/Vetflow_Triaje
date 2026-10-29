import 'package:flutter_test/flutter_test.dart';
import 'package:vetflow_triaje/features/auth/domain/model/user_profile.dart';
import 'package:vetflow_triaje/features/auth/domain/model/user_role.dart';
import 'package:vetflow_triaje/infrastructure/supabase/supabase_repositories.dart';

void main() {
  group('SupabaseUserProfileMapper', () {
    test('roundtrip dueño', () {
      const profile = UserProfile(
        uid: 'uid-1',
        email: 'ana@ejemplo.com',
        role: UserRole.dueno,
        ownerId: 'uid-1',
      );

      final map = SupabaseUserProfileMapper.toMap(profile);
      final decoded = SupabaseUserProfileMapper.fromMap(map);

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

      final decoded = SupabaseUserProfileMapper.fromMap(
        SupabaseUserProfileMapper.toMap(profile),
      );

      expect(decoded?.role, UserRole.personal);
      expect(decoded?.companyId, 'empresa-1');
    });

    test('rechaza roles desconocidos', () {
      final decoded = SupabaseUserProfileMapper.fromMap({
        'id': 'uid-1',
        'email': 'ana@ejemplo.com',
        'role': 'admin_magico',
      });

      expect(decoded, isNull);
    });

    test('rechaza tipos inválidos', () {
      final decoded = SupabaseUserProfileMapper.fromMap({
        'id': 'uid-1',
        'email': 42,
        'role': 'dueno',
      });

      expect(decoded, isNull);
    });

    test('createdAt se lee como fecha ISO-8601', () {
      final now = DateTime.utc(2026, 10, 12, 12);
      final decoded = SupabaseUserProfileMapper.fromMap({
        'id': 'uid-1',
        'email': 'ana@ejemplo.com',
        'role': 'dueno',
        'created_at': now.toIso8601String(),
      });

      expect(decoded?.createdAt?.toUtc(), now);
    });
  });
}
