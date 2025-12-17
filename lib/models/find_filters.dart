/// Filtros para la búsqueda de usuarios
class FindFilters {
  final bool onlineOnly;
  final bool proOnly;
  final double? minRating;
  final String? nativeLanguage;
  final String? targetLanguage;
  final String? country;

  const FindFilters({
    this.onlineOnly = false,
    this.proOnly = false,
    this.minRating,
    this.nativeLanguage,
    this.targetLanguage,
    this.country,
  });

  /// Filtros por defecto (sin ningún filtro activo)
  static const FindFilters defaults = FindFilters();

  FindFilters copyWith({
    bool? onlineOnly,
    bool? proOnly,
    double? minRating,
    String? nativeLanguage,
    String? targetLanguage,
    String? country,
    bool clearMinRating = false,
    bool clearNativeLanguage = false,
    bool clearTargetLanguage = false,
    bool clearCountry = false,
  }) {
    return FindFilters(
      onlineOnly: onlineOnly ?? this.onlineOnly,
      proOnly: proOnly ?? this.proOnly,
      minRating: clearMinRating ? null : (minRating ?? this.minRating),
      nativeLanguage: clearNativeLanguage ? null : (nativeLanguage ?? this.nativeLanguage),
      targetLanguage: clearTargetLanguage ? null : (targetLanguage ?? this.targetLanguage),
      country: clearCountry ? null : (country ?? this.country),
    );
  }

  /// Verifica si hay algún filtro activo
  bool get hasActiveFilters =>
      onlineOnly ||
      proOnly ||
      minRating != null ||
      nativeLanguage != null ||
      targetLanguage != null ||
      country != null;
}
