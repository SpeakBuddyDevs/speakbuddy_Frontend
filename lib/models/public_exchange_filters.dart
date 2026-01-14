/// Filtros para la búsqueda de intercambios públicos
/// 
/// BACKEND: Estos filtros se envían como query params a GET /api/exchanges/public
/// Query params esperados: ?q=&page=&pageSize=&requiredLevel=&minDate=&maxDuration=&nativeLang=&targetLang=
/// TODO(BE): Soportar todos estos filtros en el endpoint de búsqueda
class PublicExchangeFilters {
  final String? requiredLevel;
  final DateTime? minDate;
  final int? maxDuration;
  final String? nativeLanguage; // Filtrar por idioma que se ofrece
  final String? targetLanguage; // Filtrar por idioma que se busca practicar

  const PublicExchangeFilters({
    this.requiredLevel,
    this.minDate,
    this.maxDuration,
    this.nativeLanguage,
    this.targetLanguage,
  });

  /// Filtros por defecto (sin ningún filtro activo)
  static const PublicExchangeFilters defaults = PublicExchangeFilters();

  PublicExchangeFilters copyWith({
    String? requiredLevel,
    DateTime? minDate,
    int? maxDuration,
    String? nativeLanguage,
    String? targetLanguage,
    bool clearRequiredLevel = false,
    bool clearMinDate = false,
    bool clearMaxDuration = false,
    bool clearNativeLanguage = false,
    bool clearTargetLanguage = false,
  }) {
    return PublicExchangeFilters(
      requiredLevel: clearRequiredLevel ? null : (requiredLevel ?? this.requiredLevel),
      minDate: clearMinDate ? null : (minDate ?? this.minDate),
      maxDuration: clearMaxDuration ? null : (maxDuration ?? this.maxDuration),
      nativeLanguage: clearNativeLanguage ? null : (nativeLanguage ?? this.nativeLanguage),
      targetLanguage: clearTargetLanguage ? null : (targetLanguage ?? this.targetLanguage),
    );
  }

  /// Verifica si hay algún filtro activo
  bool get hasActiveFilters =>
      requiredLevel != null ||
      minDate != null ||
      maxDuration != null ||
      nativeLanguage != null ||
      targetLanguage != null;
}
