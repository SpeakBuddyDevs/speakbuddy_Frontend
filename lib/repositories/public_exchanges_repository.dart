import '../models/public_exchange.dart';
import '../models/public_exchange_filters.dart';

/// Abstracción para el repositorio de intercambios públicos
/// 
/// BACKEND: Crear ApiPublicExchangesRepository que implemente esta interfaz.
/// Sustituir FakePublicExchangesRepository por ApiPublicExchangesRepository en public_exchanges_screen.dart
/// 
/// Endpoint: GET /api/exchanges/public
/// Query params: ?q=&page=&pageSize=&requiredLevel=&minDate=&maxDuration=&nativeLang=&targetLang=
/// Response: { "exchanges": PublicExchange[], "totalCount": int, "hasMore": bool }
/// TODO(BE): Usar paginación offset (page, pageSize) o cursor según preferencia
abstract class PublicExchangesRepository {
  /// Busca intercambios públicos con query, filtros y paginación
  /// BACKEND: GET /api/exchanges/public con query params
  Future<List<PublicExchange>> searchExchanges({
    String query = '',
    PublicExchangeFilters? filters,
    int page = 0,
    int pageSize = 10,
  });
}
