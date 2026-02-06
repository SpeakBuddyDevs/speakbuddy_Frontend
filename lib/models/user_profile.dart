import 'language_item.dart';

// BACKEND: Mapea respuesta de GET /api/auth/me o GET /api/profile
// TODO(BE): Endpoint debe devolver todos estos campos en formato JSON
// TODO(FE): Implementar factory UserProfile.fromJson(Map<String, dynamic>)
// Response esperado: { name, email, level, progressPct, exchanges, rating, languagesCount,
//   hoursTotal, currentStreakDays, bestStreakDays, medals, learningLanguages[], isPro,
//   avatarUrl?, nativeLanguage, description }

/// Perfil completo del usuario autenticado
class UserProfile {
  final String id;
  final String name;
  final String email;
  final int level;
  final double progressPct;
  final int exchanges;
  final double rating;
  final int languagesCount;
  final int hoursTotal;
  final int currentStreakDays;
  final int bestStreakDays;
  final int medals;
  final List<LanguageItem> learningLanguages;
  final bool isPro;
  final String? avatarPath; // TODO(FE): Renombrar a avatarUrl cuando BE devuelva URL
  final String nativeLanguage;
  final String description;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.level,
    required this.progressPct,
    required this.exchanges,
    required this.rating,
    required this.languagesCount,
    required this.hoursTotal,
    required this.currentStreakDays,
    required this.bestStreakDays,
    required this.medals,
    required this.learningLanguages,
    required this.isPro,
    required this.nativeLanguage,
    required this.description,
    this.avatarPath,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    int? level,
    double? progressPct,
    int? exchanges,
    double? rating,
    int? languagesCount,
    int? hoursTotal,
    int? currentStreakDays,
    int? bestStreakDays,
    int? medals,
    List<LanguageItem>? learningLanguages,
    bool? isPro,
    String? nativeLanguage,
    String? avatarPath,
    String? description,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      level: level ?? this.level,
      progressPct: progressPct ?? this.progressPct,
      exchanges: exchanges ?? this.exchanges,
      rating: rating ?? this.rating,
      languagesCount: languagesCount ?? this.languagesCount,
      hoursTotal: hoursTotal ?? this.hoursTotal,
      currentStreakDays: currentStreakDays ?? this.currentStreakDays,
      bestStreakDays: bestStreakDays ?? this.bestStreakDays,
      medals: medals ?? this.medals,
      learningLanguages: learningLanguages ?? this.learningLanguages,
      isPro: isPro ?? this.isPro,
      nativeLanguage: nativeLanguage ?? this.nativeLanguage,
      avatarPath: avatarPath ?? this.avatarPath,
      description: description ?? this.description,
    );
  }
}

