import 'dart:math';
import '../models/public_exchange.dart';
import '../models/public_exchange_filters.dart';
import 'public_exchanges_repository.dart';
import '../constants/languages.dart';

/// Implementación fake del repositorio de intercambios públicos para desarrollo
/// 
/// TODO(FE): Eliminar este archivo cuando exista ApiPublicExchangesRepository
/// BACKEND: Sustituir por ApiPublicExchangesRepository que consuma GET /api/exchanges/public
class FakePublicExchangesRepository implements PublicExchangesRepository {
  static final _random = Random();
  
  // Datos mock del usuario de prueba (deben coincidir con profile_screen.dart)
  // Usuario nativo: Español
  // Aprendiendo: Inglés nivel Intermedio (4), Francés nivel Principiante (1)
  static const String _userNativeLanguageName = 'Español';
  static const Map<String, int> _userLearningLanguages = {
    'EN': 4, // Inglés - Intermedio
    'FR': 1, // Francés - Principiante
  };
  
  /// Obtiene el nivel del usuario en un idioma por su nombre
  static int _getUserLanguageLevel(String languageName) {
    // Buscar el código del idioma
    for (final entry in AppLanguages.codeToName.entries) {
      if (entry.value.toLowerCase() == languageName.toLowerCase()) {
        return _userLearningLanguages[entry.key] ?? 0;
      }
    }
    return 0;
  }

  /// Calcula si el usuario actual es elegible para un intercambio y qué requisitos no cumple
  static ({bool isEligible, List<String>? unmetRequirements}) _calculateEligibility(
    PublicExchange exchange,
  ) {
    final unmetRequirements = <String>[];

    // Requisito 1: El usuario debe tener el idioma nativo que coincide con el targetLanguage del intercambio
    // (el idioma que el creador busca practicar)
    if (_userNativeLanguageName != exchange.targetLanguage) {
      unmetRequirements.add('Idioma nativo: ${exchange.targetLanguage}');
    }

    // Requisito 2: El usuario debe estar aprendiendo el nativeLanguage del intercambio
    // (el idioma que el creador ofrece) con nivel suficiente
    final userLevelInOfferedLanguage = _getUserLanguageLevel(exchange.nativeLanguage);
    if (userLevelInOfferedLanguage < exchange.minLevel) {
      final levelText = _getLevelText(exchange.requiredLevel);
      unmetRequirements.add('Nivel de ${exchange.nativeLanguage}: $levelText');
    }

    return (
      isEligible: unmetRequirements.isEmpty,
      unmetRequirements: unmetRequirements.isEmpty ? null : unmetRequirements,
    );
  }

  /// Convierte nivel numérico a texto
  static String _getLevelText(String level) {
    return level; // Ya viene como texto
  }

