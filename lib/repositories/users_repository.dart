import '../models/public_user_profile.dart';

/// Abstracción para el repositorio de usuarios
/// 
/// BACKEND: Crear ApiUsersRepository que implemente esta interfaz.
/// Sustituir FakeUsersRepository por ApiUsersRepository en public_profile_screen.dart
/// 
/// Endpoint: GET /api/users/{userId}
/// Response: PublicUserProfile (ver modelo para campos esperados)
abstract class UsersRepository {
  /// Obtiene el perfil público de un usuario por su ID
  /// BACKEND: GET /api/users/{userId}
  Future<PublicUserProfile?> getPublicProfile(String userId);
}

