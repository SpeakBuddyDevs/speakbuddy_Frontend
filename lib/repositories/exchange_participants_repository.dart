import '../models/public_user_profile.dart';

/// Abstracción para el repositorio de participantes de intercambio.
/// 
/// BACKEND: Crear ApiExchangeParticipantsRepository que implemente esta interfaz.
/// Sustituir FakeExchangeParticipantsRepository por ApiExchangeParticipantsRepository en chat_screen.dart
/// 
/// Endpoint: GET /api/exchanges/{exchangeId}/participants
/// Response: { "participants": PublicUserProfile[] }
/// 
/// TODO(BE): El endpoint debe devolver la lista completa de participantes con:
///   - id, name, country, avatarUrl?, isOnline, isPro, nativeLanguage, targetLanguage,
///     level, rating, exchanges, bio?
abstract class ExchangeParticipantsRepository {
  /// Obtiene la lista de participantes de un intercambio.
  /// BACKEND: GET /api/exchanges/{exchangeId}/participants
  /// Debe incluir al creador del intercambio y todos los usuarios unidos
  Future<List<PublicUserProfile>> getParticipants(String exchangeId);
}
