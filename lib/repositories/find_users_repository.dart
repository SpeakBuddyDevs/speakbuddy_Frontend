import '../models/find_user.dart';
import '../models/find_filters.dart';

/// Abstracción para el repositorio de búsqueda de usuarios
/// 
/// BACKEND: Crear ApiFindUsersRepository que implemente esta interfaz.
/// Sustituir FakeFindUsersRepository por ApiFindUsersRepository en find_screen.dart
/// 
/// Endpoint: GET /api/users/search
/// Query params: ?q=&page=&pageSize=&online=&pro=&minRating=&nativeLang=&targetLang=&country=
/// Response: { "users": FindUser[], "totalCount": int, "hasMore": bool }
/// TODO(BE): Usar paginación offset (page, pageSize) o cursor según preferencia
abstract class FindUsersRepository {
  /// Busca usuarios con query, filtros y paginación
  /// BACKEND: GET /api/users/search con query params
  Future<List<FindUser>> searchUsers({
    String query = '',
    FindFilters? filters,
    int page = 0,
    int pageSize = 10,
  });
}

