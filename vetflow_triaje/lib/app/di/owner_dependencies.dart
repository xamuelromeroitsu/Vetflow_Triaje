/// Módulo de inyección de dependencias para dueños.
library;

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vetflow_triaje/features/owners/application/use_case/get_owner_by_id.dart';
import 'package:vetflow_triaje/features/owners/application/use_case/register_owner.dart';
import 'package:vetflow_triaje/features/owners/application/use_case/update_owner.dart';
import 'package:vetflow_triaje/infrastructure/demo/demo_repositories.dart';
import 'package:vetflow_triaje/infrastructure/supabase/supabase_repositories.dart';

class OwnerModule {
  const OwnerModule({
    required this.getOwnerById,
    required this.registerOwner,
    required this.updateOwner,
  });

  factory OwnerModule.create({SupabaseClient? client, bool demoMode = true}) {
    final ownerRepository = demoMode
        ? DemoOwnerRepository()
        : SupabaseOwnerRepository(client: client);
    return OwnerModule(
      getOwnerById: GetOwnerById(ownerRepository: ownerRepository),
      registerOwner: RegisterOwner(ownerRepository: ownerRepository),
      updateOwner: UpdateOwner(ownerRepository: ownerRepository),
    );
  }

  final GetOwnerById getOwnerById;
  final RegisterOwner registerOwner;
  final UpdateOwner updateOwner;
}
