/// Lista de países disponibles para el selector de registro y filtros.
class AppCountries {
  AppCountries._();

  static const List<String> available = [
    'Spain',
    'Mexico',
    'Argentina',
    'Colombia',
    'Chile',
    'Peru',
    'United States',
    'United Kingdom',
    'France',
    'Germany',
    'Italy',
    'Brazil',
    'Portugal',
    'Japan',
    'China',
    'Russia',
    'Other',
  ];

  /// Maps Spanish (or other) country names from backend to English for UI display.
  static const Map<String, String> _toEnglish = {
    'España': 'Spain',
    'México': 'Mexico',
    'Mexico': 'Mexico',
    'Argentina': 'Argentina',
    'Colombia': 'Colombia',
    'Chile': 'Chile',
    'Perú': 'Peru',
    'Peru': 'Peru',
    'Estados Unidos': 'United States',
    'Reino Unido': 'United Kingdom',
    'Francia': 'France',
    'Alemania': 'Germany',
    'Italia': 'Italy',
    'Brasil': 'Brazil',
    'Portugal': 'Portugal',
    'Japón': 'Japan',
    'China': 'China',
    'Rusia': 'Russia',
    'Otro': 'Other',
  };

  /// Returns the country name in English for display. If already in English or unknown, returns as-is.
  static String displayName(String? country) {
    if (country == null || country.isEmpty) return country ?? '';
    final trimmed = country.trim();
    return _toEnglish[trimmed] ?? trimmed;
  }
}
