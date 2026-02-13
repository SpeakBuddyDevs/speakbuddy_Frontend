import '../models/public_exchange.dart';
import '../models/public_exchange_filters.dart';

/// Abstracción para el repositorio de intercambios públicos.
/// Implementación: ApiPublicExchangesRepository
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

  /// Crea un nuevo intercambio (público o privado)
  /// BACKEND: POST /api/exchanges
  /// Body: { title, description, nativeLanguageCode, targetLanguageCode, requiredLevelMinOrder,
  ///   requiredLevelMaxOrder, scheduledAt, durationMinutes, maxParticipants, topics[]?, isPublic }
  Future<PublicExchange> createExchange({
    required String title,
    required String description,
    required String nativeLanguage,
    required String targetLanguage,
    required int requiredLevelMinOrder,
    required int requiredLevelMaxOrder,
    required DateTime date,
    required int durationMinutes,
    required int maxParticipants,
    List<String>? topics,
    List<String>? platforms,
    required bool isPublic,
  });

  /// Une al usuario actual al intercambio.
  /// BACKEND: POST /api/exchanges/{id}/join
  Future<void> joinExchange(String id);

  /// Abandona el intercambio (solo participantes, no el creador).
  /// BACKEND: DELETE /api/exchanges/{id}/leave
  Future<void> leaveExchange(String id);
}
