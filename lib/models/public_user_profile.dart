import 'find_user.dart';
import 'language_item.dart';
import 'public_exchange.dart';

/// Modelo de perfil público de usuario
class PublicUserProfile {
  final String id;
  final String name;
  final String country;
  final String? avatarUrl;
  final bool isOnline;
  final bool isPro;
  final String nativeLanguage;
  final List<LanguageItem> learningLanguages;
  final int level;
  final double rating;
  final int exchanges;
  final String? bio;
  final List<String>? interests;

  const PublicUserProfile({
    required this.id,
    required this.name,
    required this.country,
    this.avatarUrl,
    this.isOnline = false,
    this.isPro = false,
    required this.nativeLanguage,
    this.learningLanguages = const [],
    required this.level,
    required this.rating,
    required this.exchanges,
    this.bio,
    this.interests,
  });

  /// Crea un PublicUserProfile desde un FindUser
  factory PublicUserProfile.fromFindUser(FindUser user) {
    return PublicUserProfile(
      id: user.id,
      name: user.name,
      country: user.country,
      avatarUrl: user.avatarUrl,
      isOnline: user.isOnline,
      isPro: user.isPro,
      nativeLanguage: user.nativeLanguage,
      learningLanguages: user.targetLanguage.isNotEmpty
          ? [LanguageItem(code: '', name: user.targetLanguage, level: '')]
          : [],
      level: user.level,
      rating: user.rating,
      exchanges: user.exchanges,
      bio: user.bio,
    );
  }

  /// Perfil parcial desde un PublicExchange (creador). Se usa como prefetched
  /// hasta cargar el perfil completo desde la API.
  factory PublicUserProfile.fromPublicExchange(PublicExchange exchange) {
    return PublicUserProfile(
      id: exchange.creatorId,
      name: exchange.creatorName,
      country: '',
      avatarUrl: exchange.creatorAvatarUrl,
      isOnline: false,
      isPro: exchange.creatorIsPro,
      nativeLanguage: exchange.nativeLanguage,
      learningLanguages: exchange.targetLanguage.isNotEmpty
          ? [LanguageItem(code: '', name: exchange.targetLanguage, level: '')]
          : [],
      level: 1,
      rating: 0.0,
      exchanges: 0,
      bio: null,
    );
  }
}

