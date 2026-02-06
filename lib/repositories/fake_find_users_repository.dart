import 'dart:math';
import '../models/find_user.dart';
import '../models/find_filters.dart';
import 'find_users_repository.dart';

/// Implementación fake del repositorio de usuarios para desarrollo
/// 
/// TODO(FE): Eliminar este archivo cuando exista ApiFindUsersRepository
/// BACKEND: Sustituir por ApiFindUsersRepository que consuma GET /api/users/search
class FakeFindUsersRepository implements FindUsersRepository {
  static final _random = Random();

  /// Datos mock de usuarios
  static final List<FindUser> _mockUsers = [
    const FindUser(
      id: '1',
      name: 'Sarah Johnson',
      country: 'Estados Unidos',
      isOnline: true,
      isPro: true,
      nativeLanguage: 'Inglés',
      targetLanguage: 'Español',
      level: 8,
      rating: 4.9,
      exchanges: 45,
      bio: '¡Hola! Soy profesora de inglés y me encanta aprender español. Busco compañeros para practicar conversación sobre viajes, cultura y música.',
    ),
    const FindUser(
      id: '2',
      name: 'Carlos Mendez',
      country: 'México',
      isOnline: true,
      isPro: false,
      nativeLanguage: 'Español',
      targetLanguage: 'Inglés',
      level: 5,
      rating: 4.7,
      exchanges: 23,
      bio: 'Ingeniero de software buscando mejorar mi inglés para el trabajo. Me gusta hablar de tecnología, videojuegos y cocina mexicana.',
    ),
    const FindUser(
      id: '3',
      name: 'Marie Dupont',
      country: 'Francia',
      isOnline: false,
      isPro: true,
      nativeLanguage: 'Francés',
      targetLanguage: 'Español',
      level: 6,
      rating: 4.8,
      exchanges: 31,
      bio: 'Estudiante de literatura apasionada por los idiomas. Quiero practicar español para leer a García Márquez en su idioma original.',
    ),
    const FindUser(
      id: '4',
      name: 'Hans Mueller',
      country: 'Alemania',
      isOnline: true,
      isPro: false,
      nativeLanguage: 'Alemán',
      targetLanguage: 'Inglés',
      level: 4,
      rating: 4.5,
      exchanges: 12,
      bio: 'Arquitecto alemán aprendiendo inglés. Me interesan el diseño, la fotografía y los viajes por Europa.',
    ),
    const FindUser(
      id: '5',
      name: 'Yuki Tanaka',
      country: 'Japón',
      isOnline: false,
      isPro: true,
      nativeLanguage: 'Japonés',
      targetLanguage: 'Español',
      level: 7,
      rating: 4.9,
      exchanges: 38,
    ),
    const FindUser(
      id: '6',
      name: 'Emma Wilson',
      country: 'Reino Unido',
      isOnline: true,
      isPro: false,
      nativeLanguage: 'Inglés',
      targetLanguage: 'Francés',
      level: 3,
      rating: 4.3,
      exchanges: 8,
    ),
    const FindUser(
      id: '7',
      name: 'Lucas Silva',
      country: 'Brasil',
      isOnline: true,
      isPro: true,
      nativeLanguage: 'Portugués',
      targetLanguage: 'Inglés',
      level: 9,
      rating: 5.0,
      exchanges: 67,
    ),
    const FindUser(
      id: '8',
      name: 'Anna Kowalski',
      country: 'Polonia',
      isOnline: false,
      isPro: false,
      nativeLanguage: 'Polaco',
      targetLanguage: 'Español',
      level: 2,
      rating: 4.1,
      exchanges: 5,
    ),
    const FindUser(
      id: '9',
      name: 'Marco Rossi',
      country: 'Italia',
      isOnline: true,
      isPro: false,
      nativeLanguage: 'Italiano',
      targetLanguage: 'Inglés',
      level: 6,
      rating: 4.6,
      exchanges: 29,
    ),
    const FindUser(
      id: '10',
      name: 'Sofia Garcia',
      country: 'España',
      isOnline: true,
      isPro: true,
      nativeLanguage: 'Español',
      targetLanguage: 'Alemán',
      level: 7,
      rating: 4.8,
      exchanges: 41,
    ),
    const FindUser(
      id: '11',
      name: 'Chen Wei',
      country: 'China',
      isOnline: false,
      isPro: false,
      nativeLanguage: 'Chino',
      targetLanguage: 'Inglés',
      level: 4,
      rating: 4.4,
      exchanges: 15,
    ),
    const FindUser(
      id: '12',
      name: 'Olga Petrova',
      country: 'Rusia',
      isOnline: true,
      isPro: true,
      nativeLanguage: 'Ruso',
      targetLanguage: 'Español',
      level: 8,
      rating: 4.9,
      exchanges: 52,
    ),
    const FindUser(
      id: '13',
      name: 'Ahmed Hassan',
      country: 'Egipto',
      isOnline: false,
      isPro: false,
      nativeLanguage: 'Árabe',
      targetLanguage: 'Inglés',
      level: 3,
      rating: 4.2,
      exchanges: 9,
    ),
    const FindUser(
      id: '14',
      name: 'Lisa Anderson',
      country: 'Canadá',
      isOnline: true,
      isPro: false,
      nativeLanguage: 'Inglés',
      targetLanguage: 'Español',
      level: 5,
      rating: 4.6,
      exchanges: 21,
    ),
    const FindUser(
      id: '15',
      name: 'Kim Min-jun',
      country: 'Corea del Sur',
      isOnline: true,
      isPro: true,
      nativeLanguage: 'Coreano',
      targetLanguage: 'Inglés',
      level: 6,
      rating: 4.7,
      exchanges: 33,
    ),
    const FindUser(
      id: '16',
      name: 'Julia Santos',
      country: 'Argentina',
      isOnline: false,
      isPro: false,
      nativeLanguage: 'Español',
      targetLanguage: 'Portugués',
      level: 4,
      rating: 4.5,
      exchanges: 17,
    ),
    const FindUser(
      id: '17',
      name: 'Thomas Berg',
      country: 'Suecia',
      isOnline: true,
      isPro: false,
      nativeLanguage: 'Sueco',
      targetLanguage: 'Español',
      level: 5,
      rating: 4.4,
      exchanges: 19,
    ),
    const FindUser(
      id: '18',
      name: 'Fatima Al-Rashid',
      country: 'Emiratos Árabes',
      isOnline: false,
      isPro: true,
      nativeLanguage: 'Árabe',
      targetLanguage: 'Francés',
      level: 7,
      rating: 4.8,
      exchanges: 36,
    ),
    const FindUser(
      id: '19',
      name: 'David Lee',
      country: 'Australia',
      isOnline: true,
      isPro: false,
      nativeLanguage: 'Inglés',
      targetLanguage: 'Japonés',
      level: 3,
      rating: 4.3,
      exchanges: 11,
    ),
    const FindUser(
      id: '20',
      name: 'Ingrid Larsen',
      country: 'Noruega',
      isOnline: true,
      isPro: true,
      nativeLanguage: 'Noruego',
      targetLanguage: 'Español',
      level: 8,
      rating: 4.9,
      exchanges: 48,
    ),
  ];

