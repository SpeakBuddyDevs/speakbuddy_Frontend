import '../models/joined_exchange.dart';

/// Abstracción para el repositorio de intercambios del usuario.
/// Endpoint: GET /api/exchanges/joined
abstract class UserExchangesRepository {
  /// Obtiene los intercambios a los que el usuario está unido.
  Future<List<JoinedExchange>> getJoinedExchanges();
}
