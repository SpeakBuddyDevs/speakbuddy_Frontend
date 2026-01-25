class AppLanguages {
  static const Map<String, String> codeToName = {
    'es': 'Español',
    'en': 'English',
    'fr': 'Français',
    'de': 'Deutsch',
    'it': 'Italiano',
    'pt': 'Portugués',
    'zh': 'Chino',
    'ja': 'Japonés',
  };

  /// Obtiene el nombre del idioma a partir de su código.
  /// Si el código no existe, retorna el código mismo.
  static String getName(String code) {
    return codeToName[code] ?? code;
  }

  /// Retorna la lista de códigos de idiomas disponibles.
  static List<String> get availableCodes => codeToName.keys.toList();

  /// Obtiene el código a partir del nombre del idioma (ej. "Español" → "ES").
  /// Para usar con filtros que envían nombres a la API como isoCode en minúsculas.
  static String? getCodeFromName(String name) {
    if (name.isEmpty) return null;
    for (final e in codeToName.entries) {
      if (e.value == name) return e.key;
    }
    return null;
  }
}