  @override
  Future<List<FindUser>> searchUsers({
    String query = '',
    FindFilters? filters,
    int page = 0,
    int pageSize = 10,
  }) async {
    // Simular latencia de red
    await Future.delayed(Duration(milliseconds: 300 + _random.nextInt(300)));

    var results = List<FindUser>.from(_mockUsers);

    // Filtrar por query (nombre, país, idiomas)
    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      results = results.where((u) {
        return u.name.toLowerCase().contains(q) ||
            u.country.toLowerCase().contains(q) ||
            u.nativeLanguage.toLowerCase().contains(q) ||
            u.targetLanguage.toLowerCase().contains(q);
      }).toList();
    }

    // Aplicar filtros
    if (filters != null) {
      if (filters.proOnly) {
        results = results.where((u) => u.isPro).toList();
      }
      if (filters.minRating != null) {
        results = results.where((u) => u.rating >= filters.minRating!).toList();
      }
      if (filters.nativeLanguage != null && filters.nativeLanguage!.isNotEmpty) {
        final lang = filters.nativeLanguage!.toLowerCase();
        results = results.where((u) => u.nativeLanguage.toLowerCase().contains(lang)).toList();
      }
      if (filters.targetLanguage != null && filters.targetLanguage!.isNotEmpty) {
        final lang = filters.targetLanguage!.toLowerCase();
        results = results.where((u) => u.targetLanguage.toLowerCase().contains(lang)).toList();
      }
      if (filters.country != null && filters.country!.isNotEmpty) {
        results = results
            .where((u) => u.country.toLowerCase().contains(filters.country!.toLowerCase()))
            .toList();
      }
    }

    // Paginación
    final start = page * pageSize;
    if (start >= results.length) return [];
    final end = (start + pageSize).clamp(0, results.length);

    return results.sublist(start, end);
  }

  /// Obtiene un usuario por su ID (método helper para desarrollo)
  /// BACKEND: Este método no es necesario cuando se use el backend real
  static FindUser? getUserById(String userId) {
    try {
      return _mockUsers.firstWhere((user) => user.id == userId);
    } catch (e) {
      return null;
    }
  }
}
