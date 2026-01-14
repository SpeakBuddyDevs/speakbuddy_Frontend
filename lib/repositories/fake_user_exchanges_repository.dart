import '../models/public_exchange.dart';
import 'user_exchanges_repository.dart';

/// Implementación fake del repositorio de intercambios del usuario para desarrollo.
/// 
/// TODO(FE): Eliminar este archivo cuando exista ApiUserExchangesRepository
/// BACKEND: Sustituir por ApiUserExchangesRepository que consuma GET /api/exchanges/joined
class FakeUserExchangesRepository implements UserExchangesRepository {
  /// Datos mock de intercambios a los que el usuario está unido.
  /// Solo incluye intercambios con fechas futuras.
  static List<PublicExchange> _mockJoinedExchanges = [];

  /// Mapa auxiliar para obtener información adicional del creador (país, rating)
  /// BACKEND: Esta información debería venir en el PublicExchange desde el backend
  static final Map<String, ({String country, double rating})> _creatorInfo = {
    '1': (country: 'Estados Unidos', rating: 4.9), // Sarah Johnson
    '2': (country: 'Estados Unidos', rating: 4.9), // John Smith (mock)
    '3': (country: 'Francia', rating: 4.8), // Marie Dupont
    '4': (country: 'Alemania', rating: 4.5), // Hans Mueller
    '5': (country: 'Japón', rating: 4.9), // Yuki Tanaka
    '7': (country: 'Brasil', rating: 5.0), // Lucas Silva
  };

  /// Obtiene el país del creador
  static String getCreatorCountry(String creatorId) {
    return _creatorInfo[creatorId]?.country ?? 'Desconocido';
  }

  /// Obtiene el rating del creador
  static double getCreatorRating(String creatorId) {
    return _creatorInfo[creatorId]?.rating ?? 0.0;
  }

  /// Inicializa los intercambios mock con fechas futuras.
  static void _initializeMockData() {
    final now = DateTime.now();
    // Calcular el año para las fechas de enero
    // Si estamos en enero y el día actual es menor a 26, usar el año actual
    // Si estamos después del 26 de enero o en otro mes, usar el próximo año
    final targetYear = (now.month == 1 && now.day < 26) ? now.year : 
                       (now.month == 1 ? now.year + 1 : now.year + 1);
    
    _mockJoinedExchanges = [
      // Intercambio hoy a las 16:30
      PublicExchange(
        id: 'joined-1',
        title: 'Business English - Presentaciones',
        description: 'Práctica de presentaciones en inglés de negocios',
        creatorId: '1', // Sarah Johnson (Estados Unidos, PRO, rating 4.9)
        creatorName: 'John Smith', // Mock: nombre diferente para el intercambio
        creatorAvatarUrl: null,
        creatorIsPro: true,
        requiredLevel: 'Intermedio',
        minLevel: 4,
        date: DateTime(now.year, now.month, now.day, 16, 30),
        durationMinutes: 60,
        currentParticipants: 3,
        maxParticipants: 5,
        nativeLanguage: 'Inglés',
        targetLanguage: 'Español',
        topics: ['Business English - Presentaciones'],
        isEligible: true,
        isPublic: true,
      ),
      // Intercambio mañana a las 10:00
      PublicExchange(
        id: 'joined-2',
        title: 'Conversación casual',
        description: 'Intercambio casual de español e inglés',
        creatorId: '3', // Marie Dupont (Francia, PRO, rating 4.8)
        creatorName: 'Marie Dupont',
        creatorAvatarUrl: null,
        creatorIsPro: true,
        requiredLevel: 'Principiante',
        minLevel: 1,
        date: DateTime(now.year, now.month, now.day + 1, 10, 0),
        durationMinutes: 45,
        currentParticipants: 2,
        maxParticipants: 4,
        nativeLanguage: 'Español',
        targetLanguage: 'Inglés',
        topics: null,
        isEligible: true,
        isPublic: true,
      ),
      // Intercambio 20 de enero a las 14:00
      PublicExchange(
        id: 'joined-3',
        title: 'Alemán para principiantes',
        description: 'Sesión de intercambio para practicar alemán básico',
        creatorId: '4', // Hans Mueller (Alemania, rating 4.5)
        creatorName: 'Hans Mueller',
        creatorAvatarUrl: null,
        creatorIsPro: false,
        requiredLevel: 'Principiante',
        minLevel: 1,
        date: DateTime(targetYear, 1, 20, 14, 0),
        durationMinutes: 50,
        currentParticipants: 4,
        maxParticipants: 6,
        nativeLanguage: 'Alemán',
        targetLanguage: 'Español',
        topics: ['Conversación básica', 'Presentaciones'],
        isEligible: true,
        isPublic: true,
      ),
      // Intercambio 23 de enero a las 18:00
      PublicExchange(
        id: 'joined-4',
        title: 'Japonés avanzado - Cultura',
        description: 'Intercambio avanzado sobre cultura japonesa',
        creatorId: '5', // Yuki Tanaka (Japón, PRO, rating 4.9)
        creatorName: 'Yuki Tanaka',
        creatorAvatarUrl: null,
        creatorIsPro: true,
        requiredLevel: 'Avanzado',
        minLevel: 7,
        date: DateTime(targetYear, 1, 23, 18, 0),
        durationMinutes: 75,
        currentParticipants: 2,
        maxParticipants: 4,
        nativeLanguage: 'Japonés',
        targetLanguage: 'Español',
        topics: ['Cultura', 'Literatura', 'Tradiciones'],
        isEligible: true,
        isPublic: true,
      ),
      // Intercambio 26 de enero a las 11:30
      PublicExchange(
        id: 'joined-5',
        title: 'Portugués brasileño',
        description: 'Práctica de portugués brasileño con enfoque en conversación natural',
        creatorId: '7', // Lucas Silva (Brasil, PRO, rating 5.0)
        creatorName: 'Lucas Silva',
        creatorAvatarUrl: null,
        creatorIsPro: true,
        requiredLevel: 'Intermedio',
        minLevel: 4,
        date: DateTime(targetYear, 1, 26, 11, 30),
        durationMinutes: 60,
        currentParticipants: 5,
        maxParticipants: 8,
        nativeLanguage: 'Portugués',
        targetLanguage: 'Español',
        topics: ['Conversación natural', 'Expresiones coloquiales'],
        isEligible: true,
        isPublic: true,
      ),
    ];
  }

  @override
  Future<List<PublicExchange>> getJoinedExchanges() async {
    // Inicializar datos mock si no están inicializados
    if (_mockJoinedExchanges.isEmpty) {
      _initializeMockData();
    }

    final now = DateTime.now();
    
    // Filtrar solo intercambios futuros (fecha + duración >= ahora)
    return _mockJoinedExchanges.where((exchange) {
      final endTime = exchange.date.add(Duration(minutes: exchange.durationMinutes));
      return endTime.isAfter(now);
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date)); // Ordenar por fecha (más inmediato primero)
  }
}
