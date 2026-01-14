import '../models/public_exchange.dart';

/// Abstracción para el repositorio de intercambios del usuario.
/// 
/// BACKEND: Crear ApiUserExchangesRepository que implemente esta interfaz.
/// Sustituir FakeUserExchangesRepository por ApiUserExchangesRepository en home_screen.dart
/// 
/// Endpoint: GET /api/exchanges/joined
/// Response: { "exchanges": PublicExchange[] }
abstract class UserExchangesRepository {
  /// Obtiene los intercambios a los que el usuario está unido.
  /// BACKEND: GET /api/exchanges/joined
  /// Solo debe devolver intercambios futuros (fecha >= ahora)
  Future<List<PublicExchange>> getJoinedExchanges();
}