  /// Datos mock de intercambios públicos
  /// Concepto: Intercambio mutuo de idiomas - conversación dividida a partes iguales
  /// NOTA: isEligible y unmetRequirements se calculan dinámicamente en searchExchanges
  /// 
  /// BACKEND: Los creatorId deben coincidir con IDs de usuarios reales del sistema.
  /// Los usuarios mock están definidos en FakeFindUsersRepository.
  static final List<PublicExchange> _mockExchangesBase = [
    // Intercambio 1: Español ↔ Inglés (Usuario: Carlos Mendez - ID: 2, Español nativo, aprendiendo Inglés)
    PublicExchange(
      id: '1',
      title: 'Intercambio casual de idiomas',
      description: 'Conversación libre dividida a partes iguales entre español e inglés. Ambiente relajado y amigable.',
      creatorId: '2', // Carlos Mendez
      creatorName: 'Carlos Mendez',
      creatorAvatarUrl: null,
      creatorIsPro: false,
      requiredLevel: 'Principiante',
      minLevel: 1,
      date: DateTime.now().add(const Duration(days: 3)),
      durationMinutes: 45,
      currentParticipants: 5,
      maxParticipants: 10,
      nativeLanguage: 'Español',
      targetLanguage: 'Inglés',
      topics: null, // Sin temas específicos
      isEligible: false, // Se calculará dinámicamente
      unmetRequirements: null, // Se calculará dinámicamente
    ),
    // Intercambio 2: Francés ↔ Español (Usuario: Marie Dupont - ID: 3, Francés nativo, aprendiendo Español, PRO)
    PublicExchange(
      id: '2',
      title: 'Intercambio Español-Francés',
      description: 'Práctica mutua de español y francés. Conversación dividida equitativamente entre ambos idiomas.',
      creatorId: '3', // Marie Dupont
      creatorName: 'Marie Dupont',
      creatorAvatarUrl: null,
      creatorIsPro: true, // Usuario PRO
      requiredLevel: 'Principiante',
      minLevel: 1,
      date: DateTime.now().add(const Duration(days: 5)),
      durationMinutes: 50,
      currentParticipants: 7,
      maxParticipants: 10,
      nativeLanguage: 'Francés',
      targetLanguage: 'Español',
      topics: ['Viajes', 'turismo', 'cultura'],
      isEligible: false, // Se calculará dinámicamente
      unmetRequirements: null, // Se calculará dinámicamente
    ),
    // Intercambio 3: Inglés ↔ Español (Usuario: Sarah Johnson - ID: 1, Inglés nativo, aprendiendo Español, PRO)
    PublicExchange(
      id: '3',
      title: 'Intercambio Inglés-Español',
      description: 'Sesión de intercambio mutuo. Ofrezco mi inglés nativo a cambio de practicar español. Todos los niveles bienvenidos.',
      creatorId: '1', // Sarah Johnson
      creatorName: 'Sarah Johnson',
      creatorAvatarUrl: null,
      creatorIsPro: true, // Usuario PRO
      requiredLevel: 'Intermedio',
      minLevel: 4,
      date: DateTime.now().add(const Duration(days: 10)),
      durationMinutes: 60,
      currentParticipants: 3,
      maxParticipants: 6,
      nativeLanguage: 'Inglés',
      targetLanguage: 'Español',
      topics: ['Negocios', 'presentaciones', 'profesional'],
      isEligible: false, // Se calculará dinámicamente
      unmetRequirements: null, // Se calculará dinámicamente
    ),
    // Intercambio 4: Alemán ↔ Español (Usuario: Hans Mueller - ID: 4, Alemán nativo, aprendiendo Inglés)
    // Nota: Este usuario aprende Inglés, pero crea un intercambio Alemán-Español (puede aprender ambos)
    PublicExchange(
      id: '4',
      title: 'Intercambio Alemán-Español',
      description: 'Conversación libre en alemán y español. Ambiente relajado para practicar ambos idiomas a partes iguales.',
      creatorId: '4', // Hans Mueller
      creatorName: 'Hans Mueller',
      creatorAvatarUrl: null,
      creatorIsPro: false,
      requiredLevel: 'Intermedio',
      minLevel: 4,
      date: DateTime.now().add(const Duration(days: 7)),
      durationMinutes: 55,
      currentParticipants: 4,
      maxParticipants: 8,
      nativeLanguage: 'Alemán',
      targetLanguage: 'Español',
      topics: null, // Sin temas específicos
      isEligible: false, // Se calculará dinámicamente
      unmetRequirements: null, // Se calculará dinámicamente
    ),
    // Intercambio 5: Italiano ↔ Español (Usuario: Marco Rossi - ID: 9, Italiano nativo, aprendiendo Inglés)
    PublicExchange(
      id: '5',
      title: 'Intercambio Italiano-Español',
      description: 'Para estudiantes avanzados. Intercambio mutuo de italiano y español con discusión sobre literatura y cultura.',
      creatorId: '9', // Marco Rossi
      creatorName: 'Marco Rossi',
      creatorAvatarUrl: null,
      creatorIsPro: false,
      requiredLevel: 'Avanzado',
      minLevel: 7,
      date: DateTime.now().add(const Duration(days: 14)),
      durationMinutes: 75,
      currentParticipants: 2,
      maxParticipants: 5,
      nativeLanguage: 'Italiano',
      targetLanguage: 'Español',
      topics: ['Literatura', 'cultura', 'arte'],
      isEligible: false, // Se calculará dinámicamente
      unmetRequirements: null, // Se calculará dinámicamente
    ),
    // Intercambio 6: Portugués ↔ Español (Usuario: Lucas Silva - ID: 7, Portugués nativo, aprendiendo Inglés, PRO)
    PublicExchange(
      id: '6',
      title: 'Intercambio Portugués-Español',
      description: 'Intercambio mutuo de portugués brasileño y español. Enfoque en expresiones coloquiales y cultura.',
      creatorId: '7', // Lucas Silva
      creatorName: 'Lucas Silva',
      creatorAvatarUrl: null,
      creatorIsPro: true, // Usuario PRO
      requiredLevel: 'Intermedio',
      minLevel: 4,
      date: DateTime.now().add(const Duration(days: 6)),
      durationMinutes: 50,
      currentParticipants: 6,
      maxParticipants: 10,
      nativeLanguage: 'Portugués',
      targetLanguage: 'Español',
      topics: ['Expresiones', 'cultura brasileña', 'coloquial'],
      isEligible: false, // Se calculará dinámicamente
      unmetRequirements: null, // Se calculará dinámicamente
    ),
    // Intercambio 7: Japonés ↔ Español (Usuario: Yuki Tanaka - ID: 5, Japonés nativo, aprendiendo Español, PRO)
    PublicExchange(
      id: '7',
      title: 'Intercambio Japonés-Español',
      description: 'Conversación mutua dividida entre japonés y español. Ideal para principiantes que quieren practicar ambos idiomas.',
      creatorId: '5', // Yuki Tanaka
      creatorName: 'Yuki Tanaka',
      creatorAvatarUrl: null,
      creatorIsPro: true, // Usuario PRO
      requiredLevel: 'Principiante',
      minLevel: 1,
      date: DateTime.now().add(const Duration(days: 8)),
      durationMinutes: 45,
      currentParticipants: 8,
      maxParticipants: 15,
      nativeLanguage: 'Japonés',
      targetLanguage: 'Español',
      topics: null, // Sin temas específicos
      isEligible: false, // Se calculará dinámicamente
      unmetRequirements: null, // Se calculará dinámicamente
    ),
    // Intercambio 8: Chino ↔ Español (Usuario: Chen Wei - ID: 11, Chino nativo, aprendiendo Inglés)
    PublicExchange(
      id: '8',
      title: 'Intercambio Chino-Español',
      description: 'Práctica mutua de chino mandarín y español. Conversación sobre temas de actualidad dividida equitativamente.',
      creatorId: '11', // Chen Wei
      creatorName: 'Chen Wei',
      creatorAvatarUrl: null,
      creatorIsPro: false,
      requiredLevel: 'Intermedio',
      minLevel: 4,
      date: DateTime.now().add(const Duration(days: 12)),
      durationMinutes: 60,
      currentParticipants: 3,
      maxParticipants: 8,
      nativeLanguage: 'Chino',
      targetLanguage: 'Español',
      topics: ['Actualidad', 'cultura', 'conversación'],
      isEligible: false, // Se calculará dinámicamente
      unmetRequirements: null, // Se calculará dinámicamente
    ),
    // Intercambio 9: Inglés ↔ Español (Usuario: Emma Wilson - ID: 6, Inglés nativo, aprendiendo Francés)
    PublicExchange(
      id: '9',
      title: 'Intercambio Inglés-Español para Principiantes',
      description: 'Sesión amigable para principiantes. Conversación simple dividida entre inglés y español.',
      creatorId: '6', // Emma Wilson
      creatorName: 'Emma Wilson',
      creatorAvatarUrl: null,
      creatorIsPro: false,
      requiredLevel: 'Principiante',
      minLevel: 1,
      date: DateTime.now().add(const Duration(days: 2)),
      durationMinutes: 40,
      currentParticipants: 4,
      maxParticipants: 12,
      nativeLanguage: 'Inglés',
      targetLanguage: 'Español',
      topics: ['Principiante', 'básico', 'conversación'],
      isEligible: false, // Se calculará dinámicamente
      unmetRequirements: null, // Se calculará dinámicamente
    ),
    // Intercambio 10: Francés ↔ Español (Usuario: Marie Dupont - ID: 3, ya usado, usar otro)
    // Usar: Lisa Anderson - ID: 14, Inglés nativo, aprendiendo Español (pero crea intercambio Francés-Español)
    PublicExchange(
      id: '10',
      title: 'Intercambio Francés-Español',
      description: 'Práctica mutua de francés y español. Enfoque en conversación natural y fluida.',
      creatorId: '3', // Marie Dupont (ya usada, pero puede crear múltiples intercambios)
      creatorName: 'Marie Dupont',
      creatorAvatarUrl: null,
      creatorIsPro: true, // Usuario PRO
      requiredLevel: 'Intermedio',
      minLevel: 4,
      date: DateTime.now().add(const Duration(days: 4)),
      durationMinutes: 55,
      currentParticipants: 5,
      maxParticipants: 8,
      nativeLanguage: 'Francés',
      targetLanguage: 'Español',
      topics: ['Conversación', 'cultura francesa', 'cotidiano'],
      isEligible: false, // Se calculará dinámicamente
      unmetRequirements: null, // Se calculará dinámicamente
    ),
    // Intercambio 11: Inglés ↔ Español Avanzado (Usuario: Sarah Johnson - ID: 1, ya usado)
    PublicExchange(
      id: '11',
      title: 'Intercambio Inglés-Español Avanzado',
      description: 'Para estudiantes avanzados. Discusión sobre temas complejos en inglés y español.',
      creatorId: '1', // Sarah Johnson (puede crear múltiples intercambios)
      creatorName: 'Sarah Johnson',
      creatorAvatarUrl: null,
      creatorIsPro: true, // Usuario PRO
      requiredLevel: 'Avanzado',
      minLevel: 7,
      date: DateTime.now().add(const Duration(days: 9)),
      durationMinutes: 70,
      currentParticipants: 2,
      maxParticipants: 6,
      nativeLanguage: 'Inglés',
      targetLanguage: 'Español',
      topics: ['Avanzado', 'debate', 'temas complejos'],
      isEligible: false, // Se calculará dinámicamente
      unmetRequirements: null, // Se calculará dinámicamente
    ),
    // Intercambio 12: Alemán ↔ Español (Usuario: Hans Mueller - ID: 4, ya usado)
    PublicExchange(
      id: '12',
      title: 'Intercambio Alemán-Español',
      description: 'Conversación relajada en alemán y español. Perfecto para practicar ambos idiomas de forma natural.',
      creatorId: '4', // Hans Mueller (puede crear múltiples intercambios)
      creatorName: 'Hans Mueller',
      creatorAvatarUrl: null,
      creatorIsPro: false,
      requiredLevel: 'Principiante',
      minLevel: 1,
      date: DateTime.now().add(const Duration(days: 1)),
      durationMinutes: 45,
      currentParticipants: 6,
      maxParticipants: 10,
      nativeLanguage: 'Alemán',
      targetLanguage: 'Español',
      topics: null, // Sin temas específicos
      isEligible: false, // Se calculará dinámicamente
      unmetRequirements: null, // Se calculará dinámicamente
    ),
    // Intercambio 13: Ruso ↔ Español (Usuario: Olga Petrova - ID: 12, Ruso nativo, aprendiendo Español, PRO)
    PublicExchange(
      id: '13',
      title: 'Intercambio Ruso-Español',
      description: 'Intercambio mutuo de ruso y español. Conversación sobre cultura y tradiciones.',
      creatorId: '12', // Olga Petrova
      creatorName: 'Olga Petrova',
      creatorAvatarUrl: null,
      creatorIsPro: true, // Usuario PRO
      requiredLevel: 'Intermedio',
      minLevel: 4,
      date: DateTime.now().add(const Duration(days: 11)),
      durationMinutes: 60,
      currentParticipants: 3,
      maxParticipants: 8,
      nativeLanguage: 'Ruso',
      targetLanguage: 'Español',
      topics: ['Cultura', 'tradiciones', 'historia'],
      isEligible: false, // Se calculará dinámicamente
      unmetRequirements: null, // Se calculará dinámicamente
    ),
    // Intercambio 14: Inglés ↔ Español Casual (Usuario: Lisa Anderson - ID: 14, Inglés nativo, aprendiendo Español)
    PublicExchange(
      id: '14',
      title: 'Intercambio Inglés-Español Casual',
      description: 'Sesión casual y relajada. Conversación libre dividida equitativamente entre inglés y español.',
      creatorId: '14', // Lisa Anderson
      creatorName: 'Lisa Anderson',
      creatorAvatarUrl: null,
      creatorIsPro: false,
      requiredLevel: 'Principiante',
      minLevel: 1,
      date: DateTime.now().add(const Duration(days: 13)),
      durationMinutes: 50,
      currentParticipants: 7,
      maxParticipants: 12,
      nativeLanguage: 'Inglés',
      targetLanguage: 'Español',
      topics: ['Casual', 'conversación libre'],
      isEligible: false, // Se calculará dinámicamente
      unmetRequirements: null, // Se calculará dinámicamente
    ),
    // Intercambio 15: Coreano ↔ Español (Usuario: Kim Min-jun - ID: 15, Coreano nativo, aprendiendo Inglés, PRO)
    PublicExchange(
      id: '15',
      title: 'Intercambio Coreano-Español',
      description: 'Práctica mutua de coreano y español. Ideal para quienes están comenzando con coreano.',
      creatorId: '15', // Kim Min-jun
      creatorName: 'Kim Min-jun',
      creatorAvatarUrl: null,
      creatorIsPro: true, // Usuario PRO
      requiredLevel: 'Principiante',
      minLevel: 1,
      date: DateTime.now().add(const Duration(days: 15)),
      durationMinutes: 45,
      currentParticipants: 4,
      maxParticipants: 10,
      nativeLanguage: 'Coreano',
      targetLanguage: 'Español',
      topics: ['Principiante', 'K-pop', 'cultura coreana'],
      isEligible: false, // Se calculará dinámicamente
      unmetRequirements: null, // Se calculará dinámicamente
    ),
  ];

