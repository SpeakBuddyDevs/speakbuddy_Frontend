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

  /// Mapeo nombre → código para filtros (admite nombres en español e inglés)
  static const Map<String, String> nameToCode = {
    'Español': 'es',
    'English': 'en',
    'Inglés': 'en',
    'Français': 'fr',
    'Francés': 'fr',
    'Deutsch': 'de',
    'Alemán': 'de',
    'Italiano': 'it',
    'Portugués': 'pt',
    'Chino': 'zh',
    'Japonés': 'ja',
  };

  /// Obtiene el nombre del idioma a partir de su código.
  /// Si el código no existe, retorna el código mismo.
  static String getName(String code) {
    return codeToName[code.toLowerCase()] ?? code;
  }

  /// Retorna la lista de códigos de idiomas disponibles.
  static List<String> get availableCodes => codeToName.keys.toList();

  /// Nombres de idiomas para filtros (alineados con nameToCode)
  static List<String> get filterLanguageNames => nameToCode.keys.toList();

  /// Idiomas soportados por el backend en la búsqueda (DataInitializer: es, en, fr, de, it)
  static const List<String> searchFilterLanguageNames = [
    'Español',
    'Inglés',
    'Francés',
    'Alemán',
    'Italiano',
  ];

  /// Obtiene el código a partir del nombre del idioma (ej. "Español" → "es").
  static String? getCodeFromName(String name) {
    if (name.isEmpty) return null;
    return nameToCode[name];
  }
}
