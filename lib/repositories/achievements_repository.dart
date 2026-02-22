import '../models/achievement.dart';

/// Interfaz abstracta para el repositorio de logros
abstract class AchievementsRepository {
  /// Obtiene todos los logros del usuario (desbloqueados y pendientes)
  Future<List<Achievement>> getAchievements();

  /// Obtiene solo los logros desbloqueados
  Future<List<Achievement>> getUnlockedAchievements();

  /// Obtiene solo los logros pendientes (no desbloqueados)
  Future<List<Achievement>> getLockedAchievements();

  /// Actualiza el progreso de un logro específico
  Future<void> updateProgress(String achievementId, int newProgress);
}