  @override
  Future<List<PublicExchange>> searchExchanges({
    String query = '',
    PublicExchangeFilters? filters,
    int page = 0,
    int pageSize = 10,
  }) async {
    // Simular latencia de red
    await Future.delayed(Duration(milliseconds: 300 + _random.nextInt(300)));

    // Calcular elegibilidad dinámicamente para cada intercambio
    var results = _mockExchangesBase.map((exchange) {
      final eligibility = _calculateEligibility(exchange);
      return PublicExchange(
        id: exchange.id,
        title: exchange.title,
        description: exchange.description,
        creatorId: exchange.creatorId,
        creatorName: exchange.creatorName,
        creatorAvatarUrl: exchange.creatorAvatarUrl,
        creatorIsPro: exchange.creatorIsPro,
        requiredLevel: exchange.requiredLevel,
        minLevel: exchange.minLevel,
        date: exchange.date,
        durationMinutes: exchange.durationMinutes,
        currentParticipants: exchange.currentParticipants,
        maxParticipants: exchange.maxParticipants,
        nativeLanguage: exchange.nativeLanguage,
        targetLanguage: exchange.targetLanguage,
        topics: exchange.topics,
        isEligible: eligibility.isEligible,
        unmetRequirements: eligibility.unmetRequirements,
      );
    }).toList();

    // Filtrar por query (título, descripción, creador, idiomas)
    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      results = results.where((e) {
        return e.title.toLowerCase().contains(q) ||
            e.description.toLowerCase().contains(q) ||
            e.creatorName.toLowerCase().contains(q) ||
            e.nativeLanguage.toLowerCase().contains(q) ||
            e.targetLanguage.toLowerCase().contains(q);
      }).toList();
    }

