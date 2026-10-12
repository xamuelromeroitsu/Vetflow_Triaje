/// Puerto (interfaz) del repositorio de perfiles (users/{uid}).
library;

import 'package:vetflow_triaje/core/result.dart';
import 'package:vetflow_triaje/features/auth/domain/user_profile.dart';

abstract class UserProfileRepository {
  Future<Result<UserProfile>> getByUid(String uid);

  Stream<UserProfile?> watchByUid(String uid);

  Future<Result<UserProfile>> create(UserProfile profile);
}
