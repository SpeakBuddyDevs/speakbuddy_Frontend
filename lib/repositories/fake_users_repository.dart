import '../models/public_user_profile.dart';
import 'users_repository.dart';
import 'fake_find_users_repository.dart';

/// Implementación fake del repositorio de usuarios
/// 
/// TODO(FE): Eliminar este archivo cuando exista ApiUsersRepository
/// BACKEND: Sustituir por ApiUsersRepository que consuma GET /api/users/{id}
class FakeUsersRepository implements UsersRepository {
  @override
  Future<PublicUserProfile?> getPublicProfile(String userId) async {
    // Simular latencia de red
    await Future.delayed(const Duration(milliseconds: 400));

    // Buscar en los datos mock de FakeFindUsersRepository
    final users = await FakeFindUsersRepository().searchUsers(pageSize: 100);
    
    try {
      final user = users.firstWhere((u) => u.id == userId);
      return PublicUserProfile.fromFindUser(user);
    } catch (_) {
      return null;
    }
  }
}

