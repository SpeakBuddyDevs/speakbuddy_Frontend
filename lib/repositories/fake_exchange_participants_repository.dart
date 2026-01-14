import '../models/public_user_profile.dart';
import 'exchange_participants_repository.dart';
import 'fake_find_users_repository.dart';

/// Implementación fake del repositorio de participantes de intercambio para desarrollo.
/// 
/// TODO(FE): Eliminar este archivo cuando exista ApiExchangeParticipantsRepository
/// BACKEND: Sustituir por ApiExchangeParticipantsRepository que consuma GET /api/exchanges/{exchangeId}/participants
class FakeExchangeParticipantsRepository implements ExchangeParticipantsRepository {
  /// Mapa de participantes por exchangeId
  /// BACKEND: Esta información debe venir del endpoint GET /api/exchanges/{exchangeId}/participants
  static final Map<String, List<String>> _exchangeParticipants = {
    'joined-1': ['1', '2', 'current_user_001'], // Sarah Johnson, Carlos Mendez, usuario actual
    'joined-2': ['3', 'current_user_001'], // Marie Dupont, usuario actual
    'joined-3': ['4', '10', 'current_user_001'], // Hans Mueller, Sofia Garcia, usuario actual
    'joined-4': ['5', 'current_user_001'], // Yuki Tanaka, usuario actual
    'joined-5': ['7', '2', '10', 'current_user_001'], // Lucas Silva, Carlos Mendez, Sofia Garcia, usuario actual
  };

  @override
  Future<List<PublicUserProfile>> getParticipants(String exchangeId) async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 200));

    // Obtener IDs de participantes para este intercambio
    final participantIds = _exchangeParticipants[exchangeId] ?? [];
    
    // Convertir FindUser a PublicUserProfile usando los usuarios mock
    final participants = <PublicUserProfile>[];
    
    for (final userId in participantIds) {
      // Si es el usuario actual, usar datos del CurrentUserService
      if (userId == 'current_user_001') {
        // Crear perfil mock del usuario actual
        participants.add(const PublicUserProfile(
          id: 'current_user_001',
          name: 'Sergio Arjona',
          country: 'España',
          isOnline: true,
          isPro: true,
          nativeLanguage: 'Español',
          targetLanguage: 'Inglés',
          level: 5,
          rating: 4.8,
          exchanges: 12,
          bio: '¡Hola! Soy Sergio, estudiante de idiomas.',
        ));
      } else {
        // Buscar en los usuarios mock
        final findUser = FakeFindUsersRepository.getUserById(userId);
        if (findUser != null) {
          participants.add(PublicUserProfile.fromFindUser(findUser));
        }
      }
    }
    
    return participants;
  }
}
