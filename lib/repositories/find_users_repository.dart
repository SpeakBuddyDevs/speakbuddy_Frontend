import '../models/find_user.dart';
import '../models/find_filters.dart';

/// Abstracción para el repositorio de búsqueda de usuarios
abstract class FindUsersRepository {
  /// Busca usuarios con query, filtros y paginación
  Future<List<FindUser>> searchUsers({
    String query = '',
    FindFilters? filters,
    int page = 0,
    int pageSize = 10,
  });
}