    // Aplicar filtros
    if (filters != null) {
      if (filters.requiredLevel != null && filters.requiredLevel!.isNotEmpty) {
        results = results.where((e) => e.requiredLevel == filters.requiredLevel).toList();
      }
      if (filters.minDate != null) {
        results = results.where((e) => e.date.isAfter(filters.minDate!) || e.date.isAtSameMomentAs(filters.minDate!)).toList();
      }
      if (filters.maxDuration != null) {
        results = results.where((e) => e.durationMinutes <= filters.maxDuration!).toList();
      }
      if (filters.nativeLanguage != null && filters.nativeLanguage!.isNotEmpty) {
        final lang = filters.nativeLanguage!.toLowerCase();
        results = results.where((e) => e.nativeLanguage.toLowerCase().contains(lang)).toList();
      }
      if (filters.targetLanguage != null && filters.targetLanguage!.isNotEmpty) {
        final lang = filters.targetLanguage!.toLowerCase();
        results = results.where((e) => e.targetLanguage.toLowerCase().contains(lang)).toList();
      }
    }

    // Ordenar según prioridad:
    // 1. PRO elegibles (por fecha ascendente)
    // 2. No PRO elegibles (por fecha ascendente)
    // 3. PRO no elegibles (por fecha ascendente)
    // 4. No PRO no elegibles (por fecha ascendente)
    results.sort((a, b) {
      // Calcular prioridad de cada intercambio (menor número = mayor prioridad)
      int getPriority(PublicExchange e) {
        if (e.isEligible && e.creatorIsPro) return 1; // PRO elegible
        if (e.isEligible && !e.creatorIsPro) return 2; // No PRO elegible
        if (!e.isEligible && e.creatorIsPro) return 3; // PRO no elegible
        return 4; // No PRO no elegible
      }
      
      final priorityA = getPriority(a);
      final priorityB = getPriority(b);
      
      // Si tienen diferente prioridad, ordenar por prioridad
      if (priorityA != priorityB) {
        return priorityA.compareTo(priorityB);
      }
      
      // Si tienen la misma prioridad, ordenar por fecha (más cercanos primero)
      return a.date.compareTo(b.date);
    });

    // Paginación
    final start = page * pageSize;
    if (start >= results.length) return [];
    final end = (start + pageSize).clamp(0, results.length);

    return results.sublist(start, end);
  }
}
