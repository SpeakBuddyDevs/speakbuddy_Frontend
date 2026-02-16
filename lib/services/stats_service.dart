import '../models/user_stats.dart';
import '../repositories/stats_repository.dart';

/// Servicio de alto nivel para obtener y cachear estadísticas del usuario.
class StatsService {
  // Singleton pattern para acceso global
  static final StatsService _instance = StatsService._internal();
  factory StatsService() => _instance;
  StatsService._internal();

  final StatsRepository _repository = StatsRepository();
  UserStats? _cached;

  /// Limpia la caché de estadísticas. Debe llamarse al cerrar sesión para que
  /// el siguiente usuario vea sus datos en Home.
  void clearCache() {
    _cached = null;
  }

  /// Obtiene las estadísticas del usuario desde el backend.
  ///
  /// Cachea en memoria el último resultado para evitar llamadas redundantes
  /// durante la vida de la sesión en Home.
  Future<UserStats> fetchStats({bool forceRefresh = false}) async {
    if (!forceRefresh && _cached != null) return _cached!;
    final stats = await _repository.getUserStats();
    _cached = stats;
    return stats;
  }
}

