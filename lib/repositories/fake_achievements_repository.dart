import '../models/achievement.dart';
import 'achievements_repository.dart';

class FakeAchievementsRepository implements AchievementsRepository {
  final List<Achievement> _achievements = [
    // === LOGROS DESBLOQUEADOS ===
    Achievement(
      id: 'polyglot',
      type: AchievementType.polyglot,
      title: 'Políglota',
      description: '5 idiomas practicados',
      isUnlocked: true,
      currentProgress: 5,
      targetProgress: 5,
      unlockedAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    Achievement(
      id: 'conversationalist',
      type: AchievementType.conversationalist,
      title: 'Conversador',
      description: '50 conversaciones',
      isUnlocked: true,
      currentProgress: 50,
      targetProgress: 50,
      unlockedAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
    Achievement(
      id: 'early_bird',
      type: AchievementType.earlyBird,
      title: 'Madrugador',
      description: '20 sesiones matutinas',
      isUnlocked: true,
      currentProgress: 20,
      targetProgress: 20,
      unlockedAt: DateTime.now().subtract(const Duration(days: 7)),
    ),

    // === LOGROS POR DESBLOQUEAR ===
    Achievement(
      id: 'star',
      type: AchievementType.star,
      title: 'Estrella',
      description: '100 valoraciones 5★',
      isUnlocked: false,
      currentProgress: 65,
      targetProgress: 100,
    ),
    Achievement(
      id: 'streak',
      type: AchievementType.streak,
      title: 'Racha',
      description: '30 días consecutivos',
      isUnlocked: false,
      currentProgress: 13,
      targetProgress: 30,
    ),
    Achievement(
      id: 'explorer',
      type: AchievementType.explorer,
      title: 'Explorador',
      description: '10 países diferentes',
      isUnlocked: false,
      currentProgress: 4,
      targetProgress: 10,
    ),
    Achievement(
      id: 'mentor',
      type: AchievementType.mentor,
      title: 'Mentor',
      description: '25 principiantes ayudados',
      isUnlocked: false,
      currentProgress: 8,
      targetProgress: 25,
    ),
    Achievement(
      id: 'host',
      type: AchievementType.host,
      title: 'Anfitrión',
      description: '10 intercambios creados',
      isUnlocked: false,
      currentProgress: 3,
      targetProgress: 10,
    ),
  ];

  @override
  Future<List<Achievement>> getAchievements() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_achievements);
  }

  @override
  Future<List<Achievement>> getUnlockedAchievements() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _achievements.where((a) => a.isUnlocked).toList();
  }

  @override
  Future<List<Achievement>> getLockedAchievements() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _achievements.where((a) => !a.isUnlocked).toList();
  }

  @override
  Future<void> updateProgress(String achievementId, int newProgress) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _achievements.indexWhere((a) => a.id == achievementId);
    if (index != -1) {
      final achievement = _achievements[index];
      final isNowUnlocked = newProgress >= achievement.targetProgress;
      _achievements[index] = achievement.copyWith(
        currentProgress: newProgress,
        isUnlocked: isNowUnlocked,
        unlockedAt: isNowUnlocked ? DateTime.now() : null,
      );
    }
  }
}
