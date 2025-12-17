/// Modelo para usuarios en la pantalla de búsqueda
class FindUser {
  final String id;
  final String name;
  final String country;
  final String? avatarUrl;
  final bool isOnline;
  final bool isPro;
  final String nativeLanguage;
  final String targetLanguage;
  final int level;
  final double rating;
  final int exchanges;

  const FindUser({
    required this.id,
    required this.name,
    required this.country,
    this.avatarUrl,
    this.isOnline = false,
    this.isPro = false,
    required this.nativeLanguage,
    required this.targetLanguage,
    required this.level,
    required this.rating,
    required this.exchanges,
  });
}

